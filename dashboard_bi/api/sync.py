"""
Vercel Serverless Function & Cron Job : /api/cron/sync
ENA W BONDIN x FIDNESS (Synchronisation Automatique DWH / PostgreSQL)
"""

from http.server import BaseHTTPRequestHandler
import json
import os
import time
from datetime import datetime

class handler(BaseHTTPRequestHandler):
    def do_GET(self):
        start_time = time.time()
        try:
            # 1. Vérification de sécurité CRON_SECRET (si configuré sur Vercel)
            cron_secret = os.environ.get("CRON_SECRET")
            auth_header = self.headers.get("Authorization")
            if cron_secret and auth_header != f"Bearer {cron_secret}":
                # Si un secret est exigé et ne correspond pas
                self.send_response(401)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({"error": "Non autorisé : CRON_SECRET invalide"}).encode('utf-8'))
                return

            import pg8000.native

            # 2. Paramètres de connexion PostgreSQL Live (57.131.30.69:5432)
            db_host = os.environ.get("DB_HOST", "57.131.30.69")
            db_user = os.environ.get("DB_USER", "fidness")
            db_pass = os.environ.get("DB_PASSWORD", "6a7ce156b7bc9445")
            db_name = os.environ.get("DB_NAME", "fidness")
            db_port = int(os.environ.get("DB_PORT", 5432))

            con = pg8000.native.Connection(
                user=db_user,
                password=db_pass,
                host=db_host,
                port=db_port,
                database=db_name,
                timeout=8
            )

            # 3. Agrégations DWH temps réel
            stats = con.run("""
                SELECT 
                    count(*) as total_scans,
                    coalesce(sum(amount), 0) as total_ca,
                    coalesce(avg(amount), 0) as avg_basket,
                    coalesce(sum(points), 0) as total_points,
                    count(distinct user_id) as active_users,
                    max(created_at) as last_scan
                FROM public.purchase
                WHERE company_id = 2
            """)[0]

            # 4. Cinq dernières transactions
            recent = con.run("""
                SELECT p.id, p.ticket, p.amount, p.points, p.created_at, coalesce(s.name, 'BONDIN Magasin') as store_name
                FROM public.purchase p
                LEFT JOIN public.sell_points s ON p.sell_point_id = s.id
                WHERE p.company_id = 2
                ORDER BY p.created_at DESC
                LIMIT 5
            """)

            # 5. Top 5 Magasins par CA
            top_stores = con.run("""
                SELECT coalesce(s.name, 'BONDIN Inconnu') as nom, count(p.id) as scans, sum(p.amount) as ca
                FROM public.purchase p
                LEFT JOIN public.sell_points s ON p.sell_point_id = s.id
                WHERE p.company_id = 2
                GROUP BY s.name
                ORDER BY ca DESC
                LIMIT 5
            """)

            con.close()

            # Formatage des montants
            recent_list = []
            for r in recent:
                amt = float(r[2]) / 1000.0 if float(r[2]) > 100 else float(r[2])
                recent_list.append({
                    "id": r[0],
                    "ticket": str(r[1]),
                    "montant_tnd": round(amt, 3),
                    "points": float(r[3]),
                    "date": str(r[4]),
                    "magasin": str(r[5])
                })

            top_stores_list = []
            for ts in top_stores:
                ca_amt = float(ts[2]) / 1000.0 if float(ts[2]) > 100000 else float(ts[2])
                top_stores_list.append({
                    "magasin": str(ts[0]),
                    "scans": int(ts[1]),
                    "ca_tnd": round(ca_amt, 2)
                })

            tot_ca = float(stats[1]) / 1000.0 if float(stats[1]) > 100000 else float(stats[1])
            avg_b = float(stats[2]) / 1000.0 if float(stats[2]) > 100 else float(stats[2])

            elapsed_ms = round((time.time() - start_time) * 1000, 2)

            payload = {
                "success": True,
                "event": "CRON_ETL_SYNC_COMPLETE",
                "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                "source": "PostgreSQL 17.7 (57.131.30.69:5432)",
                "execution_time_ms": elapsed_ms,
                "metrics": {
                    "total_scans": int(stats[0]),
                    "total_ca_tnd": round(tot_ca, 2),
                    "panier_moyen_tnd": round(avg_b, 3),
                    "total_points_emis": int(stats[3]),
                    "clients_actifs": int(stats[4]),
                    "dernier_scan": str(stats[5]),
                    "dernier_ticket": recent_list[0]["ticket"] if recent_list else None,
                    "dernier_magasin": recent_list[0]["magasin"] if recent_list else None
                },
                "top_magasins": top_stores_list,
                "recent_transactions": recent_list
            }

            # Mise à jour du cache disque local si possible
            for target_cache in [
                os.path.join(os.path.dirname(__file__), "..", "live_sync_cache.json"),
                "/tmp/live_sync_cache.json"
            ]:
                try:
                    with open(target_cache, "w", encoding="utf-8") as f:
                        json.dump(payload, f, ensure_ascii=False, indent=2)
                    break
                except Exception:
                    pass

            self.send_response(200)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')
            self.end_headers()
            self.wfile.write(json.dumps(payload, ensure_ascii=False).encode('utf-8'))

        except Exception as e:
            self.send_response(500)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            error_payload = {
                "success": False,
                "event": "CRON_ETL_SYNC_FAILED",
                "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                "error": str(e)
            }
            self.wfile.write(json.dumps(error_payload, ensure_ascii=False).encode('utf-8'))

    def do_POST(self):
        # Permet aussi de déclencher la synchro par POST
        self.do_GET()
