const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({
    viewport: { width: 1400, height: 900 }
  });

  await page.goto('http://localhost:8000/index.html', { waitUntil: 'networkidle' });

  // Take screenshot
  await page.screenshot({ path: 'screenshot.png', fullPage: true });

  await browser.close();
})();
