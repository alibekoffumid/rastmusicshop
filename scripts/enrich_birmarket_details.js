import fs from 'fs';

const products = JSON.parse(fs.readFileSync('scripts/data/birmarket_products.json', 'utf8'));
const HEADERS = {
  'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
};

async function fetchDetails() {
  console.log(`Starting resilient detail enrichment for ${products.length} products...`);
  const CHUNK_SIZE = 10;
  let completed = 0;

  for (let i = 0; i < products.length; i += CHUNK_SIZE) {
    const chunk = products.slice(i, i + CHUNK_SIZE);
    await Promise.all(chunk.map(async (p) => {
      try {
        const [resAz, resRu] = await Promise.all([
          fetch(p.url_az, { headers: HEADERS, signal: AbortSignal.timeout(4000) }),
          fetch(p.url_ru, { headers: HEADERS, signal: AbortSignal.timeout(4000) })
        ]);

        const [htmlAz, htmlRu] = await Promise.all([resAz.text(), resRu.text()]);

        const mAz = htmlAz.match(/<script type="application\/ld\+json">([\s\S]*?)<\/script>/i) || [...htmlAz.matchAll(/<script[^>]*>([\s\S]*?)<\/script>/gi)][1];
        const mRu = htmlRu.match(/<script type="application\/ld\+json">([\s\S]*?)<\/script>/i) || [...htmlRu.matchAll(/<script[^>]*>([\s\S]*?)<\/script>/gi)][1];

        if (mAz) {
          const sAz = JSON.parse(mAz[1]);
          p.description = sAz.description || '';
          p.mpn = sAz.mpn || '';
          const imgs = Array.isArray(sAz.image) ? sAz.image : (sAz.image ? [sAz.image] : []);
          const cleanImgs = imgs.map(img => img.replace('/sized/280/', '/sized/1680/').replace('/280/', '/1680/'));
          if (cleanImgs.length > 0) {
            p.images = cleanImgs;
            p.image = cleanImgs[0];
          }
        }

        if (mRu) {
          const sRu = JSON.parse(mRu[1]);
          p.description_ru = sRu.description || '';
        }
      } catch (e) {
        // Fallback silently if individual item times out
      }
    }));

    completed += chunk.length;
    if (completed % 50 === 0 || completed >= products.length) {
      console.log(`Progress: [${completed}/${products.length}] processed.`);
    }
    // Small delay to be courteous to server
    await new Promise(r => setTimeout(r, 150));
  }

  fs.writeFileSync('scripts/data/birmarket_enriched.json', JSON.stringify(products, null, 2), 'utf8');
  console.log('✓ Successfully saved all enriched products to birmarket_enriched.json');
}

fetchDetails();
