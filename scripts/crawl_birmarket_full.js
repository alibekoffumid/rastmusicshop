import fs from 'fs';

const BASE_AZ = 'https://birmarket.az';
const BASE_RU = 'https://birmarket.az/ru';
const HEADERS = {
  'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
};

async function crawlMerchantPages() {
  console.log('Crawling merchant pages 1 to 26 from BirMarket...');
  const allProducts = new Map(); // sku -> product

  for (let page = 1; page <= 26; page++) {
    const urlAz = `${BASE_AZ}/merchant/4880-rast-musiqi-aletleri?page=${page}`;
    const urlRu = `${BASE_RU}/merchant/4880-rast-musiqi-aletleri?page=${page}`;

    try {
      const [resAz, resRu] = await Promise.all([
        fetch(urlAz, { headers: HEADERS }),
        fetch(urlRu, { headers: HEADERS })
      ]);

      const [htmlAz, htmlRu] = await Promise.all([resAz.text(), resRu.text()]);

      const sAz = JSON.parse([...htmlAz.matchAll(/<script[^>]*>([\s\S]*?)<\/script>/gi)][1][1]);
      const sRu = JSON.parse([...htmlRu.matchAll(/<script[^>]*>([\s\S]*?)<\/script>/gi)][1][1]);

      const itemsAz = sAz.mainEntity?.itemListElement || [];
      const itemsRu = sRu.mainEntity?.itemListElement || [];

      for (let i = 0; i < itemsAz.length; i++) {
        const az = itemsAz[i].item;
        const ru = itemsRu[i]?.item;
        if (!az || !az.sku) continue;

        const sku = String(az.sku);
        const img = (az.image || '')
          .replace('/sized/280/', '/sized/1680/')
          .replace('/280/', '/1680/');

        allProducts.set(sku, {
          sku: `BM-${sku}`,
          raw_sku: sku,
          name: az.name,
          name_ru: ru?.name || az.name,
          price: Number(az.offers?.price) || 0,
          image: img,
          images: img ? [img] : [],
          brand: (az.brand?.name && az.brand.name !== 'No Brand') ? az.brand.name : null,
          url_az: az.url,
          url_ru: ru?.url || az.url
        });
      }

      console.log(`Page [${page}/26]: +${itemsAz.length} products. Total unique: ${allProducts.size}`);
    } catch (err) {
      console.warn(`Error on page ${page}:`, err.message);
    }
  }

  const list = [...allProducts.values()];
  console.log(`\nSuccessfully crawled ${list.length} products from BirMarket merchant 4880.`);
  fs.writeFileSync('scripts/data/birmarket_products.json', JSON.stringify(list, null, 2), 'utf8');
}

crawlMerchantPages();
