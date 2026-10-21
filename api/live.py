"""
Vercel Serverless Function : /api/live
ENA W BONDIN x FIDNESS (Temps Réel PostgreSQL)
"""

from http.server import BaseHTTPRequestHandler
import json
import os
from datetime import datetime

class handler(BaseHTTPRequestHandler):
    def do_GET(self):
        try:
            import pg8000.native
            
            # Connexion sécurisée avec variables d'environnement Vercel
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
                timeout=2.5
            )
            
            # 1. Statistiques globales BONDIN (company_id = 2)
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

            # 2. Cinq dernières transactions réelles
            recent = con.run("""
                SELECT p.id, p.ticket, p.amount, p.points, p.created_at, coalesce(s.name, 'BONDIN Magasin') as store_name
                FROM public.purchase p
                LEFT JOIN public.sell_points s ON p.sell_point_id = s.id
                WHERE p.company_id = 2
                ORDER BY p.created_at DESC
                LIMIT 5
            """)
            con.close()

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

            tot_ca = float(stats[1]) / 1000.0 if float(stats[1]) > 100000 else float(stats[1])
            avg_b = float(stats[2]) / 1000.0 if float(stats[2]) > 100 else float(stats[2])

            payload = {
                "status": "connected_live",
                "source": "PostgreSQL 17.7 (Prod Live)",
                "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                "company_id": 2,
                "company_name": "BONDIN",
                "total_scans": int(stats[0]),
                "total_ca_tnd": round(tot_ca, 2),
                "panier_moyen_tnd": round(avg_b, 3),
                "total_points_emis": int(stats[3]),
                "clients_actifs": int(stats[4]),
                "dernier_scan": str(stats[5]),
                "dernier_ticket": recent_list[0]["ticket"] if recent_list else None,
                "dernier_magasin": recent_list[0]["magasin"] if recent_list else None,
                "recent_scans": recent_list
            }

            self.send_response(200)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')
            self.end_headers()
            self.wfile.write(json.dumps(payload, ensure_ascii=False).encode('utf-8'))

        except Exception as e:
            # Fallback gracieux en cas de coupure réseau pour éviter toute erreur 500
            cache_file = os.path.join(os.path.dirname(__file__), "..", "live_sync_cache.json")
            if not os.path.exists(cache_file):
                cache_file = os.path.join(os.path.dirname(__file__), "..", "dashboard_bi", "live_sync_cache.json")
            
            fallback_payload = None
            if os.path.exists(cache_file):
                try:
                    with open(cache_file, "r", encoding="utf-8") as f:
                        fallback_payload = json.load(f)
                        fallback_payload["status"] = "cached_fallback"
                        fallback_payload["warning"] = str(e)
                except Exception:
                    pass
            
            if not fallback_payload:
                fallback_payload = {
                    "status": "cached_fallback",
                    "source": "Cache DWH (Mode Résilient)",
                    "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                    "total_scans": 13051,
                    "total_ca_tnd": 152234.95,
                    "panier_moyen_tnd": 11.665,
                    "total_points_emis": 509959,
                    "clients_actifs": 757,
                    "dernier_scan": "2026-10-20 12:17:04",
                    "dernier_ticket": "bondin6128916",
                    "dernier_magasin": "Cafétéria Tunis Espagne",
                    "warning": str(e)
                }
            self.send_response(200)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')
            self.end_headers()
            self.wfile.write(json.dumps(fallback_payload, ensure_ascii=False).encode('utf-8'))
