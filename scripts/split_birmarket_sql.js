import fs from 'fs';
import path from 'path';

const products = JSON.parse(fs.readFileSync('scripts/data/birmarket_ready_products.json', 'utf8'));

function escapeSql(val) {
  if (val === null || val === undefined) return 'NULL';
  return `'${String(val).replace(/'/g, "''")}'`;
}

function escapeJson(val) {
  if (!val) return "'[]'::jsonb";
  return `'${JSON.stringify(val).replace(/'/g, "''")}'::jsonb`;
}

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
  map.forEach(([rgx, repl]) => { en = en.replace(rgx, repl); });
  return en;
}

const dir = 'supabase/migrations/birmarket_parts';
if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });

const PART_SIZE = 160;
const totalParts = Math.ceil(products.length / PART_SIZE);

for (let pIdx = 0; pIdx < totalParts; pIdx++) {
  const start = pIdx * PART_SIZE;
  const end = Math.min(start + PART_SIZE, products.length);
  const partProds = products.slice(start, end);
  const partNum = pIdx + 1;

  const lines = [
    `-- ====================================================================`,
    `-- BirMarket Catalog Part ${partNum} of ${totalParts} (Products ${start + 1} to ${end})`,
    `-- ====================================================================`,
    `BEGIN;`,
    ``
  ];

  if (partNum === 1) {
    lines.push(`-- Step 1: Clear old products table`);
    lines.push(`DELETE FROM public.products;`);
    lines.push(``);
  }

  lines.push(`INSERT INTO public.products (`);
  lines.push(`  id, sku, barcode, name, name_ru, name_en, price, old_price, brand, category_slug, subcategory_slug, image, images, description, description_ru, description_en, slug, stock_status, condition, is_archived`);
  lines.push(`) VALUES`);

  const valueRows = partProds.map((p, idx) => {
    const isLast = idx === partProds.length - 1;
    const nameEn = toEnglish(p.name, p.name_ru);
    const descEn = p.description ? `${nameEn}. Genuine music store product.` : null;
    return `  (${escapeSql(p.id)}, ${escapeSql(p.sku)}, ${escapeSql(p.barcode)}, ${escapeSql(p.name)}, ${escapeSql(p.name_ru)}, ${escapeSql(nameEn)}, ${p.price}, NULL, ${escapeSql(p.brand)}, ${escapeSql(p.category_slug)}, ${escapeSql(p.subcategory_slug)}, ${escapeSql(p.image)}, ${escapeJson(p.images)}, ${escapeSql(p.description)}, ${escapeSql(p.description_ru)}, ${escapeSql(descEn)}, ${escapeSql(p.slug)}, 'in_stock', 'new', false)${isLast ? '' : ','}`;
  });

  lines.push(valueRows.join('\n'));
  lines.push(`ON CONFLICT (id) DO UPDATE SET`);
  lines.push(`  name = EXCLUDED.name,`);
  lines.push(`  name_ru = EXCLUDED.name_ru,`);
  lines.push(`  name_en = EXCLUDED.name_en,`);
  lines.push(`  price = EXCLUDED.price,`);
  lines.push(`  brand = EXCLUDED.brand,`);
  lines.push(`  category_slug = EXCLUDED.category_slug,`);
  lines.push(`  subcategory_slug = EXCLUDED.subcategory_slug,`);
  lines.push(`  image = EXCLUDED.image,`);
  lines.push(`  images = EXCLUDED.images,`);
  lines.push(`  description = EXCLUDED.description,`);
  lines.push(`  description_ru = EXCLUDED.description_ru,`);
  lines.push(`  description_en = EXCLUDED.description_en,`);
  lines.push(`  stock_status = EXCLUDED.stock_status,`);
  lines.push(`  is_archived = false;`);
  lines.push(``);
  lines.push(`COMMIT;`);

  const filePath = path.join(dir, `part${partNum}_of_${totalParts}.sql`);
  fs.writeFileSync(filePath, lines.join('\n'), 'utf8');
  const sizeKb = (fs.statSync(filePath).size / 1024).toFixed(1);
  console.log(`✓ Generated ${filePath} (${sizeKb} KB) [${partProds.length} products]`);
}
