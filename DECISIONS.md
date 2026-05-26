# Architectural Decisions (ADRs)

Documenting technical decisions made during the design of Guru Pulse & Trainer Pulse apps.

---

## ADR #1: State Management Framework

### Context
Recreating a pixel-perfect layout for two highly interactive applications side-by-side requires a framework that integrates state management, dependency injection, and responsive navigation effortlessly.

### Decision
We selected **GetX** over Riverpod/Bloc.
- **GetX Controllers** (MVC pattern) separate business logic from UI widgets completely, preventing giant state classes.
- **GetX DI** allows controllers to be registered globally (`Get.put()`) and located dynamically without passing BuildContext down long trees.
- **Reactive state binding** (`Obx`) guarantees instant, 60fps renders when WebSocket feeds receive incoming data.

### Consequences
Code readability increases drastically. Custom widgets and layouts remain purely visual, while GetX Controllers handle client-server handshakes reactively.

---

## ADR #2: Persistent Database Strategy

### Context
To support offline operation and caching, both apps must save user context, chat messages, scheduled appointments, and ratings logs across app reboots.

### Decision
We deployed **GetStorage** for local persistent storage.
- Highly optimized, synchronous, key-value storage engine.
- Fits natively into the GetX lifecycle.
- Lightweight, self-contained, and compiles out-of-the-box on Windows desktop and Web without complex SQLite/Hive setup.

### Consequences
Upon booting, both apps instantly read GetStorage to restore previous profiles, chat feeds, requests, and session diaries. Wiping database cache is bound to a single button click for rapid testing.

---

## ADR #3: Offline Real-Time Sync Strategy

### Context
Section 3 of the Assessment mandates full-fledged real-time chatting (with typing feedback and read ticks) and scheduling approvals between both applications working concurrently, completely offline and **without Firebase** or active internet APIs.

### Decision
We developed an **Offline WebSocket Server/Client architecture** utilizing Dart's core `HttpServer` and `WebSocket` libraries:
- **Trainer App** starts a loopback WebSocket Server on port `8080/ws` at launch.
- **Trainer App** hosts an inline mock **100ms HTTP Token Server** on `http://localhost:8080/token`.
- **Guru App** acts as a client, connecting to `ws://localhost:8080/ws` and polling connection status every 4 seconds if unreachable.

### Consequences
Both apps achieve true real-time bidirectional syncing completely offline. Chat bubbles, typing dots, call booking handshakes, and video room grid synchronization work instantaneously and reliably.
