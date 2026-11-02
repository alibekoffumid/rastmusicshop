import fs from 'fs';
import path from 'path';

const rawData = JSON.parse(fs.readFileSync('scripts/data/gidoo_catalog_titles.json', 'utf8'));

// Deduplicate dataset by SKU (keeping RP-C09 for RM-880495, and adding RM-017546 for RP-C01 White)
const skuMap = new Map();
for (const item of rawData) {
  if (item.sku === 'RM-880495') {
    if (item.name.includes('RP-C09')) {
      skuMap.set('RM-880495', item);
    } else {
      skuMap.set('RM-017546', { ...item, sku: 'RM-017546' });
    }
  } else {
    skuMap.set(item.sku, item);
  }
}

const items = Array.from(skuMap.values());
console.log('Total unique mapped items:', items.length);

function escapeSql(str) {
  if (str === null || str === undefined) return 'NULL';
  return `'${String(str).replace(/'/g, "''")}'`;
}

const sqlLines = [];
sqlLines.push('-- =================================================================');
sqlLines.push('-- IDEMPOTENT UPDATE: PRODUCT TITLES FROM FACTORY CATALOG');
sqlLines.push('-- Brands: Kaysen, Tayste, The Rose, Gidoo');
sqlLines.push(`-- Total Titles Updated: ${items.length}`);
sqlLines.push('-- =================================================================');
sqlLines.push('BEGIN;\n');

// Batch into chunks of 100
const CHUNK_SIZE = 100;
for (let i = 0; i < items.length; i += CHUNK_SIZE) {
  const chunk = items.slice(i, i + CHUNK_SIZE);
  sqlLines.push(`-- Batch ${Math.floor(i / CHUNK_SIZE) + 1} (${chunk.length} items)`);
  sqlLines.push('UPDATE public.products AS p');
  sqlLines.push('SET');
  sqlLines.push('  name = u.name,');
  sqlLines.push('  name_ru = u.name_ru,');
  sqlLines.push('  name_en = u.name_en');
  sqlLines.push('FROM (VALUES');
  
  const values = chunk.map(item => {
    return `  (${escapeSql(item.sku)}, ${escapeSql(item.name)}, ${escapeSql(item.name_ru)}, ${escapeSql(item.name_en)})`;
  });
  
  sqlLines.push(values.join(',\n'));
  sqlLines.push(') AS u(sku, name, name_ru, name_en)');
  sqlLines.push('WHERE p.sku = u.sku;\n');
}

sqlLines.push('COMMIT;');

const outPath = 'supabase/migrations/20261102_update_gidoo_titles.sql';
fs.writeFileSync(outPath, sqlLines.join('\n'), 'utf8');
console.log(`✓ Migration created at: ${outPath} (${(fs.statSync(outPath).size / 1024).toFixed(1)} KB)`);

