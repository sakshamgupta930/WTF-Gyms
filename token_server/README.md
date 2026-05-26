# Standalone 100ms Token Server

A lightweight, local-first Node.js Express server to generate mock 100ms authorization tokens for **Guru Pulse** and **Trainer Pulse** applications.

---

## How to Set Up & Run

### 1. Install Node.js
Ensure you have [Node.js](https://nodejs.org/) installed (v14.0.0 or higher is recommended).

### 2. Configure Environment Variables
Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```
Open `.env` in a text editor and enter your real 100ms credentials if testing online (default placeholders are pre-filled for local mock offline validation).

### 3. Install Dependencies
Run npm install in the token server folder:
```bash
npm install
```

### 4. Start Server
Run the local server using standard npm scripts:
```bash
npm start
```

The server will boot up locally at `http://localhost:8080` (CORS-enabled), exposing the standard API endpoint:
* **GET `/token?userId={id}&role={role}`**
  * E.g., `http://localhost:8080/token?userId=DK&role=member`
