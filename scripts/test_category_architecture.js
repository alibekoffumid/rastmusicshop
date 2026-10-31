import assert from 'assert';
import { CATEGORY_TAXONOMY, FORBIDDEN_RULES, SLUG_LEGACY_ALIASES } from '../src/data/categoryTaxonomy.js';
import {
  normalizeCategorySlug,
  getCategoryBySlug,
  getCategoryName,
  getParentCategory,
  getSubcategories,
  getRootCategories,
  getCategoryBreadcrumbs,
  validateTaxonomySanitization
} from '../src/utils/categoryHelper.js';

console.log('====================================================');
console.log('🧪 RUNNING CATEGORY ARCHITECTURE TEST SUITE');
console.log('====================================================\n');

let passedTests = 0;
let totalTests = 0;

function it(desc, fn) {
  totalTests++;
  try {
    fn();
    console.log(`  ✅ PASS: ${desc}`);
    passedTests++;
  } catch (err) {
    console.error(`  ❌ FAIL: ${desc}`);
    console.error(`     ${err.message}`);
  }
}

// ---------------------------------------------------------
// 1. Strict Cleaning & Sanitization Rules
// ---------------------------------------------------------
console.log('--- 1. Strict Cleaning & Sanitization Rules ---');

it('No categories contain artisan/master names (Teymur, Bəxtiyar, Sahib, etc.)', () => {
  const result = validateTaxonomySanitization();
  const artisanViolations = result.violations.filter(v => v.rule === 'artisans');
  assert.strictEqual(artisanViolations.length, 0, `Found artisan violations: ${JSON.stringify(artisanViolations)}`);
});

it('No categories contain instrument sizes (4/4, 3/4, 1/2, 5 oktava, etc.)', () => {
  const result = validateTaxonomySanitization();
  const sizeViolations = result.violations.filter(v => v.rule === 'sizes');
  assert.strictEqual(sizeViolations.length, 0, `Found size violations: ${JSON.stringify(sizeViolations)}`);
});

it('No categories contain brand names (Dominguez, Korg, Vandoren, etc.)', () => {
  const result = validateTaxonomySanitization();
  const brandViolations = result.violations.filter(v => v.rule === 'brands');
  assert.strictEqual(brandViolations.length, 0, `Found brand violations: ${JSON.stringify(brandViolations)}`);
});

it('No categories contain raw materials (Qoz, Fıstıq, Ebonit, etc.)', () => {
  const result = validateTaxonomySanitization();
  const materialViolations = result.violations.filter(v => v.rule === 'materials');
  assert.strictEqual(materialViolations.length, 0, `Found material violations: ${JSON.stringify(materialViolations)}`);
});

it('Total taxonomy sanitization validation returns 0 violations', () => {
  const result = validateTaxonomySanitization();
  assert.strictEqual(result.isValid, true);
  assert.strictEqual(result.violations.length, 0);
});

// ---------------------------------------------------------
// 2. Hierarchy & Dataset Completeness
// ---------------------------------------------------------
console.log('\n--- 2. Hierarchy & Dataset Completeness ---');

it('Root categories count is exactly 8', () => {
  const roots = getRootCategories();
  assert.strictEqual(roots.length, 8);
});

it('Root categories match specified slugs and order', () => {
  const expectedSlugs = [
    'gitaralar',
    'milli-musiqi-aletleri',
    'pianolar-ve-klavisler',
    'yayli-aletler',
    'nefes-aletleri',
    'zerb-aletleri',
    'audio-ve-studia',
    'kabeller-dayaqlar-aksesuarlar'
  ];
  const roots = getRootCategories();
  expectedSlugs.forEach((slug, idx) => {
    assert.strictEqual(roots[idx].slug, slug);
    assert.strictEqual(roots[idx].order_index, idx + 1);
  });
});

it('Every category node in taxonomy has valid slug and trilingual names (az, ru, en)', () => {
  let count = 0;
  function traverse(node) {
    count++;
    assert(typeof node.slug === 'string' && node.slug.length > 0, `Invalid slug on node: ${JSON.stringify(node)}`);
    assert(/^[a-z0-9-]+$/.test(node.slug), `Slug '${node.slug}' is not kebab-case`);
    assert(node.name && typeof node.name === 'object', `Node ${node.slug} missing name object`);
    assert(typeof node.name.az === 'string' && node.name.az.length > 0, `Node ${node.slug} missing az name`);
    assert(typeof node.name.ru === 'string' && node.name.ru.length > 0, `Node ${node.slug} missing ru name`);
    assert(typeof node.name.en === 'string' && node.name.en.length > 0, `Node ${node.slug} missing en name`);

    if (node.children) {
      node.children.forEach(traverse);
    }
  }

  CATEGORY_TAXONOMY.forEach(traverse);
  // Total nodes in seed dataset is 134 (8 L1 root + 52 L2 sub + 74 L3 sub-sub)
  assert.strictEqual(count, 134, `Expected 134 total category nodes, found ${count}`);
});


// ---------------------------------------------------------
// 3. Routing, Legacy Aliases & Normalization
// ---------------------------------------------------------
console.log('\n--- 3. Routing & Legacy Normalization ---');

it('Legacy English slugs correctly normalize to canonical Azerbaijani slugs', () => {
  assert.strictEqual(normalizeCategorySlug('guitars'), 'gitaralar');
  assert.strictEqual(normalizeCategorySlug('keys'), 'pianolar-ve-klavisler');
  assert.strictEqual(normalizeCategorySlug('bowed'), 'yayli-aletler');
  assert.strictEqual(normalizeCategorySlug('wind-instruments'), 'nefes-aletleri');
  assert.strictEqual(normalizeCategorySlug('percussion'), 'zerb-aletleri');
  assert.strictEqual(normalizeCategorySlug('national-instruments'), 'milli-musiqi-aletleri');
  assert.strictEqual(normalizeCategorySlug('audio-equipment'), 'audio-ve-studia');
  assert.strictEqual(normalizeCategorySlug('accessories'), 'kabeller-dayaqlar-aksesuarlar');
  // Subcategory legacy aliases
  assert.strictEqual(normalizeCategorySlug('classical-guitars'), 'klassik-gitaralar');
  assert.strictEqual(normalizeCategorySlug('digital-pianos'), 'elektron-pianolar');
  assert.strictEqual(normalizeCategorySlug('violins'), 'skripkalar');
  assert.strictEqual(normalizeCategorySlug('acoustic-drums'), 'akustik-barabanlar');
});

it('getCategoryBySlug resolves both canonical and legacy slugs (root and subcategories)', () => {
  const fromCanonical = getCategoryBySlug('gitaralar');
  const fromLegacy = getCategoryBySlug('guitars');
  assert.ok(fromCanonical);
  assert.strictEqual(fromCanonical.slug, 'gitaralar');
  assert.strictEqual(fromCanonical, fromLegacy);

  const subCanonical = getCategoryBySlug('klassik-gitaralar');
  const subLegacy = getCategoryBySlug('classical-guitars');
  assert.ok(subCanonical);
  assert.strictEqual(subCanonical.slug, 'klassik-gitaralar');
  assert.strictEqual(subCanonical, subLegacy);
});

it('getParentCategory resolves parent relationships correctly', () => {
  const parentOfClassic = getParentCategory('klassik-gitaralar');
  assert.ok(parentOfClassic);
  assert.strictEqual(parentOfClassic.slug, 'gitaralar');

  const parentOfStandart = getParentCategory('standart-klassik');
  assert.ok(parentOfStandart);
  assert.strictEqual(parentOfStandart.slug, 'klassik-gitaralar');
});

// ---------------------------------------------------------
// 4. Multilingual Resolution & Breadcrumbs
// ---------------------------------------------------------
console.log('\n--- 4. Multilingual Resolution & Breadcrumbs ---');

it('getCategoryName resolves correct locale labels', () => {
  const node = getCategoryBySlug('gitaralar');
  assert.strictEqual(getCategoryName(node, 'az'), 'Gitaralar');
  assert.strictEqual(getCategoryName(node, 'ru'), 'Гитары');
  assert.strictEqual(getCategoryName(node, 'en'), 'Guitars');

  const subNode = getCategoryBySlug('klassik-gitaralar');
  assert.strictEqual(getCategoryName(subNode, 'az'), 'Klassik gitaralar');
  assert.strictEqual(getCategoryName(subNode, 'ru'), 'Классические гитары');
  assert.strictEqual(getCategoryName(subNode, 'en'), 'Classical Guitars');
});

it('Breadcrumbs resolve dynamically per locale (AZ)', () => {
  const bc = getCategoryBreadcrumbs({
    categorySlug: 'gitaralar',
    subcategorySlug: 'klassik-gitaralar',
    subSubcategorySlug: 'standart-klassik',
    locale: 'az'
  });

  assert.strictEqual(bc.length, 4);
  assert.strictEqual(bc[0].label, 'Ana səhifə');
  assert.strictEqual(bc[0].url, '/');
  assert.strictEqual(bc[1].label, 'Gitaralar');
  assert.strictEqual(bc[1].url, '/category/gitaralar');
  assert.strictEqual(bc[2].label, 'Klassik gitaralar');
  assert.strictEqual(bc[2].url, '/category/gitaralar/klassik-gitaralar');
  assert.strictEqual(bc[3].label, 'Standart klassik gitaralar');
  assert.strictEqual(bc[3].url, '/category/gitaralar/klassik-gitaralar/standart-klassik');
  assert.strictEqual(bc[3].isCurrent, true);
});

it('Breadcrumbs resolve dynamically per locale (RU)', () => {
  const bc = getCategoryBreadcrumbs({
    categorySlug: 'gitaralar',
    subcategorySlug: 'klassik-gitaralar',
    subSubcategorySlug: 'standart-klassik',
    locale: 'ru'
  });

  assert.strictEqual(bc.length, 4);
  assert.strictEqual(bc[0].label, 'Главная');
  assert.strictEqual(bc[1].label, 'Гитары');
  assert.strictEqual(bc[2].label, 'Классические гитары');
  assert.strictEqual(bc[3].label, 'Стандартные классические гитары');
  assert.strictEqual(bc[3].isCurrent, true);
});

it('Breadcrumbs resolve dynamically per locale (EN)', () => {
  const bc = getCategoryBreadcrumbs({
    categorySlug: 'gitaralar',
    subcategorySlug: 'klassik-gitaralar',
    subSubcategorySlug: 'standart-klassik',
    locale: 'en'
  });

  assert.strictEqual(bc.length, 4);
  assert.strictEqual(bc[0].label, 'Home');
  assert.strictEqual(bc[1].label, 'Guitars');
  assert.strictEqual(bc[2].label, 'Classical Guitars');
  assert.strictEqual(bc[3].label, 'Standard Classical Guitars');
  assert.strictEqual(bc[3].isCurrent, true);
});

it('Breadcrumbs correctly append Product item when provided', () => {
  const bc = getCategoryBreadcrumbs({
    categorySlug: 'gitaralar',
    subcategorySlug: 'klassik-gitaralar',
    locale: 'az',
    productName: 'Yamaha C40'
  });

  assert.strictEqual(bc.length, 4);
  assert.strictEqual(bc[3].label, 'Yamaha C40');
  assert.strictEqual(bc[3].url, null);
  assert.strictEqual(bc[3].isCurrent, true);
  assert.strictEqual(bc[2].isCurrent, false);
});

// ---------------------------------------------------------
// Summary
// ---------------------------------------------------------
console.log('\n====================================================');
console.log(`📊 Test Results: ${passedTests}/${totalTests} Passed (${Math.round((passedTests/totalTests)*100)}%)`);
console.log('====================================================\n');

if (passedTests !== totalTests) {
  process.exit(1);
}
