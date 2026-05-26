# AI Ledger & Development Log

AI-native development ledger documenting prompts, debug strategies, and software iterations during the creation of Guru Pulse & Trainer Pulse.

---

## AI Prompt Logs & Intents

### Prompt #1
- **Tool**: Gemini 3.5 Flash
- **Intent**: Generate reactive GetX database persistent layer with GetStorage.
- **Output Snippet**: Created storage controllers that parse `UserModel`, `MessageModel`, and `CallRequestModel` dynamic JSON objects from storage and seed core profiles on first-run.

### Prompt #2
- **Tool**: Gemini 3.5 Flash
- **Intent**: Scaffold a local WebSockets real-time server and client synchronization layer.
- **Output Snippet**: Designed `HttpServer` bindings on loopback loop, upgrading HTTP requests to WebSockets, and broadcasting typing states, chat dispatches, and room states reactively.

### Prompt #3
- **Tool**: Gemini 3.5 Flash
- **Intent**: Recreate premium custom widgets (press-scaling button animations, shadows, adaptive fields, CustomAppBars).
- **Output Snippet**: Coded `PrimaryButton` incorporating an `AnimatedScale` gestured tap-down bounce scale (0.96) and custom app bars holding role labels.

### Prompt #4
- **Tool**: Gemini 3.5 Flash
- **Intent**: Build diagnostic logs tracker and DevPanel overlay.
- **Output Snippet**: Implemented dynamic loggers categorizing events with colored tags (`[CHAT]`, `[RTC]`, `[SCHEDULE]`, `[AUTH]`) and displaying them scrollable inside the floating DevPanel diagnostics widget.

### Prompt #5
- **Tool**: Gemini 3.5 Flash
- **Intent**: Recreate the exact Stitch UI visual hierarchy, pixel-perfect visual spacing, and unified responsive themes matching the 12 screen specs.
- **Output Snippet**: Integrated unified theme extension system (`getGuruTheme()` and `getTrainerTheme()`), local spacing configurations (8pt grids), responsive app bars, card borders, and high-fidelity call grid layouts.

---

## Debugging Sessions & Iterations

### Diagnostic Case #1: Special Characters in PowerShell Copy
- **Issue**: Attempting to unzip `.docx` assessment specs failed in PowerShell due to Unicode question marks in the file name string literal ("Illegal characters in path").
- **Fix**: Re-engineered path references using piped FileInfo objects from `Get-ChildItem -Filter "*WTF Flutter*" | Copy-Item` to bypass string literal escapes. Resolved successfully.

### Diagnostic Case #2: GetX Dependency Lookups
- **Issue**: Registering `CallController` with a custom tag but calling `Get.find<CallController>()` without a tag threw dependency locator runtime exceptions.
- **Fix**: Standardized the `CallController` injection process by registering it without a tag globally in both app entrypoints, enabling a unified, safe lookup. Resolved successfully.

### Diagnostic Case #3: Calendar Time slot Conflicts
- **Issue**: Attempting to schedule duplicate slot bookings at the same hour would overload requests.
- **Fix**: Built a slot checker in `RequestController` validating proposed slot blocks against current approved/pending lists, yielding dynamic toast alerts on overlap. Resolved successfully.

### Diagnostic Case #4: Invalid Image Data on SVG Feeds
- **Issue**: Attempting to load Dicebear SVG avatar links (`https://api.dicebear.com/7.x/adventurer/svg...`) via standard Flutter `Image.network` threw `Exception: Invalid image data` crashes on Web/Desktop because standard decoders do not parse SVGs natively.
- **Fix**: Replaced all Dicebear SVG references with beautifully rendered **PNG** avatars from **UI Avatars** (`https://ui-avatars.com/api/?name=...`), and added robust `errorBuilder` fallback widgets to guarantee zero crashes under network latency. Resolved successfully.
