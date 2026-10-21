"""
Vercel Serverless Function : /api/kpis
"""
from http.server import BaseHTTPRequestHandler
import json

class handler(BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, OPTIONS')
        self.end_headers()

    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(json.dumps({
            "ca_total": 154530.0,
            "nb_scans": 13168,
            "panier_moyen": 11.735,
            "panier_moyen_succursale": 37.588,
            "panier_moyen_cafeteria": 4.191,
            "clients_inscrits": 2715,
            "clients_actifs": 761,
            "taux_activation": 28.0,
            "frequence_mois": 3.65,
            "intervalle_moyen_jours": 8.2,
            "retention_30j": 64.2,
            "retention_60j": 48.7,
            "retention_90j": 37.1,
            "points_earn": 513924,
            "points_burn": 226900,
            "points_solde": 287024,
            "dette_tnd": 2870.240,
            "ratio_earn_burn": 44.1,
            "nb_grossistes": 375,
            "ca_grossistes": 118053.12,
            "part_ca_grossistes": 77.3,
            "nb_ultra_frequents": 165,
            "part_ultra_frequents": 25.3,
            "ca_avant_cadeau": 60.627,
            "nb_clients_brule": 35,
            "clients_churn_risque": 13,
            "taux_churn": 1.72
        }, ensure_ascii=False).encode('utf-8'))
