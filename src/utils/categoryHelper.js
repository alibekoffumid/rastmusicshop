import { CATEGORY_TAXONOMY, SLUG_LEGACY_ALIASES } from '../data/categoryTaxonomy.js';

// Flattened lookup map: slug -> node
const FLAT_CATEGORIES = new Map();
const PARENT_MAP = new Map();

function indexNodes(nodes, parent = null) {
  for (const node of nodes) {
    FLAT_CATEGORIES.set(node.slug, node);
    if (parent) {
      PARENT_MAP.set(node.slug, parent);
    }
    if (node.children && node.children.length > 0) {
      indexNodes(node.children, node);
    }
  }
}
indexNodes(CATEGORY_TAXONOMY);

/**
 * Normalizes any category slug, mapping legacy English slugs to canonical Azerbaijani slugs.
 */
export function normalizeCategorySlug(slug) {
  if (!slug) return '';
  const clean = String(slug).trim().toLowerCase();
  return SLUG_LEGACY_ALIASES[clean] || clean;
}

/**
 * Returns a category node by its slug (or legacy alias).
 */
export function getCategoryBySlug(slug) {
  if (!slug) return null;
  const canonical = normalizeCategorySlug(slug);
  return FLAT_CATEGORIES.get(canonical) || FLAT_CATEGORIES.get(slug) || null;
}

/**
 * Returns the localized name of a category for the active locale ('az', 'ru', 'en').
 */
export function getCategoryName(categoryOrSlug, locale = 'az') {
  if (!categoryOrSlug) return '';
  
  const node = typeof categoryOrSlug === 'string'
    ? getCategoryBySlug(categoryOrSlug)
    : categoryOrSlug;

  if (!node) {
    // If not found in taxonomy, format slug to title case as graceful fallback
    const slugStr = typeof categoryOrSlug === 'string' ? categoryOrSlug : (categoryOrSlug.slug || '');
    return slugStr
      .split('-')
      .map(w => w.charAt(0).toUpperCase() + w.slice(1))
      .join(' ');
  }

  // Handle object { az, ru, en } or flat columns name_az, name_ru, name_en, name
  const nameObj = node.name && typeof node.name === 'object' ? node.name : null;
  const l = (locale || 'az').toLowerCase();

  if (nameObj) {
    if (l === 'ru' && nameObj.ru) return nameObj.ru;
    if (l === 'en' && nameObj.en) return nameObj.en;
    return nameObj.az || nameObj.ru || nameObj.en || '';
  }

  if (l === 'ru' && node.name_ru) return node.name_ru;
  if (l === 'en' && node.name_en) return node.name_en;
  return node.name_az || node.name || '';
}

/**
 * Returns the parent category node of a given slug.
 */
export function getParentCategory(slug) {
  const canonical = normalizeCategorySlug(slug);
  return PARENT_MAP.get(canonical) || null;
}

/**
 * Returns immediate subcategories of a category.
 */
export function getSubcategories(slug) {
  const node = getCategoryBySlug(slug);
  return node?.children || [];
}

/**
 * Returns root categories ordered by order_index.
 */
export function getRootCategories() {
  return [...CATEGORY_TAXONOMY].sort((a, b) => (a.order_index || 0) - (b.order_index || 0));
}

/**
 * Generates dynamic, SEO-friendly multilingual breadcrumbs.
 * Formats:
 * - AZ: Ana səhifə > Kateqoriya > Alt kateqoriya > [Məhsul]
 * - RU: Главная > Категория > Подкатегория > [Товар]
 * - EN: Home > Category > Subcategory > [Product]
 */
export function getCategoryBreadcrumbs({ categorySlug, subcategorySlug, subSubcategorySlug, locale = 'az', productName } = {}) {
  const l = (locale || 'az').toLowerCase();

  const homeLabels = {
    az: 'Ana səhifə',
    ru: 'Главная',
    en: 'Home'
  };

  const breadcrumbs = [
    {
      label: homeLabels[l] || homeLabels.az,
      url: '/',
      isCurrent: !categorySlug
    }
  ];

  if (!categorySlug) return breadcrumbs;

  const canonicalRoot = normalizeCategorySlug(categorySlug);
  const rootNode = getCategoryBySlug(canonicalRoot);
  const rootName = getCategoryName(rootNode || categorySlug, l);

  breadcrumbs.push({
    label: rootName,
    url: `/category/${canonicalRoot}`,
    isCurrent: !subcategorySlug && !productName
  });

  if (subcategorySlug) {
    const subNode = getCategoryBySlug(subcategorySlug);
    const subName = getCategoryName(subNode || subcategorySlug, l);

    breadcrumbs.push({
      label: subName,
      url: `/category/${canonicalRoot}/${subcategorySlug}`,
      isCurrent: !subSubcategorySlug && !productName
    });
  }

  if (subSubcategorySlug) {
    const subSubNode = getCategoryBySlug(subSubcategorySlug);
    const subSubName = getCategoryName(subSubNode || subSubcategorySlug, l);

    breadcrumbs.push({
      label: subSubName,
      url: `/category/${canonicalRoot}/${subcategorySlug}/${subSubcategorySlug}`,
      isCurrent: !productName
    });
  }

  if (productName) {
    breadcrumbs.push({
      label: productName,
      url: null,
      isCurrent: true
    });
  }

  return breadcrumbs;
}

/**
 * Strict Sanitization Validator.
 * Asserts that no category contains prohibited artisan names, sizes, brands, or materials.
 */
export const FORBIDDEN_RULES = {
  artisans: ['teymur', 'bəxtiyar', 'baxtiyar', 'sahib', 'fərhad', 'farhad', 'fərrux', 'farrux', 'rövşən', 'rovsan', 'tahir'],
  sizes: ['4/4', '3/4', '1/2', '1/4', '4/3', '16/1', '8/1', '5 oktava', 'tam oktava'],
  brands: ['dominguez', 'vivaldi', 'korg', 'miles', 'vandoren', 'rico', 'helena mia', 'swing', 'rigotti', 'irin', 'kaysen'],
  materials: ['qoz', 'fıstıq', 'fistiq', 'ebonit', 'plastik', 'tekstolit', 'latun', 'dəmir', 'demir']
};

export function validateTaxonomySanitization() {
  const violations = [];

  function check(node) {
    const combinedText = [
      node.slug,
      node.name?.az || '',
      node.name?.ru || '',
      node.name?.en || ''
    ].join(' ').toLowerCase();

    for (const [ruleType, keywords] of Object.entries(FORBIDDEN_RULES)) {
      for (const kw of keywords) {
        // Word boundary regex
        const pattern = new RegExp(`(^|[^a-z0-9əğıöşüç])${kw}([^a-z0-9əğıöşüç]|$)`, 'i');
        if (pattern.test(combinedText)) {
          violations.push({
            slug: node.slug,
            rule: ruleType,
            forbiddenKeyword: kw
          });
        }
      }
    }

    if (node.children) {
      node.children.forEach(check);
    }
  }

  CATEGORY_TAXONOMY.forEach(check);
  return {
    isValid: violations.length === 0,
    violations
  };
}
