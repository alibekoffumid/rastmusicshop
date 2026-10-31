/**
 * Rast Music Shop - Multilingual Category Taxonomy
 * Languages: Azerbaijani ('az' - default), Russian ('ru'), English ('en')
 * 
 * Strict Sanitization Compliance:
 * - NO Artisan / Master Names (e.g., Teymur, Sahib, Bəxtiyar, etc.)
 * - NO Instrument Sizes as categories (e.g., 4/4, 3/4 - these are product attributes)
 * - NO Brand Names as categories (e.g., Dominguez, Korg, etc. - these belong to brand attribute)
 * - NO Raw Materials as categories (e.g., Qoz, Fıstıq - these belong to specifications)
 */

export const CATEGORY_TAXONOMY = [
  {
    slug: "gitaralar",
    order_index: 1,
    name: {
      az: "Gitaralar",
      ru: "Гитары",
      en: "Guitars"
    },
    children: [
      {
        slug: "klassik-gitaralar",
        name: {
          az: "Klassik gitaralar",
          ru: "Классические гитары",
          en: "Classical Guitars"
        },
        children: [
          {
            slug: "standart-klassik",
            name: {
              az: "Standart klassik gitaralar",
              ru: "Стандартные классические гитары",
              en: "Standard Classical Guitars"
            }
          },
          {
            slug: "elektro-klassik-eq",
            name: {
              az: "Elektro-klassik gitaralar (EQ)",
              ru: "Электроакустические классические (EQ)",
              en: "Acoustic-Electric Classical Guitars"
            }
          }
        ]
      },
      {
        slug: "akustik-gitaralar",
        name: {
          az: "Akustik gitaralar",
          ru: "Акустические гитары",
          en: "Acoustic Guitars"
        },
        children: [
          {
            slug: "6-simli-akustik",
            name: {
              az: "6 simli akustik gitaralar",
              ru: "6-струнные акустические гитары",
              en: "6-String Acoustic Guitars"
            }
          },
          {
            slug: "12-simli-akustik",
            name: {
              az: "12 simli akustik gitaralar",
              ru: "12-струнные акустические гитары",
              en: "12-String Acoustic Guitars"
            }
          },
          {
            slug: "elektro-akustik-eq",
            name: {
              az: "Elektro-akustik gitaralar (EQ)",
              ru: "Электроакустические гитары (EQ)",
              en: "Acoustic-Electric Guitars"
            }
          }
        ]
      },
      {
        slug: "elektro-gitaralar",
        name: {
          az: "Elektro gitaralar",
          ru: "Электрогитары",
          en: "Electric Guitars"
        },
        children: [
          { slug: "stratocaster", name: { az: "Stratocaster", ru: "Стратокастер (Stratocaster)", en: "Stratocaster" } },
          { slug: "telecaster", name: { az: "Telecaster", ru: "Телекастер (Telecaster)", en: "Telecaster" } },
          { slug: "superstrat", name: { az: "Superstrat", ru: "Суперстрат (Superstrat)", en: "Superstrat" } },
          { slug: "jazz-semi-hollow", name: { az: "Caz və semi-hollow gitaralar", ru: "Полуакустические и джазовые гитары", en: "Semi-Hollow & Hollowbody Guitars" } },
          { slug: "headless", name: { az: "Başsız (Headless) gitaralar", ru: "Безголовые (Headless) гитары", en: "Headless Guitars" } }
        ]
      },
      {
        slug: "bas-gitaralar",
        name: {
          az: "Bas gitaralar",
          ru: "Бас-гитары",
          en: "Bass Guitars"
        },
        children: [
          { slug: "elektro-bas", name: { az: "Elektro bas gitaralar", ru: "Электро бас-гитары", en: "Electric Bass Guitars" } },
          { slug: "akustik-bas", name: { az: "Akustik bas gitaralar", ru: "Акустические бас-гитары", en: "Acoustic Bass Guitars" } }
        ]
      },
      {
        slug: "ukulele-ve-gitaralele",
        name: {
          az: "Ukulele və gitaralele",
          ru: "Укулеле и гитаралеле",
          en: "Ukuleles & Guitaleles"
        }
      },
      {
        slug: "gitara-aksesuarlari",
        name: {
          az: "Gitara aksesuarları və hissələri",
          ru: "Гитарные аксессуары и запчасти",
          en: "Guitar Accessories & Parts"
        },
        children: [
          { slug: "gitara-simleri", name: { az: "Gitara simləri", ru: "Струны для гитары", en: "Guitar Strings" } },
          { slug: "gitara-cantalari", name: { az: "Gitara çantaları və sərt keyslər", ru: "Чехлы и жесткие кейсы", en: "Gig Bags & Hard Cases" } },
          { slug: "kemerler-kapolar", name: { az: "Kəmərlər və kapolar", ru: "Ремни и каподастры", en: "Straps & Capos" } },
          { slug: "mizrablar", name: { az: "Mizrablar (Mediatorlar)", ru: "Медиаторы", en: "Picks & Plectrums" } },
          { slug: "asiqlar", name: { az: "Aşığlar (Kökləyicilər)", ru: "Колки", en: "Tuning Pegs (Machine Heads)" } },
          { slug: "xerekler", name: { az: "Xərəklər və körpülər", ru: "Нижние порожки и струнодержатели", en: "Bridges & Saddles" } },
          { slug: "ses-qebulediciler-eq", name: { az: "Səs qəbuledicilər və ekvalayzerlər", ru: "Звукосниматели и темброблоки", en: "Pickups & Preamp EQ Systems" } },
          { slug: "qulluq-vasiteleri", name: { az: "Təmizləmə və qulluq vasitələri", ru: "Средства для ухода и полироли", en: "Care & Maintenance" } }
        ]
      }
    ]
  },
  {
    slug: "milli-musiqi-aletleri",
    order_index: 2,
    name: {
      az: "Milli musiqi alətləri",
      ru: "Национальные инструменты",
      en: "Traditional Folk Instruments"
    },
    children: [
      {
        slug: "tar",
        name: {
          az: "Tar və aksesuarları",
          ru: "Тар и аксессуары",
          en: "Tar & Accessories"
        },
        children: [
          { slug: "telebe-sade-tarlar", name: { az: "Tələbə və sadə tarlar", ru: "Ученические и простые тары", en: "Student & Basic Tars" } },
          { slug: "orta-pesekar-tarlar", name: { az: "Orta və peşəkar tarlar", ru: "Полупрофессиональные и профессиональные тары", en: "Semi-Pro & Professional Tars" } },
          { slug: "sedefli-tarlar", name: { az: "Sədəfli tarlar", ru: "Тары с инкрустацией перламутром", en: "Mother-of-Pearl Inlaid Tars" } },
          { slug: "tar-simleri", name: { az: "Tar simləri", ru: "Струны для тара", en: "Tar Strings" } },
          { slug: "tar-mizrablari", name: { az: "Tar mizrabları", ru: "Медиаторы для тара", en: "Tar Plectrums" } },
          { slug: "tar-xereklari", name: { az: "Tar xərəkləri", ru: "Порожки для тара", en: "Tar Bridges" } },
          { slug: "tar-hisseleri", name: { az: "Tar aşığları və hissələri", ru: "Колки и детали для тара", en: "Tar Tuning Pegs & Parts" } },
          { slug: "tar-cantalari", name: { az: "Tar çantaları", ru: "Чехлы для тара", en: "Tar Bags & Cases" } }
        ]
      },
      {
        slug: "kamanca",
        name: {
          az: "Kamança və aksesuarları",
          ru: "Кяманча и аксессуары",
          en: "Kamancha & Accessories"
        },
        children: [
          { slug: "telebe-sade-kamancalar", name: { az: "Tələbə və sadə kamançalar", ru: "Ученические и простые кяманчи", en: "Student & Basic Kamanchas" } },
          { slug: "orta-pesekar-kamancalar", name: { az: "Orta və peşəkar kamançalar", ru: "Полупрофессиональные и профессиональные кяманчи", en: "Semi-Pro & Professional Kamanchas" } },
          { slug: "sedefli-kamancalar", name: { az: "Sədəfli kamançalar", ru: "Кяманчи с инкрустацией перламутром", en: "Mother-of-Pearl Inlaid Kamanchas" } },
          { slug: "kamanca-simleri", name: { az: "Kamança simləri", ru: "Струны для кяманчи", en: "Kamancha Strings" } },
          { slug: "smicoklar-ve-tuk", name: { az: "Smicoklar və at tükü", ru: "Смычки и конский волос", en: "Kamancha Bows & Horsehair" } },
          { slug: "kamanca-hisseleri", name: { az: "Xərəklər, dizliklər və simkeşlər", ru: "Подставки, ножки-упоры и струнодержатели", en: "Bridges, Endpins & Tailpieces" } },
          { slug: "kamanca-cantalari", name: { az: "Kamança çantaları", ru: "Чехлы для кяманчи", en: "Kamancha Bags & Cases" } }
        ]
      },
      {
        slug: "saz-ve-baglama",
        name: {
          az: "Saz və bağlama",
          ru: "Саз и баглама",
          en: "Saz & Baglama"
        },
        children: [
          { slug: "boyuk-saz", name: { az: "Böyük saz", ru: "Большой (классический) саз", en: "Standard Long-Neck Saz" } },
          { slug: "cure-saz", name: { az: "Cürə saz", ru: "Джура саз (малый саз)", en: "Cura Saz" } },
          { slug: "qedimi-saz", name: { az: "Qədimi saz", ru: "Традиционный (старинный) саз", en: "Traditional Saz" } },
          { slug: "turk-baglamasi", name: { az: "Türk bağlaması (Qısa və uzun sap)", ru: "Турецкая баглама (короткий и длинный гриф)", en: "Turkish Baglama (Short & Long Neck)" } },
          { slug: "elektro-baglama", name: { az: "Elektro bağlama", ru: "Электробаглама", en: "Electric Baglama" } },
          { slug: "saz-baglama-simleri", name: { az: "Saz və bağlama simləri", ru: "Струны для саза и багламы", en: "Saz & Baglama Strings" } },
          { slug: "saz-aksesuarlari", name: { az: "Saz mizrabları, kəmərlər və çantalar", ru: "Медиаторы (тезене), ремни и чехлы для саза", en: "Saz Picks, Straps & Bags" } }
        ]
      },
      {
        slug: "qanun-ve-ud",
        name: {
          az: "Qanun və ud",
          ru: "Канон и уд",
          en: "Qanun & Oud"
        },
        children: [
          { slug: "qanun", name: { az: "Qanun", ru: "Канон (Канун)", en: "Qanun (Kanun)" } },
          { slug: "ud", name: { az: "Ud", ru: "Уд", en: "Oud" } },
          { slug: "qanun-aksesuarlari", name: { az: "Qanun aksesuarları (Simlər, mizrab, üskük, açar)", ru: "Аксессуары для канона (струны, плектры, наперстки, ключ)", en: "Qanun Accessories (Strings, Picks, Rings, Key)" } },
          { slug: "ud-aksesuarlari", name: { az: "Ud aksesuarları (Simlər, mizrab, çanta)", ru: "Аксессуары для уда (струны, медиаторы, чехлы)", en: "Oud Accessories (Strings, Picks, Bags)" } }
        ]
      },
      {
        slug: "milli-nefes-aletleri",
        name: {
          az: "Milli nəfəs alətləri",
          ru: "Национальные духовые инструменты",
          en: "Traditional Wind Instruments"
        },
        children: [
          { slug: "balaban-mey", name: { az: "Balaban və mey", ru: "Балабан и мэй", en: "Balaban & Mey" } },
          { slug: "tutek", name: { az: "Tütək", ru: "Тютек", en: "Tutek" } },
          { slug: "ney", name: { az: "Ney", ru: "Ней", en: "Ney" } },
          { slug: "zurna", name: { az: "Zurna", ru: "Зурна", en: "Zurna" } },
          { slug: "milli-qamislar", name: { az: "Balaban və zurna qamışları, millər", ru: "Трости для балабана и зурны, пищики", en: "Balaban & Zurna Reeds, Staples" } }
        ]
      },
      {
        slug: "milli-zerb-aletleri",
        name: {
          az: "Milli zərb alətləri",
          ru: "Национальные ударные инструменты",
          en: "Traditional Percussion"
        },
        children: [
          { slug: "nagara", name: { az: "Nağara və qoşa nağara", ru: "Нагара и гоша-нагара", en: "Nagara & Gosha Nagara" } },
          { slug: "qaval-def", name: { az: "Qaval və dəf", ru: "Гавал и деф", en: "Gaval & Daf" } },
          { slug: "zerb-darbuka", name: { az: "Zərb və darbuka", ru: "Зерб и дарбука", en: "Zerb & Darbuka" } },
          { slug: "davul", name: { az: "Davul", ru: "Давул", en: "Davul" } },
          { slug: "zerb-uzlukleri", name: { az: "Darbuka və nağara üzlükləri (Dərilər)", ru: "Пластики и мембраны для ударных", en: "Drum Heads & Skins" } },
          { slug: "zerb-cantalari", name: { az: "Zərb çantaları və kəmərləri", ru: "Чехлы и ремни для нагары и давула", en: "Percussion Bags & Straps" } }
        ]
      }
    ]
  },
  {
    slug: "pianolar-ve-klavisler",
    order_index: 3,
    name: {
      az: "Pianolar və klavişli alətlər",
      ru: "Клавишные инструменты",
      en: "Keyboards & Pianos"
    },
    children: [
      { slug: "elektron-pianolar", name: { az: "Rəqəmsal (Elektro) pianolar", ru: "Цифровые пианино", en: "Digital Pianos" } },
      { slug: "portativ-pianolar", name: { az: "Portativ pianolar", ru: "Портативные пианино", en: "Portable Digital Pianos" } },
      { slug: "akustik-pianolar", name: { az: "Akustik pianolar və royallar", ru: "Акустические пианино и рояли", en: "Acoustic Pianos & Grand Pianos" } },
      { slug: "sintezatorlar", name: { az: "Sintezatorlar və MIDI klaviaturalar", ru: "Синтезаторы и MIDI-клавиатуры", en: "Synthesizers & MIDI Keyboards" } },
      { slug: "qarmon-akkordeon", name: { az: "Qarmon və akkordeon", ru: "Гармонь и аккордеон", en: "Garmon & Accordions" } },
      { slug: "melodika-harmonica", name: { az: "Melodika və dodaq qarmonları", ru: "Мелодики и губные гармошки", en: "Melodicas & Harmonicas" } },
      {
        slug: "piano-aksesuarlari",
        name: {
          az: "Piano aksesuarları və hissələri",
          ru: "Аксессуары для клавишных и запчасти",
          en: "Piano Accessories & Parts"
        },
        children: [
          { slug: "piano-oturacaqlari", name: { az: "Piano oturacaqları (Banketlər)", ru: "Банкетки и стулья для пианино", en: "Piano Benches & Stools" } },
          { slug: "pedallar-adaptorlar", name: { az: "Sustain və blok pedallar", ru: "Педали сустейна и педальные блоки", en: "Sustain & Multi-Pedals" } },
          { slug: "sintezator-cantalari", name: { az: "Sintezator çantaları", ru: "Чехлы для синтезаторов", en: "Keyboard Gig Bags" } },
          { slug: "klavis-dayaqlari", name: { az: "Klaviş və sintezator dayaqları", ru: "Стойки для клавишных инструментов", en: "Keyboard Stands" } }
        ]
      }
    ]
  },
  {
    slug: "yayli-aletler",
    order_index: 4,
    name: {
      az: "Skripkalar və yaylı alətlər",
      ru: "Скрипки и смычковые",
      en: "Orchestral Strings"
    },
    children: [
      { slug: "skripkalar", name: { az: "Akustik skripkalar", ru: "Акустические скрипки", en: "Acoustic Violins" } },
      { slug: "elektro-skripkalar", name: { az: "Elektro skripkalar", ru: "Электроскрипки", en: "Electric Violins" } },
      { slug: "viola", name: { az: "Viola (Alt)", ru: "Альт (Виола)", en: "Violas" } },
      { slug: "cello", name: { az: "Çello (Violonçel)", ru: "Виолончель (Челло)", en: "Cellos" } },
      { slug: "kontrabas", name: { az: "Kontrabas", ru: "Контрабас", en: "Double Basses" } },
      {
        slug: "yayli-alet-aksesuarlari",
        name: {
          az: "Yaylı alət aksesuarları",
          ru: "Аксессуары для смычковых",
          en: "String Instrument Accessories"
        },
        children: [
          { slug: "yayli-simler", name: { az: "Skripka, alt və çello simləri", ru: "Струны для скрипки, альта и виолончели", en: "Strings for Violin, Viola & Cello" } },
          { slug: "yayli-smicoklar", name: { az: "Smicoklar (Kamanlar)", ru: "Смычки", en: "Bows" } },
          { slug: "mostikler", name: { az: "Mostiklər (Çiyinliklər)", ru: "Мостики (плечевые упоры)", en: "Shoulder Rests" } },
          { slug: "cenelikler-simkesler", name: { az: "Çənəliklər, simkeşlər və maşinkalar", ru: "Подбородники, подгрифки и машинки", en: "Chinrests, Tailpieces & Fine Tuners" } },
          { slug: "kanifollar", name: { az: "Kanifollar", ru: "Канифоль", en: "Rosin" } },
          { slug: "yayli-cantalar", name: { az: "Yaylı alət keysləri və çantaları", ru: "Футляры и чехлы для смычковых", en: "Cases & Gig Bags" } }
        ]
      }
    ]
  },
  {
    slug: "nefes-aletleri",
    order_index: 5,
    name: {
      az: "Nəfəs alətləri",
      ru: "Духовые инструменты",
      en: "Wind & Brass"
    },
    children: [
      { slug: "saksofon", name: { az: "Saksofonlar (Alto, Tenor, Soprano)", ru: "Саксофоны (Альт, Тенор, Сопрано)", en: "Saxophones (Alto, Tenor, Soprano)" } },
      { slug: "klarnet", name: { az: "Klarnetlər", ru: "Кларнеты", en: "Clarinets" } },
      { slug: "fleyta", name: { az: "Fleytalar", ru: "Флейты", en: "Flutes" } },
      { slug: "truba-trombon", name: { az: "Trubalar və trombonlar", ru: "Трубы и тромбоны", en: "Trumpets & Trombones" } },
      { slug: "valtorna-qoboy", name: { az: "Valtorna və qoboy", ru: "Валторны и гобои", en: "French Horns & Oboes" } },
      {
        slug: "nefes-aksesuarlari",
        name: {
          az: "Nəfəs aləti aksesuarları",
          ru: "Аксессуары для духовых",
          en: "Wind Instrument Accessories"
        },
        children: [
          { slug: "qamislar", name: { az: "Klarnet və saksofon qamışları", ru: "Трости для кларнета и саксофона", en: "Clarinet & Saxophone Reeds" } },
          { slug: "mustukler", name: { az: "Müştüklər, liqaturalar və qapaqlar", ru: "Мундштуки, лигатуры и колпачки", en: "Mouthpieces, Ligatures & Caps" } },
          { slug: "nefes-cantalari", name: { az: "Nəfəs kəmərləri, yastıqcıqlar və çantalar", ru: "Гайтаны (ремни), подушечки и чехлы", en: "Neck Straps, Pads & Bags" } }
        ]
      }
    ]
  },
  {
    slug: "zerb-aletleri",
    order_index: 6,
    name: {
      az: "Barabanlar və perkussiya",
      ru: "Ударные и перкуссия",
      en: "Drums & Percussion"
    },
    children: [
      { slug: "akustik-barabanlar", name: { az: "Akustik baraban dəstləri", ru: "Акустические ударные установки", en: "Acoustic Drum Kits" } },
      { slug: "elektron-barabanlar", name: { az: "Elektron barabanlar", ru: "Электронные ударные установки", en: "Electronic Drum Kits" } },
      { slug: "mars-barabanlari", name: { az: "Marş barabanları", ru: "Маршевые барабаны", en: "Marching & Snare Drums" } },
      { slug: "etnik-perkussiya", name: { az: "Konqa, bonqo və cembe", ru: "Конги, бонго и джембе", en: "Congas, Bongos & Djembes" } },
      { slug: "el-ritmleri", name: { az: "Əl ritmləri (Tamburin, şeyker, marakas)", ru: "Шумовая перкуссия (Тамбурины, шейкеры)", en: "Hand Percussion (Tambourines, Shakers)" } },
      { slug: "kalimba", name: { az: "Kalimba", ru: "Калимба", en: "Kalimba" } },
      { slug: "baraban-aksesuarlari", name: { az: "Baraban çubuqları və aksesuarları", ru: "Барабанные палочки и аксессуары", en: "Drumsticks & Hardware" } }
    ]
  },
  {
    slug: "audio-ve-studia",
    order_index: 7,
    name: {
      az: "Audio, studiya və səhnə",
      ru: "Звук и студия",
      en: "Pro Audio & Studio"
    },
    children: [
      {
        slug: "mikrofonlar",
        name: {
          az: "Mikrofonlar",
          ru: "Микрофоны",
          en: "Microphones"
        },
        children: [
          { slug: "simsiz-mikrofonlar", name: { az: "Simsiz mikrofon sistemləri (Yaxalıq/Əl)", ru: "Радиосистемы (беспроводные петлички/ручные)", en: "Wireless Systems (Lavalier & Handheld)" } },
          { slug: "kabelli-mikrofonlar", name: { az: "Kabelli vokal əl mikrofonları", ru: "Проводные вокальные микрофоны", en: "Wired Vocal Handheld Microphones" } },
          { slug: "studia-mikrofonlari", name: { az: "Studiya kondensator mikrofonları", ru: "Студийные конденсаторные микрофоны", en: "Studio Condenser Microphones" } },
          { slug: "instrumental-mikrofonlar", name: { az: "İnstrumental mikrofonlar", ru: "Инструментальные микрофоны", en: "Instrument Microphones" } }
        ]
      },
      { slug: "dinamikler", name: { az: "Aktiv dinamiklər və kolonkalar", ru: "Активные акустические системы (Колонки)", en: "Active PA Speakers & Monitors" } },
      { slug: "kombo-guclendiriciler", name: { az: "Gitara və bas komboları (Gücləndiricilər)", ru: "Комбоусилители для гитар и баса", en: "Guitar & Bass Amplifiers (Combos)" } },
      { slug: "ses-kartlari-mikserler", name: { az: "Səs kartları və mikşer pultları", ru: "Аудиоинтерфейсы и микшеры", en: "Audio Interfaces & Mixing Consoles" } },
      { slug: "effekt-pedallari", name: { az: "Effekt pedalları və prosessorlar", ru: "Гитарные педали эффектов и процессоры", en: "Guitar Effect Pedals & Processors" } },
      { slug: "simsiz-oturuculer", name: { az: "İnstrumental ötürücülər (Transmitterlər)", ru: "Инструментальные радиосистемы", en: "Wireless Guitar Systems (Transmitters)" } },
      { slug: "studiya-qulaqliqlari", name: { az: "Studiya qulaqlıqları", ru: "Студийные наушники", en: "Studio Monitoring Headphones" } }
    ]
  },
  {
    slug: "kabeller-dayaqlar-aksesuarlar",
    order_index: 8,
    name: {
      az: "Kabellər, dayaqlar və aksesuarlar",
      ru: "Коммутация и стойки",
      en: "Cables, Stands & Accessories"
    },
    children: [
      { slug: "ses-kabelleri", name: { az: "Səs kabelləri (XLR, Jack, AUX, RCA)", ru: "Аудиокабели (XLR, Jack, AUX, RCA)", en: "Audio Cables (XLR, Jack, AUX, RCA)" } },
      { slug: "stekkerler-perexodnikler", name: { az: "Ştekerlər və keçiricilər (Perexodniklər)", ru: "Разъемы, переходники и адаптеры", en: "Connectors & Audio Adapters" } },
      { slug: "mikrofon-dinamik-dayaqlari", name: { az: "Mikrofon və dinamik dayaqları", ru: "Стойки для микрофонов и акустических систем", en: "Microphone & Speaker Stands" } },
      { slug: "alet-not-dayaqlari", name: { az: "Alət və not dayaqları (Püpitrlər)", ru: "Стойки для инструментов и пюпитры", en: "Instrument & Music Sheet Stands" } },
      { slug: "adapterler-batareyalar", name: { az: "Qida blokları, adapterlər və batareyalar", ru: "Блоки питания, адаптеры и батарейки", en: "Power Supplies, Adapters & Batteries" } },
      { slug: "musiqi-kitablari", name: { az: "Musiqi dərslikləri və not kitabları", ru: "Нотная литература и учебные пособия", en: "Music Books & Sheet Music" } },
      { slug: "suvenirler-usaq-aletleri", name: { az: "Suvenirlər və uşaq musiqi alətləri", ru: "Сувениры и детские музыкальные инструменты", en: "Souvenirs & Kids Musical Toys" } }
    ]
  }
];

export const FORBIDDEN_RULES = {
  artisans: ['teymur', 'bəxtiyar', 'baxtiyar', 'sahib', 'fərhad', 'farhad', 'fərrux', 'farrux', 'rövşən', 'rovsan', 'tahir'],
  sizes: ['4/4', '3/4', '1/2', '1/4', '4/3', '16/1', '8/1', '5 oktava', 'tam oktava'],
  brands: ['dominguez', 'vivaldi', 'korg', 'miles', 'vandoren', 'rico', 'helena mia', 'swing', 'rigotti', 'irin', 'kaysen'],
  materials: ['qoz', 'fıstıq', 'fistiq', 'ebonit', 'plastik', 'tekstolit', 'latun', 'dəmir', 'demir']
};

// Mapping of legacy English slugs to new canonical Azerbaijani slugs for seamless backwards compatibility
export const SLUG_LEGACY_ALIASES = {
  guitars: "gitaralar",
  keys: "pianolar-ve-klavisler",
  pianos: "pianolar-ve-klavisler",
  keyboards: "pianolar-ve-klavisler",
  bowed: "yayli-aletler",
  "string-instruments": "yayli-aletler",
  "wind-instruments": "nefes-aletleri",
  winds: "nefes-aletleri",
  percussion: "zerb-aletleri",
  drums: "zerb-aletleri",
  "national-instruments": "milli-musiqi-aletleri",
  national: "milli-musiqi-aletleri",
  "audio-equipment": "audio-ve-studia",
  audio: "audio-ve-studia",
  studio: "audio-ve-studia",
  accessories: "kabeller-dayaqlar-aksesuarlar"
};


