import { createClient } from '@supabase/supabase-js';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { CATEGORY_TAXONOMY, FORBIDDEN_RULES } from '../src/data/categoryTaxonomy.js';
import { validateTaxonomySanitization } from '../src/utils/categoryHelper.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Read .env if present
const envPath = path.join(__dirname, '..', '.env');
if (fs.existsSync(envPath)) {
  const envContent = fs.readFileSync(envPath, 'utf-8');
  for (const line of envContent.split('\n')) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const [key, ...values] = trimmed.split('=');
    if (key && values.length > 0) {
      const val = values.join('=').trim().replace(/^["']|["']$/g, '');
      if (!process.env[key.trim()]) {
        process.env[key.trim()] = val;
      }
    }
  }
}

const SUPABASE_URL = process.env.SUPABASE_URL || process.env.VITE_SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_KEY || process.env.VITE_SUPABASE_ANON_KEY;

if (!SUPABASE_URL || !SUPABASE_KEY) {
  console.error('❌ Error: Missing Supabase URL or Key in environment variables or .env file.');
  process.exit(1);
}

const isServiceRole = !!(process.env.SUPABASE_SERVICE_ROLE_KEY);
const supabase = createClient(SUPABASE_URL, SUPABASE_KEY, {
  auth: { persistSession: false }
});

async function seedCategories() {
  console.log('====================================================');
  console.log('🚀 Rast Music Shop - Category Seeding & Sync Script');
  console.log('Languages: Azerbaijani (az), Russian (ru), English (en)');
  console.log('====================================================\n');

  // Step 1: Validate Taxonomy Sanitization
  console.log('🔍 [1/4] Validating taxonomy against strict sanitization rules...');
  const validation = validateTaxonomySanitization();
  if (!validation.isValid) {
    console.error('❌ Sanitization check failed! Found forbidden keywords in taxonomy:');
    console.table(validation.violations);
    process.exit(1);
  }
  console.log('✅ Taxonomy validation passed: 0 forbidden keywords found.\n');

  // Step 2: Prepare hierarchical data
  console.log('📦 [2/4] Preparing hierarchical records...');
  const level1 = [];
  const level2 = [];
  const level3 = [];

  for (const root of CATEGORY_TAXONOMY) {
    level1.push({
      slug: root.slug,
      name: root.name.az,
      name_az: root.name.az,
      name_ru: root.name.ru,
      name_en: root.name.en,
      order_index: root.order_index || 0,
      is_archived: false
    });

    if (root.children) {
      let subIdx = 1;
      for (const sub of root.children) {
        level2.push({
          parentSlug: root.slug,
          slug: sub.slug,
          name: sub.name.az,
          name_az: sub.name.az,
          name_ru: sub.name.ru,
          name_en: sub.name.en,
          order_index: subIdx++,
          is_archived: false
        });

        if (sub.children) {
          let subSubIdx = 1;
          for (const child of sub.children) {
            level3.push({
              parentSlug: sub.slug,
              slug: child.slug,
              name: child.name.az,
              name_az: child.name.az,
              name_ru: child.name.ru,
              name_en: child.name.en,
              order_index: subSubIdx++,
              is_archived: false
            });
          }
        }
      }
    }
  }

  console.log(`Total nodes ready: ${level1.length} root, ${level2.length} subcategories, ${level3.length} sub-subcategories (Total: ${level1.length + level2.length + level3.length})\n`);

  // Step 3: Upsert into database
  console.log('⚡ [3/4] Executing idempotent upserts in database...');

  try {
    // 3.1 Upsert Level 1
    console.log(`- Upserting ${level1.length} Root Categories...`);
    const { data: rootData, error: rootErr } = await supabase
      .from('categories')
      .upsert(level1, { onConflict: 'slug' })
      .select('id, slug');

    if (rootErr) {
      if (rootErr.code === '42501' || rootErr.message?.includes('row-level security')) {
        console.warn('\n⚠️  RLS Access Restriction Notice:');
        console.warn('The current Supabase key does not have write permissions due to Row-Level Security.');
        console.warn('To apply the category migration directly to Supabase, please execute the SQL migration:');
        console.warn('📁 File: supabase/migrations/20261031_multilingual_categories.sql');
        console.warn('Or supply SUPABASE_SERVICE_ROLE_KEY in your .env or environment.\n');
        return;
      }
      throw rootErr;
    }

    // Map parent slugs to IDs
    const slugToIdMap = new Map();
    const { data: allCategories, error: fetchErr } = await supabase
      .from('categories')
      .select('id, slug');

    if (fetchErr) throw fetchErr;
    allCategories.forEach(c => slugToIdMap.set(c.slug, c.id));

    // 3.2 Upsert Level 2
    console.log(`- Upserting ${level2.length} Subcategories (Level 2)...`);
    const preparedLevel2 = level2.map(item => ({
      slug: item.slug,
      name: item.name,
      name_az: item.name_az,
      name_ru: item.name_ru,
      name_en: item.name_en,
      order_index: item.order_index,
      parent_id: slugToIdMap.get(item.parentSlug) || null,
      is_archived: false
    }));

    const { error: subErr } = await supabase
      .from('categories')
      .upsert(preparedLevel2, { onConflict: 'slug' });
    if (subErr) throw subErr;

    // Refresh slug map for level 3
    const { data: refreshedCategories, error: refreshErr } = await supabase
      .from('categories')
      .select('id, slug');
    if (refreshErr) throw refreshErr;
    refreshedCategories.forEach(c => slugToIdMap.set(c.slug, c.id));

    // 3.3 Upsert Level 3
    console.log(`- Upserting ${level3.length} Sub-subcategories (Level 3)...`);
    const preparedLevel3 = level3.map(item => ({
      slug: item.slug,
      name: item.name,
      name_az: item.name_az,
      name_ru: item.name_ru,
      name_en: item.name_en,
      order_index: item.order_index,
      parent_id: slugToIdMap.get(item.parentSlug) || null,
      is_archived: false
    }));

    const { error: childErr } = await supabase
      .from('categories')
      .upsert(preparedLevel3, { onConflict: 'slug' });
    if (childErr) throw childErr;

    console.log('\n✨ [4/4] Category Database Seeding Completed Successfully!');
  } catch (err) {
    console.error('❌ Error during database seeding:', err.message || err);
    console.error('If the categories table is missing multilingual columns, execute:');
    console.error('📁 supabase/migrations/20261031_multilingual_categories.sql');
  }
}

seedCategories();
