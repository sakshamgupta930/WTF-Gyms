# Guru & Trainer Pulse

Recreation of the Stitch UI designs and layout systems for the **Guru Member App** and **Trainer Admin App** in a production-grade, local-first Flutter codebase.

---

## Technical Stack & Architecture

- **Decoupled Standalone Apps**: Both apps are completely separate, independent, self-contained entities with zero shared package links. They can be compiled, transported, and run individually anywhere.
- **State Management & DI**: **GetX** utilizing a robust **MVC (Model-View-Controller)** pattern.
- **Local Database Persistence**: **GetStorage** for lightning-fast reactive database queries.
- **Local Real-Time Sync**: Custom, offline WebSocket server hosted inside the Trainer App (port `8080/ws`) with automatic reconnect handlers inside the Guru Client App.
- **Mock Token Server**: Embedded GET `/token?userId=&role=` endpoint inside the Trainer WebSocket server to mock 100ms authentications local-first.
- **Visual Design**: Strict 8pt spacing system, custom text themes (H1 24sp, H2 20sp, Body 14-16sp), custom shadows, and press-scaling haptic button animations (150ms bounce).

---

## Standalone Project Scaffolding

```
wtf_flutter_test/
├─ README.md
├─ AI_LEDGER.md
├─ ARCHITECTURE.md
├─ DECISIONS.md               # ADRs (#1 state mgmt, #2 storage, #3 RTC strategy)
├─ guru_app/                    # Member App (Blue Theme, Onboarding, Chats, Calendar Bookings, Rating Form)
└─ trainer_app/                 # Trainer App (Red Theme, CRM Dashboards, Slot Approvals, Logs Feed)
```

---

## How to Compile & Run Both Apps Locally

### Prerequisites
Make sure you have the Flutter stable SDK installed (Flutter 3.x with Dart 3.x is highly recommended).

### 1. Download Dependencies
Run `flutter pub get` inside both app directories:
```bash
# Get dependencies in Guru App
cd guru_app
flutter pub get

# Get dependencies in Trainer App
cd ../trainer_app
flutter pub get
```

### 2. Run Trainer App (WebSocket Server Host)
Launch the **Trainer App** first. When compiled, it boots up a local WebSocket server on `ws://localhost:8080/ws` and a mock 100ms token server on `http://localhost:8080/token`.
```bash
cd trainer_app
flutter run -d windows   # or flutter run -d chrome / android
```

### 3. Run Guru Member App (Client Connect)
With the Trainer App active, start the **Guru App** in a separate window. It will immediately establish a WebSocket link and synchronize messages, bookings, and room statuses in real-time!
```bash
cd ../guru_app
flutter run -d windows   # or flutter run -d chrome / android
```

---

## Manual Integration Testing Protocol

1. **Boot Apps**: Launch Trainer App ( Aarav ) first, then Guru App.
2. **Onboard Member**: Launch Guru App, progress through the 2 onboarding slides, fill name `DK` (pre-filled), select trainer `Aarav`, and tap *Create Profile*.
3. **Interactive Chats**: Open *Chat with Trainer* in Guru App and *Chats* in Trainer App. Send messages back and forth. Observe:
   - **Typing status**: dots animate when typing in one window.
   - **Read status ticks**: done/done_all checkmarks update reactively.
   - **Quick replies**: tap Action Chips in Guru App to send canned texts instantly.
4. **Calendar Scheduling**: Tap *Schedule Call* in Guru App. Pick slot and add focus notes. Submit:
   - Conflict checking prevents booking the exact same time slot twice.
   - Toast displays: *Call requested. Waiting for trainer approval.*
   - Request displays under Aarav's *Requests* tab in real-time.
5. **Inline Approval**: Aarav taps *Approve*. An automated system message posts to the chat: *"Call approved for [date] [time]"*.
6. **Video Call Join**: Tap *Join* on the upcoming call card in both apps.
7. **Resilient Local Stream fallbacks**: Mute/video/flip controls simulate 100ms state changes smoothly using clean PNG placeholder flows.
8. **Feedback & Rating Sheet**:
   - Guru App displays the member rating form. DK rates Aarav `5★` and adds comments.
   - Trainer App prompts Aarav to add detailed notes.
9. **Verify Logs**: Tap *Sessions* in both apps to review completed diagnostic history, rating summaries, and filtered lists.
