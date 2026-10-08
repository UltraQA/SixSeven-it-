# SixSeven it! — дизайн-система MVP

## Направление

Рекомендуемое направление — **warm editorial arcade**: тёплые бумажные поверхности, почти чёрный ink, крупная округлая типографика и три самостоятельных цвета исходов. Интерфейс должен ощущаться быстрым и немного дерзким, но не превращаться в шумный мемный экран.

Цвет не сообщает «правильный» ответ: `6`, `7` и `67` — равноценные варианты игры. Поэтому палитра не использует красный/зелёный семантический паттерн и не полагается только на цвет для различения.

## Цветовые токены

Все значения ниже — source tokens. SwiftUI semantic tokens находятся в `SixSevenColors`.

| Token | Light | Dark | Назначение |
|---|---|---|---|
| `backgroundPrimary` | `#F6F6F2` | `#11110F` | Основной фон Home/Stats/Settings |
| `backgroundSecondary` | `#ECECE6` | `#1A1A17` | Вторичный фон и будущие секции |
| `surfaceElevated` | `#FFFFFF` | `#24241F` | Карточки, input, elevated controls |
| `contentPrimary` | `#171715` | `#F5F4EE` | Основной текст и primary button |
| `contentSecondary` | `#666660` | `#B9B8AF` | Подзаголовки, helper text |
| `separator` | `#D8D8D0` | `#3A3A34` | Обводки и разделители |
| `accentSix` | `#155EEF` | `#6D9BFF` | Исход `6` |
| `accentSeven` | `#6E42D7` | `#B59AFF` | Исход `7` |
| `accentRare` | `#C87900` | `#FFD166` | Редкий исход `67` |

`accentSix`, `accentSeven` и `accentRare` имеют достаточный визуальный контраст на собственных coin surfaces. В тексте результата одновременно используется число/label и цвет; VoiceOver получает текстовое значение (`6`, `7`, `SIX SEVEN`).

## Типографика

Используется системный San Francisco с `rounded` design там, где нужен игровой бренд. Это сохраняет Dynamic Type, локальную поддержку iOS и нулевую зависимость от лицензируемого шрифта.

| Роль | SwiftUI token | Применение |
|---|---|---|
| Eyebrow | `SixSevenTypography.eyebrow` | `CAN'T DECIDE?`, labels карточек |
| Hero | `SixSevenTypography.hero` | `Sixseven it.` |
| Display | `SixSevenTypography.display` | `It's a 6`, `SIX SEVEN!` |
| Title | `SixSevenTypography.title` | Primary/secondary buttons |
| Body | `SixSevenTypography.body` | Вопрос и основной текст |
| Callout | `SixSevenTypography.callout` | Tagline и helper text |
| Caption | `SixSevenTypography.caption` | Motion hint и пояснения |
| Metric | `SixSevenTypography.metric` | Числа в Stats |

Eyebrow использует небольшое tracking только для коротких uppercase-labels. Не использовать tracking на длинных пользовательских строках и вопросах.

## Геометрия

Базовая spacing scale: `4 / 8 / 12 / 16 / 24 / 32 / 48pt`.

- `control = 16pt`: buttons, text controls, toggles around the content.
- `card = 24pt`: decision card, result question card, elevated surfaces.
- `hero = 32pt`: reserved for future large hero containers.
- Минимальная интерактивная область — `44×44pt`; фактическая primary button height — `52pt`.
- Coin base diameter — `220pt`, масштабируется через `@ScaledMetric`.
- Тени мягкие и редкие: coin использует цветной shadow, карточки не используют heavy shadow.

## Компоненты и SwiftUI mapping

| Product component | SwiftUI implementation |
|---|---|
| Decision card | `SixSevenCard` + `TextField(axis: .vertical)` |
| Coin renderer | `CoinView` на `Circle`, `LinearGradient`, `rotation3DEffect` |
| Primary action | `SixSevenPrimaryButtonStyle` |
| Secondary/share action | `SixSevenSecondaryButtonStyle` + `ShareLink` |
| Result question card | `RoundedRectangle` с теми же card tokens |
| Stats row | `List` row с outcome color + monospaced metric |
| Settings row | Native `Form`/`Toggle`, system accessibility behavior |
| Navigation actions | `NavigationStack` + SF Symbols `chart.bar`, `gearshape` |

Бизнес-логика остаётся в `HomeViewModel`. `HomeView` только отображает state и отправляет intents (`flip`, `flipAgain`, swipe). `CoinView` не знает о probabilities, storage и RNG.

## Макеты экранов

### Home — idle

1. Inline navigation title `SixSeven it!`; справа `Stats` и `Settings`.
2. Centered header: eyebrow `CAN'T DECIDE?`, hero `Sixseven it.`, tagline `Let the numbers make the call.`
3. Decision card: label `YOUR DECISION`, optional multiline input.
4. Coin stage: neutral coin with `?`, helper `Swipe up to flip`.
5. Reserved result label `Ready when you are`.
6. Full-width `Flip it` primary button.

### Home — result

1. Coin показывает выбранный outcome.
2. Label: `It's a 6`, `It's a 7` или `SIX SEVEN!`.
3. При наличии вопроса — result question card.
4. `Flip again` остаётся на том же месте, чтобы действие не прыгало между состояниями.
5. Ниже появляется `Share result` secondary action.

### Stats

Native grouped `List` с тёплым фоном. В `Overview` показываются total/current/best streak. В `Outcomes` значения `6`, `7`, `67` получают соответствующий outcome color, но имеют текстовые labels и не зависят только от цвета.

### Settings

Native `Form`: `Sound Effects`, `Motion Control`, затем короткое объяснение shake control. Системные `Toggle` сохраняются ради знакомого поведения, Dynamic Type и VoiceOver.

## Motion и accessibility

- При `Reduce Motion` coin не делает 3D spin; остаётся короткий state transition.
- `67` усиливается scale/sparkle только визуально; текст и haptic — отдельные fallback-safe каналы.
- Swipe — дополнительный affordance, primary control всегда доступен кнопкой.
- Coin — один accessibility element с value `Ready`, `Flipping`, `6`, `7` или `SIX SEVEN`.
- Не использовать цвет как единственный сигнал; текст результата и форма UI обязательны.
- Проверять Light/Dark, Dynamic Type до `accessibilityXXXL`, VoiceOver labels, 44pt targets и landscape на iPhone.

## App icon concept

Квадратный icon с тёплым `#F6F6F2` полем, крупным чёрным `67` в rounded grotesk и коротким diagonal coin-edge highlight в `accentRare`. Не использовать буквальный screenshot мема и не добавлять мелкие детали: icon должен читаться на 60pt. Текущий placeholder остаётся до отдельного решения по финальной artwork и trademark review.

## Open decisions

- Финальная artwork монеты и App Icon: оставить native token-driven coin или заказать отдельную иллюстрацию.
- Проверить contrast финальных accent оттенков на реальных OLED-устройствах.
- Выбрать snapshot dependency после утверждения текущего layout.
- Лицензировать production audio; текущие WAV — только development placeholders.
