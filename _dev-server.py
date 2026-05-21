#!/usr/bin/env python3
"""
Dev preview server with aggressive no-cache headers.

The default `python3 -m http.server` lets browsers cache HTML/CSS/JS/audio
indefinitely, which makes iterating on the site painful — you change a file
and the browser keeps serving you the old version. This wrapper adds
Cache-Control headers that tell the browser "don't cache anything here".

Run from website/:   python3 _dev-server.py
"""
import http.server
import sys

PORT = 8000

class NoCacheHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        # Tell every browser: do not cache, ever.
        self.send_header("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
        self.send_header("Pragma", "no-cache")
        self.send_header("Expires", "0")
        super().end_headers()

    # (No log filter — the default per-request line is fine and the previous
    # custom filter crashed on 404s, which froze the server.)

if __name__ == "__main__":
    print(f"Dev preview server with no-cache headers")
    print(f"→ http://localhost:{PORT}")
    print(f"Stop with Ctrl-C")
    try:
        with http.server.HTTPServer(("", PORT), NoCacheHandler) as httpd:
            httpd.serve_forever()
    except KeyboardInterrupt:
        sys.exit(0)
