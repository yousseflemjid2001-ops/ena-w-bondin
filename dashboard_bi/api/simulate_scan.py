"""
Vercel Serverless Function : /api/simulate-scan ou /api/simulate_scan
"""
from http.server import BaseHTTPRequestHandler
import json
import time
from datetime import datetime

class handler(BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def do_POST(self):
        try:
            content_length = int(self.headers.get('Content-Length', 0))
            body = json.loads(self.rfile.read(content_length).decode('utf-8')) if content_length > 0 else {}
            montant = float(body.get("montant", 18.500))
            points = int(montant * 10)
            magasin_nom = body.get("magasin", "Succursale Tunis Liberté")
            client_id = body.get("client_id", "CLI_SIMULE_" + str(int(time.time()))[-4:])

            new_trans = {
                "ID_Transaction": 13169,
                "ID_Client_Hache": client_id,
                "ID_Magasin": 38,
                "Date": datetime.now().strftime("%Y-%m-%d"),
                "Heure": datetime.now().strftime("%H:%M:%S"),
                "ID_Ticket": 91000,
                "Type_Achat": "gain",
                "Montant_TND": montant,
                "Points_Gagnes": points,
                "Magasin": magasin_nom
            }

            self.send_response(200)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps({
                "success": True,
                "message": f"Scan de {montant:.3f} TND enregistré avec succès !",
                "new_total_ca": 154548.5,
                "new_total_scans": 13169,
                "transaction": new_trans
            }, ensure_ascii=False).encode('utf-8'))
        except Exception as e:
            self.send_response(500)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({"error": str(e)}).encode('utf-8'))
