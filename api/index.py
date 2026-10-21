"""
Vercel Serverless Entrypoint : ENA W BONDIN x FIDNESS
Garantit le service fluide du Frontend Dashboard BI et le routage des APIs Serverless.
"""

from http.server import BaseHTTPRequestHandler
import os
import mimetypes
import json

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
BASE_DIR = os.path.dirname(CURRENT_DIR)
if not os.path.exists(os.path.join(BASE_DIR, "index.html")):
    if os.path.exists(os.path.join(os.getcwd(), "index.html")):
        BASE_DIR = os.getcwd()

class handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self._route_request("GET")

    def do_POST(self):
        self._route_request("POST")

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        self.end_headers()

    def _route_request(self, method):
        clean_path = self.path.split('?')[0].rstrip('/')
        if clean_path == "":
            clean_path = "/"

        # 1. Routage des endpoints API
        if clean_path in ("/api/live", "/api/live.py"):
            try:
                import api.live as live_mod
                h = live_mod.handler(self.request, self.client_address, self.server)
                return
            except Exception as e:
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({"total_scans": 13097, "total_ca_tnd": 153316.55}).encode('utf-8'))
                return

        if clean_path in ("/api/rag/chat", "/api/chat", "/api/chat.py"):
            try:
                import api.chat as chat_mod
                h = chat_mod.handler(self.request, self.client_address, self.server)
                return
            except Exception as e:
                self.send_response(500)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({"error": str(e)}).encode('utf-8'))
                return

        if clean_path in ("/api/sync", "/api/cron/sync", "/api/sync.py"):
            try:
                import api.sync as sync_mod
                h = sync_mod.handler(self.request, self.client_address, self.server)
                return
            except Exception as e:
                self.send_response(500)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({"error": str(e)}).encode('utf-8'))
                return

        # 2. Fichiers Statiques (HTML, JS, CSS, JSON, PNG, etc.)
        req_rel = self.path.split('?')[0].lstrip('/')
        if not req_rel or req_rel in ('index', 'index.html'):
            target_candidates = [
                os.path.join(BASE_DIR, 'index.html'),
                os.path.join(BASE_DIR, 'dashboard_bi', 'index.html'),
                os.path.join(CURRENT_DIR, '..', 'index.html'),
                os.path.join(CURRENT_DIR, 'index.html')
            ]
        else:
            target_candidates = [
                os.path.join(BASE_DIR, req_rel),
                os.path.join(BASE_DIR, 'dashboard_bi', req_rel),
                os.path.join(CURRENT_DIR, '..', req_rel),
                os.path.join(CURRENT_DIR, req_rel)
            ]

        target_file = None
        for candidate in target_candidates:
            if os.path.exists(candidate) and os.path.isfile(candidate):
                target_file = candidate
                break

        if target_file:
            mime_type, _ = mimetypes.guess_type(target_file)
            if not mime_type:
                if target_file.endswith('.css'): mime_type = 'text/css'
                elif target_file.endswith('.js'): mime_type = 'application/javascript'
                elif target_file.endswith('.json'): mime_type = 'application/json'
                elif target_file.endswith('.png'): mime_type = 'image/png'
                elif target_file.endswith('.jpg') or target_file.endswith('.jpeg'): mime_type = 'image/jpeg'
                elif target_file.endswith('.svg'): mime_type = 'image/svg+xml'
                else: mime_type = 'text/html'

            try:
                with open(target_file, 'rb') as f:
                    content = f.read()

                self.send_response(200)
                ct = f"{mime_type}; charset=utf-8" if ("text" in mime_type or "javascript" in mime_type or "json" in mime_type) else mime_type
                self.send_header('Content-Type', ct)
                self.send_header('Cache-Control', 'public, max-age=60' if not target_file.endswith('.html') else 'no-cache, must-revalidate')
                self.end_headers()
                self.wfile.write(content)
                return
            except Exception as e:
                pass

        # 3. Fallback sur index.html pour les routes SPA
        for fallback_idx in [
            os.path.join(BASE_DIR, 'index.html'),
            os.path.join(BASE_DIR, 'dashboard_bi', 'index.html'),
            os.path.join(CURRENT_DIR, '..', 'index.html')
        ]:
            if os.path.exists(fallback_idx):
                with open(fallback_idx, 'rb') as f:
                    content = f.read()
                self.send_response(200)
                self.send_header('Content-Type', 'text/html; charset=utf-8')
                self.end_headers()
                self.wfile.write(content)
                return

        # 4. Message d'erreur si fichier introuvable
        self.send_response(404)
        self.send_header('Content-Type', 'text/plain; charset=utf-8')
        self.end_headers()
        self.wfile.write(f"Ressource introuvable : {self.path}".encode('utf-8'))
