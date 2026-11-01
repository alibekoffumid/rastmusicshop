-- ====================================================================
-- MIGRATION: Multilingual Category Architecture & Clean Taxonomy Seed
-- Project: Rast Music Shop (rastmusicshop.az / rastmusicshop.com)
-- Languages: AZ (default), RU, EN
-- ====================================================================

BEGIN;

-- 1. Ensure localized and ordering columns exist
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS name_az TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS name_ru TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS name_en TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS order_index INTEGER DEFAULT 0;

-- 2. Deduplicate existing categories and ensure unique index on slug
DELETE FROM public.categories a USING public.categories b WHERE a.ctid < b.ctid AND a.slug = b.slug;
CREATE UNIQUE INDEX IF NOT EXISTS categories_slug_unique ON public.categories(slug);
DO $
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'categories_slug_unique'
  ) THEN
    ALTER TABLE public.categories ADD CONSTRAINT categories_slug_unique UNIQUE USING INDEX categories_slug_unique;
  END IF;
END $;

-- 3. Idempotent Upsert: Root Categories (Level 1)
INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('gitaralar', 'Gitaralar', 'Gitaralar', 'Гитары', 'Guitars', NULL, 1, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = NULL,
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('milli-musiqi-aletleri', 'Milli musiqi alətləri', 'Milli musiqi alətləri', 'Национальные инструменты', 'Traditional Folk Instruments', NULL, 2, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = NULL,
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('pianolar-ve-klavisler', 'Pianolar və klavişli alətlər', 'Pianolar və klavişli alətlər', 'Клавишные инструменты', 'Keyboards & Pianos', NULL, 3, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = NULL,
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('yayli-aletler', 'Skripkalar və yaylı alətlər', 'Skripkalar və yaylı alətlər', 'Скрипки и смычковые', 'Orchestral Strings', NULL, 4, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = NULL,
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('nefes-aletleri', 'Nəfəs alətləri', 'Nəfəs alətləri', 'Духовые инструменты', 'Wind & Brass', NULL, 5, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = NULL,
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('zerb-aletleri', 'Barabanlar və perkussiya', 'Barabanlar və perkussiya', 'Ударные и перкуссия', 'Drums & Percussion', NULL, 6, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = NULL,
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('audio-ve-studia', 'Audio, studiya və səhnə', 'Audio, studiya və səhnə', 'Звук и студия', 'Pro Audio & Studio', NULL, 7, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = NULL,
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('kabeller-dayaqlar-aksesuarlar', 'Kabellər, dayaqlar və aksesuarlar', 'Kabellər, dayaqlar və aksesuarlar', 'Коммутация и стойки', 'Cables, Stands & Accessories', NULL, 8, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = NULL,
  order_index = EXCLUDED.order_index,
  is_archived = false;

-- 4. Idempotent Upsert: Subcategories (Level 2)
-- Subcategories of gitaralar
INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('klassik-gitaralar', 'Klassik gitaralar', 'Klassik gitaralar', 'Классические гитары', 'Classical Guitars', (SELECT id FROM public.categories WHERE slug = 'gitaralar' LIMIT 1), 1, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'gitaralar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('akustik-gitaralar', 'Akustik gitaralar', 'Akustik gitaralar', 'Акустические гитары', 'Acoustic Guitars', (SELECT id FROM public.categories WHERE slug = 'gitaralar' LIMIT 1), 2, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'gitaralar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('elektro-gitaralar', 'Elektro gitaralar', 'Elektro gitaralar', 'Электрогитары', 'Electric Guitars', (SELECT id FROM public.categories WHERE slug = 'gitaralar' LIMIT 1), 3, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'gitaralar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('bas-gitaralar', 'Bas gitaralar', 'Bas gitaralar', 'Бас-гитары', 'Bass Guitars', (SELECT id FROM public.categories WHERE slug = 'gitaralar' LIMIT 1), 4, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'gitaralar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('ukulele-ve-gitaralele', 'Ukulele və gitaralele', 'Ukulele və gitaralele', 'Укулеле и гитаралеле', 'Ukuleles & Guitaleles', (SELECT id FROM public.categories WHERE slug = 'gitaralar' LIMIT 1), 5, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'gitaralar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('gitara-aksesuarlari', 'Gitara aksesuarları və hissələri', 'Gitara aksesuarları və hissələri', 'Гитарные аксессуары и запчасти', 'Guitar Accessories & Parts', (SELECT id FROM public.categories WHERE slug = 'gitaralar' LIMIT 1), 6, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'gitaralar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

-- Subcategories of milli-musiqi-aletleri
INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('tar', 'Tar və aksesuarları', 'Tar və aksesuarları', 'Тар и аксессуары', 'Tar & Accessories', (SELECT id FROM public.categories WHERE slug = 'milli-musiqi-aletleri' LIMIT 1), 1, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'milli-musiqi-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('kamanca', 'Kamança və aksesuarları', 'Kamança və aksesuarları', 'Кяманча и аксессуары', 'Kamancha & Accessories', (SELECT id FROM public.categories WHERE slug = 'milli-musiqi-aletleri' LIMIT 1), 2, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'milli-musiqi-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('saz-ve-baglama', 'Saz və bağlama', 'Saz və bağlama', 'Саз и баглама', 'Saz & Baglama', (SELECT id FROM public.categories WHERE slug = 'milli-musiqi-aletleri' LIMIT 1), 3, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'milli-musiqi-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('qanun-ve-ud', 'Kanon və ud', 'Kanon və ud', 'Канон и уд', 'Kanon & Oud', (SELECT id FROM public.categories WHERE slug = 'milli-musiqi-aletleri' LIMIT 1), 4, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'milli-musiqi-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('milli-nefes-aletleri', 'Milli nəfəs alətləri', 'Milli nəfəs alətləri', 'Национальные духовые инструменты', 'Traditional Wind Instruments', (SELECT id FROM public.categories WHERE slug = 'milli-musiqi-aletleri' LIMIT 1), 5, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'milli-musiqi-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('milli-zerb-aletleri', 'Milli zərb alətləri', 'Milli zərb alətləri', 'Национальные ударные инструменты', 'Traditional Percussion', (SELECT id FROM public.categories WHERE slug = 'milli-musiqi-aletleri' LIMIT 1), 6, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'milli-musiqi-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

-- Subcategories of pianolar-ve-klavisler
INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('elektron-pianolar', 'Rəqəmsal (Elektro) pianolar', 'Rəqəmsal (Elektro) pianolar', 'Цифровые пианино', 'Digital Pianos', (SELECT id FROM public.categories WHERE slug = 'pianolar-ve-klavisler' LIMIT 1), 1, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'pianolar-ve-klavisler' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('portativ-pianolar', 'Portativ pianolar', 'Portativ pianolar', 'Портативные пианино', 'Portable Digital Pianos', (SELECT id FROM public.categories WHERE slug = 'pianolar-ve-klavisler' LIMIT 1), 2, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'pianolar-ve-klavisler' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('akustik-pianolar', 'Akustik pianolar və royallar', 'Akustik pianolar və royallar', 'Акустические пианино и рояли', 'Acoustic Pianos & Grand Pianos', (SELECT id FROM public.categories WHERE slug = 'pianolar-ve-klavisler' LIMIT 1), 3, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'pianolar-ve-klavisler' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('sintezatorlar', 'Sintezatorlar və MIDI klaviaturalar', 'Sintezatorlar və MIDI klaviaturalar', 'Синтезаторы и MIDI-клавиатуры', 'Synthesizers & MIDI Keyboards', (SELECT id FROM public.categories WHERE slug = 'pianolar-ve-klavisler' LIMIT 1), 4, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'pianolar-ve-klavisler' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('qarmon-akkordeon', 'Qarmon və akkordeon', 'Qarmon və akkordeon', 'Гармонь и аккордеон', 'Garmon & Accordions', (SELECT id FROM public.categories WHERE slug = 'pianolar-ve-klavisler' LIMIT 1), 5, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'pianolar-ve-klavisler' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('melodika-harmonica', 'Melodika və dodaq qarmonları', 'Melodika və dodaq qarmonları', 'Мелодики и губные гармошки', 'Melodicas & Harmonicas', (SELECT id FROM public.categories WHERE slug = 'pianolar-ve-klavisler' LIMIT 1), 6, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'pianolar-ve-klavisler' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('piano-aksesuarlari', 'Piano aksesuarları və hissələri', 'Piano aksesuarları və hissələri', 'Аксессуары для клавишных и запчасти', 'Piano Accessories & Parts', (SELECT id FROM public.categories WHERE slug = 'pianolar-ve-klavisler' LIMIT 1), 7, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'pianolar-ve-klavisler' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

-- Subcategories of yayli-aletler
INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('skripkalar', 'Akustik skripkalar', 'Akustik skripkalar', 'Акустические скрипки', 'Acoustic Violins', (SELECT id FROM public.categories WHERE slug = 'yayli-aletler' LIMIT 1), 1, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'yayli-aletler' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('elektro-skripkalar', 'Elektro skripkalar', 'Elektro skripkalar', 'Электроскрипки', 'Electric Violins', (SELECT id FROM public.categories WHERE slug = 'yayli-aletler' LIMIT 1), 2, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'yayli-aletler' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('viola', 'Viola (Alt)', 'Viola (Alt)', 'Альт (Виола)', 'Violas', (SELECT id FROM public.categories WHERE slug = 'yayli-aletler' LIMIT 1), 3, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'yayli-aletler' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('cello', 'Çello (Violonçel)', 'Çello (Violonçel)', 'Виолончель (Челло)', 'Cellos', (SELECT id FROM public.categories WHERE slug = 'yayli-aletler' LIMIT 1), 4, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'yayli-aletler' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('kontrabas', 'Kontrabas', 'Kontrabas', 'Контрабас', 'Double Basses', (SELECT id FROM public.categories WHERE slug = 'yayli-aletler' LIMIT 1), 5, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'yayli-aletler' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('yayli-alet-aksesuarlari', 'Yaylı alət aksesuarları', 'Yaylı alət aksesuarları', 'Аксессуары для смычковых', 'String Instrument Accessories', (SELECT id FROM public.categories WHERE slug = 'yayli-aletler' LIMIT 1), 6, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'yayli-aletler' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

-- Subcategories of nefes-aletleri
INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('saksofon', 'Saksofonlar (Alto, Tenor, Soprano)', 'Saksofonlar (Alto, Tenor, Soprano)', 'Саксофоны (Альт, Тенор, Сопрано)', 'Saxophones (Alto, Tenor, Soprano)', (SELECT id FROM public.categories WHERE slug = 'nefes-aletleri' LIMIT 1), 1, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'nefes-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('klarnet', 'Klarnetlər', 'Klarnetlər', 'Кларнеты', 'Clarinets', (SELECT id FROM public.categories WHERE slug = 'nefes-aletleri' LIMIT 1), 2, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'nefes-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('fleyta', 'Fleytalar', 'Fleytalar', 'Флейты', 'Flutes', (SELECT id FROM public.categories WHERE slug = 'nefes-aletleri' LIMIT 1), 3, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'nefes-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('truba-trombon', 'Trubalar və trombonlar', 'Trubalar və trombonlar', 'Трубы и тромбоны', 'Trumpets & Trombones', (SELECT id FROM public.categories WHERE slug = 'nefes-aletleri' LIMIT 1), 4, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'nefes-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('valtorna-qoboy', 'Valtorna və qoboy', 'Valtorna və qoboy', 'Валторны и гобои', 'French Horns & Oboes', (SELECT id FROM public.categories WHERE slug = 'nefes-aletleri' LIMIT 1), 5, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'nefes-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('nefes-aksesuarlari', 'Nəfəs aləti aksesuarları', 'Nəfəs aləti aksesuarları', 'Аксессуары для духовых', 'Wind Instrument Accessories', (SELECT id FROM public.categories WHERE slug = 'nefes-aletleri' LIMIT 1), 6, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'nefes-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

-- Subcategories of zerb-aletleri
INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('akustik-barabanlar', 'Akustik baraban dəstləri', 'Akustik baraban dəstləri', 'Акустические ударные установки', 'Acoustic Drum Kits', (SELECT id FROM public.categories WHERE slug = 'zerb-aletleri' LIMIT 1), 1, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'zerb-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('elektron-barabanlar', 'Elektron barabanlar', 'Elektron barabanlar', 'Электронные ударные установки', 'Electronic Drum Kits', (SELECT id FROM public.categories WHERE slug = 'zerb-aletleri' LIMIT 1), 2, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'zerb-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('mars-barabanlari', 'Marş barabanları', 'Marş barabanları', 'Маршевые барабаны', 'Marching & Snare Drums', (SELECT id FROM public.categories WHERE slug = 'zerb-aletleri' LIMIT 1), 3, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'zerb-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('etnik-perkussiya', 'Konqa, bonqo və cembe', 'Konqa, bonqo və cembe', 'Конги, бонго и джембе', 'Congas, Bongos & Djembes', (SELECT id FROM public.categories WHERE slug = 'zerb-aletleri' LIMIT 1), 4, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'zerb-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('el-ritmleri', 'Əl ritmləri (Tamburin, şeyker, marakas)', 'Əl ritmləri (Tamburin, şeyker, marakas)', 'Шумовая перкуссия (Тамбурины, шейкеры)', 'Hand Percussion (Tambourines, Shakers)', (SELECT id FROM public.categories WHERE slug = 'zerb-aletleri' LIMIT 1), 5, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'zerb-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('kalimba', 'Kalimba', 'Kalimba', 'Калимба', 'Kalimba', (SELECT id FROM public.categories WHERE slug = 'zerb-aletleri' LIMIT 1), 6, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'zerb-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('baraban-aksesuarlari', 'Baraban çubuqları və aksesuarları', 'Baraban çubuqları və aksesuarları', 'Барабанные палочки и аксессуары', 'Drumsticks & Hardware', (SELECT id FROM public.categories WHERE slug = 'zerb-aletleri' LIMIT 1), 7, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'zerb-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

-- Subcategories of audio-ve-studia
INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('mikrofonlar', 'Mikrofonlar', 'Mikrofonlar', 'Микрофоны', 'Microphones', (SELECT id FROM public.categories WHERE slug = 'audio-ve-studia' LIMIT 1), 1, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'audio-ve-studia' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('dinamikler', 'Aktiv dinamiklər və kolonkalar', 'Aktiv dinamiklər və kolonkalar', 'Активные акустические системы (Колонки)', 'Active PA Speakers & Monitors', (SELECT id FROM public.categories WHERE slug = 'audio-ve-studia' LIMIT 1), 2, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'audio-ve-studia' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('kombo-guclendiriciler', 'Gitara və bas komboları (Gücləndiricilər)', 'Gitara və bas komboları (Gücləndiricilər)', 'Комбоусилители для гитар и баса', 'Guitar & Bass Amplifiers (Combos)', (SELECT id FROM public.categories WHERE slug = 'audio-ve-studia' LIMIT 1), 3, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'audio-ve-studia' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('ses-kartlari-mikserler', 'Səs kartları və mikşer pultları', 'Səs kartları və mikşer pultları', 'Аудиоинтерфейсы и микшеры', 'Audio Interfaces & Mixing Consoles', (SELECT id FROM public.categories WHERE slug = 'audio-ve-studia' LIMIT 1), 4, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'audio-ve-studia' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('effekt-pedallari', 'Effekt pedalları və prosessorlar', 'Effekt pedalları və prosessorlar', 'Гитарные педали эффектов и процессоры', 'Guitar Effect Pedals & Processors', (SELECT id FROM public.categories WHERE slug = 'audio-ve-studia' LIMIT 1), 5, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'audio-ve-studia' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('simsiz-oturuculer', 'İnstrumental ötürücülər (Transmitterlər)', 'İnstrumental ötürücülər (Transmitterlər)', 'Инструментальные радиосистемы', 'Wireless Guitar Systems (Transmitters)', (SELECT id FROM public.categories WHERE slug = 'audio-ve-studia' LIMIT 1), 6, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'audio-ve-studia' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('studiya-qulaqliqlari', 'Studiya qulaqlıqları', 'Studiya qulaqlıqları', 'Студийные наушники', 'Studio Monitoring Headphones', (SELECT id FROM public.categories WHERE slug = 'audio-ve-studia' LIMIT 1), 7, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'audio-ve-studia' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

-- Subcategories of kabeller-dayaqlar-aksesuarlar
INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('ses-kabelleri', 'Səs kabelləri (XLR, Jack, AUX, RCA)', 'Səs kabelləri (XLR, Jack, AUX, RCA)', 'Аудиокабели (XLR, Jack, AUX, RCA)', 'Audio Cables (XLR, Jack, AUX, RCA)', (SELECT id FROM public.categories WHERE slug = 'kabeller-dayaqlar-aksesuarlar' LIMIT 1), 1, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'kabeller-dayaqlar-aksesuarlar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('stekkerler-perexodnikler', 'Ştekerlər və keçiricilər (Perexodniklər)', 'Ştekerlər və keçiricilər (Perexodniklər)', 'Разъемы, переходники и адаптеры', 'Connectors & Audio Adapters', (SELECT id FROM public.categories WHERE slug = 'kabeller-dayaqlar-aksesuarlar' LIMIT 1), 2, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'kabeller-dayaqlar-aksesuarlar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('mikrofon-dinamik-dayaqlari', 'Mikrofon və dinamik dayaqları', 'Mikrofon və dinamik dayaqları', 'Стойки для микрофонов и акустических систем', 'Microphone & Speaker Stands', (SELECT id FROM public.categories WHERE slug = 'kabeller-dayaqlar-aksesuarlar' LIMIT 1), 3, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'kabeller-dayaqlar-aksesuarlar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('alet-not-dayaqlari', 'Alət və not dayaqları (Püpitrlər)', 'Alət və not dayaqları (Püpitrlər)', 'Стойки для инструментов и пюпитры', 'Instrument & Music Sheet Stands', (SELECT id FROM public.categories WHERE slug = 'kabeller-dayaqlar-aksesuarlar' LIMIT 1), 4, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'kabeller-dayaqlar-aksesuarlar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('adapterler-batareyalar', 'Qida blokları, adapterlər və batareyalar', 'Qida blokları, adapterlər və batareyalar', 'Блоки питания, адаптеры и батарейки', 'Power Supplies, Adapters & Batteries', (SELECT id FROM public.categories WHERE slug = 'kabeller-dayaqlar-aksesuarlar' LIMIT 1), 5, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'kabeller-dayaqlar-aksesuarlar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('musiqi-kitablari', 'Musiqi dərslikləri və not kitabları', 'Musiqi dərslikləri və not kitabları', 'Нотная литература и учебные пособия', 'Music Books & Sheet Music', (SELECT id FROM public.categories WHERE slug = 'kabeller-dayaqlar-aksesuarlar' LIMIT 1), 6, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'kabeller-dayaqlar-aksesuarlar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('suvenirler-usaq-aletleri', 'Suvenirlər və uşaq musiqi alətləri', 'Suvenirlər və uşaq musiqi alətləri', 'Сувениры и детские музыкальные инструменты', 'Souvenirs & Kids Musical Toys', (SELECT id FROM public.categories WHERE slug = 'kabeller-dayaqlar-aksesuarlar' LIMIT 1), 7, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'kabeller-dayaqlar-aksesuarlar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

-- 5. Idempotent Upsert: Sub-subcategories (Level 3)
-- Children of klassik-gitaralar (parent: gitaralar)
INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('standart-klassik', 'Standart klassik gitaralar', 'Standart klassik gitaralar', 'Стандартные классические гитары', 'Standard Classical Guitars', (SELECT id FROM public.categories WHERE slug = 'klassik-gitaralar' LIMIT 1), 1, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'klassik-gitaralar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('elektro-klassik-eq', 'Elektro-klassik gitaralar (EQ)', 'Elektro-klassik gitaralar (EQ)', 'Электроакустические классические (EQ)', 'Acoustic-Electric Classical Guitars', (SELECT id FROM public.categories WHERE slug = 'klassik-gitaralar' LIMIT 1), 2, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'klassik-gitaralar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

-- Children of akustik-gitaralar (parent: gitaralar)
INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('6-simli-akustik', '6 simli akustik gitaralar', '6 simli akustik gitaralar', '6-струнные акустические гитары', '6-String Acoustic Guitars', (SELECT id FROM public.categories WHERE slug = 'akustik-gitaralar' LIMIT 1), 1, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'akustik-gitaralar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('12-simli-akustik', '12 simli akustik gitaralar', '12 simli akustik gitaralar', '12-струнные акустические гитары', '12-String Acoustic Guitars', (SELECT id FROM public.categories WHERE slug = 'akustik-gitaralar' LIMIT 1), 2, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'akustik-gitaralar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('elektro-akustik-eq', 'Elektro-akustik gitaralar (EQ)', 'Elektro-akustik gitaralar (EQ)', 'Электроакустические гитары (EQ)', 'Acoustic-Electric Guitars', (SELECT id FROM public.categories WHERE slug = 'akustik-gitaralar' LIMIT 1), 3, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'akustik-gitaralar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

-- Children of elektro-gitaralar (parent: gitaralar)
INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('stratocaster', 'Stratocaster', 'Stratocaster', 'Стратокастер (Stratocaster)', 'Stratocaster', (SELECT id FROM public.categories WHERE slug = 'elektro-gitaralar' LIMIT 1), 1, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'elektro-gitaralar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('telecaster', 'Telecaster', 'Telecaster', 'Телекастер (Telecaster)', 'Telecaster', (SELECT id FROM public.categories WHERE slug = 'elektro-gitaralar' LIMIT 1), 2, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'elektro-gitaralar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('superstrat', 'Superstrat', 'Superstrat', 'Суперстрат (Superstrat)', 'Superstrat', (SELECT id FROM public.categories WHERE slug = 'elektro-gitaralar' LIMIT 1), 3, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'elektro-gitaralar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('jazz-semi-hollow', 'Caz və semi-hollow gitaralar', 'Caz və semi-hollow gitaralar', 'Полуакустические и джазовые гитары', 'Semi-Hollow & Hollowbody Guitars', (SELECT id FROM public.categories WHERE slug = 'elektro-gitaralar' LIMIT 1), 4, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'elektro-gitaralar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('headless', 'Başsız (Headless) gitaralar', 'Başsız (Headless) gitaralar', 'Безголовые (Headless) гитары', 'Headless Guitars', (SELECT id FROM public.categories WHERE slug = 'elektro-gitaralar' LIMIT 1), 5, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'elektro-gitaralar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

-- Children of bas-gitaralar (parent: gitaralar)
INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('elektro-bas', 'Elektro bas gitaralar', 'Elektro bas gitaralar', 'Электро бас-гитары', 'Electric Bass Guitars', (SELECT id FROM public.categories WHERE slug = 'bas-gitaralar' LIMIT 1), 1, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'bas-gitaralar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('akustik-bas', 'Akustik bas gitaralar', 'Akustik bas gitaralar', 'Акустические бас-гитары', 'Acoustic Bass Guitars', (SELECT id FROM public.categories WHERE slug = 'bas-gitaralar' LIMIT 1), 2, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'bas-gitaralar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

-- Children of gitara-aksesuarlari (parent: gitaralar)
INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('gitara-simleri', 'Gitara simləri', 'Gitara simləri', 'Струны для гитары', 'Guitar Strings', (SELECT id FROM public.categories WHERE slug = 'gitara-aksesuarlari' LIMIT 1), 1, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'gitara-aksesuarlari' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('gitara-cantalari', 'Gitara çantaları və sərt keyslər', 'Gitara çantaları və sərt keyslər', 'Чехлы и жесткие кейсы', 'Gig Bags & Hard Cases', (SELECT id FROM public.categories WHERE slug = 'gitara-aksesuarlari' LIMIT 1), 2, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'gitara-aksesuarlari' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('kemerler-kapolar', 'Kəmərlər və kapolar', 'Kəmərlər və kapolar', 'Ремни и каподастры', 'Straps & Capos', (SELECT id FROM public.categories WHERE slug = 'gitara-aksesuarlari' LIMIT 1), 3, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'gitara-aksesuarlari' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('mizrablar', 'Mizrablar (Mediatorlar)', 'Mizrablar (Mediatorlar)', 'Медиаторы', 'Picks & Plectrums', (SELECT id FROM public.categories WHERE slug = 'gitara-aksesuarlari' LIMIT 1), 4, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'gitara-aksesuarlari' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('asiqlar', 'Aşığlar (Kökləyicilər)', 'Aşığlar (Kökləyicilər)', 'Колки', 'Tuning Pegs (Machine Heads)', (SELECT id FROM public.categories WHERE slug = 'gitara-aksesuarlari' LIMIT 1), 5, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'gitara-aksesuarlari' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('xerekler', 'Xərəklər və körpülər', 'Xərəklər və körpülər', 'Нижние порожки и струнодержатели', 'Bridges & Saddles', (SELECT id FROM public.categories WHERE slug = 'gitara-aksesuarlari' LIMIT 1), 6, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'gitara-aksesuarlari' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('ses-qebulediciler-eq', 'Səs qəbuledicilər və ekvalayzerlər', 'Səs qəbuledicilər və ekvalayzerlər', 'Звукосниматели и темброблоки', 'Pickups & Preamp EQ Systems', (SELECT id FROM public.categories WHERE slug = 'gitara-aksesuarlari' LIMIT 1), 7, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'gitara-aksesuarlari' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('qulluq-vasiteleri', 'Təmizləmə və qulluq vasitələri', 'Təmizləmə və qulluq vasitələri', 'Средства для ухода и полироли', 'Care & Maintenance', (SELECT id FROM public.categories WHERE slug = 'gitara-aksesuarlari' LIMIT 1), 8, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'gitara-aksesuarlari' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

-- Children of tar (parent: milli-musiqi-aletleri)
INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('telebe-sade-tarlar', 'Tələbə və sadə tarlar', 'Tələbə və sadə tarlar', 'Ученические и простые тары', 'Student & Basic Tars', (SELECT id FROM public.categories WHERE slug = 'tar' LIMIT 1), 1, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'tar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('orta-pesekar-tarlar', 'Orta və peşəkar tarlar', 'Orta və peşəkar tarlar', 'Полупрофессиональные и профессиональные тары', 'Semi-Pro & Professional Tars', (SELECT id FROM public.categories WHERE slug = 'tar' LIMIT 1), 2, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'tar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('sedefli-tarlar', 'Sədəfli tarlar', 'Sədəfli tarlar', 'Тары с инкрустацией перламутром', 'Mother-of-Pearl Inlaid Tars', (SELECT id FROM public.categories WHERE slug = 'tar' LIMIT 1), 3, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'tar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('tar-simleri', 'Tar simləri', 'Tar simləri', 'Струны для тара', 'Tar Strings', (SELECT id FROM public.categories WHERE slug = 'tar' LIMIT 1), 4, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'tar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('tar-mizrablari', 'Tar mizrabları', 'Tar mizrabları', 'Медиаторы для тара', 'Tar Plectrums', (SELECT id FROM public.categories WHERE slug = 'tar' LIMIT 1), 5, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'tar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('tar-xereklari', 'Tar xərəkləri', 'Tar xərəkləri', 'Порожки для тара', 'Tar Bridges', (SELECT id FROM public.categories WHERE slug = 'tar' LIMIT 1), 6, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'tar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('tar-hisseleri', 'Tar aşığları və hissələri', 'Tar aşığları və hissələri', 'Колки и детали для тара', 'Tar Tuning Pegs & Parts', (SELECT id FROM public.categories WHERE slug = 'tar' LIMIT 1), 7, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'tar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('tar-cantalari', 'Tar çantaları', 'Tar çantaları', 'Чехлы для тара', 'Tar Bags & Cases', (SELECT id FROM public.categories WHERE slug = 'tar' LIMIT 1), 8, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'tar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

-- Children of kamanca (parent: milli-musiqi-aletleri)
INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('telebe-sade-kamancalar', 'Tələbə və sadə kamançalar', 'Tələbə və sadə kamançalar', 'Ученические и простые кяманчи', 'Student & Basic Kamanchas', (SELECT id FROM public.categories WHERE slug = 'kamanca' LIMIT 1), 1, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'kamanca' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('orta-pesekar-kamancalar', 'Orta və peşəkar kamançalar', 'Orta və peşəkar kamançalar', 'Полупрофессиональные и профессиональные кяманчи', 'Semi-Pro & Professional Kamanchas', (SELECT id FROM public.categories WHERE slug = 'kamanca' LIMIT 1), 2, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'kamanca' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('sedefli-kamancalar', 'Sədəfli kamançalar', 'Sədəfli kamançalar', 'Кяманчи с инкрустацией перламутром', 'Mother-of-Pearl Inlaid Kamanchas', (SELECT id FROM public.categories WHERE slug = 'kamanca' LIMIT 1), 3, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'kamanca' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('kamanca-simleri', 'Kamança simləri', 'Kamança simləri', 'Струны для кяманчи', 'Kamancha Strings', (SELECT id FROM public.categories WHERE slug = 'kamanca' LIMIT 1), 4, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'kamanca' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('smicoklar-ve-tuk', 'Smicoklar və at tükü', 'Smicoklar və at tükü', 'Смычки и конский волос', 'Kamancha Bows & Horsehair', (SELECT id FROM public.categories WHERE slug = 'kamanca' LIMIT 1), 5, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'kamanca' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('kamanca-hisseleri', 'Xərəklər, dizliklər və simkeşlər', 'Xərəklər, dizliklər və simkeşlər', 'Подставки, ножки-упоры и струнодержатели', 'Bridges, Endpins & Tailpieces', (SELECT id FROM public.categories WHERE slug = 'kamanca' LIMIT 1), 6, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'kamanca' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('kamanca-cantalari', 'Kamança çantaları', 'Kamança çantaları', 'Чехлы для кяманчи', 'Kamancha Bags & Cases', (SELECT id FROM public.categories WHERE slug = 'kamanca' LIMIT 1), 7, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'kamanca' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

-- Children of saz-ve-baglama (parent: milli-musiqi-aletleri)
INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('boyuk-saz', 'Böyük saz', 'Böyük saz', 'Большой (классический) саз', 'Standard Long-Neck Saz', (SELECT id FROM public.categories WHERE slug = 'saz-ve-baglama' LIMIT 1), 1, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'saz-ve-baglama' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('cure-saz', 'Cürə saz', 'Cürə saz', 'Джура саз (малый саз)', 'Cura Saz', (SELECT id FROM public.categories WHERE slug = 'saz-ve-baglama' LIMIT 1), 2, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'saz-ve-baglama' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('qedimi-saz', 'Qədimi saz', 'Qədimi saz', 'Традиционный (старинный) саз', 'Traditional Saz', (SELECT id FROM public.categories WHERE slug = 'saz-ve-baglama' LIMIT 1), 3, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'saz-ve-baglama' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('turk-baglamasi', 'Türk bağlaması (Qısa və uzun sap)', 'Türk bağlaması (Qısa və uzun sap)', 'Турецкая баглама (короткий и длинный гриф)', 'Turkish Baglama (Short & Long Neck)', (SELECT id FROM public.categories WHERE slug = 'saz-ve-baglama' LIMIT 1), 4, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'saz-ve-baglama' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('elektro-baglama', 'Elektro bağlama', 'Elektro bağlama', 'Электробаглама', 'Electric Baglama', (SELECT id FROM public.categories WHERE slug = 'saz-ve-baglama' LIMIT 1), 5, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'saz-ve-baglama' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('saz-baglama-simleri', 'Saz və bağlama simləri', 'Saz və bağlama simləri', 'Струны для саза и багламы', 'Saz & Baglama Strings', (SELECT id FROM public.categories WHERE slug = 'saz-ve-baglama' LIMIT 1), 6, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'saz-ve-baglama' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('saz-aksesuarlari', 'Saz mizrabları, kəmərlər və çantalar', 'Saz mizrabları, kəmərlər və çantalar', 'Медиаторы (тезене), ремни и чехлы для саза', 'Saz Picks, Straps & Bags', (SELECT id FROM public.categories WHERE slug = 'saz-ve-baglama' LIMIT 1), 7, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'saz-ve-baglama' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

-- Children of qanun-ve-ud (parent: milli-musiqi-aletleri)
INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('qanun', 'Kanon', 'Kanon', 'Канон (Канун)', 'Kanon (Kanun)', (SELECT id FROM public.categories WHERE slug = 'qanun-ve-ud' LIMIT 1), 1, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'qanun-ve-ud' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('ud', 'Ud', 'Ud', 'Уд', 'Oud', (SELECT id FROM public.categories WHERE slug = 'qanun-ve-ud' LIMIT 1), 2, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'qanun-ve-ud' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('qanun-aksesuarlari', 'Kanon aksesuarları (Simlər, mizrab, üskük, açar)', 'Kanon aksesuarları (Simlər, mizrab, üskük, açar)', 'Аксессуары для канона (струны, плектры, наперстки, ключ)', 'Kanon Accessories (Strings, Picks, Rings, Key)', (SELECT id FROM public.categories WHERE slug = 'qanun-ve-ud' LIMIT 1), 3, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'qanun-ve-ud' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('ud-aksesuarlari', 'Ud aksesuarları (Simlər, mizrab, çanta)', 'Ud aksesuarları (Simlər, mizrab, çanta)', 'Аксессуары для уда (струны, медиаторы, чехлы)', 'Oud Accessories (Strings, Picks, Bags)', (SELECT id FROM public.categories WHERE slug = 'qanun-ve-ud' LIMIT 1), 4, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'qanun-ve-ud' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

-- Children of milli-nefes-aletleri (parent: milli-musiqi-aletleri)
INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('balaban-mey', 'Balaban və mey', 'Balaban və mey', 'Балабан и мэй', 'Balaban & Mey', (SELECT id FROM public.categories WHERE slug = 'milli-nefes-aletleri' LIMIT 1), 1, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'milli-nefes-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('tutek', 'Tütək', 'Tütək', 'Тютек', 'Tutek', (SELECT id FROM public.categories WHERE slug = 'milli-nefes-aletleri' LIMIT 1), 2, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'milli-nefes-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('ney', 'Ney', 'Ney', 'Ней', 'Ney', (SELECT id FROM public.categories WHERE slug = 'milli-nefes-aletleri' LIMIT 1), 3, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'milli-nefes-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('zurna', 'Zurna', 'Zurna', 'Зурна', 'Zurna', (SELECT id FROM public.categories WHERE slug = 'milli-nefes-aletleri' LIMIT 1), 4, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'milli-nefes-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('milli-qamislar', 'Balaban və zurna qamışları, millər', 'Balaban və zurna qamışları, millər', 'Трости для балабана и зурны, пищики', 'Balaban & Zurna Reeds, Staples', (SELECT id FROM public.categories WHERE slug = 'milli-nefes-aletleri' LIMIT 1), 5, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'milli-nefes-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

-- Children of milli-zerb-aletleri (parent: milli-musiqi-aletleri)
INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('nagara', 'Nağara və qoşa nağara', 'Nağara və qoşa nağara', 'Нагара и гоша-нагара', 'Nagara & Gosha Nagara', (SELECT id FROM public.categories WHERE slug = 'milli-zerb-aletleri' LIMIT 1), 1, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'milli-zerb-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('qaval-def', 'Qaval və dəf', 'Qaval və dəf', 'Гавал и деф', 'Gaval & Daf', (SELECT id FROM public.categories WHERE slug = 'milli-zerb-aletleri' LIMIT 1), 2, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'milli-zerb-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('zerb-darbuka', 'Zərb və darbuka', 'Zərb və darbuka', 'Зерб и дарбука', 'Zerb & Darbuka', (SELECT id FROM public.categories WHERE slug = 'milli-zerb-aletleri' LIMIT 1), 3, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'milli-zerb-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('davul', 'Davul', 'Davul', 'Давул', 'Davul', (SELECT id FROM public.categories WHERE slug = 'milli-zerb-aletleri' LIMIT 1), 4, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'milli-zerb-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('zerb-uzlukleri', 'Darbuka və nağara üzlükləri (Dərilər)', 'Darbuka və nağara üzlükləri (Dərilər)', 'Пластики и мембраны для ударных', 'Drum Heads & Skins', (SELECT id FROM public.categories WHERE slug = 'milli-zerb-aletleri' LIMIT 1), 5, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'milli-zerb-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('zerb-cantalari', 'Zərb çantaları və kəmərləri', 'Zərb çantaları və kəmərləri', 'Чехлы и ремни для нагары и давула', 'Percussion Bags & Straps', (SELECT id FROM public.categories WHERE slug = 'milli-zerb-aletleri' LIMIT 1), 6, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'milli-zerb-aletleri' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

-- Children of piano-aksesuarlari (parent: pianolar-ve-klavisler)
INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('piano-oturacaqlari', 'Piano oturacaqları (Banketlər)', 'Piano oturacaqları (Banketlər)', 'Банкетки и стулья для пианино', 'Piano Benches & Stools', (SELECT id FROM public.categories WHERE slug = 'piano-aksesuarlari' LIMIT 1), 1, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'piano-aksesuarlari' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('pedallar-adaptorlar', 'Sustain və blok pedallar', 'Sustain və blok pedallar', 'Педали сустейна и педальные блоки', 'Sustain & Multi-Pedals', (SELECT id FROM public.categories WHERE slug = 'piano-aksesuarlari' LIMIT 1), 2, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'piano-aksesuarlari' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('sintezator-cantalari', 'Sintezator çantaları', 'Sintezator çantaları', 'Чехлы для синтезаторов', 'Keyboard Gig Bags', (SELECT id FROM public.categories WHERE slug = 'piano-aksesuarlari' LIMIT 1), 3, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'piano-aksesuarlari' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('klavis-dayaqlari', 'Klaviş və sintezator dayaqları', 'Klaviş və sintezator dayaqları', 'Стойки для клавишных инструментов', 'Keyboard Stands', (SELECT id FROM public.categories WHERE slug = 'piano-aksesuarlari' LIMIT 1), 4, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'piano-aksesuarlari' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

-- Children of yayli-alet-aksesuarlari (parent: yayli-aletler)
INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('yayli-simler', 'Skripka, alt və çello simləri', 'Skripka, alt və çello simləri', 'Струны для скрипки, альта и виолончели', 'Strings for Violin, Viola & Cello', (SELECT id FROM public.categories WHERE slug = 'yayli-alet-aksesuarlari' LIMIT 1), 1, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'yayli-alet-aksesuarlari' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('yayli-smicoklar', 'Smicoklar (Kamanlar)', 'Smicoklar (Kamanlar)', 'Смычки', 'Bows', (SELECT id FROM public.categories WHERE slug = 'yayli-alet-aksesuarlari' LIMIT 1), 2, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'yayli-alet-aksesuarlari' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('mostikler', 'Mostiklər (Çiyinliklər)', 'Mostiklər (Çiyinliklər)', 'Мостики (плечевые упоры)', 'Shoulder Rests', (SELECT id FROM public.categories WHERE slug = 'yayli-alet-aksesuarlari' LIMIT 1), 3, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'yayli-alet-aksesuarlari' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('cenelikler-simkesler', 'Çənəliklər, simkeşlər və maşinkalar', 'Çənəliklər, simkeşlər və maşinkalar', 'Подбородники, подгрифки и машинки', 'Chinrests, Tailpieces & Fine Tuners', (SELECT id FROM public.categories WHERE slug = 'yayli-alet-aksesuarlari' LIMIT 1), 4, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'yayli-alet-aksesuarlari' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('kanifollar', 'Kanifollar', 'Kanifollar', 'Канифоль', 'Rosin', (SELECT id FROM public.categories WHERE slug = 'yayli-alet-aksesuarlari' LIMIT 1), 5, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'yayli-alet-aksesuarlari' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('yayli-cantalar', 'Yaylı alət keysləri və çantaları', 'Yaylı alət keysləri və çantaları', 'Футляры и чехлы для смычковых', 'Cases & Gig Bags', (SELECT id FROM public.categories WHERE slug = 'yayli-alet-aksesuarlari' LIMIT 1), 6, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'yayli-alet-aksesuarlari' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

-- Children of nefes-aksesuarlari (parent: nefes-aletleri)
INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('qamislar', 'Klarnet və saksofon qamışları', 'Klarnet və saksofon qamışları', 'Трости для кларнета и саксофона', 'Clarinet & Saxophone Reeds', (SELECT id FROM public.categories WHERE slug = 'nefes-aksesuarlari' LIMIT 1), 1, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'nefes-aksesuarlari' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('mustukler', 'Müştüklər, liqaturalar və qapaqlar', 'Müştüklər, liqaturalar və qapaqlar', 'Мундштуки, лигатуры и колпачки', 'Mouthpieces, Ligatures & Caps', (SELECT id FROM public.categories WHERE slug = 'nefes-aksesuarlari' LIMIT 1), 2, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'nefes-aksesuarlari' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('nefes-cantalari', 'Nəfəs kəmərləri, yastıqcıqlar və çantalar', 'Nəfəs kəmərləri, yastıqcıqlar və çantalar', 'Гайтаны (ремни), подушечки и чехлы', 'Neck Straps, Pads & Bags', (SELECT id FROM public.categories WHERE slug = 'nefes-aksesuarlari' LIMIT 1), 3, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'nefes-aksesuarlari' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

-- Children of mikrofonlar (parent: audio-ve-studia)
INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('simsiz-mikrofonlar', 'Simsiz mikrofon sistemləri (Yaxalıq/Əl)', 'Simsiz mikrofon sistemləri (Yaxalıq/Əl)', 'Радиосистемы (беспроводные петлички/ручные)', 'Wireless Systems (Lavalier & Handheld)', (SELECT id FROM public.categories WHERE slug = 'mikrofonlar' LIMIT 1), 1, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'mikrofonlar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('kabelli-mikrofonlar', 'Kabelli vokal əl mikrofonları', 'Kabelli vokal əl mikrofonları', 'Проводные вокальные микрофоны', 'Wired Vocal Handheld Microphones', (SELECT id FROM public.categories WHERE slug = 'mikrofonlar' LIMIT 1), 2, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'mikrofonlar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('studia-mikrofonlari', 'Studiya kondensator mikrofonları', 'Studiya kondensator mikrofonları', 'Студийные конденсаторные микрофоны', 'Studio Condenser Microphones', (SELECT id FROM public.categories WHERE slug = 'mikrofonlar' LIMIT 1), 3, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'mikrofonlar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

INSERT INTO public.categories (slug, name, name_az, name_ru, name_en, parent_id, order_index, is_archived)
VALUES ('instrumental-mikrofonlar', 'İnstrumental mikrofonlar', 'İnstrumental mikrofonlar', 'Инструментальные микрофоны', 'Instrument Microphones', (SELECT id FROM public.categories WHERE slug = 'mikrofonlar' LIMIT 1), 4, false)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  name_az = EXCLUDED.name_az,
  name_ru = EXCLUDED.name_ru,
  name_en = EXCLUDED.name_en,
  parent_id = (SELECT id FROM public.categories WHERE slug = 'mikrofonlar' LIMIT 1),
  order_index = EXCLUDED.order_index,
  is_archived = false;

-- 6. Strict Cleaning & Product Slug Migration
-- Unlink polluted subcategories from products
UPDATE public.products SET subcategory_slug = NULL WHERE subcategory_slug ~* '(teymur|bəxtiyar|sahib|fərhad|fərrux|rövşən|tahir|4/4|3/4|1/2|1/4|qoz|fıstıq|ebonit|dominguez|korg|miles)';

-- 6.1 Migrate legacy category slugs in products to canonical Azerbaijani slugs
UPDATE public.products SET category_slug = 'gitaralar' WHERE category_slug IN ('guitars', 'gitara', 'guitar');
UPDATE public.products SET category_slug = 'pianolar-ve-klavisler' WHERE category_slug IN ('keys', 'pianos', 'keyboards');
UPDATE public.products SET category_slug = 'yayli-aletler' WHERE category_slug IN ('bowed', 'string-instruments', 'strings');
UPDATE public.products SET category_slug = 'nefes-aletleri' WHERE category_slug IN ('wind-instruments', 'winds');
UPDATE public.products SET category_slug = 'zerb-aletleri' WHERE category_slug IN ('percussion', 'drums');
UPDATE public.products SET category_slug = 'milli-musiqi-aletleri' WHERE category_slug IN ('national-instruments', 'national');
UPDATE public.products SET category_slug = 'audio-ve-studia' WHERE category_slug IN ('audio-equipment', 'audio', 'studio');
UPDATE public.products SET category_slug = 'kabeller-dayaqlar-aksesuarlar' WHERE category_slug IN ('accessories');

-- 6.2 Migrate legacy subcategory slugs in products to canonical Azerbaijani slugs
UPDATE public.products SET subcategory_slug = 'klassik-gitaralar' WHERE subcategory_slug IN ('classical-guitars', 'klassik');
UPDATE public.products SET subcategory_slug = 'akustik-gitaralar' WHERE subcategory_slug IN ('acoustic-guitars', 'akustik');
UPDATE public.products SET subcategory_slug = 'elektro-gitaralar' WHERE subcategory_slug IN ('electric-guitars');
UPDATE public.products SET subcategory_slug = 'bas-gitaralar' WHERE subcategory_slug IN ('bass-guitars');
UPDATE public.products SET subcategory_slug = 'elektro-klassik-eq' WHERE subcategory_slug IN ('electro-classical-guitars');
UPDATE public.products SET subcategory_slug = 'elektro-akustik-eq' WHERE subcategory_slug IN ('electro-acoustic-guitars');
UPDATE public.products SET subcategory_slug = 'elektron-pianolar' WHERE subcategory_slug IN ('digital-pianos');
UPDATE public.products SET subcategory_slug = 'sintezatorlar' WHERE subcategory_slug IN ('synthesizers');
UPDATE public.products SET subcategory_slug = 'skripkalar' WHERE subcategory_slug IN ('violins');
UPDATE public.products SET subcategory_slug = 'cello' WHERE subcategory_slug IN ('cellos');
UPDATE public.products SET subcategory_slug = 'kontrabas' WHERE subcategory_slug IN ('double-basses');
UPDATE public.products SET subcategory_slug = 'elektron-barabanlar' WHERE subcategory_slug IN ('electronic-drums');
UPDATE public.products SET subcategory_slug = 'ses-kabelleri' WHERE subcategory_slug IN ('cables');
UPDATE public.products SET subcategory_slug = 'piano-oturacaqlari' WHERE subcategory_slug IN ('piano-benches');
UPDATE public.products SET subcategory_slug = 'studiya-qulaqliqlari' WHERE subcategory_slug IN ('headphones');
UPDATE public.products SET subcategory_slug = 'adapterler-batareyalar' WHERE subcategory_slug IN ('adapters', 'powerbanks');

-- 6.3 Archive polluted/forbidden categories in categories table
UPDATE public.categories SET is_archived = true WHERE slug ~* '(teymur|bəxtiyar|sahib|fərhad|fərrux|rövşən|tahir|4-4|3-4|1-2|1-4|qoz|fistiq|ebonit|dominguez|korg|miles)';

-- 7. RLS Configuration: Ensure Public SELECT is enabled
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public can view active categories" ON public.categories;
CREATE POLICY "Public can view active categories" ON public.categories
  FOR SELECT USING (is_archived = false OR is_archived IS NULL);

COMMIT;