#!/usr/bin/env python3
import http.server
import socketserver
import os
import sys
import subprocess
import socket

# Define the port and handler
PORT = 5000  # Default port expected by Replit
MAX_PORT_ATTEMPTS = 10
web_dir = os.path.join(os.getcwd(), 'build/web')

# Make sure the build exists
if not os.path.exists(web_dir):
    print("Building Flutter web application...")
    subprocess.run(["flutter", "build", "web"], check=True)

os.chdir(web_dir)

class Handler(http.server.SimpleHTTPRequestHandler):
    # Set correct MIME types for Flutter web files
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
    
    def end_headers(self):
        # Enable CORS to allow connections from anywhere
        self.send_header('Access-Control-Allow-Origin', '*')
        http.server.SimpleHTTPRequestHandler.end_headers(self)
    
    def guess_type(self, path):
        base, ext = os.path.splitext(path)
        if ext == '.js':
            return 'application/javascript'
        elif ext == '.json':
            return 'application/json'
        elif ext == '.wasm':
            return 'application/wasm'
        return super().guess_type(path)

# Try to start server on PORT, increment if already in use
current_port = PORT
port_found = False
attempts = 0

while not port_found and attempts < MAX_PORT_ATTEMPTS:
    try:
        # Try to create a socket to test if port is available
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.bind(("0.0.0.0", current_port))
        sock.close()
        port_found = True
    except OSError:
        print(f"Port {current_port} is in use, trying next port...")
        current_port += 1
        attempts += 1

if not port_found:
    print(f"Could not find an available port after {MAX_PORT_ATTEMPTS} attempts.")
    sys.exit(1)

print(f"Starting server on port {current_port}...")
print(f"Serving Flutter web application from {web_dir}")
print(f"Access the app at http://localhost:{current_port}/")

try:
    with socketserver.TCPServer(("0.0.0.0", current_port), Handler) as httpd:
        print("Server running... Press Ctrl+C to stop.")
        httpd.serve_forever()
except KeyboardInterrupt:
    print("\nShutting down server...")
    sys.exit(0)
except OSError as e:
    print(f"Error starting server: {e}")
    sys.exit(1)