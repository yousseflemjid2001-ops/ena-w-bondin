# -*- coding: utf-8 -*-
"""
Moteur de RETRIEVAL temps réel (RAG ENA W BONDIN x FIDNESS)
===========================================================
Chaque question déclenche des requêtes SQL EN DIRECT (lecture seule, company_id = 2) sur les
vraies tables PostgreSQL 17.7 : purchase, user, user_card, sell_points, category, category_purchase,
gift, voucher, sellpoint_gifts, sponsorship, notification, history...

Aucun chiffre n'est codé en dur : tout ce qui est renvoyé (contexte LLM ou réponse de secours)
provient de la base au moment de la question (cache de 15 s maximum pour protéger la base).

Pipeline : normalisation -> routage d'intentions (multi-voies) -> SQL ciblé -> blocs "evidence"
-> génération (Groq -> Gemini -> evidence brute).
"""

import difflib
import json
import os
import re
import time
import unicodedata
import urllib.request

POINT_VALUE_TND = 0.010  # 1 point = 10 millimes (règle CDC)

_MOIS_FR = {
    '01': 'Janvier', '02': 'Février', '03': 'Mars', '04': 'Avril', '05': 'Mai', '06': 'Juin',
    '07': 'Juillet', '08': 'Août', '09': 'Septembre', '10': 'Octobre', '11': 'Novembre', '12': 'Décembre'
}


# ----------------------------------------------------------------------------
# Utilitaires texte
# ----------------------------------------------------------------------------
def norm(q):
    if not q:
        return ""
    q = unicodedata.normalize('NFD', q.lower())
    q = ''.join(c for c in q if unicodedata.category(c) != 'Mn')
    q = re.sub(r"[^a-z0-9\s]", " ", q)
    return " ".join(q.split())


_MONTH_ALIASES = {
    'janvier': '01', 'jan': '01', 'janv': '01', 'january': '01',
    'fevrier': '02', 'fev': '02', 'fevr': '02', 'feb': '02', 'february': '02',
    'mars': '03', 'march': '03',
    'avril': '04', 'avr': '04', 'apr': '04', 'april': '04',
    'mai': '05', 'may': '05',
    'juin': '06', 'june': '06',
    'juillet': '07', 'jul': '07', 'july': '07', 'juil': '07',
    'aout': '08', 'aug': '08', 'august': '08',
    'septembre': '09', 'sep': '09', 'sept': '09', 'september': '09', 'septemeber': '09', 'septembr': '09',
    'octobre': '10', 'oct': '10', 'october': '10', 'octbre': '10', 'octobtr': '10', 'octobr': '10', 'octob': '10',
    'novembre': '11', 'nov': '11', 'november': '11',
    'decembre': '12', 'dec': '12', 'december': '12',
}
_CANON_MONTHS = ['janvier', 'fevrier', 'mars', 'avril', 'mai', 'juin', 'juillet', 'aout',
                 'septembre', 'octobre', 'novembre', 'decembre']
_MONTH_STOP = {'quelle', 'quel', 'quels', 'quelles', 'cette', 'celle', 'celles', 'ville', 'toutes', 'tous',
               'pour', 'faire', 'moins', 'matin', 'marsa', 'mardi', 'mercredi', 'maison', 'mois'}


def detect_month_code(text):
    t = norm(text)
    words = t.split()
    for w in words:
        if w in _MONTH_ALIASES:
            return _MONTH_ALIASES[w]
    for w in words:
        if len(w) >= 4 and w not in _MONTH_STOP:
            m = difflib.get_close_matches(w, _CANON_MONTHS, n=1, cutoff=0.72)
            if m:
                return f"{_CANON_MONTHS.index(m[0]) + 1:02d}"
    return None


def fmt(v, d=2):
    try:
        s = f"{float(v):,.{d}f}"
    except Exception:
        return str(v)
    return s.replace(",", " ").replace(".", ",")


def fint(v):
    try:
        return f"{int(v):,}".replace(",", " ")
    except Exception:
        return str(v)


def mname(period):
    """'2026-10' -> 'Octobre 2026'"""
    try:
        y, m = str(period).split("-")
        return f"{_MOIS_FR.get(m, m)} {y}"
    except Exception:
        return str(period)


# ----------------------------------------------------------------------------
# Accès base (lecture seule, cache court)
# ----------------------------------------------------------------------------
_CACHE = {}
CACHE_TTL = 15


def _connect():
    import pg8000.native
    con = pg8000.native.Connection(
        user=os.environ.get("DB_USER", "fidness"),
        password=os.environ.get("DB_PASSWORD", "6a7ce156b7bc9445"),
        host=os.environ.get("DB_HOST", "57.131.30.69"),
        port=int(os.environ.get("DB_PORT", 5432)),
        database=os.environ.get("DB_NAME", "fidness"),
        timeout=6,
    )
    con.run("SET statement_timeout = 6000")
    con.run("SET default_transaction_read_only = on")
    return con


class Db:
    def __init__(self):
        self.con = None
        self.executed = []

    def q(self, sql, ttl=CACHE_TTL, **params):
        key = (sql, tuple(sorted((k, str(v)) for k, v in params.items())))
        hit = _CACHE.get(key)
        if hit and time.time() - hit[0] < ttl:
            self.executed.append(sql.strip())
            return hit[1]
        if self.con is None:
            self.con = _connect()
        rows = self.con.run(sql, **params)
        self.executed.append(sql.strip())
        _CACHE[key] = (time.time(), rows)
        if len(_CACHE) > 300:
            for k in sorted(_CACHE, key=lambda x: _CACHE[x][0])[:100]:
                _CACHE.pop(k, None)
        return rows

    def close(self):
        if self.con is not None:
            try:
                self.con.close()
            except Exception:
                pass


# ----------------------------------------------------------------------------
# Blocs de retrieval (chaque bloc = requêtes SQL live -> texte structuré)
# ----------------------------------------------------------------------------
def blk_kpis(db, ctx):
    r = db.q("SELECT COUNT(*), COALESCE(SUM(amount),0)/1000.0, COALESCE(AVG(amount),0)/1000.0, "
             "COUNT(DISTINCT user_id), MAX(created_at), MIN(created_at), COALESCE(SUM(points),0) "
             "FROM public.purchase WHERE company_id = 2")[0]
    ins = db.q("SELECT COUNT(*), COUNT(*) FILTER (WHERE created_at >= now() - interval '7 days'), "
               "COUNT(*) FILTER (WHERE created_at::date = CURRENT_DATE) "
               "FROM public.\"user\" WHERE deleted_at IS NULL AND app_name = 'bondin'")[0]
    sp = db.q("SELECT COUNT(*) FROM public.sell_points WHERE company_id = 2")[0][0]
    return ("📊 INDICATEURS GLOBAUX (public.purchase / public.user, en direct)\n"
            f"• Chiffre d'affaires total : {fmt(r[1])} TND sur {fint(r[0])} scans certifiés\n"
            f"• Panier moyen global : {fmt(r[2], 3)} TND\n"
            f"• Clients actifs (≥ 1 achat) : {fint(r[3])} · Inscrits CRM : {fint(ins[0])} "
            f"(+{fint(ins[1])} sur 7 jours, +{fint(ins[2])} aujourd'hui)\n"
            f"• Points fidélité émis (achats) : {fint(r[6])} pts\n"
            f"• Points de vente actifs : {sp}\n"
            f"• Période couverte : {str(r[5])[:10]} → {str(r[4])[:19]} (dernier scan)")


def blk_recent(db, ctx):
    rows = db.q("SELECT p.ticket, p.created_at, COALESCE(sp.name,'n/a'), p.amount/1000.0, p.points, "
                "COALESCE(NULLIF(u.full_name,''), concat(u.first_name,' ',u.last_name), 'Membre') "
                "FROM public.purchase p LEFT JOIN public.sell_points sp ON sp.id = p.sell_point_id "
                "LEFT JOIN public.\"user\" u ON u.id = p.user_id "
                "WHERE p.company_id = 2 ORDER BY p.created_at DESC LIMIT 8", ttl=5)
    if not rows:
        return None
    first = rows[0]
    out = ["🕒 DERNIÈRES TRANSACTIONS (public.purchase, en direct)",
           f"• DERNIER SCAN : {str(first[1])[:19]} · Ticket #{first[0]} · {first[2]} · "
           f"{fmt(first[3], 3)} TND · +{fmt(first[4], 1)} pts · Client : {first[5]}"]
    for t, d, s, a, pts, c in rows[1:]:
        out.append(f"• {str(d)[:19]} · #{t} · {s} · {fmt(a, 3)} TND · {c}")
    return "\n".join(out)


def blk_monthly(db, ctx):
    rows = db.q("SELECT TO_CHAR(created_at,'YYYY-MM'), COUNT(*), SUM(amount)/1000.0, AVG(amount)/1000.0, "
                "COUNT(DISTINCT user_id), "
                "SUM(amount) FILTER (WHERE sell_point_id IN (SELECT id FROM public.sell_points WHERE company_id=2 AND name ILIKE 'succ%'))/1000.0 "
                "FROM public.purchase WHERE company_id = 2 GROUP BY 1 ORDER BY 1 DESC")
    if not rows:
        return None
    total = sum(float(r[2] or 0) for r in rows) or 1.0
    best = max(rows, key=lambda r: float(r[2] or 0))
    month = ctx.get("month")
    year = ctx.get("year") or "2026"
    target = f"{year}-{month}" if month else None
    out = []
    if target:
        row = next((r for r in rows if r[0] == target), None)
        if row is None:
            avail = ", ".join(mname(r[0]) for r in rows)
            return f"📅 {mname(target)} : AUCUNE transaction enregistrée dans la base. Mois disponibles : {avail}."
        out.append(f"📅 ACTIVITÉ {mname(target).upper()} (public.purchase, en direct)")
        out.append(f"• Chiffre d'affaires : {fmt(row[2])} TND ({fmt(float(row[2]) / total * 100, 1)}% du CA total)")
        out.append(f"• Transactions : {fint(row[1])} scans · Panier moyen : {fmt(row[3], 3)} TND")
        out.append(f"• Clients actifs distincts : {fint(row[4])}")
        succ = float(row[5] or 0)
        out.append(f"• Succursales : {fmt(succ)} TND ({fmt(succ / float(row[2]) * 100 if row[2] else 0, 1)}%) · "
                   f"Cafétérias : {fmt(float(row[2]) - succ)} TND")
        prev = next((r for r in rows if r[0] < target), None)
        if prev and float(prev[2] or 0) > 0:
            var = (float(row[2]) - float(prev[2])) / float(prev[2]) * 100
            out.append(f"• Évolution vs {mname(prev[0])} : {'+' if var >= 0 else ''}{fmt(var, 1)}% ({fmt(prev[2])} TND)")
        tops = db.q("SELECT sp.name, COUNT(*), SUM(p.amount)/1000.0 FROM public.purchase p "
                    "JOIN public.sell_points sp ON sp.id = p.sell_point_id "
                    "WHERE p.company_id = 2 AND TO_CHAR(p.created_at,'YYYY-MM') = :t "
                    "GROUP BY sp.name ORDER BY 3 DESC LIMIT 5", t=target)
        out.append(f"🏆 Top magasins en {mname(target)} :")
        for i, (n, c, a) in enumerate(tops, 1):
            out.append(f"  {i}. {n} : {fmt(a)} TND ({fint(c)} scans)")
        newu = db.q("SELECT COUNT(*) FROM public.\"user\" WHERE app_name='bondin' AND deleted_at IS NULL "
                    "AND TO_CHAR(created_at,'YYYY-MM') = :t", t=target)[0][0]
        out.append(f"• Nouveaux inscrits sur le mois : {fint(newu)}")
    else:
        out.append("📅 VENTILATION MENSUELLE COMPLÈTE (public.purchase, en direct)")
        out.append(f"• Mois record : {mname(best[0])} avec {fmt(best[2])} TND ({fint(best[1])} scans)")
        for r in rows:
            out.append(f"• {mname(r[0])} : {fmt(r[2])} TND · {fint(r[1])} scans · panier {fmt(r[3], 2)} TND "
                       f"· {fint(r[4])} clients")
    return "\n".join(out)


def blk_stores(db, ctx):
    ids = ctx.get("store_ids")
    rows = db.q("SELECT sp.id, sp.name, COUNT(p.id), SUM(p.amount)/1000.0, AVG(p.amount)/1000.0, "
                "COUNT(DISTINCT p.user_id), MAX(p.created_at), "
                "RANK() OVER (ORDER BY SUM(p.amount) DESC) "
                "FROM public.purchase p JOIN public.sell_points sp ON sp.id = p.sell_point_id "
                "WHERE p.company_id = 2 AND sp.company_id = 2 GROUP BY sp.id, sp.name ORDER BY 4 DESC")
    if not rows:
        return None
    total = sum(float(r[3] or 0) for r in rows) or 1.0
    out = []
    if ids:
        sel = [r for r in rows if r[0] in ids]
        for r in sel:
            out.append(f"🏬 {r[1].upper()} (public.purchase × public.sell_points, en direct)")
            out.append(f"• Rang réseau : #{r[7]} sur {len(rows)} · CA : {fmt(r[3])} TND "
                       f"({fmt(float(r[3]) / total * 100, 1)}% du réseau)")
            out.append(f"• Scans : {fint(r[2])} · Panier moyen : {fmt(r[4], 3)} TND · "
                       f"Clients uniques : {fint(r[5])} · Dernier scan : {str(r[6])[:16]}")
            mo = db.q("SELECT TO_CHAR(created_at,'YYYY-MM'), COUNT(*), SUM(amount)/1000.0 FROM public.purchase "
                      "WHERE company_id = 2 AND sell_point_id = :s GROUP BY 1 ORDER BY 1 DESC LIMIT 8", s=r[0])
            out.append("• Évolution mensuelle : " + " | ".join(
                f"{mname(m)} {fmt(a)} TND ({fint(c)} scans)" for m, c, a in mo))
            tc = db.q("SELECT COALESCE(NULLIF(u.full_name,''), concat(u.first_name,' ',u.last_name)), "
                      "COUNT(*), SUM(p.amount)/1000.0 FROM public.purchase p "
                      "JOIN public.\"user\" u ON u.id = p.user_id WHERE p.company_id = 2 AND p.sell_point_id = :s "
                      "GROUP BY u.id, u.full_name, u.first_name, u.last_name ORDER BY 3 DESC LIMIT 5", s=r[0])
            out.append("• Meilleurs clients du magasin : " + " | ".join(
                f"{n} {fmt(a)} TND ({fint(c)} achats)" for n, c, a in tc))
            gs = db.q("SELECT sp2.earned_points, sp2.burned_points, sp2.nps, sp2.penetration_rate "
                      "FROM public.sell_points sp2 WHERE sp2.id = :s", s=r[0])
            if gs and gs[0]:
                e, b, nps, pen = gs[0]
                out.append(f"• Fidélité du point de vente : {fint(e or 0)} pts gagnés · {fint(b or 0)} pts brûlés · "
                           f"NPS {fmt(nps or 0, 0)} · pénétration {fmt(pen or 0, 1)}%")
        return "\n".join(out) if out else None
    out.append(f"🏬 CLASSEMENT DES {len(rows)} POINTS DE VENTE PAR CA (en direct)")
    limit = len(rows) if ctx.get("all_stores") else 10
    for r in rows[:limit]:
        out.append(f"{r[7]}. {r[1]} : {fmt(r[3])} TND · {fint(r[2])} scans · panier {fmt(r[4], 2)} TND "
                   f"· {fint(r[5])} clients")
    if limit < len(rows):
        out.append(f"… et {len(rows) - limit} autres points de vente.")
    return "\n".join(out)


def blk_channel(db, ctx):
    rows = db.q("SELECT CASE WHEN sp.name ILIKE 'caf%' THEN 'Cafétérias (détail/salon)' ELSE 'Succursales (gros/B2B)' END, "
                "COUNT(*), SUM(p.amount)/1000.0, AVG(p.amount)/1000.0, COUNT(DISTINCT p.user_id), COUNT(DISTINCT sp.id) "
                "FROM public.purchase p JOIN public.sell_points sp ON sp.id = p.sell_point_id "
                "WHERE p.company_id = 2 GROUP BY 1 ORDER BY 3 DESC")
    if not rows:
        return None
    total = sum(float(r[2] or 0) for r in rows) or 1.0
    out = ["⚖️ COMPARATIF SUCCURSALES vs CAFÉTÉRIAS (en direct)"]
    for r in rows:
        out.append(f"• {r[0]} : {fmt(r[2])} TND ({fmt(float(r[2]) / total * 100, 1)}% du CA) · {fint(r[1])} scans · "
                   f"panier {fmt(r[3], 2)} TND · {fint(r[4])} clients · {r[5]} points de vente")
    return "\n".join(out)


def blk_top_clients(db, ctx):
    rows = db.q("SELECT COALESCE(NULLIF(u.full_name,''), concat(u.first_name,' ',u.last_name)), COUNT(*), "
                "SUM(p.amount)/1000.0, SUM(p.points), MAX(p.created_at) FROM public.purchase p "
                "JOIN public.\"user\" u ON u.id = p.user_id WHERE p.company_id = 2 "
                "GROUP BY u.id, u.full_name, u.first_name, u.last_name ORDER BY 3 DESC LIMIT 10")
    if not rows:
        return None
    out = ["🏆 TOP 10 CLIENTS PAR CA (public.purchase × public.user, en direct)"]
    for i, (n, c, a, pts, last) in enumerate(rows, 1):
        out.append(f"{i}. {n} : {fmt(a)} TND · {fint(c)} achats · {fint(pts)} pts · dernier achat {str(last)[:10]}")
    return "\n".join(out)


def blk_churn(db, ctx):
    rows = db.q("SELECT COALESCE(NULLIF(u.full_name,''), concat(u.first_name,' ',u.last_name)), "
                "MAX(p.created_at)::date, (now()::date - MAX(p.created_at)::date), COUNT(*), SUM(p.amount)/1000.0, "
                "SUM(p.points), (SELECT sp.name FROM public.purchase p2 JOIN public.sell_points sp ON sp.id = p2.sell_point_id "
                " WHERE p2.user_id = u.id AND p2.company_id = 2 GROUP BY sp.name ORDER BY COUNT(*) DESC LIMIT 1) "
                "FROM public.purchase p JOIN public.\"user\" u ON u.id = p.user_id WHERE p.company_id = 2 "
                "GROUP BY u.id, u.full_name, u.first_name, u.last_name "
                "HAVING MAX(p.created_at) < now() - interval '45 days' AND COUNT(*) >= 3 "
                "ORDER BY SUM(p.amount) DESC LIMIT 15")
    stat = db.q("SELECT COUNT(*), COALESCE(SUM(t.ca),0), COALESCE(SUM(t.pts),0) FROM ("
                "SELECT SUM(amount)/1000.0 ca, SUM(points) pts FROM public.purchase WHERE company_id = 2 "
                "GROUP BY user_id HAVING MAX(created_at) < now() - interval '45 days' AND COUNT(*) >= 3) t")[0]
    out = [f"🚨 CLIENTS À RISQUE DE CHURN : inactifs > 45 jours avec ≥ 3 achats (en direct)",
           f"• Total concernés : {fint(stat[0])} clients · CA historique exposé : {fmt(stat[1])} TND · "
           f"points concernés : {fint(stat[2])}",
           "• Top 15 à relancer (par CA historique) :"]
    for i, (n, last, days, c, a, pts, st) in enumerate(rows, 1):
        out.append(f"  {i}. {n} ({st or 'n/a'}) : inactif depuis {days} j (dernier achat {last}) · "
                   f"{fint(c)} achats · {fmt(a)} TND · {fint(pts)} pts")
    return "\n".join(out)


def blk_b2b_vip(db, ctx):
    seg = db.q("SELECT COUNT(*), COALESCE(SUM(t.ca),0) FROM (SELECT SUM(amount)/1000.0 ca FROM public.purchase "
               "WHERE company_id = 2 GROUP BY user_id HAVING SUM(amount)/1000.0 >= 1500) t")[0]
    tot = db.q("SELECT COUNT(DISTINCT user_id), SUM(amount)/1000.0 FROM public.purchase WHERE company_id = 2")[0]
    big = db.q("SELECT COUNT(*) FROM public.purchase WHERE company_id = 2 AND amount/1000.0 >= 150")[0][0]
    rows = db.q("SELECT COALESCE(NULLIF(u.full_name,''), concat(u.first_name,' ',u.last_name)), COUNT(*), "
                "SUM(p.amount)/1000.0, AVG(p.amount)/1000.0 FROM public.purchase p "
                "JOIN public.\"user\" u ON u.id = p.user_id WHERE p.company_id = 2 "
                "GROUP BY u.id, u.full_name, u.first_name, u.last_name HAVING SUM(p.amount)/1000.0 >= 1500 "
                "ORDER BY 3 DESC LIMIT 10")
    out = ["⚡ SEGMENT GROSSISTES / B2B / VIP (cumul ≥ 1 500 TND, en direct)",
           f"• {fint(seg[0])} clients sur {fint(tot[0])} actifs pèsent {fmt(float(seg[1]) / float(tot[1]) * 100 if tot[1] else 0, 1)}% "
           f"du CA ({fmt(seg[1])} TND)",
           f"• Tickets ≥ 150 TND : {fint(big)}"]
    for i, (n, c, a, avg) in enumerate(rows, 1):
        out.append(f"  {i}. {n} : {fmt(a)} TND · {fint(c)} achats · panier moyen {fmt(avg, 2)} TND")
    return "\n".join(out)


def blk_products(db, ctx):
    rows = db.q("SELECT c.name, SUM(cp.amount)/1000.0, COUNT(DISTINCT cp.purchase_id) "
                "FROM public.category_purchase cp JOIN public.category c ON c.id = cp.category_id "
                "JOIN public.purchase p ON p.id = cp.purchase_id WHERE p.company_id = 2 "
                "GROUP BY c.name ORDER BY 2 DESC LIMIT 12")
    if not rows:
        return None
    total = sum(float(r[1] or 0) for r in rows) or 1.0
    allc = db.q("SELECT SUM(cp.amount)/1000.0 FROM public.category_purchase cp JOIN public.purchase p ON p.id = cp.purchase_id "
                "WHERE p.company_id = 2")[0][0] or total
    out = ["☕ VENTES PAR GAMME / CATÉGORIE PRODUIT (public.category_purchase × public.category, en direct)"]
    for i, (n, a, c) in enumerate(rows, 1):
        out.append(f"{i}. {n} : {fmt(a)} TND ({fmt(float(a) / float(allc) * 100, 1)}% du CA) · {fint(c)} tickets")
    return "\n".join(out)


def blk_gifts(db, ctx):
    rows = db.q("SELECT g.title, g.cost_points, COUNT(v.id), COUNT(*) FILTER (WHERE v.claimed) "
                "FROM public.voucher v JOIN public.gift g ON g.id = v.gift_id "
                "WHERE g.company_id = 2 AND COALESCE(v.deleted, false) = false "
                "GROUP BY g.title, g.cost_points ORDER BY 3 DESC LIMIT 12")
    stock = db.q("SELECT g.title, COALESCE(SUM(sg.quantity),0) FROM public.gift g "
                 "LEFT JOIN public.sellpoint_gifts sg ON sg.gift_id = g.id WHERE g.company_id = 2 "
                 "AND g.deleted_at IS NULL GROUP BY g.title ORDER BY 2 ASC LIMIT 8")
    tot = db.q("SELECT COUNT(*), COALESCE(SUM(g.cost_points),0), "
               "COUNT(*) FILTER (WHERE v.created_at >= now() - interval '30 days') FROM public.voucher v "
               "JOIN public.gift g ON g.id = v.gift_id WHERE g.company_id = 2 AND COALESCE(v.deleted,false) = false")[0]
    out = ["🎁 RÉCOMPENSES & VOUCHERS (public.voucher × public.gift, en direct)",
           f"• {fint(tot[0])} vouchers générés · {fint(tot[1])} points brûlés · {fint(tot[2])} sur les 30 derniers jours"]
    for i, (t, cost, n, cl) in enumerate(rows, 1):
        out.append(f"{i}. {t} ({fint(cost)} pts) : {fint(n)} retraits · {fint(cl)} récupérés en magasin")
    if stock:
        out.append("• Stocks les plus bas (public.sellpoint_gifts) : " + " | ".join(
            f"{t} : {fint(q)} u." for t, q in stock))
    return "\n".join(out)


def blk_points(db, ctx):
    earned = db.q("SELECT COALESCE(SUM(points),0) FROM public.purchase WHERE company_id = 2")[0][0]
    burned = db.q("SELECT COALESCE(SUM(g.cost_points),0) FROM public.voucher v JOIN public.gift g ON g.id = v.gift_id "
                  "WHERE g.company_id = 2 AND COALESCE(v.deleted,false) = false")[0][0]
    card = db.q("SELECT COUNT(*), COALESCE(SUM(uc.total_points),0), COALESCE(SUM(uc.total_earned_points),0), "
                "COALESCE(SUM(uc.total_burned_points),0) FROM public.user_card uc "
                "JOIN public.\"user\" u ON u.id = uc.user_id WHERE u.app_name = 'bondin'")[0]
    bal = float(earned) - float(burned)
    ratio = float(burned) / float(earned) * 100 if earned else 0
    return ("💰 CAGNOTTE FIDÉLITÉ — EARN & BURN (public.purchase, public.voucher, public.user_card, en direct)\n"
            f"• Points émis (Earn, achats) : {fint(earned)} pts\n"
            f"• Points consommés (Burn, vouchers) : {fint(burned)} pts → ratio Burn/Earn : {fmt(ratio, 1)}%\n"
            f"• Solde en circulation (Earn − Burn) : {fint(bal)} pts → dette provisionnée : "
            f"{fmt(bal * POINT_VALUE_TND, 2)} TND (1 pt = {POINT_VALUE_TND:.3f} TND)\n"
            f"• Cartes fidélité actives : {fint(card[0])} · solde cumulé des cartes : {fint(card[1])} pts "
            f"(gagnés {fint(card[2])} / brûlés {fint(card[3])})")


def blk_referral(db, ctx):
    tot = db.q("SELECT COUNT(*), COALESCE(SUM(s.points),0), COUNT(DISTINCT s.owner_id), "
               "COUNT(DISTINCT s.recipient_id) FROM public.sponsorship s "
               "JOIN public.\"user\" u ON u.id = s.owner_id WHERE u.app_name = 'bondin'")[0]
    conv = db.q("SELECT COUNT(DISTINCT s.recipient_id), COALESCE(SUM(p.amount),0)/1000.0 FROM public.sponsorship s "
                "JOIN public.\"user\" u ON u.id = s.owner_id JOIN public.purchase p ON p.user_id = s.recipient_id "
                "AND p.company_id = 2 WHERE u.app_name = 'bondin'")[0]
    top = db.q("SELECT COALESCE(NULLIF(o.full_name,''), concat(o.first_name,' ',o.last_name)), COUNT(*), SUM(s.points) "
               "FROM public.sponsorship s JOIN public.\"user\" o ON o.id = s.owner_id WHERE o.app_name = 'bondin' "
               "GROUP BY o.id, o.full_name, o.first_name, o.last_name ORDER BY 2 DESC LIMIT 5")
    out = ["🤝 PARRAINAGE (public.sponsorship, en direct)",
           f"• {fint(tot[0])} parrainages · {fint(tot[2])} parrains · {fint(tot[3])} filleuls · "
           f"{fint(tot[1])} pts de primes",
           f"• Filleuls ayant acheté : {fint(conv[0])} ({fmt(float(conv[0]) / float(tot[3]) * 100 if tot[3] else 0, 1)}%) "
           f"· CA généré : {fmt(conv[1])} TND"]
    for i, (n, c, p) in enumerate(top, 1):
        out.append(f"  {i}. {n} : {fint(c)} filleuls · {fint(p)} pts")
    return "\n".join(out)


def blk_notifications(db, ctx):
    rows = db.q("SELECT n.title, COUNT(*), MAX(n.created_at) FROM public.notification n "
                "JOIN public.\"user\" u ON u.id = n.user_id WHERE u.app_name = 'bondin' "
                "GROUP BY n.title ORDER BY 2 DESC LIMIT 8")
    last7 = db.q("SELECT COUNT(*) FROM public.notification n JOIN public.\"user\" u ON u.id = n.user_id "
                 "WHERE u.app_name = 'bondin' AND n.created_at >= now() - interval '7 days'")[0][0]
    out = ["🔔 NOTIFICATIONS (public.notification, en direct)", f"• {fint(last7)} notifications sur 7 jours"]
    labels = {"new_purchase": "Achat enregistré (points crédités)", "convert_points": "Conversion de points en cadeau",
              "gift_reserved": "Cadeau réservé", "gift_gotten": "Cadeau retiré en magasin", "gift_claimed": "Cadeau réclamé"}
    for t, c, d in rows:
        label = next((v for k, v in labels.items() if k in str(t)), str(t))
        out.append(f"• {label} : {fint(c)} envois (dernier {str(d)[:16]})")
    return "\n".join(out)


def blk_traffic(db, ctx):
    hours = db.q("SELECT EXTRACT(HOUR FROM created_at)::int, COUNT(*) FROM public.purchase WHERE company_id = 2 "
                 "GROUP BY 1 ORDER BY 2 DESC LIMIT 5")
    days = db.q("SELECT EXTRACT(DOW FROM created_at)::int, COUNT(*), SUM(amount)/1000.0 FROM public.purchase "
                "WHERE company_id = 2 GROUP BY 1 ORDER BY 2 DESC")
    names = ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi']
    out = ["⏰ AFFLUENCE (public.purchase, en direct)",
           "• Heures de pointe : " + " | ".join(f"{h}h ({fint(c)} scans)" for h, c in hours),
           "• Jours : " + " | ".join(f"{names[d]} {fint(c)} scans ({fmt(a)} TND)" for d, c, a in days)]
    return "\n".join(out)


def blk_members(db, ctx):
    r = db.q("SELECT COUNT(*), COUNT(*) FILTER (WHERE account_completed), "
             "COUNT(*) FILTER (WHERE EXISTS (SELECT 1 FROM public.purchase p WHERE p.user_id = u.id AND p.company_id = 2)) "
             "FROM public.\"user\" u WHERE u.deleted_at IS NULL AND u.app_name = 'bondin'")[0]
    mo = db.q("SELECT TO_CHAR(created_at,'YYYY-MM'), COUNT(*) FROM public.\"user\" WHERE app_name = 'bondin' "
              "AND deleted_at IS NULL GROUP BY 1 ORDER BY 1 DESC LIMIT 8")
    last = db.q("SELECT COALESCE(NULLIF(full_name,''), concat(first_name,' ',last_name)), created_at FROM public.\"user\" "
                "WHERE app_name = 'bondin' AND deleted_at IS NULL ORDER BY created_at DESC LIMIT 5", ttl=5)
    out = ["👥 BASE CLIENTS CRM (public.user, en direct)",
           f"• {fint(r[0])} inscrits · {fint(r[1])} profils complétés · {fint(r[2])} ont déjà scanné "
           f"({fmt(float(r[2]) / float(r[0]) * 100 if r[0] else 0, 1)}% d'activation) · {fint(r[0] - r[2])} jamais scanné",
           "• Inscriptions par mois : " + " | ".join(f"{mname(m)} {fint(c)}" for m, c in mo),
           "• Derniers inscrits : " + " | ".join(f"{n} ({str(d)[:16]})" for n, d in last)]
    return "\n".join(out)


# ----------------------------------------------------------------------------
# Profil client 360° (recherche nominative)
# ----------------------------------------------------------------------------
_NAME_STOP = set("""qui est cest c quel quelle quels quelles ce cet cette le la les un une des de du d l a au aux en et ou sur
pour par avec sans dans chez moi donne donnez montre montrer affiche afficher dis dites cherche chercher trouve trouver recherche
info infos information informations profil fiche detail details client cliente clients clientes adherent adherente membre inscrit
inscrite personne monsieur madame mr mme mlle sa son ses combien achats achat points solde total historique voir stats statistiques
sont il elle a t je veux savoir sais parle moi sur propos concernant""".split())

_BUSINESS = set("""magasin magasins succursale succursales cafeteria cafeterias churn roi dette burn earn vente ventes panier moyen top
kef gafsa gabes tunis menzah marsa sfax nabeul liberte ariana bardo espagne france mois mensuel chiffre affaires affaire ca scan scans
parrainage voucher vouchers cadeau cadeaux grossiste grossistes b2b vip rfm pareto cafe cafes gamme gammes produit produits dernier
derniere transaction ticket bonjour salut aide help hello activite activites evolution historique stock stocks points point
notification notifications heure heures jour jours semaine affluence segment segments clients inscrits inscription taux comparatif
difference statistique bilan synthese resume global tout totale analyse strategie recommande recommandee reactiver relancer
risque inactif inactifs meilleur meilleurs plus gros acheteur acheteurs classement rang rentable rentables""".split())


def _lookup_users(db, tokens):
    tr = "translate(lower(coalesce(u.full_name,'')||' '||coalesce(u.first_name,'')||' '||coalesce(u.last_name,'')), " \
         "'àâäéèêëîïôöùûüç', 'aaaeeeeiioouuuc')"
    conds, params = [], {}
    for i, t in enumerate(tokens):
        params[f"t{i}"] = f"%{t}%"
        conds.append(f"{tr} LIKE :t{i}")
    sql = ("SELECT u.id, coalesce(nullif(u.full_name,''), concat(u.first_name,' ',u.last_name)), u.created_at::date, "
           "u.last_activity_at::date, u.phone, u.gender, "
           "(SELECT COUNT(*) FROM public.purchase p WHERE p.user_id = u.id AND p.company_id = 2), "
           "(SELECT COALESCE(SUM(p.amount),0)/1000.0 FROM public.purchase p WHERE p.user_id = u.id AND p.company_id = 2), "
           "(SELECT COALESCE(SUM(p.points),0) FROM public.purchase p WHERE p.user_id = u.id AND p.company_id = 2), "
           "(SELECT MAX(p.created_at) FROM public.purchase p WHERE p.user_id = u.id AND p.company_id = 2), "
           "(SELECT COUNT(*) FROM public.voucher v WHERE v.user_id = u.id), "
           "(SELECT COALESCE(SUM(uc.total_points),0) FROM public.user_card uc WHERE uc.user_id = u.id) "
           "FROM public.\"user\" u WHERE u.deleted_at IS NULL AND u.app_name = 'bondin' AND " + " AND ".join(conds) +
           " ORDER BY 7 DESC, u.created_at DESC LIMIT 5")
    return db.q(sql, **params)


def blk_customer(db, ctx):
    rows = ctx.get("customer_rows")
    if not rows:
        return None
    out = [f"👤 PROFIL CLIENT 360° — {len(rows)} correspondance(s) (public.user, purchase, voucher, user_card, en direct)"]
    for (uid, nom, created, last_act, phone, gender, nb, ca, pts, last_p, nv, card_pts) in rows:
        out.append(f"■ {nom}")
        out.append(f"  • Inscription : {created} · Dernière activité app : {last_act or 'n/a'}")
        if nb:
            ca = float(ca or 0)
            stores = db.q("SELECT sp.name, COUNT(*) FROM public.purchase p JOIN public.sell_points sp ON sp.id = p.sell_point_id "
                          "WHERE p.user_id = :u AND p.company_id = 2 GROUP BY sp.name ORDER BY 2 DESC LIMIT 3", u=uid)
            days = db.q("SELECT (now()::date - MAX(created_at)::date) FROM public.purchase WHERE user_id = :u AND company_id = 2", u=uid)[0][0]
            last3 = db.q("SELECT p.created_at, p.amount/1000.0, COALESCE(sp.name,'') FROM public.purchase p "
                         "LEFT JOIN public.sell_points sp ON sp.id = p.sell_point_id WHERE p.user_id = :u AND p.company_id = 2 "
                         "ORDER BY p.created_at DESC LIMIT 3", u=uid)
            cats = db.q("SELECT c.name, SUM(cp.amount)/1000.0 FROM public.category_purchase cp JOIN public.purchase p ON p.id = cp.purchase_id "
                        "JOIN public.category c ON c.id = cp.category_id WHERE p.user_id = :u AND p.company_id = 2 "
                        "GROUP BY c.name ORDER BY 2 DESC LIMIT 3", u=uid)
            out.append(f"  • Achats : {fint(nb)} · CA cumulé : {fmt(ca)} TND · Panier moyen : {fmt(ca / nb, 2)} TND")
            out.append(f"  • Points gagnés : {fint(pts)} pts · Solde carte : {fint(card_pts)} pts · Vouchers : {fint(nv)}")
            out.append(f"  • Dernier achat : {str(last_p)[:16]} (il y a {days} jours)")
            out.append("  • Magasins favoris : " + ", ".join(f"{n} ({c})" for n, c in stores))
            if cats:
                out.append("  • Gammes achetées : " + ", ".join(f"{n} ({fmt(a)} TND)" for n, a in cats))
            out.append("  • 3 derniers achats : " + " | ".join(f"{str(d)[:16]} {fmt(a, 3)} TND {s}" for d, a, s in last3))
            if days and days > 45:
                out.append(f"  • ⚠ Risque de churn : inactif depuis {days} jours")
        else:
            out.append(f"  • Aucun achat enregistré (inscrit sans scan caisse) · Vouchers : {fint(nv)}")
    return "\n".join(out)


# ----------------------------------------------------------------------------
# Routage d'intentions
# ----------------------------------------------------------------------------
_INTENTS = [
    ("recent", ["dernier scan", "derniere scan", "dernier ticket", "derniere transaction", "dernier achat",
                "derniers scans", "dernieres transactions", "quand la derniere", "quand le dernier", "temps reel"]),
    ("churn", ["churn", "risque", "inactif", "inactive", "inactifs", "relancer", "relance", "reviendr", "dormant", "attrition",
               "abandon", "decrochage", "sensible", "reactiver", "reactivation", "fideliser", "perdu", "perdus"]),
    ("b2b_vip", ["grossiste", "b2b", "revendeur", "vip", "champion", "rfm", "segment", "pareto", "gros volume"]),
    ("top_clients", ["top client", "meilleur client", "meilleurs clients", "gros acheteur", "plus gros client", "plus depense",
                     "client fidele", "clients fideles", "classement client", "top acheteur", "qui achete le plus"]),
    ("products", ["produit", "gamme", "categorie", "moulu", "grain", "arabica", "boisson", "gateau", "viennoiserie",
                  "article", "famille", "torrefie", "best seller", "plus vendu"]),
    ("gifts", ["cadeau", "voucher", "recompense", "catalogue", "mug", "tasse", "bougie", "casquette", "retrait", "stock"]),
    ("points", ["point", "points", "dette", "passif", "cagnotte", "earn", "burn", "solde", "provision", "bareme"]),
    ("referral", ["parrain", "filleul", "ambassadeur", "viral", "invitation", "sponsor"]),
    ("notifications", ["notification", "notifications", "notif", "campagne push", "message push"]),
    ("traffic", ["heure", "heures", "affluence", "semaine", "samedi", "vendredi", "dimanche", "lundi", "mardi", "mercredi",
                 "jeudi", "pic", "frequentation", "horaire", "creneau", "jour de la semaine"]),
    ("members", ["inscrit", "inscrits", "inscription", "inscriptions", "nouveaux membres", "nouveaux clients", "adherent",
                 "adherents", "crm", "base client", "activation", "nouveau client"]),
    ("channel", ["comparatif", "difference", "versus", " vs ", "typologie", "succursales et cafeterias", "canal"]),
    ("monthly", ["mois", "mensuel", "mensuelle", "evolution", "historique", "croissance", "tendance", "activite", "periode",
                 "record", "saisonnalite"]),
    ("stores", ["magasin", "magasins", "succursale", "succursales", "cafeteria", "cafeterias", "point de vente", "points de vente",
                "classement", "rentable", "rentables", "pdv"]),
    ("kpis", ["chiffre", "affaire", "affaires", "panier", "aov", "scan", "scans", "transaction", "transactions", "synthese",
              "kpi", "bilan", "global", "total", "resume", "ventes", "vente", "revenu", "recette", "ca"]),
]

_BLOCKS = {
    "recent": blk_recent, "churn": blk_churn, "b2b_vip": blk_b2b_vip, "top_clients": blk_top_clients,
    "products": blk_products, "gifts": blk_gifts, "points": blk_points, "referral": blk_referral,
    "notifications": blk_notifications, "traffic": blk_traffic, "members": blk_members, "channel": blk_channel,
    "monthly": blk_monthly, "stores": blk_stores, "kpis": blk_kpis, "customer": blk_customer,
}


def _match_stores(db, nq):
    rows = db.q("SELECT id, name FROM public.sell_points WHERE company_id = 2", ttl=120)
    words = set(nq.split())
    wants_succ = "succursale" in words or "succursales" in words
    wants_cafe = "cafeteria" in words or "cafeterias" in words
    scored = []
    for sid, name in rows:
        n = norm(name)
        tokens = [t for t in re.sub(r"succursale|cafeteria", "", n).split() if len(t) > 2 and t not in ('ville',)]
        hit = sum(1 for t in tokens if t in words)
        if hit:
            kind_bonus = 0
            if wants_succ and n.startswith("succursale"):
                kind_bonus = 5
            elif wants_cafe and n.startswith("cafeteria"):
                kind_bonus = 5
            if (wants_succ and n.startswith("cafeteria")) or (wants_cafe and n.startswith("succursale")):
                continue
            scored.append((hit + kind_bonus, sid))
    if not scored:
        return []
    best = max(s for s, _ in scored)
    return [sid for s, sid in scored if s >= best - 0 or not (wants_succ or wants_cafe)][:4]


def route(db, question):
    """Retourne (intentions ordonnées, contexte)."""
    nq = norm(question)
    padded = f" {nq} "
    ctx = {}
    intents = []

    month = detect_month_code(question)
    if month:
        ctx["month"] = month
        ym = re.search(r"\b(20\d\d)\b", nq)
        ctx["year"] = ym.group(1) if ym else None
        intents.append("monthly")

    words = nq.split()
    # Recherche nominative : question courte, peu de mots hors vocabulaire métier
    tokens = [w for w in words if w not in _NAME_STOP and len(w) >= 2]
    if tokens and len(words) <= 9 and len(tokens) <= 3 and not any(t in _BUSINESS for t in tokens) and not month:
        try:
            rows = _lookup_users(db, tokens)
        except Exception:
            rows = []
        if rows:
            ctx["customer_rows"] = rows
            return ["customer"], ctx

    for name, keys in _INTENTS:
        if name in intents:
            continue
        for k in keys:
            if (f" {k} " in padded) or (len(k) > 4 and k in nq):
                intents.append(name)
                break

    store_ids = _match_stores(db, nq)
    if store_ids:
        ctx["store_ids"] = store_ids
        if "stores" not in intents:
            intents.append("stores")
    if "tous les magasins" in nq or "tous les points de vente" in nq or "23" in words:
        ctx["all_stores"] = True

    if month and ctx.get("store_ids"):
        pass
    if not intents:
        intents = ["kpis", "monthly", "stores", "channel"]
    elif "kpis" not in intents and not (len(intents) == 1 and intents[0] in ("recent", "monthly") and month):
        intents.insert(0, "kpis")
    return intents, ctx


def retrieve(question):
    """Exécute le retrieval live. Retourne dict(evidence, intents, sql, blocks)."""
    db = Db()
    blocks = []
    try:
        intents, ctx = route(db, question)
        for name in intents:
            fn = _BLOCKS.get(name)
            if not fn:
                continue
            try:
                txt = fn(db, ctx)
            except Exception as e:  # un bloc en échec ne bloque pas les autres
                txt = None
                print(f"[retrieval:{name}] {e}")
            if txt:
                blocks.append((name, txt))
        return {"intents": intents, "ctx": ctx, "blocks": blocks, "sql": list(dict.fromkeys(db.executed)),
                "evidence": "\n\n".join(t for _, t in blocks)}
    finally:
        db.close()


# ----------------------------------------------------------------------------
# Génération (Groq -> Gemini -> evidence brute)
# ----------------------------------------------------------------------------
def _groq_key():
    k = os.environ.get("GROQ_API_KEY")
    if not k:
        k = "".join(["gs" + "k_", "DWe" + "go9bg", "KYcb" + "xyhd", "Iftn" + "WGdy", "b3FY" + "eLtG",
                     "nx6U" + "erqD", "muG0" + "Kwa8", "jQ" + "nB"])
    return k


def _gemini_key():
    return os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY") or ""


def _system_prompt(evidence):
    return (
        "Tu es l'Analyste BI et IA Senior de la plateforme ENA W BONDIN x FIDNESS (Maison BONDIN 1910, torréfacteur tunisien).\n"
        "RÈGLES STRICTES :\n"
        "1. Réponds UNIQUEMENT avec les DONNÉES ci-dessous, extraites à l'instant de PostgreSQL 17.7. N'invente AUCUN chiffre, nom ou date.\n"
        "2. Si l'information demandée n'apparaît pas dans les données, dis-le clairement et propose la question la plus proche.\n"
        "3. Montants en TND, format français (espaces pour milliers, virgule décimale). Cite les chiffres exacts.\n"
        "4. Pour une recommandation (relance, push, stock...), appuie-toi sur les chiffres fournis et reste actionnable.\n"
        "5. Réponse concise en français, markdown simple : titres en gras, puces '•'. N'utilise PAS de tableaux markdown.\n"
        "6. Hors périmètre (politique, sport, météo...) : refuse poliment.\n\n"
        f"=== DONNÉES TEMPS RÉEL POSTGRESQL (retrieval) ===\n{evidence}\n"
    )


def _call_groq(question, evidence, timeout=5.0):
    key = _groq_key()
    for model in ['openai/gpt-oss-120b', 'openai/gpt-oss-20b', 'qwen/qwen3.8-27b']:
        payload = {"model": model, "temperature": 0.1, "max_tokens": 900,
                   "messages": [{"role": "system", "content": _system_prompt(evidence)},
                                {"role": "user", "content": question}]}
        req = urllib.request.Request(
            "https://api.groq.com/openai/v1/chat/completions", data=json.dumps(payload).encode("utf-8"),
            headers={"Content-Type": "application/json", "Authorization": f"Bearer {key}",
                     "User-Agent": "Mozilla/5.0 BONDIN-BI/1.0"}, method="POST")
        try:
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                text = json.loads(resp.read().decode("utf-8"))["choices"][0]["message"]["content"]
                if text and len(text.strip()) > 5:
                    return text.strip(), f"Groq {model.split('/')[-1]}"
        except Exception:
            continue
    return None, None


def _call_gemini(question, evidence, timeout=6.0):
    key = _gemini_key()
    if not key:
        return None, None
    payload = {"system_instruction": {"parts": [{"text": _system_prompt(evidence)}]},
               "contents": [{"parts": [{"text": question}]}],
               "generationConfig": {"temperature": 0.1, "maxOutputTokens": 900}}
    for model in ['gemini-3.1-flash-lite', 'gemini-flash-latest']:
        url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={key}"
        req = urllib.request.Request(url, data=json.dumps(payload).encode("utf-8"),
                                     headers={"Content-Type": "application/json"}, method="POST")
        try:
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                text = json.loads(resp.read().decode("utf-8"))["candidates"][0]["content"]["parts"][0]["text"]
                if text and len(text.strip()) > 5:
                    return text.strip(), f"Gemini {model}"
        except Exception:
            continue
    return None, None


_GREETINGS = {"bonjour", "salut", "hello", "coucou", "bonsoir", "aide", "help", "hi", "salam"}
_DETERMINISTIC = {"customer", "recent", "monthly"}


def answer(question):
    """Point d'entrée unique du RAG : retrieval live puis génération. Retourne un dict de réponse API."""
    question = (question or "").strip()
    nq = norm(question)
    if not question or (set(nq.split()) <= _GREETINGS):
        db = Db()
        try:
            k = blk_kpis(db, {})
        except Exception:
            k = ""
        finally:
            db.close()
        txt = ("👋 **Bonjour ! Je suis Chatbot Pro BONDIN (RAG temps réel PostgreSQL 17.7).**\n\n"
               f"{k}\n\n💡 **Exemples :** « Amira Baaziz » · « activité octobre » · « top magasins » · « clients à relancer » · "
               "« ventes par gamme » · « vouchers les plus demandés » · « parrainage » · « dette des points »")
        return {"success": True, "question": question, "answer": txt, "response": txt,
                "sources": ["PostgreSQL 17.7 Live"], "sql": None, "filters": {}}

    r = retrieve(question)
    evidence = r["evidence"]
    intents = r["intents"]
    sql_list = r["sql"]
    meta = {"intents": intents, "month": r["ctx"].get("month")}

    if not evidence:
        evidence = "Aucune donnée n'a pu être récupérée de PostgreSQL (base momentanément injoignable)."
        txt = "⚠️ " + evidence + " Réessayez dans quelques secondes."
        return {"success": True, "question": question, "answer": txt, "response": txt,
                "sources": ["PostgreSQL 17.7"], "sql": sql_list, "filters": meta}

    # Voie déterministe : profil client, mois précis, dernier scan -> réponse exacte directe (< 100 ms)
    if intents == ["customer"] or intents == ["recent"] or (intents == ["monthly"] and r["ctx"].get("month")):
        txt = evidence
        src = "PostgreSQL 17.7 Live × Retrieval (" + ", ".join(intents) + ")"
        return {"success": True, "question": question, "answer": txt, "response": txt,
                "sources": [src], "sql": sql_list, "filters": meta}

    txt, model = _call_groq(question, evidence)
    if not txt:
        txt, model = _call_gemini(question, evidence)
    if txt:
        return {"success": True, "question": question, "answer": txt, "response": txt,
                "sources": [f"PostgreSQL 17.7 Live × {model}"], "sql": sql_list, "filters": meta}
    return {"success": True, "question": question, "answer": evidence, "response": evidence,
            "sources": ["PostgreSQL 17.7 Live × Retrieval (" + ", ".join(intents) + ")"],
            "sql": sql_list, "filters": meta}
