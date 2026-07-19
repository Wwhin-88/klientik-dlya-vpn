# План разработки VPN-клиента «vpnchik»

> Статус: **Этап 0 выполнен** ✅ | Этап 1-5 ожидают

---

## Этап 0: Подготовка окружения

| Шаг | Описание | Статус |
|-----|----------|--------|
| 0.1 | Клонирование форка `Wwhin-88/klientik-dlya-vpn` | ✅ Готово |
| 0.2 | Flutter SDK 3.44.6 (Dart 3.12.2) | ✅ Установлен |
| 0.3 | Инициализация git submodules | ✅ Готово (SSH → HTTPS исправлены) |
| 0.4 | `flutter pub get` | ✅ Зависимости установлены |
| 0.5 | Android toolchain (cmdline-tools) | ❌ Требуется установка Android Studio |
| 0.6 | Windows toolchain | ❌ Нужна Windows-машина для сборки EXE |

### Заметки по окружению
- **Репозиторий:** `/Users/admin/Documents/vpnclientik`
- **Origin:** `https://github.com/Wwhin-88/klientik-dlya-vpn.git`
- **Upstream:** `https://github.com/hiddify/hiddify-app.git` (для синхронизации)
- **Flutter:** 3.44.6 stable, macOS arm64
- **Сабмодули в .gitmodules — исправлены с SSH на HTTPS**
- **Android SDK:** не настроен — установить Android Studio для cmdline-tools
- **Windows сборка:** невозможна на macOS, нужна отдельная Windows-машина или CI

---

## Этап 1: Ребрендинг — замена названия и метаданных ✅

| Шаг | Файл | Что меняем | Статус |
|-----|------|-----------|--------|
| 1.1 | `pubspec.yaml` | `name: vpnchik`, описание | ✅ |
| 1.2 | `lib/core/model/constants.dart` | `appName = 'vpnchik'`, обновлены URL, сохранены все *Const классы | ✅ |
| 1.3 | `android/app/build.gradle` | `applicationId "com.vpnchik.app"`, namespace, testNamespace | ✅ |
| 1.4 | `android/app/src/main/AndroidManifest.xml` | `android:label="vpnchik"`, URL scheme `vpnchik://` | ✅ |
| 1.5 | `android/app/src/main/kotlin/com/hiddify/...` | Переименовано в `com/vpnchik/app/`, 37 Kotlin файлов | ✅ |
| 1.6 | `windows/runner/Runner.rc` + `main.cpp` | Название окна, mutex, все строки | ✅ |
| 1.7 | macOS/iOS xcconfig, Info.plist | PRODUCT_NAME, bundle ID, URL scheme, Swift | ✅ |
| 1.8 | Mass replace `package:hiddify/` → `package:vpnchik/` | 220+ Dart файлов | ✅ |
| 1.9 | `flutter pub get` + `build_runner` | Перегенерация 1061 .g.dart/.freezed.dart | ✅ |
| 1.10 | `flutter analyze` | **0 errors**, 405 info (всё чисто) | ✅ |

---

## Этап 2: Хардкод VPN-ключа (авто-подключение)

### VLESS ключ:
```
vless://8e31b30c-2c25-4ff9-8ffb-82b836ecf0d7@79.76.57.148:443
  ?encryption=none
  &flow=xtls-rprx-vision
  &fp=chrome
  &pbk=i1c2a9rh4YOnq6c3bIrru_aCIluxnBMct0Od6eM9_Xg
  &security=reality
  &sid=c5ba
  &sni=images.apple.com
  &spx=%2F28242087155299c
  &type=tcp
  #for-lubimaya-lubimaya
```

| Шаг | Файл | Что делаем | Статус |
|-----|------|-----------|--------|
| 2.1 | `lib/core/hardcoded_config.dart` | **НОВЫЙ ФАЙЛ** — константы с VLESS URL | ⏳ |
| 2.2 | `lib/core/preferences/general_preferences.dart` | Добавить флаг `firstProfileCreated` | ⏳ |
| 2.3 | `lib/bootstrap.dart` | После `_init("profile repository")` авто-добавить профиль | ⏳ |
| 2.4 | `lib/features/intro/widget/intro_page.dart` | При нажатии "Start" → создать профиль + авто-коннект | ⏳ |
| 2.5 | Проверить парсинг VLESS URL через `ProfileParser` | Sing-box парсит VLESS ссылки нативно | ⏳ |

### Логика авто-подключения:
1. При первом запуске — онбординг (локализация + старт)
2. После онбординга проверяем `firstProfileCreated == false`
3. Создаём `LocalProfileEntity` с VLESS ссылкой
4. Устанавливаем профиль как активный
5. Вызываем `connectionNotifier.toggleConnection()` для подключения

---

## Этап 3: Кастомный дизайн в аниме-стиле

### 3.1 Цветовая палитра (пастельные тона)
Файл: `lib/core/theme/app_theme.dart`

| Токен | Цвет | Hex |
|-------|------|-----|
| Primary | Пастельно-розовый | `#F8BBD0` / `#FFB5C2` |
| Secondary | Пастельно-персиковый | `#FFD1B3` |
| Tertiary | Лавандовый | `#E8D5F5` / `#D1C4E9` |
| Surface | Кремово-белый | `#FFFAF5` |
| Background | Светло-розовый | `#FFF0F3` |

| Шаг | Файл | Что делаем | Статус |
|-----|------|-----------|--------|
| 3.1a | `lib/core/theme/app_theme.dart` | Новая пастельная палитра, только светлая тема | ⏳ |
| 3.1b | `lib/features/app/widget/app.dart` | `themeMode: ThemeMode.light` (форсируем светлую) | ⏳ |

### 3.2 Кастомные иконки в аниме-стиле
| Шаг | Файл | Что делаем | Статус |
|-----|------|-----------|--------|
| 3.2a | `assets/icons/` | SVG иконки: кошачьи лапки, звёздочки, сердечки | ⏳ |
| 3.2b | `pubspec.yaml` | Добавить ассеты `assets/icons/` | ⏳ |
| 3.2c | Главная/home_page | Заменить Material-иконки на кастомные | ⏳ |

### 3.3 Анимированный фон на главном экране
| Шаг | Файл | Что делаем | Статус |
|-----|------|-----------|--------|
| 3.3a | `lib/features/home/widget/anime_background.dart` | **НОВЫЙ ФАЙЛ** — CustomPainter с плавающими сердечками/лепестками | ⏳ |
| 3.3b | `lib/features/home/widget/home_page.dart` | Заменить `world_map.png` на `AnimeBackground` | ⏳ |

### 3.4 Кнопка подключения
Файл: `lib/features/home/widget/connection_button.dart` (найти через grep)
| Шаг | Что делаем | Статус |
|-----|-----------|--------|
| 3.4a | Закруглённые углы (borderRadius: 24) | ⏳ |
| 3.4b | Градиент: розовый → оранжевый → фиолетовый | ⏳ |
| 3.4c | Анимация свечения при нажатии | ⏳ |
| 3.4d | Иконка в виде звёздочки/лапки | ⏳ |

### 3.5 Анимации при нажатии
| Шаг | Файл | Что делаем | Статус |
|-----|------|-----------|--------|
| 3.5a | `lib/features/home/widget/home_page.dart` | AnimatedContainer при тапах | ⏳ |
| 3.5b | `lib/features/profile/widget/profile_tile_main.dart` | Scale-анимация + сердечки | ⏳ |
| 3.5c | `lib/features/settings/widget/preference_tile.dart` | Плавные переходы цвета | ⏳ |

### 3.6 Экран онбординга
| Шаг | Файл | Что делаем | Статус |
|-----|------|-----------|--------|
| 3.6a | `lib/features/intro/widget/intro_page.dart` | Убрать GitHub/лицензия ссылки, пастельный фон | ⏳ |
| 3.6b | `lib/features/intro/widget/intro_page.dart` | Кнопка "Начать" с градиентом | ⏳ |
| 3.6c | `lib/features/intro/widget/intro_page.dart` | Плавающие элементы на фоне | ⏳ |

### 3.7 Шрифт
| Шаг | Что делаем | Статус |
|-----|-----------|--------|
| 3.7a | Выбрать шрифт (Nunito / Quicksand / Comic Neue) | ⏳ |
| 3.7b | `pubspec.yaml` — добавить google_fonts или кастомный шрифт | ⏳ |
| 3.7c | `lib/core/theme/app_theme.dart` — применить шрифт | ⏳ |

---

## Этап 4: Финализация и скрытие лишнего

| Шаг | Файл | Что делаем | Статус |
|-----|------|-----------|--------|
| 4.1 | `lib/features/home/widget/home_page.dart` | Скрыть кнопку "Добавить профиль" (+) | ⏳ |
| 4.2 | `lib/features/settings/...` | Упростить настройки (убрать WARP, TLS-трюки, DNS, регион) | ⏳ |
| 4.3 | `lib/core/analytics/analytics_controller.dart` | Отключить Sentry/аналитику по умолчанию | ⏳ |
| 4.4 | `lib/features/profile/...` | Убрать Free Profiles кнопки | ⏳ |
| 4.5 | `lib/features/settings/...` | Убрать кнопку обновления, проверки обновлений | ⏳ |

---

## Этап 5: Сборка и коммит

| Шаг | Команда | Статус |
|-----|---------|--------|
| 5.1 | `flutter build apk --release` | ⏳ (нужен Android SDK) |
| 5.2 | `flutter build windows --release` | ⏳ (нужна Windows-машина) |
| 5.3 | `git add -A && git commit && git push origin main` | ⏳ |

---

## Блокирующие проблемы

1. **Android SDK (cmdline-tools)** — нужно установить Android Studio или sdkmanager
2. **Windows сборка** — невозможна на macOS, нужна отдельная машина или GitHub Actions CI
