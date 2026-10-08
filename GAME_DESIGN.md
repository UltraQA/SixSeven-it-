# SixSeven it!

## Game Design Document — v1.0

**Статус:** Pre-production / MVP specification  
**Платформа:** iOS, iPhone-first  
**Жанр:** Casual / Entertainment / Decision helper  
**Рабочее название:** `SixSeven it!`  
**Слоган:** `Can't decide? Sixseven it.`  
**Язык документа:** русский; UI-строки и technical identifiers — English

## 1. Видение и аудитория

`SixSeven it!` — короткая интерактивная игра-рандомайзер, стилизованная под мем Six Seven. Пользователь формулирует вопрос или запускает бросок и получает `6`, `7` или редкий `67`, когда монета «встаёт на ребро». Ценность — в простом, приятном и легко распространяемом моменте.

Основная аудитория — подростки и молодые взрослые, знакомые с мемом Six Seven. Вторичная — пользователи casual-рандомайзеров без аккаунта.

Принципы: instant, satisfying, funny, shareable, honest, accessible.

## 2. Игровой цикл

`Idle → Input (optional) → Flip in progress → Result → Share or Flip again`

Home screen содержит tagline, поле с placeholder `What are you deciding?`, крупную монету, `Flip it!`, motion affordance и доступ к `Stats`/`Settings`. До завершения броска новые запуски блокируются.

Точный timeline MVP: `Flip it!`/swipe → RNG выбирает outcome → coin animation (`650ms`) → coin settles → показываются outcome, `Share result` и заданный вопрос → запускаются haptic/audio feedback → следующий flip заблокирован на `1.25s`. Вопрос сохраняется в `FlipResult`, а input очищается после показа результата.

Запуск: кнопка, свайп вверх по монете или shake, если motion control включён.

## 3. Результаты и RNG

| Outcome | Probability | Meaning |
|---|---:|---|
| `6` | 47.5% | Первый вариант |
| `7` | 47.5% | Второй вариант |
| `67` | 5% | Редкий edge result |

Результат выбирается до анимации через системный RNG за abstraction `RandomNumberGenerating`. Анимация только визуализирует выбранный outcome; точная физическая симуляция не входит в MVP.

Рекомендуется integer mapping `0...9999`: 4750 значений для `6`, 4750 для `7` и 500 для `67`. Вероятности находятся в `GameRules`, сумма равна 100%, RNG заменяем в тестах.

## 4. Подача

MVP допускает SwiftUI renderer через `Canvas`, `Shape` и rotation/scale animation. Стороны монеты — крупные цифры `6` и `7`; edge state — `67`.

Обычный результат: подъём, вращение, падение, settling. `67`: замедление, wobble, балансирование, zoom-in и celebration effect. При Reduce Motion эффекты упрощаются.

Haptics: launch — light impact; обычный result — medium impact; `67` — impact + success notification. Audio — короткие локальные effects через `AVAudioSession`, toggle `Sound Effects`. Отсутствие capability не ломает игру.

UI-строки: `Flip`, `SIX SEVEN!`, `Again`, `Share result`, `Sound Effects`, `Motion Control`.

## 5. Result и sharing

После броска показываются outcome, `It's a 6`/`It's a 7`/`SIX SEVEN!`, вопрос и действия `Share result`/`Flip again`.

MVP использует текстовый payload: `I asked SixSeven it!: “Should I text my ex?” → 67. Can't decide? Sixseven it.` В post-MVP допустима share card через `ImageRenderer`.

## 6. Статистика и scope

MVP сохраняет локально: `totalFlips`, counts каждого outcome, `sixtySeven` count, текущую/максимальную серию и timestamp. История вопросов — опциональна и требует privacy-решения.

В MVP входят Home, optional question, три outcome 47.5/47.5/5, button/swipe/optional shake, SwiftUI animation, haptics, sound toggle, result, Share Sheet, statistics, Dynamic Type, VoiceOver, Dark Mode, Reduce Motion и unit tests.

Не входят: online multiplayer, accounts, backend, ads, purchases, leaderboards, обязательная физика, обязательный RealityKit, cloud sync и полноценная локализация.

Post-MVP: RealityKit prototype, result cards, achievements (`Three Sixes`, `Lucky Seven`, `SIX SEVEN!`, `Double Trouble`), History, daily challenge, streaks, themes, privacy-first analytics и App Store experiments.

## 7. Метрики и roadmap

Ориентиры MVP: time-to-first-flip < 15 секунд; crash-free sessions > 99.5%; успешное завершение броска > 99%; второй бросок; share rate результата `67`; feedback по понятности.

P1 — polish и RealityKit prototype. P2 — retention mechanics. P3 — growth/analytics/monetization decision. Retention thresholds открыты.

## 8. Допущения и открытые решения

Зафиксировано: `67` имеет 5%; outcome выбирается до animation; storage local-only; регистрация не нужна; UI English, docs Russian.

Открыто: финальное имя (`SixSeven it!` или `6 or 7?`); хранить ли вопросы; обязательность RealityKit; лицензирование meme-like audio; analytics/privacy; финальные brand tokens.

## 9. Definition of Done

Пользователь без аккаунта открывает приложение, запускает бросок поддержанным способом, получает один из трёх исходов, видит понятный результат, делится им и сохраняет статистику после relaunch. Критические сценарии покрыты tests и работают при Dynamic Type/Reduce Motion.
