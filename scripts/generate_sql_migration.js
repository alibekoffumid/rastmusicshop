import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { CATEGORY_TAXONOMY, FORBIDDEN_RULES } from '../src/data/categoryTaxonomy.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

function escapeSql(str) {
  if (!str) return 'NULL';
  return `'${String(str).replace(/'/g, "''")}'`;
}

function generateMigrationSql() {
  const lines = [];

  lines.push(`-- ====================================================================`);
  lines.push(`-- MIGRATION: Multilingual Category Architecture & Clean Taxonomy Seed`);
  lines.push(`-- Project: Rast Music Shop (rastmusicshop.az / rastmusicshop.com)`);
  lines.push(`-- Languages: AZ (default), RU, EN`);
  lines.push(`-- ====================================================================`);
  lines.push(``);
  lines.push(`BEGIN;`);
  lines.push(``);

  // 1. Schema Alterations
  lines.push(`-- 1. Ensure localized and ordering columns exist`);
  lines.push(`ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS name_az TEXT;`);
  lines.push(`ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS name_ru TEXT;`);
  lines.push(`ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS name_en TEXT;`);
  lines.push(`ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS order_index INTEGER DEFAULT 0;`);
  lines.push(``);

  lines.push(`-- 2. Ensure unique constraint on slug`);
  lines.push(`DO $$`);
  lines.push(`BEGIN`);
  lines.push(`  IF NOT EXISTS (`);
  lines.push(`    SELECT 1 FROM pg_constraint WHERE conname = 'categories_slug_unique'`);
  lines.push(`  ) THEN`);
  lines.push(`    ALTER TABLE public.categories ADD CONSTRAINT categories_slug_unique UNIQUE (slug);`);
  lines.push(`  END IF;`);
  lines.push(`END $$;`);
  lines.push(``);

  // 2. Level 1 - Root Categories
  lines.push(`-- 3. Idempotent Upsert: Root Categories (Level 1)`);
  for (const root of CATEGORY_TAXONOMY) {
    const slug = escapeSql(root.slug);
    const name = escapeSql(root.name.az);
    const nameAz = escapeSql(root.name.az);
    const nameRu = escapeSql(root.name.ru);
    const nameEn = escapeSql(root.name.en);
    const orderIdx = root.order_index || 0;

    lines.push(`INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)`);
    lines.push(`VALUES (${slug}, ${name}, ${nameAz}, ${nameRu}, ${nameEn}, NULL, ${orderIdx}, false)`);
    lines.push(`ON CONFLICT (slug) DO UPDATE SET`);
    lines.push(`  name = EXCLUDED.name,`);
    lines.push(`  name_az = EXCLUDED.name_az,`);
    lines.push(`  name_ru = EXCLUDED.name_ru,`);
    lines.push(`  name_en = EXCLUDED.name_en,`);
    lines.push(`  parent_id = NULL,`);
    lines.push(`  order_index = EXCLUDED.order_index,`);
    lines.push(`  is_archived = false;`);
    lines.push(``);
  }

  // 3. Level 2 - Subcategories
  lines.push(`-- 4. Idempotent Upsert: Subcategories (Level 2)`);
  for (const root of CATEGORY_TAXONOMY) {
    if (!root.children || root.children.length === 0) continue;
    lines.push(`-- Subcategories of ${root.slug}`);
    let subIdx = 1;
    for (const sub of root.children) {
      const slug = escapeSql(sub.slug);
      const name = escapeSql(sub.name.az);
      const nameAz = escapeSql(sub.name.az);
      const nameRu = escapeSql(sub.name.ru);
      const nameEn = escapeSql(sub.name.en);
      const rootSlug = escapeSql(root.slug);

      lines.push(`INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)`);
      lines.push(`VALUES (${slug}, ${name}, ${nameAz}, ${nameRu}, ${nameEn}, (SELECT id FROM public.categories WHERE slug = ${rootSlug} LIMIT 1), ${subIdx++}, false)`);
      lines.push(`ON CONFLICT (slug) DO UPDATE SET`);
      lines.push(`  name = EXCLUDED.name,`);
      lines.push(`  name_az = EXCLUDED.name_az,`);
      lines.push(`  name_ru = EXCLUDED.name_ru,`);
      lines.push(`  name_en = EXCLUDED.name_en,`);
      lines.push(`  parent_id = (SELECT id FROM public.categories WHERE slug = ${rootSlug} LIMIT 1),`);
      lines.push(`  order_index = EXCLUDED.order_index,`);
      lines.push(`  is_archived = false;`);
      lines.push(``);
    }
  }

  // 4. Level 3 - Sub-subcategories
  lines.push(`-- 5. Idempotent Upsert: Sub-subcategories (Level 3)`);
  for (const root of CATEGORY_TAXONOMY) {
    if (!root.children) continue;
    for (const sub of root.children) {
      if (!sub.children || sub.children.length === 0) continue;
      lines.push(`-- Children of ${sub.slug} (parent: ${root.slug})`);
      let subSubIdx = 1;
      for (const child of sub.children) {
        const slug = escapeSql(child.slug);
        const name = escapeSql(child.name.az);
        const nameAz = escapeSql(child.name.az);
        const nameRu = escapeSql(child.name.ru);
        const nameEn = escapeSql(child.name.en);
        const subSlug = escapeSql(sub.slug);

        lines.push(`INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)`);
        lines.push(`VALUES (${slug}, ${name}, ${nameAz}, ${nameRu}, ${nameEn}, (SELECT id FROM public.categories WHERE slug = ${subSlug} LIMIT 1), ${subSubIdx++}, false)`);
        lines.push(`ON CONFLICT (slug) DO UPDATE SET`);
        lines.push(`  name = EXCLUDED.name,`);
        lines.push(`  name_az = EXCLUDED.name_az,`);
        lines.push(`  name_ru = EXCLUDED.name_ru,`);
        lines.push(`  name_en = EXCLUDED.name_en,`);
        lines.push(`  parent_id = (SELECT id FROM public.categories WHERE slug = ${subSlug} LIMIT 1),`);
        lines.push(`  order_index = EXCLUDED.order_index,`);
        lines.push(`  is_archived = false;`);
        lines.push(``);
      }
    }
  }

  // 5. Product Migration & Cleaning (Safe now because all canonical category slugs exist in categories table)
  lines.push(`-- 6. Strict Cleaning & Product Slug Migration`);
  lines.push(`-- Unlink polluted subcategories from products`);
  lines.push(`UPDATE public.products SET subcategory_slug = NULL WHERE subcategory_slug ~* '(teymur|bəxtiyar|sahib|fərhad|fərrux|rövşən|tahir|4/4|3/4|1/2|1/4|qoz|fıstıq|ebonit|dominguez|korg|miles)';`);
  lines.push(``);

  lines.push(`-- 6.1 Migrate legacy category slugs in products to canonical Azerbaijani slugs`);
  lines.push(`UPDATE public.products SET category_slug = 'gitaralar' WHERE category_slug IN ('guitars', 'gitara', 'guitar');`);
  lines.push(`UPDATE public.products SET category_slug = 'pianolar-ve-klavisler' WHERE category_slug IN ('keys', 'pianos', 'keyboards');`);
  lines.push(`UPDATE public.products SET category_slug = 'yayli-aletler' WHERE category_slug IN ('bowed', 'string-instruments', 'strings');`);
  lines.push(`UPDATE public.products SET category_slug = 'nefes-aletleri' WHERE category_slug IN ('wind-instruments', 'winds');`);
  lines.push(`UPDATE public.products SET category_slug = 'zerb-aletleri' WHERE category_slug IN ('percussion', 'drums');`);
  lines.push(`UPDATE public.products SET category_slug = 'milli-musiqi-aletleri' WHERE category_slug IN ('national-instruments', 'national');`);
  lines.push(`UPDATE public.products SET category_slug = 'audio-ve-studia' WHERE category_slug IN ('audio-equipment', 'audio', 'studio');`);
  lines.push(`UPDATE public.products SET category_slug = 'kabeller-dayaqlar-aksesuarlar' WHERE category_slug IN ('accessories');`);
  lines.push(``);

  lines.push(`-- 6.2 Migrate legacy subcategory slugs in products to canonical Azerbaijani slugs`);
  lines.push(`UPDATE public.products SET subcategory_slug = 'klassik-gitaralar' WHERE subcategory_slug IN ('classical-guitars', 'klassik');`);
  lines.push(`UPDATE public.products SET subcategory_slug = 'akustik-gitaralar' WHERE subcategory_slug IN ('acoustic-guitars', 'akustik');`);
  lines.push(`UPDATE public.products SET subcategory_slug = 'elektro-gitaralar' WHERE subcategory_slug IN ('electric-guitars');`);
  lines.push(`UPDATE public.products SET subcategory_slug = 'bas-gitaralar' WHERE subcategory_slug IN ('bass-guitars');`);
  lines.push(`UPDATE public.products SET subcategory_slug = 'elektro-klassik-eq' WHERE subcategory_slug IN ('electro-classical-guitars');`);
  lines.push(`UPDATE public.products SET subcategory_slug = 'elektro-akustik-eq' WHERE subcategory_slug IN ('electro-acoustic-guitars');`);
  lines.push(`UPDATE public.products SET subcategory_slug = 'elektron-pianolar' WHERE subcategory_slug IN ('digital-pianos');`);
  lines.push(`UPDATE public.products SET subcategory_slug = 'sintezatorlar' WHERE subcategory_slug IN ('synthesizers');`);
  lines.push(`UPDATE public.products SET subcategory_slug = 'skripkalar' WHERE subcategory_slug IN ('violins');`);
  lines.push(`UPDATE public.products SET subcategory_slug = 'cello' WHERE subcategory_slug IN ('cellos');`);
  lines.push(`UPDATE public.products SET subcategory_slug = 'kontrabas' WHERE subcategory_slug IN ('double-basses');`);
  lines.push(`UPDATE public.products SET subcategory_slug = 'elektron-barabanlar' WHERE subcategory_slug IN ('electronic-drums');`);
  lines.push(`UPDATE public.products SET subcategory_slug = 'ses-kabelleri' WHERE subcategory_slug IN ('cables');`);
  lines.push(`UPDATE public.products SET subcategory_slug = 'piano-oturacaqlari' WHERE subcategory_slug IN ('piano-benches');`);
  lines.push(`UPDATE public.products SET subcategory_slug = 'studiya-qulaqliqlari' WHERE subcategory_slug IN ('headphones');`);
  lines.push(`UPDATE public.products SET subcategory_slug = 'adapterler-batareyalar' WHERE subcategory_slug IN ('adapters', 'powerbanks');`);
  lines.push(``);

  lines.push(`-- 6.3 Archive polluted/forbidden categories in categories table`);
  lines.push(`UPDATE public.categories SET is_archived = true WHERE slug ~* '(teymur|bəxtiyar|sahib|fərhad|fərrux|rövşən|tahir|4-4|3-4|1-2|1-4|qoz|fistiq|ebonit|dominguez|korg|miles)';`);
  lines.push(``);

  // 6. Security and RLS
  lines.push(`-- 7. RLS Configuration: Ensure Public SELECT is enabled`);
  lines.push(`ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;`);
  lines.push(`DROP POLICY IF EXISTS "Public can view active categories" ON public.categories;`);
  lines.push(`CREATE POLICY "Public can view active categories" ON public.categories`);
  lines.push(`  FOR SELECT USING (is_archived = false OR is_archived IS NULL);`);
  lines.push(``);
  lines.push(`COMMIT;`);

  return lines.join('\n');
}

const outDir = path.join(__dirname, '..', 'supabase', 'migrations');
if (!fs.existsSync(outDir)) {
  fs.mkdirSync(outDir, { recursive: true });
}

const sqlContent = generateMigrationSql();
const outFile = path.join(outDir, '20261031_multilingual_categories.sql');
fs.writeFileSync(outFile, sqlContent, 'utf-8');
console.log('Successfully generated SQL migration at:', outFile);
