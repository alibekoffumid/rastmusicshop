import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const mainPath = path.join(__dirname, '..', 'src', 'main.jsx');

let code = fs.readFileSync(mainPath, 'utf-8');

// 1. Add imports at the very beginning
if (!code.includes("from './utils/categoryHelper.js'")) {
  code = code.replace(
    "import './index.css';",
    "import './index.css';\nimport { getCategoryBreadcrumbs, getCategoryName, normalizeCategorySlug } from './utils/categoryHelper.js';"
  );
  console.log('✅ Added categoryHelper imports');
}

// 2. Enhance Kf component:
// 2.1 Destructure i18n from st()
// Search for: {t:g}=st() in Kf
const kfMarker = 'Kf=()=>{';
const kfIdx = code.indexOf(kfMarker);
if (kfIdx !== -1) {
  const stMatch = ',{t:g}=st();';
  const nextStIdx = code.indexOf(stMatch, kfIdx);
  if (nextStIdx !== -1 && nextStIdx < kfIdx + 500) {
    code = code.slice(0, nextStIdx) + ',{t:g,i18n:kfI18n}=st();' + code.slice(nextStIdx + stMatch.length);
    console.log('✅ Updated st() in Kf to include i18n');
  }

  // 2.2 Update data fetching in Kf to query both original and canonical slugs
  const fetchPattern = 'let n=Q.from(`products`).select(`*`).eq(`category_slug`,e).eq(`is_archived`,!1);t&&(n=n.eq(`subcategory_slug`,t));';
  const fetchReplacement = 'let cCat=normalizeCategorySlug(e),catSlugs=Array.from(new Set([e,cCat].filter(Boolean))),n=Q.from(`products`).select(`*`).in(`category_slug`,catSlugs).eq(`is_archived`,!1);if(t){let cSub=normalizeCategorySlug(t),subSlugs=Array.from(new Set([t,cSub].filter(Boolean)));n=n.in(`subcategory_slug`,subSlugs)}';
  if (code.includes(fetchPattern)) {
    code = code.replace(fetchPattern, fetchReplacement);
    console.log('✅ Updated products query in Kf for canonical & legacy slugs');
  }

  // 2.3 Update category title resolution in Kf
  // Original: let v={guitars:`Gitaralar`,keys:`Klavişli Alətlər`,"audio-equipment":`Səs Avadanlıqları`,"wind-instruments":`Nəfəsli Alətlər`,percussion:`Zərb Alətləri`,bowed:`Yaylı Alətlər`,"national-instruments":`Milli Alətlər`,accessories:`Aksesuarlar`,blog:`Blog`},y=e&&v[e.toLowerCase()]?g(`header.menu.${e.toLowerCase()}`)||v[e.toLowerCase()]:e?e.split(`-`).map(e=>e.charAt(0).toUpperCase()+e.slice(1)).join(` `):`Kategoriya`
  const titleSearch = 'let v={guitars:`Gitaralar`';
  const titleStart = code.indexOf(titleSearch, kfIdx);
  if (titleStart !== -1) {
    const titleEnd = code.indexOf('),b=[...new Set', titleStart);
    if (titleEnd !== -1) {
      const origTitleChunk = code.slice(titleStart, titleEnd + 1);
      const newTitleChunk = 'let kfLang=(kfI18n?.language||`az`).toLowerCase(),y=(t?getCategoryName(t,kfLang):getCategoryName(e,kfLang))||(e?e.split(`-`).map(e=>e.charAt(0).toUpperCase()+e.slice(1)).join(` `):`Kategoriya`)';
      code = code.slice(0, titleStart) + newTitleChunk + code.slice(titleEnd + 1);
      console.log('✅ Updated category title resolution in Kf to trilingual');
    }
  }

  // 2.4 Update subcategory filter label helper S
  // Original: S=e=>{let t=g(`subcategories.${e}`);return t===`subcategories.${e}`?e.split(`-`).map(e=>e.charAt(0).toUpperCase()+e.slice(1)).join(` `):t}
  const sFilterPattern = 'S=e=>{let t=g(`subcategories.${e}`);return t===`subcategories.${e}`?e.split(`-`).map(e=>e.charAt(0).toUpperCase()+e.slice(1)).join(` `):t}';
  const sFilterReplacement = 'S=e=>{let l=(kfI18n?.language||`az`).toLowerCase(),name=getCategoryName(e,l);if(name)return name;let t=g(`subcategories.${e}`);return t===`subcategories.${e}`?e.split(`-`).map(e=>e.charAt(0).toUpperCase()+e.slice(1)).join(` `):t}';
  if (code.includes(sFilterPattern)) {
    code = code.replace(sFilterPattern, sFilterReplacement);
    console.log('✅ Updated subcategory filter labels in Kf');
  }

  // 2.5 Add breadcrumbs to Category Page (Kf)
  // Look for: return(0,L.jsxs)(`div`,{className:`category-page`,children:[(0,L.jsx)(If,{title:y,description:`${y} Rast Music-də. Sərfəli qiymət və rəsmi zəmanət.`,url:`/category/${e}`}),(0,L.jsxs)(`div`,{className:`container category-layout`
  const kfLayoutMarker = '(0,L.jsxs)(`div`,{className:`container category-layout`';
  if (code.includes(kfLayoutMarker)) {
    const breadcrumbSnippet = '(0,L.jsx)(`div`,{className:`container`,style:{paddingTop:`24px`,paddingBottom:`0px`},children:(0,L.jsxs)(`div`,{className:`breadcrumbs`,children:[(0,L.jsx)(N,{to:`/`,children:kfLang===`ru`?`Главная`:kfLang===`en`?`Home`:`Ana səhifə`}),` `,(0,L.jsx)(sa,{size:14}),t?(0,L.jsxs)(L.Fragment,{children:[(0,L.jsx)(N,{to:`/category/${normalizeCategorySlug(e)}`,children:getCategoryName(e,kfLang)}),` `,(0,L.jsx)(sa,{size:14}),(0,L.jsx)(`span`,{children:getCategoryName(t,kfLang)})]}):(0,L.jsx)(`span`,{children:getCategoryName(e,kfLang)})]})}),';
    code = code.replace(kfLayoutMarker, breadcrumbSnippet + kfLayoutMarker);
    console.log('✅ Added trilingual breadcrumbs to category page (Kf)');
  }
}

// 3. Enhance Gf (product details) breadcrumbs:
// Search for: (0,L.jsxs)(`div`,{className:`breadcrumbs`,children:[(0,L.jsx)(N,{to:`/`,children:E(`productDetail.home`)}),` `,(0,L.jsx)(sa,{size:14}),(0,L.jsx)(N,{to:`/category/${y.category_slug||`guitars`}`,children:y.category||`Category`}),` `,(0,L.jsx)(sa,{size:14}),(0,L.jsx)(`span`,{children:A})]
const gfBcPattern = '(0,L.jsxs)(`div`,{className:`breadcrumbs`,children:[(0,L.jsx)(N,{to:`/`,children:E(`productDetail.home`)}),` `,(0,L.jsx)(sa,{size:14}),(0,L.jsx)(N,{to:`/category/${y.category_slug||`guitars`}`,children:y.category||`Category`}),` `,(0,L.jsx)(sa,{size:14}),(0,L.jsx)(`span`,{children:A})]';
const gfBcReplacement = '(0,L.jsxs)(`div`,{className:`breadcrumbs`,children:[(0,L.jsx)(N,{to:`/`,children:E(`productDetail.home`)}),` `,(0,L.jsx)(sa,{size:14}),(0,L.jsx)(N,{to:`/category/${normalizeCategorySlug(y.category_slug)||`gitaralar`}`,children:getCategoryName(y.category_slug||`gitaralar`,k)||y.category||`Category`}),y.subcategory_slug?(0,L.jsxs)(L.Fragment,{children:[` `,(0,L.jsx)(sa,{size:14}),(0,L.jsx)(N,{to:`/category/${normalizeCategorySlug(y.category_slug)||`gitaralar`}/${normalizeCategorySlug(y.subcategory_slug)}`,children:getCategoryName(y.subcategory_slug,k)||y.subcategory_slug})]}):null,` `,(0,L.jsx)(sa,{size:14}),(0,L.jsx)(`span`,{children:A})]';
if (code.includes(gfBcPattern)) {
  code = code.replace(gfBcPattern, gfBcReplacement);
  console.log('✅ Enhanced product details breadcrumbs (Gf) with trilingual names and subcategories');
}

// 4. Update Header and Hero links to Canonical Slugs:
const replacements = [
  ['/category/guitars', '/category/gitaralar'],
  ['/category/keys', '/category/pianolar-ve-klavisler'],
  ['/category/bowed', '/category/yayli-aletler'],
  ['/category/wind-instruments', '/category/nefes-aletleri'],
  ['/category/percussion', '/category/zerb-aletleri'],
  ['/category/national-instruments', '/category/milli-musiqi-aletleri'],
  ['/category/audio-equipment', '/category/audio-ve-studia'],
  ['/category/accessories', '/category/kabeller-dayaqlar-aksesuarlar'],
  // Subcategory URLs in header
  ['/category/gitaralar/classical-guitars', '/category/gitaralar/klassik-gitaralar'],
  ['/category/gitaralar/acoustic-guitars', '/category/gitaralar/akustik-gitaralar'],
  ['/category/gitaralar/electric-guitars', '/category/gitaralar/elektro-gitaralar'],
  ['/category/gitaralar/bass-guitars', '/category/gitaralar/bas-gitaralar'],
  ['/category/gitaralar/soprano-ukulele', '/category/gitaralar/ukulele-ve-gitaralele'],
  ['/category/pianolar-ve-klavisler/digital-pianos', '/category/pianolar-ve-klavisler/elektron-pianolar'],
  ['/category/pianolar-ve-klavisler/synthesizers', '/category/pianolar-ve-klavisler/sintezatorlar'],
  ['/category/pianolar-ve-klavisler/midi-keyboards', '/category/pianolar-ve-klavisler/sintezatorlar'],
  ['/category/pianolar-ve-klavisler/piano-benches', '/category/pianolar-ve-klavisler/piano-aksesuarlari'],
  ['/category/audio-ve-studia/guitar-amps', '/category/audio-ve-studia/kombo-guclendiriciler'],
  ['/category/audio-ve-studia/wireless-systems', '/category/audio-ve-studia/simsiz-oturuculer'],
  ['/category/audio-ve-studia/headphones', '/category/audio-ve-studia/studiya-qulaqliqlari'],
  ['/category/nefes-aletleri/flutes', '/category/nefes-aletleri/fleyta'],
  ['/category/nefes-aletleri/saxophones', '/category/nefes-aletleri/saksofon'],
  ['/category/nefes-aletleri/clarinets', '/category/nefes-aletleri/klarnet'],
  ['/category/nefes-aletleri/harmonicas', '/category/pianolar-ve-klavisler/melodika-harmonica'],
  ['/category/zerb-aletleri/acoustic-drums', '/category/zerb-aletleri/akustik-barabanlar'],
  ['/category/zerb-aletleri/electronic-drums', '/category/zerb-aletleri/elektron-barabanlar'],
  ['/category/zerb-aletleri/cajons', '/category/zerb-aletleri/etnik-perkussiya'],
  ['/category/yayli-aletler/violins', '/category/yayli-aletler/skripkalar'],
  ['/category/yayli-aletler/cellos', '/category/yayli-aletler/cello'],
  ['/category/yayli-aletler/double-basses', '/category/yayli-aletler/kontrabas'],
  ['/category/milli-musiqi-aletleri/strings', '/category/milli-musiqi-aletleri/tar'],
  ['/category/milli-musiqi-aletleri/national-percussion', '/category/milli-musiqi-aletleri/milli-zerb-aletleri'],
  ['/category/milli-musiqi-aletleri/national-accessories', '/category/milli-musiqi-aletleri/saz-ve-baglama'],
  ['/category/kabeller-dayaqlar-aksesuarlar/cables', '/category/kabeller-dayaqlar-aksesuarlar/ses-kabelleri'],
  ['/category/kabeller-dayaqlar-aksesuarlar/stands', '/category/kabeller-dayaqlar-aksesuarlar/mikrofon-dinamik-dayaqlari'],
  ['/category/kabeller-dayaqlar-aksesuarlar/bags', '/category/gitaralar/gitara-cantalari'],
  ['/category/kabeller-dayaqlar-aksesuarlar/strings', '/category/gitaralar/gitara-simleri']
];

for (const [from, to] of replacements) {
  if (code.includes(from)) {
    code = code.replaceAll(from, to);
    console.log(`✅ Migrated link: ${from} -> ${to}`);
  }
}

// 5. Add 3-level route support to router if not present:
const twoLevelRoute = '(0,L.jsx)(Nr,{path:`/category/:slug/:subslug`,element:(0,L.jsx)(Kf,{})})';
const threeLevelRoute = '(0,L.jsx)(Nr,{path:`/category/:slug/:subslug/:subsubslug`,element:(0,L.jsx)(Kf,{})})';
if (code.includes(twoLevelRoute) && !code.includes(threeLevelRoute)) {
  code = code.replace(twoLevelRoute, twoLevelRoute + ',' + threeLevelRoute);
  console.log('✅ Added 3-level category route: /category/:slug/:subslug/:subsubslug');
}

fs.writeFileSync(mainPath, code, 'utf-8');
console.log('\n🎉 Successfully updated src/main.jsx with multilingual category architecture!');
