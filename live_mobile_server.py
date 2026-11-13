# -*- coding: utf-8 -*-
"""
Serveur Temps Réel Flutter Mobile Hub + API Directe PostgreSQL 17.7 (57.131.30.69:5432)
Port : 8090
- Sert l'application mobile Flutter compilée (fidness_mobile_hub/build/web)
- Expose GET /api/live-bondin connecté en temps réel à PostgreSQL (57.131.30.69:5432)
"""

import os
import json
import time
import re
import urllib.request
import urllib.error
from datetime import datetime
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse
import pg8000.native

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
WEB_BUILD_DIR = os.path.join(BASE_DIR, "fidness_mobile_hub", "build", "web")
CACHE_FILE = os.path.join(BASE_DIR, "live_sync_cache.json")
STIEL_API_BASE = os.environ.get("STIEL_API_BASE", "http://localhost:8086").rstrip("/")
# Routes Alpha by STIEL autorisees (lecture + actions du dashboard web + galerie photos).
STIEL_ALLOWED = re.compile(
    r"^(kpis/(general|commercials|loyalty)|churn|users|status|gallery|chantiers|simulate-whatif|rag/chat|whatsapp/voice-simulate|"
    r"agent-ia/(churn|offers|trial)|electricien/360/[A-Za-z0-9_-]{1,64})$"
)

_last_fetch_ts = 0.0
_cached_payload = None


def fetch_live_postgres_payload():
    global _last_fetch_ts, _cached_payload
    now = time.time()
    if _cached_payload is not None and (now - _last_fetch_ts) < 10.0:
        return _cached_payload

    try:
        con = pg8000.native.Connection(
            user=os.environ.get("DB_USER", "fidness"),
            password=os.environ.get("DB_PASSWORD", "6a7ce156b7bc9445"),
            host=os.environ.get("DB_HOST", "57.131.30.69"),
            port=int(os.environ.get("DB_PORT", 5432)),
            database=os.environ.get("DB_NAME", "fidness"),
            timeout=10,
        )

        kpi = con.run("""
            SELECT 
                COUNT(*) as total_scans,
                ROUND(COALESCE(SUM(amount/1000.0),0)::numeric, 2) as total_ca_tnd,
                ROUND(COALESCE(AVG(amount/1000.0),0)::numeric, 3) as panier_moyen_tnd,
                ROUND(COALESCE(SUM(points),0)::numeric, 0) as total_points_emis,
                COUNT(DISTINCT user_id) as clients_actifs,
                to_char(MAX(created_at), 'YYYY-MM-DD HH24:MI:SS') as dernier_scan
            FROM public.purchase
            WHERE company_id = 2
        """)[0]

        users_cnt = con.run("""
            SELECT COUNT(*) FROM public.user WHERE app_name = 'bondin'
        """)[0][0]

        burn = con.run("""
            SELECT COUNT(*), COALESCE(SUM(g.cost_points), 0)
            FROM public.voucher v
            JOIN public.gift g ON v.gift_id = g.id
            WHERE g.company_id = 2
        """)[0]

        recent_scans_rows = con.run("""
            SELECT 
                p.id,
                COALESCE(p.ticket, 'SCAN-' || p.id::text) as ticket,
                ROUND((p.amount / 1000.0)::numeric, 3) as montant_tnd,
                ROUND(p.points::numeric, 1) as points,
                to_char(p.created_at, 'YYYY-MM-DD HH24:MI:SS') as dt,
                COALESCE(s.name, 'PDV ENA W BONDIN') as magasin,
                COALESCE(NULLIF(TRIM(u.full_name), ''), NULLIF(TRIM(COALESCE(u.first_name,'') || ' ' || COALESCE(u.last_name,'')), ''), 'Client Fidélité') as client
            FROM public.purchase p
            LEFT JOIN public.sell_points s ON p.sell_point_id = s.id
            LEFT JOIN public.user u ON p.user_id = u.id
            WHERE p.company_id = 2
            ORDER BY p.created_at DESC
            LIMIT 12
        """)

        recent_scans = [
            {
                "id": int(r[0]),
                "ticket": str(r[1]),
                "montant_tnd": float(r[2]),
                "points": float(r[3]),
                "date": str(r[4]),
                "magasin": str(r[5]),
                "client": str(r[6]),
            }
            for r in recent_scans_rows
        ]

        recent_users_rows = con.run("""
            SELECT 
                u.id::text,
                COALESCE(NULLIF(TRIM(u.full_name), ''), NULLIF(TRIM(COALESCE(u.first_name,'') || ' ' || COALESCE(u.last_name,'')), ''), 'Membre BONDIN') as nom,
                to_char(u.created_at, 'YYYY-MM-DD HH24:MI') as dt,
                COALESCE(NULLIF(TRIM(u.phone), ''), 'Non renseigné') as tel,
                COALESCE(NULLIF(TRIM(u.email), ''), 'Non renseigné') as email,
                COUNT(p.id) as achats,
                ROUND(COALESCE(SUM(p.points), 0)::numeric, 1) as pts,
                COALESCE(MAX(s.name), 'Application Mobile BONDIN') as magasin
            FROM public.user u
            LEFT JOIN public.purchase p ON p.user_id = u.id AND p.company_id = 2
            LEFT JOIN public.sell_points s ON p.sell_point_id = s.id
            WHERE u.app_name = 'bondin'
            GROUP BY u.id, u.full_name, u.first_name, u.last_name, u.created_at, u.phone, u.email
            ORDER BY u.created_at DESC
            LIMIT 12
        """)

        recent_inscrits = [
            {
                "id": "CLI_" + str(r[0]).replace("-", "")[:10].upper(),
                "nom": str(r[1]),
                "date": str(r[2]),
                "tel": str(r[3]),
                "email": str(r[4]),
                "achats": int(r[5]),
                "points": float(r[6]),
                "magasin": str(r[7]),
                "segment": "Client Actif" if int(r[5]) > 0 else "Nouveau Membre",
                "statut": "Actif Fidélité" if int(r[5]) > 0 else "Inscrit Récent",
            }
            for r in recent_users_rows
        ]

        top_stores_rows = con.run("""
            SELECT 
                COALESCE(s.name, 'PDV #' || p.sell_point_id::text) as magasin,
                COUNT(p.id) as scans,
                ROUND(SUM(p.amount / 1000.0)::numeric, 2) as ca_tnd,
                ROUND(AVG(p.amount / 1000.0)::numeric, 2) as panier_moy
            FROM public.purchase p
            LEFT JOIN public.sell_points s ON p.sell_point_id = s.id
            WHERE p.company_id = 2
            GROUP BY COALESCE(s.name, 'PDV #' || p.sell_point_id::text)
            ORDER BY ca_tnd DESC
            LIMIT 10
        """)

        top_magasins_ca = [
            {
                "nom": str(r[0]),
                "type": "Cafétéria" if "caf" in str(r[0]).lower() else "Succursale",
                "scans": int(r[1]),
                "ca": float(r[2]),
                "aov": float(r[3]),
            }
            for r in top_stores_rows
        ]

        con.close()

        payload = {
            "status": "connected_live",
            "source": "PostgreSQL 17.7 (57.131.30.69:5432)",
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S") + " (Live DB)",
            "company_name": "BONDIN",
            "total_scans": int(kpi[0]),
            "total_ca_tnd": float(kpi[1]),
            "panier_moyen_tnd": float(kpi[2]),
            "total_points_emis": int(kpi[3]),
            "clients_actifs": int(kpi[4]),
            "total_inscrits": int(users_cnt),
            "clients_inscrits": int(users_cnt),
            "total_cadeaux": int(burn[0]),
            "total_points_brules": int(float(burn[1])),
            "dernier_scan": str(kpi[5]),
            "dernier_ticket": recent_scans[0]["ticket"] if recent_scans else "",
            "dernier_client": recent_scans[0]["client"] if recent_scans else "",
            "dernier_montant": recent_scans[0]["montant_tnd"] if recent_scans else 0.0,
            "dernier_magasin": recent_scans[0]["magasin"] if recent_scans else "",
            "recent_scans": recent_scans,
            "recent_inscrits": recent_inscrits,
            "top_magasins_ca": top_magasins_ca,
        }

        _cached_payload = payload
        _last_fetch_ts = now

        try:
            with open(CACHE_FILE, "w", encoding="utf-8") as f:
                json.dump(payload, f, ensure_ascii=False, indent=2)
        except Exception:
            pass

        return payload
    except Exception as e:
        print(f"[WARN] Live PostgreSQL query error: {e}")
        if _cached_payload is not None:
            return _cached_payload
        if os.path.exists(CACHE_FILE):
            with open(CACHE_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        return {"status": "offline", "error": str(e)}



def proxy_stiel(handler, method):
    parsed = urlparse(handler.path)
    rest = parsed.path[len("/api/stiel/"):].strip("/")
    if not STIEL_ALLOWED.match(rest):
        handler._json({"error": "route non autorisee"}, 403)
        return
    url = f"{STIEL_API_BASE}/api/{rest}" + (f"?{parsed.query}" if parsed.query else "")
    body = None
    if method == "POST":
        length = int(handler.headers.get("Content-Length") or 0)
        body = handler.rfile.read(length) if length else b"{}"
    req = urllib.request.Request(url, data=body, method=method,
                                 headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            handler._raw(r.read(), r.status)
    except urllib.error.HTTPError as e:
        handler._raw(e.read(), e.code)
    except Exception as e:
        handler._json({"error": "serveur Alpha indisponible", "detail": str(e)}, 502)


class LiveHubHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_BUILD_DIR, **kwargs)

    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
        super().end_headers()

    def _raw(self, raw, status=200):
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(raw)))
        self.end_headers()
        self.wfile.write(raw)

    def _json(self, obj, status=200):
        self._raw(json.dumps(obj, ensure_ascii=False).encode("utf-8"), status)

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def do_POST(self):
        if urlparse(self.path).path.startswith("/api/stiel/"):
            return proxy_stiel(self, "POST")
        self._json({"error": "not found"}, 404)

    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path.startswith("/api/stiel/"):
            return proxy_stiel(self, "GET")
        if parsed.path in ("/api/live-bondin", "/live_sync_cache.json"):
            data = fetch_live_postgres_payload()
            raw = json.dumps(data, ensure_ascii=False).encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(raw)))
            self.end_headers()
            self.wfile.write(raw)
            return
        return super().do_GET()


if __name__ == "__main__":
    print("Initialisation du cache Temps Réel PostgreSQL 17.7 (57.131.30.69:5432)...")
    initial = fetch_live_postgres_payload()
    print(f"Connecté : {initial.get('total_scans')} scans | {initial.get('total_ca_tnd')} DT | {initial.get('total_inscrits')} inscrits")
    server = ThreadingHTTPServer(("0.0.0.0", 8090), LiveHubHandler)
    print("Serveur Flutter + API Live PostgreSQL démarré sur http://localhost:8090")
    server.serve_forever()
