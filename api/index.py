"""
Vercel Serverless Entrypoint : / et /index.html
Garantit que le Dashboard BI est toujours servi avec succès (Zero-Crash Fallback).
"""

from http.server import BaseHTTPRequestHandler
import os
import mimetypes

class handler(BaseHTTPRequestHandler):
    def do_GET(self):
        try:
            base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
            req_path = self.path.split('?')[0].lstrip('/')
            
            if not req_path or req_path == 'index.html':
                target_file = os.path.join(base_dir, 'index.html')
                if not os.path.exists(target_file):
                    target_file = os.path.join(base_dir, 'dashboard_bi', 'index.html')
            else:
                target_file = os.path.join(base_dir, req_path)
                if not os.path.exists(target_file):
                    target_file = os.path.join(base_dir, 'dashboard_bi', req_path)

            if os.path.exists(target_file) and os.path.isfile(target_file):
                mime_type, _ = mimetypes.guess_type(target_file)
                if not mime_type:
                    if target_file.endswith('.css'): mime_type = 'text/css'
                    elif target_file.endswith('.js'): mime_type = 'application/javascript'
                    elif target_file.endswith('.json'): mime_type = 'application/json'
                    else: mime_type = 'text/html'
                
                with open(target_file, 'rb') as f:
                    body = f.read()
                
                self.send_response(200)
                self.send_header('Content-Type', f'{mime_type}; charset=utf-8' if 'text' in mime_type or 'javascript' in mime_type or 'json' in mime_type else mime_type)
                self.send_header('Cache-Control', 'public, max-age=300')
                self.end_headers()
                self.wfile.write(body)
                return
            
            # Si le fichier n'est pas trouvé, renvoyer l'index.html principal
            idx_file = os.path.join(base_dir, 'index.html')
            if not os.path.exists(idx_file):
                idx_file = os.path.join(base_dir, 'dashboard_bi', 'index.html')
            
            with open(idx_file, 'rb') as f:
                body = f.read()
            self.send_response(200)
            self.send_header('Content-Type', 'text/html; charset=utf-8')
            self.end_headers()
            self.wfile.write(body)

        except Exception as e:
            self.send_response(500)
            self.send_header('Content-Type', 'text/plain; charset=utf-8')
            self.end_headers()
            self.wfile.write(f"Erreur d'initialisation Vercel : {str(e)}".encode('utf-8'))
