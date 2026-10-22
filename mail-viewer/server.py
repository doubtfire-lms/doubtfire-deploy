#!/usr/bin/env python3

import argparse
import hashlib
import json
import os
import re
from email import policy
from email.parser import BytesParser
from email.utils import parsedate_to_datetime
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import unquote, urlparse


APP_DIR = Path(__file__).resolve().parent
DEFAULT_MAIL_DIR = Path('/workspace/doubtfire-api/tmp/mails')
if not DEFAULT_MAIL_DIR.exists():
    DEFAULT_MAIL_DIR = APP_DIR.parent / 'doubtfire-api/tmp/mails'


def content(part):
    if part is None:
        return ''
    try:
        value = part.get_content()
        return value if isinstance(value, str) else value.decode(errors='replace')
    except Exception:
        return part.get_payload(decode=True).decode(errors='replace')


def split_messages(raw):
    starts = [match.start() for match in re.finditer(rb'(?m)^Date: .+\r?\nFrom: ', raw)]
    if not starts:
        return [raw] if raw.strip() else []
    return [raw[start:end] for start, end in zip(starts, starts[1:] + [len(raw)])]


class MailStore:
    def __init__(self, mail_dir):
        self.mail_dir = Path(mail_dir)

    def messages(self):
        result = []
        if not self.mail_dir.exists():
            return result

        for path in sorted(self.mail_dir.iterdir()):
            if not path.is_file() or path.name.startswith('.'):
                continue
            for index, raw in enumerate(split_messages(path.read_bytes())):
                message = BytesParser(policy=policy.default).parsebytes(raw)
                message_id = str(message.get('Message-ID', '')).strip()
                identity = message_id or f'{path.name}:{index}'
                mail_id = hashlib.sha256(identity.encode()).hexdigest()[:20]
                html_part = message.get_body(preferencelist=('html',))
                plain_part = message.get_body(preferencelist=('plain',))
                plain = content(plain_part)
                html = content(html_part)
                if not html:
                    import html as html_module
                    html = f'<pre style="white-space:pre-wrap;font:14px/1.6 Arial,sans-serif">{html_module.escape(plain)}</pre>'

                date = str(message.get('Date', ''))
                try:
                    timestamp = parsedate_to_datetime(date).isoformat()
                except (TypeError, ValueError):
                    timestamp = ''

                result.append({
                    'id': mail_id,
                    'subject': str(message.get('Subject', '(no subject)')),
                    'from': str(message.get('From', 'Unknown sender')),
                    'to': str(message.get('To', path.name)),
                    'date': date,
                    'timestamp': timestamp,
                    'snippet': re.sub(r'\s+', ' ', plain).strip()[:220],
                    'html': html,
                    'plain': plain,
                })

        return sorted(result, key=lambda mail: mail['timestamp'], reverse=True)

    def find(self, mail_id):
        return next((mail for mail in self.messages() if mail['id'] == mail_id), None)


class Handler(SimpleHTTPRequestHandler):
    store = None

    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(APP_DIR), **kwargs)

    def do_GET(self):
        path = urlparse(self.path).path
        if path == '/api/messages':
            messages = self.store.messages()
            self.send_json([{key: value for key, value in mail.items() if key not in ('html', 'plain')} for mail in messages])
            return
        if path.startswith('/api/messages/'):
            mail = self.store.find(unquote(path.removeprefix('/api/messages/')))
            self.send_json(mail or {'error': 'Message not found'}, 200 if mail else 404)
            return
        if path == '/':
            self.path = '/index.html'
        super().do_GET()

    def send_json(self, value, status=200):
        body = json.dumps(value).encode()
        self.send_response(status)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Content-Length', str(len(body)))
        self.send_header('Cache-Control', 'no-store')
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, message, *args):
        print(f'{self.address_string()} - {message % args}', flush=True)


def main():
    parser = argparse.ArgumentParser(description='View Rails file-delivery emails in a browser.')
    parser.add_argument('--host', default=os.getenv('MAIL_VIEWER_HOST', '127.0.0.1'))
    parser.add_argument('--port', type=int, default=int(os.getenv('MAIL_VIEWER_PORT', '8025')))
    parser.add_argument('--mail-dir', default=os.getenv('MAIL_VIEWER_DIR', str(DEFAULT_MAIL_DIR)))
    args = parser.parse_args()

    Handler.store = MailStore(args.mail_dir)
    server = ThreadingHTTPServer((args.host, args.port), Handler)
    print(f'Mail Viewer: http://{args.host}:{args.port}', flush=True)
    print(f'Reading: {Path(args.mail_dir).resolve()}', flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == '__main__':
    main()
