import fs from 'fs';

const BASE = 'https://www.kaysenguitar.com';
const HEADERS = {
  'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
};

const gidooProducts = JSON.parse(fs.readFileSync('scripts/data/gidoo_catalog_titles.json', 'utf8'));
const allUrls = JSON.parse(fs.readFileSync('scripts/data/kaysen_all_urls.json', 'utf8'))
  .filter(u => u.match(/\/\d+\.html$/));

console.log(`Starting structured extraction on ${allUrls.length} pages...`);

async function fetchWithRetry(url, retries = 2) {
  for (let i = 0; i <= retries; i++) {
    try {
      const res = await fetch(url, { headers: HEADERS });
      if (res.status === 200) return await res.text();
    } catch (e) {
      if (i === retries) return null;
      await new Promise(r => setTimeout(r, 1000));
    }
  }
  return null;
}

async function run() {
  const crawledProducts = [];

  for (let i = 0; i < allUrls.length; i++) {
    const u = allUrls[i];
    const fullUrl = BASE + u;
    const html = await fetchWithRetry(fullUrl);
    if (!html) continue;

    const title = html.match(/<h1[^>]*>([\s\S]*?)<\/h1>/i)?.[1]?.replace(/<[^>]+>/g, '').trim() || '';

    // 1. High res images
    const srcoriMatches = [...html.matchAll(/srcori=["']([^"']+)["']/gi)].map(m => m[1]);
    const genericImgs = [...html.matchAll(/(?:https:)?\/\/bsg-i\.nbxc\.com\/product\/[a-zA-Z0-9\/._@|]+/gi)].map(m => m[0]);
    const cleanImgs = [...new Set([...srcoriMatches, ...genericImgs]
      .map(img => (img.startsWith('//') ? 'https:' + img : img).split('@')[0]))]
      .filter(img => !img.endsWith('.mp4') && !img.includes('logo') && !img.includes('banner'));

    // 2. Structured attributes (.detail_infos)
    const attrs = {};
    const attrMatches = [...html.matchAll(/class=['"]attr_title['"][^>]*>([\s\S]*?)<\/span>[^<]*:[^<]*<span[^>]*class=['"]attr_content['"][^>]*title=['"]([^'"]+)['"]/gi)];
    for (const m of attrMatches) {
      const key = m[1].replace(/<[^>]+>/g, '').trim().toLowerCase();
      const val = m[2].trim();
      attrs[key] = val;
    }

    // 3. Table cells
    const tdMatches = [...html.matchAll(/<td[^>]*>([\s\S]*?)<\/td>/gi)].map(m => m[1].replace(/<[^>]+>/g, '').trim());
    for (let j = 0; j < tdMatches.length; j++) {
      if (/^(?:Model|Model name|Item No|Model Number|Номер модели)$/i.test(tdMatches[j]) && tdMatches[j + 1]) {
        attrs['model_table'] = tdMatches[j + 1];
      }
    }

    // 4. Collect model candidates
    const modelCandidates = new Set();
    if (attrs['model no.']) modelCandidates.add(attrs['model no.']);
    if (attrs['модель']) modelCandidates.add(attrs['модель']);
    if (attrs['model_table']) modelCandidates.add(attrs['model_table']);

    // Regex search in title and model strings
    const strToSearch = `${title} ${attrs['model no.'] || ''} ${attrs['модель'] || ''} ${attrs['model_table'] || ''}`;
    const tokenMatches = strToSearch.match(/\b(?:TS[- ]?[A-Z0-9]+(?:-[A-Z0-9]+)*|T[- ]?[0-9]{3,4}(?:-[A-Z0-9]+)*|K[- ]?[A-Z0-9]+(?:-[A-Z0-9]+)*|KST[- ]?[A-Z0-9]+(?:-[A-Z0-9]+)*|KTL[- ]?[A-Z0-9]+(?:-[A-Z0-9]+)*|KIB[- ]?[A-Z0-9]+(?:-[A-Z0-9]+)*|KPB[- ]?[A-Z0-9]+(?:-[A-Z0-9]+)*|RG[- ]?[A-Z0-9]+(?:-[A-Z0-9]+)*|RH[- ]?[A-Z0-9]+(?:-[A-Z0-9]+)*|RF[- ]?[A-Z0-9]+(?:-[A-Z0-9]+)*|RP[- ]?[A-Z0-9]+(?:-[A-Z0-9]+)*|RX[- ]?[A-Z0-9]+(?:-[A-Z0-9]+)*|RC[- ]?[A-Z0-9]+(?:-[A-Z0-9]+)*|YX[- ]?[A-Z0-9]+(?:-[A-Z0-9]+)*)\b/gi) || [];
    
    tokenMatches.forEach(tok => {
      const clean = tok.toUpperCase().replace(/\s+/g, '-');
      if (!['KAYSEN', 'KEY', 'RGB', 'RGBA', 'KEYFRAMES', 'KILOGRAM', 'KILOMETER', 'KEYWORDS', 'KAYSENGUITAR'].includes(clean)) {
        modelCandidates.add(clean);
      }
    });

    if (cleanImgs.length > 0) {
      crawledProducts.push({
        url: fullUrl,
        title,
        models: [...modelCandidates],
        attrs,
        mainImage: cleanImgs[0],
        images: cleanImgs.slice(0, 8)
      });
    }

    if ((i + 1) % 25 === 0 || i === allUrls.length - 1) {
      console.log(`[${i + 1}/${allUrls.length}] Processed. Total with images: ${crawledProducts.length}`);
    }
  }

  console.log(`\nFinished parsing. Total products: ${crawledProducts.length}`);
  fs.writeFileSync('scripts/data/kaysen_structured_catalog.json', JSON.stringify(crawledProducts, null, 2), 'utf8');

  // Match against our store products
  const matchedList = [];
  const unmatchedList = [];

  for (const storeProd of gidooProducts) {
    const rawSearch = `${storeProd.name} ${storeProd.raw_name || ''}`.toUpperCase();

    let matched = null;

    // 1. Try exact model code match
    for (const cp of crawledProducts) {
      for (const m of cp.models) {
        const mNorm = m.toUpperCase().replace(/[- ]/g, '');
        const rNorm = rawSearch.replace(/[- ]/g, '');
        if (mNorm.length >= 3 && rNorm.includes(mNorm)) {
          matched = cp;
          break;
        }
      }
      if (matched) break;
    }

    if (matched) {
      matchedList.push({
        sku: storeProd.sku,
        name: storeProd.name,
        matchedModel: matched.models.join(', '),
        matchedUrl: matched.url,
        image: matched.mainImage,
        images: matched.images
      });
    } else {
      unmatchedList.push({
        sku: storeProd.sku,
        name: storeProd.name
      });
    }
  }

  console.log(`\n=== MATCHING RESULTS ===`);
  console.log(`✓ Total Matched: ${matchedList.length} / ${gidooProducts.length}`);
  console.log(`- Unmatched: ${unmatchedList.length}`);

  fs.writeFileSync('scripts/data/kaysen_matched_results.json', JSON.stringify(matchedList, null, 2), 'utf8');

  // Generate SQL Migration
  const sqlLines = [
    '-- Migration: Update high-resolution photos for Kaysen/Tayste/Gidoo products from factory website',
    'BEGIN;',
    '',
    'UPDATE public.products AS p',
    'SET',
    '  image = u.image,',
    '  images = u.images::jsonb',
    'FROM (VALUES'
  ];

  const valueRows = matchedList.map((u, idx) => {
    const isLast = idx === matchedList.length - 1;
    const jsonArr = JSON.stringify(u.images).replace(/'/g, "''");
    return `  ('${u.sku}', '${u.image}', '${jsonArr}'::jsonb)${isLast ? '' : ','}`;
  });

  sqlLines.push(valueRows.join('\n'));
  sqlLines.push(') AS u(sku, image, images)');
  sqlLines.push('WHERE p.sku = u.sku;');
  sqlLines.push('');
  sqlLines.push('COMMIT;');

  const sqlPath = 'supabase/migrations/20261102_update_kaysen_images.sql';
  fs.writeFileSync(sqlPath, sqlLines.join('\n'), 'utf8');
  console.log(`\n✓ SQL migration written to: ${sqlPath} (${(fs.statSync(sqlPath).size / 1024).toFixed(1)} KB)`);
}

run();
