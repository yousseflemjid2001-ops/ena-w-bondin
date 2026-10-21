"""
API Entrypoint & Healthcheck pour Vercel Serverless
Fournit le point d'entrée requis par Vercel Python Runtime.
"""

from http.server import BaseHTTPRequestHandler
import json
from datetime import datetime

class handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Cache-Control', 'no-cache')
        self.end_headers()
        response = {
            "service": "ENA W BONDIN x FIDNESS API",
            "status": "online",
            "timestamp": datetime.now().isoformat(),
            "endpoints": {
                "live": "/api/live",
                "chat": "/api/rag/chat",
                "sync": "/api/cron/sync"
            }
        }
        self.wfile.write(json.dumps(response, ensure_ascii=False).encode('utf-8'))
