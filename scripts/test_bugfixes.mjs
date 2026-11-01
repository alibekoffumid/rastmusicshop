import { CATEGORY_TAXONOMY, SLUG_LEGACY_ALIASES } from '../src/data/categoryTaxonomy.js';
import { getSubcategories, getCategoryName, normalizeCategorySlug } from '../src/utils/categoryHelper.js';

console.log('--- TEST 1: Deduplication & Strict Parent Constraint ---');
['gitaralar', 'nefes-aletleri', 'pianolar-ve-klavisler', 'audio-ve-studia'].forEach(parent => {
  const subs = getSubcategories(parent);
  const slugs = subs.map(s => s.slug);
  const uniqueSlugs = new Set(slugs);
  console.log(`Parent [${parent}]: ${subs.length} subcategories, unique: ${uniqueSlugs.size}`);
  if (slugs.length !== uniqueSlugs.size) {
    console.error(`FAIL: Duplicates found in ${parent}!`);
    process.exit(1);
  }
});
console.log('? PASS: All parents have strictly deduplicated subcategory trees.');

console.log('\n--- TEST 2: Foreign Category Leak Prevention ---');
const nefesSubs = getSubcategories('nefes-aletleri').map(s => s.slug);
if (nefesSubs.includes('mikrofon-dinamik-dayaqlari') || nefesSubs.includes('stands')) {
  console.error('FAIL: Stands leaked into nefes-aletleri!');
  process.exit(1);
}
console.log('? PASS: No stands or accessories leak into nefes-aletleri.');

console.log('\n--- TEST 3: Language Inconsistencies & i18n (RU) ---');
const windSubs = getSubcategories('nefes-aletleri');
windSubs.forEach(s => {
  const ruName = getCategoryName(s, 'ru');
  console.log(`  ${s.slug} -> RU: "${ruName}"`);
  // Ensure no English fallbacks like Trumpets, Oboes, Trombones, French Horns
  if (['Trumpets', 'Oboes', 'Trombones', 'French Horns'].includes(ruName)) {
    console.error(`FAIL: English fallback found for ${s.slug}: ${ruName}`);
    process.exit(1);
  }
});
console.log('? PASS: All wind subcategories localized in Russian.');

console.log('\n--- TEST 4: Missing Subcategories Completeness ---');
const pianoSubs = getSubcategories('pianolar-ve-klavisler').map(s => s.slug);
const expectedPiano = [
  'elektron-pianolar',
  'portativ-pianolar',
  'akustik-pianolar',
  'sintezatorlar',
  'qarmon-akkordeon',
  'melodika-harmonica',
  'piano-aksesuarlari'
];
expectedPiano.forEach(exp => {
  if (!pianoSubs.includes(exp)) {
    console.error(`FAIL: Missing piano subcategory ${exp}`);
    process.exit(1);
  }
});
console.log(`? PASS: All ${expectedPiano.length} piano subcategories present.`);

const audioSubs = getSubcategories('audio-ve-studia').map(s => s.slug);
const expectedAudio = [
  'mikrofonlar',
  'dinamikler',
  'kombo-guclendiriciler',
  'ses-kartlari-mikserler',
  'effekt-pedallari',
  'simsiz-oturuculer',
  'studiya-qulaqliqlari'
];
expectedAudio.forEach(exp => {
  if (!audioSubs.includes(exp)) {
    console.error(`FAIL: Missing audio subcategory ${exp}`);
    process.exit(1);
  }
});
console.log(`? PASS: All ${expectedAudio.length} audio subcategories present.`);

console.log('\n--- TEST 5: Legacy Slugs Normalization ---');
const legacyTests = [
  { in: 'trumpets', out: 'truba-trombon' },
  { in: 'trombones', out: 'truba-trombon' },
  { in: 'oboes', out: 'valtorna-qoboy' },
  { in: 'french-horns', out: 'valtorna-qoboy' },
  { in: 'soprano-ukulele', out: 'ukulele-ve-gitaralele' },
  { in: 'concert-ukulele', out: 'ukulele-ve-gitaralele' },
  { in: 'tenor-ukulele', out: 'ukulele-ve-gitaralele' },
  { in: 'guitar-amps', out: 'kombo-guclendiriciler' },
  { in: 'multi-effects', out: 'effekt-pedallari' }
];
legacyTests.forEach(t => {
  const res = normalizeCategorySlug(t.in);
  if (res !== t.out) {
    console.error(`FAIL: Legacy ${t.in} normalized to ${res}, expected ${t.out}`);
    process.exit(1);
  }
});
console.log('? PASS: All legacy slugs normalize to canonical targets.');
console.log('\n?? ALL BUGFIX AUDIT TESTS PASSED (100%)!');
