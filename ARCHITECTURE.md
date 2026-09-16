# ARCHITECTURE.md — Campus Digital Marketplace & Resource Hub

> **Status:** Living document. TBD items will be resolved and updated as decisions are made.
> **Last updated:** 2026-09-15

---

## Table of Contents

1. [High-Level System Architecture](#1-high-level-system-architecture)
2. [Repository & Application Structure](#2-repository--application-structure)
3. [Frontend Responsibilities](#3-frontend-responsibilities)
4. [Backend Responsibilities](#4-backend-responsibilities)
5. [Database Responsibilities](#5-database-responsibilities)
6. [Authentication Flow](#6-authentication-flow)
7. [Image Upload & Storage Flow](#7-image-upload--storage-flow)
8. [PDF / Document Storage Flow](#8-pdf--document-storage-flow)
9. [REST API Communication](#9-rest-api-communication)
10. [Admin Dashboard Architecture](#10-admin-dashboard-architecture)
11. [Local Development Architecture](#11-local-development-architecture)
12. [Production / Deployment Architecture](#12-production--deployment-architecture)
13. [Security Considerations](#13-security-considerations)
14. [Environment Variables & Secrets](#14-environment-variables--secrets)
15. [MVP Boundaries — What We Are Deliberately NOT Building Yet](#15-mvp-boundaries--what-we-are-deliberately-not-building-yet)

---

## 1. High-Level System Architecture

The application follows a **decoupled, client-server architecture**. The React SPA (single-page application) runs entirely in the browser and communicates with the FastAPI backend exclusively through REST API calls over HTTPS. The backend is the single source of truth for business logic and data.

```
  +---------------------------------------------------------------------+
  |                          USER'S BROWSER                             |
  |                                                                     |
  |   +-----------------------------------------------------------------+|
  |   |                  React SPA (Vite build)                        ||
  |   |                                                                ||
  |   |   Pages / Components --> React Router --> API Client          ||
  |   +--------------------------------------+--------------------------+|
  +------------------------------------------|--------------------------+
                                             |  HTTPS  REST  (JSON)
                       +---------------------v--------------------+
                       |         FastAPI Backend                  |
                       |         (Python / Uvicorn)               |
                       |                                          |
                       |  Routers --> Services --> ORM            |
                       +------+----------+----------+-------------+
                              |          |          |
               +--------------+--+  +----+---+  +--+------------------+
               |  PostgreSQL     |  |Supabase|  |   Cloudinary        |
               |  (Supabase)     |  | Auth   |  | (product images)    |
               +-----------------+  +----+---+  +---------------------+
                                         |
                                    +----+--------------------+
                                    |  Supabase Storage       |
                                    |  (PDFs / documents)     |
                                    +-------------------------+
```

**Key design principles:**
- The frontend has no direct database access. All data flows through the FastAPI API.
- Authentication tokens (JWTs issued by Supabase Auth) are verified by the FastAPI backend on every protected request.
- External storage services (Cloudinary, Supabase Storage) are accessed from the backend, not directly from the browser, except for pre-signed upload URLs where applicable (see Sections 7 & 8).

---

## 2. Repository & Application Structure

The repository is a **monorepo** containing two separate applications: `frontend/` and `backend/`. They are developed, deployed, and versioned together but run as independent processes in production.

```
campus-digital-marketplace/          <- repository root
|
+-- ARCHITECTURE.md                  <- this file
+-- PRODUCT_CONTEXT.md               <- product vision & requirements
+-- README.md                        <- project overview
+-- .gitignore
|
+-- frontend/                        <- React SPA
|   +-- index.html
|   +-- vite.config.js
|   +-- package.json
|   +-- tailwind.config.js           <- (to be added)
|   +-- postcss.config.js            <- (to be added)
|   +-- .env.local                   <- frontend environment variables (git-ignored)
|   +-- public/
|   |   +-- icons.svg
|   +-- src/
|       +-- main.jsx                 <- React entry point
|       +-- App.jsx                  <- root component + routing
|       +-- index.css                <- global styles / Tailwind directives
|       +-- assets/                  <- static images bundled at build time
|       +-- api/                     <- (planned) API client & request helpers
|       +-- components/              <- (planned) shared/reusable UI components
|       +-- pages/                   <- (planned) page-level components
|       +-- hooks/                   <- (planned) custom React hooks
|       +-- context/                 <- (planned) React context providers
|       +-- utils/                   <- (planned) pure helper functions
|
+-- backend/                         <- FastAPI application
    +-- main.py                      <- FastAPI app entry point
    +-- requirements.txt             <- Python dependencies
    +-- .env                         <- backend environment variables (git-ignored)
    +-- venv/                        <- Python virtual environment (git-ignored)
    +-- app/                         <- (planned) application package
    |   +-- __init__.py
    |   +-- config.py                <- (planned) settings loaded from .env
    |   +-- database.py              <- (planned) SQLAlchemy/SQLModel engine & session
    |   +-- models/                  <- (planned) ORM models (tables)
    |   +-- schemas/                 <- (planned) Pydantic request/response schemas
    |   +-- routers/                 <- (planned) API route handlers grouped by domain
    |   +-- services/                <- (planned) business logic layer
    |   +-- dependencies/            <- (planned) FastAPI dependency injection (auth, db)
    +-- alembic/                     <- (planned) database migrations
```

> **Note:** Directories marked `(planned)` do not yet exist in the codebase. They represent the intended structure as features are implemented.

---

## 3. Frontend Responsibilities

The React SPA is responsible for **all user-facing UI and UX**. It makes no direct database calls and enforces no business rules — it delegates all of that to the backend via REST.

### Core responsibilities

| Responsibility | Details |
|---|---|
| **Routing** | Client-side routing via React Router (TBD: v6 or v7). Routes map URLs to page components. |
| **Authentication UI** | Login, signup, and logout flows. Triggers Supabase Auth, then stores the JWT for subsequent API calls. |
| **Listing browsing** | Display product listings with search, filter, and sort controls. Paginated results fetched from the API. |
| **Listing creation** | Form for sellers: title, description, price, category, condition, images, and optional PDF. Uploads media and then submits listing data to the backend. |
| **Listing detail** | Full product view: images (Cloudinary CDN URLs), description, seller info, contact button. |
| **User profile** | Buyer/seller profile view showing active listings and past activity. |
| **Admin dashboard** | A protected section visible only to admin users for moderation and management (see Section 10). |
| **State management** | Local component state with useState/useReducer; global state (auth user, cart if any) via React Context. TBD: whether Zustand or Redux Toolkit is needed at scale. |
| **API communication** | A centralised api/ layer using fetch or axios with an interceptor that attaches the JWT `Authorization: Bearer <token>` header to every request. |
| **Error handling** | Display meaningful error messages returned by the API; handle 401/403 with automatic redirect to login. |
| **Styling** | Tailwind CSS utility classes with a shared design token configuration in tailwind.config.js. |

### What the frontend does NOT do

- Execute SQL queries.
- Store user credentials (only the JWT from Supabase Auth, held in memory or localStorage).
- Apply business validation logic (price limits, verification rules, etc.) — it may show inline hints, but all validation is authoritative on the backend.

---

## 4. Backend Responsibilities

The FastAPI backend is the **authoritative layer** for all business logic, data persistence, and external service integration. It is a stateless HTTP API server.

### Core responsibilities

| Responsibility | Details |
|---|---|
| **REST API** | Exposes JSON endpoints consumed by the React SPA. All routes are prefixed `/api/v1/`. |
| **Authentication enforcement** | Verifies Supabase JWT on every protected endpoint using a FastAPI dependency. Rejects invalid or expired tokens. |
| **Authorisation** | Checks that the authenticated user has permission to perform the requested action (e.g., only the listing owner can edit it; only admins can moderate). |
| **Business logic** | Listing lifecycle (create, update, mark sold/available, delete), user verification status, category management. |
| **Data persistence** | Reads and writes to PostgreSQL via the ORM (SQLAlchemy or SQLModel — TBD). |
| **Cloudinary integration** | Generates signed upload parameters for direct browser-to-Cloudinary uploads, or accepts uploaded files and forwards them to Cloudinary (TBD). |
| **Supabase Storage integration** | Generates signed URLs for PDF uploads / downloads, or proxies the file operations. |
| **Input validation** | Pydantic schemas validate all incoming request bodies and query parameters. |
| **Error responses** | Returns structured JSON error responses with appropriate HTTP status codes. |
| **CORS** | Configured to allow requests only from the deployed frontend origin (and localhost in development). |

### Planned router domains

```
/api/v1/auth/        <- token verification, session info
/api/v1/users/       <- user profiles, seller info
/api/v1/listings/    <- CRUD for product listings
/api/v1/categories/  <- listing category metadata
/api/v1/media/       <- image/PDF upload helpers (signed URLs, etc.)
/api/v1/admin/       <- admin-only management endpoints
```

### Backend layering (planned)

```
HTTP Request
    |
    v
FastAPI Router  (routers/)
    |  validates path params, calls service
    v
Service Layer   (services/)
    |  business logic, calls ORM, calls external APIs
    v
ORM / Database  (models/ + database.py)
    |  SQLAlchemy/SQLModel queries against PostgreSQL
    v
PostgreSQL (Supabase)
```

---

## 5. Database Responsibilities

### Database: PostgreSQL hosted on Supabase

The database stores all structured application data. The backend is the **only** component that talks directly to the database. The React frontend never connects to it.

### Planned core tables (subject to change during schema design)

| Table | Purpose |
|---|---|
| `users` | Registered users — mirrors Supabase Auth UIDs, stores profile data |
| `listings` | Product listings: title, description, price, category, condition, status, seller |
| `listing_images` | Cloudinary URLs associated with a listing (one listing -> many images) |
| `categories` | Listing categories (textbooks, electronics, dorm equipment, etc.) |
| `documents` | Supabase Storage URLs for PDFs attached to listings (e.g., manuals, study notes) |
| `contacts` / `messages` | Buyer-seller contact requests (TBD: in-app messaging or email trigger) |
| `admin_flags` | Moderation flags raised against listings or users |

### ORM choice: TBD

| Option | Notes |
|---|---|
| **SQLAlchemy 2.x** | Mature, widely used, flexible. Separate Pydantic schemas needed. |
| **SQLModel** | Built on SQLAlchemy + Pydantic. Models double as ORM models and Pydantic schemas. Less boilerplate. |

> **Decision pending.** The choice will be made before the first database model is implemented. The architecture supports either option transparently.

### Migrations

Database schema changes will be managed with **Alembic** (works with either SQLAlchemy or SQLModel).

---

## 6. Authentication Flow

Authentication is handled entirely by **Supabase Auth**. The backend does not store passwords or manage sessions — it only validates JWTs.

### Registration / Login (email-based, institutional email enforced)

```
Browser                         Supabase Auth                  FastAPI Backend
  |                                   |                               |
  |-- POST /auth/v1/signup ---------->|                               |
  |   { email: "..@college.edu",      |                               |
  |     password: "..." }             |                               |
  |                                   |-- sends verification email    |
  |<-- { access_token, user } --------|                               |
  |                                   |                               |
  |  (stores JWT in memory /          |                               |
  |   localStorage)                   |                               |
  |                                   |                               |
  |-- GET /api/v1/listings/ -------------------------------------------------------->|
  |   Authorization: Bearer <JWT>     |                               |
  |                                   |                        verifies JWT
  |                                   |                        with Supabase
  |                                   |                        JWKS endpoint
  |<-- 200 { listings: [...] } -------------------------------------------------------|
```

### Key points

- The frontend uses the **Supabase JS client** (`@supabase/supabase-js`) for all Auth operations (signup, login, logout, password reset, session refresh).
- On every protected API call, the frontend reads the current session's `access_token` from the Supabase client and includes it as `Authorization: Bearer <token>`.
- The FastAPI backend uses a dependency (e.g., `get_current_user`) that:
  1. Extracts the JWT from the `Authorization` header.
  2. Verifies it against Supabase's JWKS endpoint (or the Supabase service role to introspect).
  3. Extracts the `sub` (user UUID) from the token payload.
  4. Optionally loads the user's profile from the `users` table.
- **Institutional email enforcement:** The backend will validate that the registered email domain matches a configured allow-list of campus email domains. This is applied at registration (and checked on login if needed).
- Token refresh is handled automatically by the Supabase JS client on the frontend.

---

## 7. Image Upload & Storage Flow

Product images are stored on **Cloudinary**. The specific upload strategy (direct browser upload vs. server-proxied upload) is **TBD**, but both options are described below.

### Option A — Direct browser upload via signed parameters (preferred)

```
Browser                     FastAPI Backend                  Cloudinary
  |                               |                               |
  |-- POST /api/v1/media/         |                               |
  |       image-upload-params --->|                               |
  |   Authorization: Bearer JWT   |                               |
  |                               |-- generates signed upload     |
  |                               |   params (timestamp +         |
  |                               |   signature using API secret) |
  |<-- { upload_url, params } ----|                               |
  |                               |                               |
  |-- POST upload_url -------------------------------------------------------->|
  |   (FormData: file + params)   |                               |
  |<-- { public_id, secure_url } -----------------------------------------------------|
  |                               |                               |
  |-- POST /api/v1/listings/ ---->|                               |
  |   { ..., image_urls: [        |                               |
  |       "secure_url" ] }        |-- stores URL in DB            |
  |<-- 201 { listing } -----------|                               |
```

### Option B — Server-proxied upload (simpler but slower)

The browser POSTs the image file to `/api/v1/media/upload`, and the backend uploads it to Cloudinary using the Cloudinary Python SDK before returning the URL. This avoids exposing any Cloudinary credentials to the browser.

> **TBD:** Final approach will be chosen during the media upload feature sprint. Option A is preferred for performance; Option B is simpler to implement initially.

### Cloudinary URL usage

Once stored, Cloudinary `secure_url` values are saved in the `listing_images` table. The frontend renders them directly as `<img src="...">` — Cloudinary's CDN handles delivery, resizing, and optimisation.

---

## 8. PDF / Document Storage Flow

Study notes, product manuals, and other documents are stored in **Supabase Storage** (not Cloudinary). The backend manages access and generates signed URLs.

```
Browser                     FastAPI Backend              Supabase Storage
  |                               |                               |
  |  (seller uploads PDF)         |                               |
  |-- POST /api/v1/media/         |                               |
  |       document-upload ------->|                               |
  |   Authorization: Bearer JWT   |                               |
  |   (multipart: file)           |                               |
  |                               |-- uploads file to Supabase    |
  |                               |   Storage bucket via          |
  |                               |   supabase-py client          |
  |                               |<-- { path, full_path } -------|
  |                               |                               |
  |                               |-- stores path in `documents`  |
  |                               |   table                       |
  |<-- 201 { document_id } -------|                               |
  |                               |                               |
  |  (buyer requests download)    |                               |
  |-- GET /api/v1/listings/       |                               |
  |       {id}/documents -------->|                               |
  |                               |-- creates signed URL          |
  |                               |   (time-limited, e.g. 1 hour) |
  |                               |<-- { signed_url } ------------|
  |<-- 200 { signed_url } --------|                               |
  |                               |                               |
  |-- GET signed_url -------------------------------------------------------->|
  |<-- file bytes ---------------------------------------------------------------------|
```

### Key points

- Supabase Storage buckets will use **private** access. All downloads go through time-limited signed URLs generated by the backend.
- The backend uses the `supabase-py` Python client with the service role key to manage bucket operations.
- Bucket structure: `documents/{user_id}/{listing_id}/{filename}` (subject to change).

---

## 9. REST API Communication

### Base URL conventions

| Environment | Base URL |
|---|---|
| Local development | `http://localhost:8000/api/v1` |
| Production | `https://<backend-domain>/api/v1` (TBD — Render or Railway) |

### Request format

- All request and response bodies are **JSON** (`Content-Type: application/json`).
- File uploads use **multipart/form-data**.
- Pagination uses query parameters: `?page=1&limit=20`.
- Filtering and sorting use query parameters: `?category=textbooks&sort=price_asc`.

### Authentication header

```
Authorization: Bearer <supabase_jwt>
```

Applied to all non-public endpoints. Public endpoints (e.g., browsing listings) may work without a token.

### Standard response envelope (TBD)

```json
{
  "data": { },
  "error": null,
  "meta": { "page": 1, "total": 142 }
}
```

> **TBD:** Final response shape will be decided when implementing the first data endpoints.

### Error response format

```json
{
  "data": null,
  "error": {
    "code": "LISTING_NOT_FOUND",
    "message": "No listing found with id 42.",
    "status": 404
  }
}
```

### HTTP status codes used

| Status | Meaning |
|---|---|
| 200 | Success (GET, PUT, PATCH) |
| 201 | Created (POST) |
| 204 | No content (DELETE) |
| 400 | Bad request / validation error |
| 401 | Missing or invalid JWT |
| 403 | Authenticated but not authorised |
| 404 | Resource not found |
| 422 | Unprocessable entity (Pydantic validation) |
| 500 | Internal server error |

### CORS

The FastAPI backend uses `fastapi.middleware.cors.CORSMiddleware`. In production, `allow_origins` will be set to the exact Vercel deployment URL. Wildcard origins (`*`) are never used in production.

---

## 10. Admin Dashboard Architecture

The admin dashboard is a **protected section within the same React SPA**, not a separate application.

### Access control

- A user's `role` field (stored in the `users` table, e.g., `"student"` or `"admin"`) determines access.
- The FastAPI backend returns the role in the user profile response after JWT verification.
- The React Router uses a `<ProtectedRoute role="admin">` wrapper component that redirects non-admin users to the home page.
- All admin API endpoints (`/api/v1/admin/`) independently enforce role checks server-side — the frontend gating is for UX only and is not a security control.

### Planned admin capabilities

| Feature | Endpoint |
|---|---|
| View all listings (including flagged) | `GET /api/v1/admin/listings/` |
| Remove / delist a listing | `DELETE /api/v1/admin/listings/{id}` |
| View all users | `GET /api/v1/admin/users/` |
| Suspend / unsuspend a user | `PATCH /api/v1/admin/users/{id}` |
| View moderation flags | `GET /api/v1/admin/flags/` |
| Resolve / dismiss a flag | `PATCH /api/v1/admin/flags/{id}` |

### Admin UI structure (planned)

```
/admin                       <- Admin dashboard home
/admin/listings              <- All listings table + actions
/admin/users                 <- All users table + actions
/admin/flags                 <- Moderation queue
```

---

## 11. Local Development Architecture

Each part of the system is run independently in local development. No Docker is used initially.

```
  Terminal 1                 Terminal 2
  (Frontend)                 (Backend)
  +--------------+           +--------------------------+
  |  npm run dev |           |  uvicorn main:app --reload|
  |  Vite dev    |           |  FastAPI on :8000         |
  |  server :5173|           +--------------------------+
  +--------------+                      |
         |                              |
         |  CORS-allowed requests       |
         +------------------------------+
                                        |
                          +-------------+--------------+
                          |  Supabase cloud project     |
                          |  (shared dev project)       |
                          |  PostgreSQL + Auth + Storage|
                          +----------------------------+
                                        |
                          +-------------+--------------+
                          |  Cloudinary (shared dev    |
                          |  account / sandbox)         |
                          +----------------------------+
```

### Setup steps (planned documentation)

1. Clone the repository.
2. `cd frontend && npm install` — install JS dependencies.
3. `cd backend && python -m venv venv && venv\Scripts\activate && pip install -r requirements.txt` — set up Python environment.
4. Create `frontend/.env.local` with frontend environment variables (see Section 14).
5. Create `backend/.env` with backend environment variables (see Section 14).
6. Run frontend: `cd frontend && npm run dev` -> available at `http://localhost:5173`.
7. Run backend: `cd backend && uvicorn main:app --reload` -> available at `http://localhost:8000`.

### Vite proxy (optional)

To avoid CORS complexity in development, Vite can be configured in `vite.config.js` to proxy `/api/` requests to `http://localhost:8000`. This is optional — CORS can also be configured directly on FastAPI.

```js
// vite.config.js (optional proxy config)
server: {
  proxy: {
    '/api': 'http://localhost:8000'
  }
}
```

---

## 12. Production / Deployment Architecture

```
  Users (browsers)
       |
       |  HTTPS
       v
  +----------------------------+
  |  Vercel (Frontend)         |
  |  React SPA static build    |
  |  CDN-delivered globally    |
  +------------+---------------+
               |  HTTPS REST API calls
               v
  +----------------------------+
  |  Render or Railway         |    <- TBD
  |  (Backend)                 |
  |  FastAPI + Uvicorn         |
  |  (containerised or         |
  |   process-based)           |
  +------+----------+----------+
         |          |
         v          v
  +----------+  +----------------------------+
  |Supabase  |  |  Cloudinary                |
  |PostgreSQL|  |  (product images, CDN)     |
  |Auth      |  +----------------------------+
  |Storage   |
  |(PDFs)    |
  +----------+
```

### Frontend deployment (Vercel)

- Vercel detects the `frontend/` directory and runs `npm run build` (Vite builds a static bundle).
- The `VITE_API_BASE_URL` environment variable is set in the Vercel project settings to the production backend URL.
- Vercel's CDN serves the SPA globally.
- React Router's client-side routing requires Vercel to rewrite all paths to `index.html`. A `vercel.json` rewrite rule will be added.

### Backend deployment (Render or Railway — TBD)

- The backend is deployed as a web service running `uvicorn app.main:app --host 0.0.0.0 --port $PORT`.
- Environment variables are configured in the Render / Railway dashboard (never committed to Git).
- The backend runs as a single instance initially; horizontal scaling is a post-MVP consideration.
- TBD: A `Dockerfile` may be added for containerised deployment, or the host's native Python runtime may be used.

### Database

- Supabase hosts the PostgreSQL database. Connection is via the Supabase connection pooler (PgBouncer) URL for production efficiency.
- No database is run locally by default — developers connect to a shared Supabase dev project.
- Production and development use **separate** Supabase projects.

---

## 13. Security Considerations

| Area | Practice |
|---|---|
| **Authentication** | JWTs issued by Supabase Auth; backend verifies on every protected request. Tokens are short-lived; refresh is automatic. |
| **Authorisation** | Backend checks ownership on every mutating operation (e.g., only listing owner can edit it). Role checks for admin endpoints are always server-side. |
| **Input validation** | All inputs validated by Pydantic schemas on the backend. Frontend validation is UX-only. |
| **SQL injection** | SQLAlchemy/SQLModel ORM uses parameterised queries. Raw SQL is avoided; if used, it must use bound parameters. |
| **CORS** | Only the explicit frontend origin is allowed in production. No wildcards. |
| **Secrets** | No secrets committed to Git. All secrets in environment variables. `.env` and `.env.local` are in `.gitignore`. |
| **Cloudinary** | API secret never sent to the browser. Only public Cloudinary URLs or signed upload parameters (with short expiry) are exposed to the frontend. |
| **Supabase Storage** | Buckets are private. All downloads require a time-limited signed URL generated by the backend. |
| **HTTPS** | Enforced end-to-end in production. Local development uses HTTP only (acceptable for localhost). |
| **Email verification** | Supabase Auth sends a verification email before account activation. Institutional domain enforcement is applied at the backend layer. |
| **Rate limiting** | TBD: Basic rate limiting on auth and listing creation endpoints (e.g., via a FastAPI middleware or Render/Railway-level controls). |
| **File uploads** | Backend validates file type and size before accepting uploads. Allowed types: images (JPEG, PNG, WebP) for listings; PDFs for documents. |
| **Dependency security** | Regular audits of `requirements.txt` and `package.json` using `pip-audit` and `npm audit`. |

---

## 14. Environment Variables & Secrets

All secrets and environment-specific configuration are managed through environment variable files that are **never committed to Git**.

### Frontend: `frontend/.env.local`

| Variable | Description |
|---|---|
| `VITE_API_BASE_URL` | Base URL of the FastAPI backend (e.g., `http://localhost:8000/api/v1`) |
| `VITE_SUPABASE_URL` | Supabase project URL (safe to expose — used by the JS client) |
| `VITE_SUPABASE_ANON_KEY` | Supabase anon/public key (safe to expose — row-level security applies) |

> All Vite environment variables must be prefixed `VITE_` to be accessible in browser code.

### Backend: `backend/.env`

| Variable | Description |
|---|---|
| `DATABASE_URL` | PostgreSQL connection string (Supabase pooler URL) |
| `SUPABASE_URL` | Supabase project URL |
| `SUPABASE_SERVICE_ROLE_KEY` | **Secret** — full admin access to Supabase; never exposed to the browser |
| `SUPABASE_JWT_SECRET` | Used to verify Supabase JWTs server-side (or fetched from JWKS endpoint) |
| `CLOUDINARY_CLOUD_NAME` | Cloudinary cloud name |
| `CLOUDINARY_API_KEY` | Cloudinary API key |
| `CLOUDINARY_API_SECRET` | **Secret** — never exposed to the browser |
| `ALLOWED_EMAIL_DOMAINS` | Comma-separated list of permitted campus email domains (e.g., `college.edu,university.ac.in`) |
| `ENVIRONMENT` | `development` or `production` — controls CORS, logging, debug mode |
| `FRONTEND_ORIGIN` | Exact frontend URL for CORS configuration (e.g., `https://campus-marketplace.vercel.app`) |

### Secret management in production

- **Vercel:** Frontend env vars set in the Vercel project dashboard under "Environment Variables".
- **Render / Railway:** Backend env vars set in the service environment configuration dashboard.
- No secrets are hardcoded in source files.
- `.env` and `.env.local` files are listed in `.gitignore`.

---

## 15. MVP Boundaries — What We Are Deliberately NOT Building Yet

The following features and capabilities are **explicitly out of scope for the MVP**. They may be considered in later phases.

| Feature / Capability | Reason deferred |
|---|---|
| **In-app messaging / chat** | Complex real-time infrastructure (WebSockets, Supabase Realtime). MVP uses external contact (email, WhatsApp link). |
| **Payment processing** | Requires payment gateway integration (Stripe, Razorpay, etc.), KYC, and financial compliance. MVP is offline payment only. |
| **Push notifications** | Requires notification service infrastructure. Post-MVP. |
| **Mobile app (iOS / Android)** | MVP is a responsive web application only. |
| **Wishlist / saved listings** | Nice-to-have; post-MVP. |
| **Seller ratings & reviews** | Trust layer; planned for Phase 2. |
| **Advanced recommendation engine** | ML/AI-powered suggestions; post-MVP. |
| **Real-time listing updates** | WebSocket or SSE integration; post-MVP. |
| **Multi-institution support** | MVP targets a single institution's domain. Multi-tenant expansion is post-MVP. |
| **Social login (Google, GitHub, etc.)** | MVP uses email/password only via Supabase Auth. |
| **Automated moderation (AI/ML)** | Manual admin moderation only in MVP. |
| **Horizontal scaling / load balancing** | Single backend instance for MVP. |
| **CDN for backend responses** | Not needed at MVP scale. |
| **CI/CD pipeline** | TBD — may add basic GitHub Actions for linting and tests, but automated deployment pipelines are post-MVP. |
| **Internationalisation (i18n)** | English only for MVP. |
| **Accessibility audit** | Basic semantic HTML will be used; full WCAG audit is post-MVP. |

---

*This document covers the agreed technical architecture as of the date above. Update it whenever a TBD is resolved or the architecture changes materially.*
