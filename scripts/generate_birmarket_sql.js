import fs from 'fs';

const products = JSON.parse(fs.readFileSync('scripts/data/birmarket_ready_products.json', 'utf8'));

function escapeSql(val) {
  if (val === null || val === undefined) return 'NULL';
  return `'${String(val).replace(/'/g, "''")}'`;
}

function escapeJson(val) {
  if (!val) return "'[]'::jsonb";
  return `'${JSON.stringify(val).replace(/'/g, "''")}'::jsonb`;
}

// Simple English title generator from AZ/RU
function toEnglish(nameAz, nameRu) {
  let en = nameAz;
  const map = [
    [/Tar üst xərəyi/gi, 'Tar Upper Bridge'],
    [/Tar alt xərəyi/gi, 'Tar Lower Bridge'],
    [/Tar xərəyi/gi, 'Tar Bridge'],
    [/Tar mizrabı/gi, 'Tar Plectrum'],
    [/Tar simi/gi, 'Tar String'],
    [/Tar simləri/gi, 'Tar Strings'],
    [/Tar aşığı/gi, 'Tar Tuning Peg'],
    [/Tar pərdəsi/gi, 'Tar Fret'],
    [/Tar üçün/gi, 'For Tar'],
    [/Kamança üçün/gi, 'For Kamancha'],
    [/Kamança simi/gi, 'Kamancha String'],
    [/Kamança simləri/gi, 'Kamancha Strings'],
    [/Kamança kamanı/gi, 'Kamancha Bow'],
    [/Kamança xərəyi/gi, 'Kamancha Bridge'],
    [/Saz simi/gi, 'Saz String'],
    [/Saz simləri/gi, 'Saz Strings'],
    [/Saz üçün/gi, 'For Saz'],
    [/Qamış dilçək/gi, 'Reed for Balaban'],
    [/Balaban qamışı/gi, 'Balaban Reed'],
    [/Gitara üçün çexol/gi, 'Guitar Gig Bag'],
    [/Gitara çexolu/gi, 'Guitar Case'],
    [/Gitara kəməri/gi, 'Guitar Strap'],
    [/Gitara simi/gi, 'Guitar String'],
    [/Gitara simləri/gi, 'Guitar Strings'],
    [/Klassik gitara/gi, 'Classical Guitar'],
    [/Akustik gitara/gi, 'Acoustic Guitar'],
    [/Elektro gitara/gi, 'Electric Guitar'],
    [/Bas gitara/gi, 'Bass Guitar'],
    [/Skripka üçün/gi, 'For Violin'],
    [/Skripka simi/gi, 'Violin String'],
    [/Skripka simləri/gi, 'Violin Strings'],
    [/Skripka körpücüyü/gi, 'Violin Shoulder Rest'],
    [/Skripka futlyarı/gi, 'Violin Case'],
    [/Qara/gi, 'Black'],
    [/Ağ/gi, 'White'],
    [/Boz/gi, 'Grey'],
    [/Qəhvəyi/gi, 'Brown'],
    [/Qırmızı/gi, 'Red'],
    [/Mavi/gi, 'Blue'],
    [/Plastik/gi, 'Plastic'],
    [/Ağac/gi, 'Wooden'],
    [/Dəst/gi, 'Set'],
    [/ədəd/gi, 'pcs']
  ];

  map.forEach(([rgx, repl]) => {
    en = en.replace(rgx, repl);
  });
  return en;
}

const sqlLines = [
  '-- ====================================================================',
  '-- Rast Music Shop: Catalog Replacement with Authentic BirMarket Stock',
  `-- Total Products: ${products.length} (Merchant 4880: Rast Musiqi Alətləri)`,
  '-- ====================================================================',
  '',
  'BEGIN;',
  '',
  '-- 1. Remove legacy / demo items from products table',
  'DELETE FROM public.products;',
  '',
  '-- 2. Insert live BirMarket merchant inventory',
  'INSERT INTO public.products (',
  '  id,',
  '  sku,',
  '  barcode,',
  '  name,',
  '  name_ru,',
  '  name_en,',
  '  price,',
  '  old_price,',
  '  brand,',
  '  category_slug,',
  '  subcategory_slug,',
  '  image,',
  '  images,',
  '  description,',
  '  description_ru,',
  '  description_en,',
  '  slug,',
  '  stock_status,',
  '  condition,',
  '  is_archived',
  ') VALUES'
];

const valueRows = products.map((p, idx) => {
  const isLast = idx === products.length - 1;
  const nameEn = toEnglish(p.name, p.name_ru);
  const descEn = p.description ? `${nameEn}. Genuine music store product.` : null;

  return `  (${escapeSql(p.id)}, ${escapeSql(p.sku)}, ${escapeSql(p.barcode)}, ${escapeSql(p.name)}, ${escapeSql(p.name_ru)}, ${escapeSql(nameEn)}, ${p.price}, NULL, ${escapeSql(p.brand)}, ${escapeSql(p.category_slug)}, ${escapeSql(p.subcategory_slug)}, ${escapeSql(p.image)}, ${escapeJson(p.images)}, ${escapeSql(p.description)}, ${escapeSql(p.description_ru)}, ${escapeSql(descEn)}, ${escapeSql(p.slug)}, 'in_stock', 'new', false)${isLast ? '' : ','}`;
});

sqlLines.push(valueRows.join('\n'));
sqlLines.push('ON CONFLICT (id) DO UPDATE SET');
sqlLines.push('  name = EXCLUDED.name,');
sqlLines.push('  name_ru = EXCLUDED.name_ru,');
sqlLines.push('  name_en = EXCLUDED.name_en,');
sqlLines.push('  price = EXCLUDED.price,');
sqlLines.push('  brand = EXCLUDED.brand,');
sqlLines.push('  category_slug = EXCLUDED.category_slug,');
sqlLines.push('  subcategory_slug = EXCLUDED.subcategory_slug,');
sqlLines.push('  image = EXCLUDED.image,');
sqlLines.push('  images = EXCLUDED.images,');
sqlLines.push('  description = EXCLUDED.description,');
sqlLines.push('  description_ru = EXCLUDED.description_ru,');
sqlLines.push('  description_en = EXCLUDED.description_en,');
sqlLines.push('  stock_status = EXCLUDED.stock_status,');
sqlLines.push('  is_archived = false;');
sqlLines.push('');
sqlLines.push('COMMIT;');

const outPath = 'supabase/migrations/20261102_replace_with_birmarket_catalog.sql';
fs.writeFileSync(outPath, sqlLines.join('\n'), 'utf8');
const sizeKb = (fs.statSync(outPath).size / 1024).toFixed(1);
console.log(`✓ Migration successfully written to ${outPath} (${sizeKb} KB) with ${products.length} products.`);
