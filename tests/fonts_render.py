"""Check in a headless browser that the brand's fonts load and apply.

Serves the rendered example.html and example-slides.html, then asserts that
body text and code use the brand's fonts and that the browser loaded them
(rather than falling back to system fonts). Run by tests/acceptance.sh.
"""

import functools
import http.server
import subprocess
import sys
import threading
from pathlib import Path

from playwright.sync_api import sync_playwright

ROOT = Path(__file__).resolve().parent.parent
# Page -> element that must use each font family.
PAGES = {
    "example.html": {"Source Serif Pro": "main p", "JetBrains Mono": "main pre code"},
    "example-slides.html": {"Source Serif Pro": ".reveal p", "JetBrains Mono": ".reveal pre code"},
}


class QuietHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *args):
        pass


def serve():
    handler = functools.partial(QuietHandler, directory=ROOT)
    server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    return server


def main() -> int:
    server = serve()
    port = server.server_address[1]
    failures = 0
    with sync_playwright() as p:
        try:
            browser = p.chromium.launch()
        except Exception:
            subprocess.run([sys.executable, "-m", "playwright", "install", "chromium"], check=True)
            browser = p.chromium.launch()
        page = browser.new_page()
        for path, checks in PAGES.items():
            page.goto(f"http://127.0.0.1:{port}/{path}", wait_until="networkidle")
            page.evaluate("document.fonts.ready")
            for family, selector in checks.items():
                result = page.evaluate(
                    """([selector, family]) => {
                        const el = document.querySelector(selector);
                        const applied = getComputedStyle(el).fontFamily.replaceAll('"', '').split(',')[0].trim();
                        const loaded = [...document.fonts].some(f => f.family.replaceAll('"', '') === family && f.status === 'loaded');
                        return {applied, loaded};
                    }""",
                    [selector, family],
                )
                ok = result["applied"] == family and result["loaded"]
                print(f"{'ok:  ' if ok else 'FAIL:'} {path}: {selector} in {family} {result}")
                failures += not ok
        browser.close()
    server.shutdown()
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
