# Campus Marketplace & Resource Hub — Product Context

> **Purpose:** This document is the permanent source of truth for understanding the Campus Marketplace & Resource Hub product. Future development discussions should use this document as the baseline and should not introduce conflicting technology or product assumptions without explicitly discussing the change.

---

## 1. Product

### 1.1 Official Product Nam
**Campus Marketplace & Resource Hub**

### 1.2 Short Name
**Campus Marketplace**

### 1.3 One-Line Description
A verified student-only web marketplace for college campuses to easily buy, sell, and rent academic resources and dorm essentials with zero travel friction.

### 1.4 What We Are Building
A verified, peer-to-peer web platform for college campuses that enables students to buy, sell, rent, and pass down academic resources and dorm essentials safely within their own institution or nearby verified partner colleges.

The product has two closely connected areas:

- **Marketplace:** Buying, selling, and renting physical campus-related items.
- **Resource Hub:** Sharing and discovering academic resources, including digital materials and physical academic assets.

### 1.5 Ultimate Vision
Build a fully working product that students across a city and eventually a country actively use for campus-to-campus buying, selling, renting, and resource sharing.

---

# 2. Problem

## 2.1 Problem Being Solved
College students lack a safe, centralized, organized platform to buy, sell, rent, or pass down semester-specific academic resources and hostel essentials directly to peers on campus.

Examples include textbooks, lab gear, calculators, hardware kits, dorm equipment, and other student-use items.

## 2.2 Current Alternatives
Students currently rely on:

- WhatsApp or Telegram batch groups
- Instagram stories
- OLX or Facebook Marketplace
- Word of mouth through roommates, classmates, and seniors

## 2.3 Problems With Existing Solutions

### Feed Clutter
WhatsApp, Telegram, and Instagram posts get buried quickly under other messages, leaving no persistent or searchable inventory.

### No Availability Tracking
Buyers may contact sellers only to discover that an item was already sold.

### Safety & Scams
Open marketplaces expose students to unverified strangers, scammers, and potentially unsafe off-campus meetups.

### Logistics Overhead
Public marketplaces can involve long-distance travel, shipping costs, or courier coordination for inexpensive items where delivery costs may exceed the item's value.

## 2.4 Why Campus-Specific?
Campus Marketplace is designed around the trust and logistics advantages of a verified campus network.

- **Institutional verification:** Users must authenticate using an approved institutional email domain.
- **Zero-shipping model:** Transactions are designed around convenient physical handovers at safe campus locations.
- **Structured discovery:** Listings can be searched and filtered by category, price, condition, course, semester, and campus scope.
- **Controlled expansion:** The MVP begins with one campus and can later expand to verified nearby partner campuses.

---

# 3. Target Users

## 3.1 Primary Users
Undergraduate and postgraduate students who are actively enrolled in college.

## 3.2 Initial Market
**Polaris students only** for the MVP/pilot.

The system should be architected so that multi-campus support can be added in Phase 2 without rebuilding the core architecture.

## 3.3 Key Student Segments

### Hostelers & Outstation Students
Need affordable dorm furniture, mattresses, kettles, room accessories, and similar items.

### Junior / First-Year Students
Need lower-cost textbooks, engineering calculators, lab equipment, and other semester-specific materials.

### Seniors / Graduating Students
Need to quickly sell or pass down academic materials and hostel essentials before moving out.

### Student Makers & Tech Enthusiasts
Trade or rent spare project components such as Arduinos, sensors, development boards, and other hardware.

## 3.4 User Roles

### Student Buyer
Can search, filter, bookmark, and contact sellers.

### Student Seller
Can create, edit, reserve, and mark listings as sold. Any verified student can both buy and sell.

### Platform Admin
Can review reports, moderate listings/resources, suspend abusive users, and manage approved institutional domains.

### Resource Contributor
A verified student or approved faculty member who contributes academic resources.

---

# 4. Core User Flows

## 4.1 Buyer Flow

1. Sign up / log in using an approved college email.
2. Verify the account using the selected authentication flow.
3. Browse the home feed.
4. Switch between **My Campus** and **Nearby Campuses** when multi-campus support is available.
5. Search and filter by category, price, condition, or keyword.
6. Open a listing.
7. View photos, description, price, condition, seller's college, and preferred pickup spot.
8. Contact the seller through WhatsApp or email.
9. Meet the seller at an agreed safe location.
10. Inspect the item and complete payment directly using cash or UPI.

## 4.2 Seller Flow

1. Select **Sell / List Item**.
2. Enter title, category, price/free status, condition, description, and preferred pickup location.
3. Upload 1–3 item photos.
4. Publish the listing.
5. Receive buyer inquiries through the selected off-platform contact method.
6. Mark the listing as **Reserved** during a pending transaction.
7. Mark it **Sold** after the item is handed over.

## 4.3 Resource Sharing Flow

### Contributor
- Choose whether the resource is free/giveaway or available to borrow/rent.
- Tag the resource using course code, department, subject, and resource category.
- Upload digital materials or provide an external link where appropriate.
- For physical resources, optionally specify rental duration, rate, and security deposit.

### Seeker
- Browse the Resource Hub.
- Search by course code, subject, resource type, or keyword.
- Download eligible digital resources.
- Contact contributors for physical resources.
- Borrow or collect physical resources directly.

## 4.4 Looking For Flow
Students can post demand requests such as:

> "Need a Casio fx-991CW for tomorrow."

The request can appear on a campus bulletin board so students who have the item can contact the requester.

## 4.5 Moderation & Safety Flow

1. Student reports a suspicious, prohibited, scam, or inaccurate listing/resource.
2. Report enters the Admin Dashboard.
3. Admin reviews the report.
4. Admin can hide/delete the content or suspend/ban the account when appropriate.

---

# 5. Features

## 5.1 MVP — Version 1

The MVP includes both the Marketplace and Resource Hub.

### Authentication
- College-email-based sign-up/login.
- Institutional domain verification.
- Supabase Auth.
- Exact authentication method (OTP vs magic link) remains an implementation decision.

### Product Listings
- Create, edit, and delete listings.
- Title
- Price or Free
- Condition
- Description
- Pickup location
- Category
- Listing status

### Product Images
- 1–3 compressed images per listing.
- Cloudinary for image storage, optimization, and delivery.

### Categories
Initial categories include:

- Textbooks
- Lab Gear
- Electronics
- Dorm Essentials
- Project Kits
- Mobility / Sports
- Clothing / Event Wear

### Search & Filters
- Keyword search
- Category filtering
- Price sorting/filtering
- Condition filtering where useful
- Campus scope

### Seller Contact
Use direct WhatsApp and/or email contact with pre-filled transaction information rather than building a native chat backend in the MVP.

### Listing Status
- Available
- Reserved
- Sold / Archived

### Resource Hub
- Academic resource discovery
- Digital resource uploads/links
- Physical academic resource listings
- Search by subject/course code/keyword
- Department/degree, semester/year, subject/course code, and resource category filters
- Helpful/upvote counter
- Reporting

### Basic Admin Dashboard
- Review reported listings/resources
- Remove spam/prohibited content
- Suspend/ban abusive users
- Manage institutional email-domain whitelist

## 5.2 Post-MVP / Phase 2+

Potential future features:

- Built-in real-time chat
- Read receipts and typing indicators
- In-app escrow/payment integration
- PDF previews/native document viewer
- Ratings and peer reviews
- Push notifications
- Favorites / saved items
- Detailed public student profiles
- Looking For / Request Board
- Paid boosted listings

These are **not required for the MVP**.

---

# 6. Marketplace

## 6.1 Supported Items

### Academic & College Supplies
- Textbooks
- Semester notes
- Lab coats
- Engineering drawing kits
- Scientific calculators

### Electronics & Hardware
- Laptops
- Chargers
- Monitors
- Power banks
- Arduino/Raspberry Pi boards
- Spare project components

### Hostel & Dorm Essentials
- Kettles
- Mini-fridges
- Study lamps
- Mattresses
- Clothes drying racks
- Storage bins

### Mobility & Sports
- Bicycles
- Gym gear
- Badminton racquets
- Skateboards

### Clothing & Event Wear
- College event formals
- Blazers
- Traditional/fest wear

## 6.2 Services
Services are **not allowed in the MVP**.

Tutoring, design work, repairs, and similar peer-to-peer services may be considered later because they introduce additional dispute-resolution and moderation complexity.

## 6.3 Campus Scope
The MVP is initially single-campus (Polaris).

The intended Phase 2 model is:

- **My Campus:** Show listings from the user's home institution.
- **Nearby Campuses:** Show listings from verified partner colleges within an approximately 5–10 km radius.

## 6.4 Payments
For the MVP:

- Cash or UPI directly between users.
- Payments occur off-platform.
- No payment gateway is required.

## 6.5 Platform Commission
**0% commission for the MVP.**

The priority is adoption and marketplace liquidity, not monetization.

## 6.6 Delivery
The MVP is **self-pickup only**.

Buyer and seller coordinate a safe public campus meetup location for inspection and handover.

---

# 7. Resource Hub

## 7.1 Resource Types

### Digital Academic Materials
- Lecture notes
- Handwritten summaries
- Past-year papers (PYQs)
- Assignment references
- Syllabus guides
- Cheat sheets
- Curated external study links
- Appropriate code/resource links

### Physical Academic Assets
- Calculators
- Lab coats
- Hardware/microcontroller kits
- Engineering drawing tools
- Other short-term academic-use equipment

### Content Restrictions
The platform should not host pirated/copyright-infringing textbook PDFs or unauthorized lecture recordings.

## 7.2 Who Can Upload?
Any verified student or approved faculty member with an active institutional account.

## 7.3 Who Can Access?
Verified authenticated users.

Resources can be scoped to the contributor's campus or, where appropriate, made available to verified partner institutions.

## 7.4 Cost
Digital academic resources are free by default.

Physical borrowing can optionally include a refundable security deposit.

## 7.5 Quality & Reporting
Resources support:

- **Helpful / Upvote counter** to surface useful material.
- **Report button** for outdated, inaccurate, broken, or policy-violating content.

## 7.6 Organization

The Resource Hub uses a relatively flat, search-friendly taxonomy:

**Department / Degree**
→ **Semester / Year**
→ **Subject / Course Code**
→ **Resource Category**

Example:

`CSE / B.Tech → 3rd Semester → Data Structures / CS201 → Notes / PYQs / Lab Work`

Global search should support subject names, course codes, and keywords.

---

# 8. Technology Stack

## 8.1 Frontend
- React
- Vite
- JavaScript initially
- Tailwind CSS

## 8.2 Backend
- Python
- FastAPI
- Pydantic
- SQLAlchemy or SQLModel

The exact ORM choice remains TBD and will be selected during implementation.

## 8.3 Database
**PostgreSQL via Supabase**

### Reason for PostgreSQL
The product has strongly relational data involving users, campuses, listings, categories, resources, reports, and roles. PostgreSQL provides a better long-term foundation than SQLite or MongoDB for this architecture.

SQLite is not the intended production database.

MongoDB is not part of the selected MVP architecture.

## 8.4 Authentication
**Supabase Auth**

Institutional email/domain validation will be enforced by the application.

The exact login mechanism (OTP or magic link) is an implementation decision.

## 8.5 Image Storage
**Cloudinary**

Used for product/listing images, including optimization and delivery.

## 8.6 Document/PDF Storage
**Supabase Storage**

Used for eligible academic documents/PDFs.

## 8.7 Hosting
### Frontend
Vercel preferred, with Netlify as an alternative.

### Backend
Render or Railway initially, depending on free-tier suitability at implementation time.

### Database & Storage
Supabase.

---

# 9. Architecture

## 9.1 High-Level Architecture

```text
User Browser
     ↓
React + Vite Frontend
     ↓ HTTPS / REST
FastAPI Backend
     ↓
Authentication / Authorization
     ↓
Business Logic
     ↓
PostgreSQL (Supabase)
     ↓
Cloudinary / Supabase Storage
```

## 9.2 Application Structure
The frontend and backend are separate applications.

### Frontend
Standalone React/Vite SPA.

### Backend
Dedicated FastAPI REST API handling:

- Authentication verification
- Authorization
- Business logic
- Listings CRUD
- Resource operations
- Search/filtering
- Reports
- Admin operations
- Database access

## 9.3 API
**REST API**

Reason:
- Simple to understand and test.
- Works naturally with FastAPI.
- Easy to document using OpenAPI/Swagger.
- Appropriate for MVP requirements.

## 9.4 Admin Dashboard
A protected `/admin` route can exist inside the main frontend.

Access is restricted to users whose database role is `admin`.

Core capabilities:

- Review reports
- Remove prohibited/spam content
- Suspend/ban accounts
- Manage approved institutional domains

---

# 10. Design Principles

The product should feel:

- **Student-focused**
- **Fast**
- **Trustworthy**
- **Minimal**

## Student-Focused
The product should feel built by students for students rather than like a corporate classifieds portal.

Use terminology and categories that reflect real campus life.

## Fast
Browsing, searching, filtering, and campus switching should feel immediate.

Images should be optimized and backend/database queries should be efficient.

## Trustworthy
The UI should clearly communicate:

- Verified student status
- Institutional verification
- Seller campus
- Safe pickup expectations

## Minimal
Avoid:

- Unnecessary ads in the MVP
- Popups
- Visual clutter
- Excessive social features

The goal is to let a student find or list an item quickly.

## What the Product Should NOT Feel Like

### Not a generic enterprise portal
Avoid rigid, boring enterprise UI.

### Not OLX/Craigslist
Avoid clutter, banner-heavy layouts, spam-like listings, and visual chaos.

### Not social media
Avoid endless feeds and engagement mechanics unrelated to buying/selling/resource discovery.

## Visual Preferences
**TBD**

---

# 11. Business Model

## 11.1 MVP
The MVP is completely free:

- No listing fee
- No transaction commission
- No subscription/paywall
- Free account creation
- Free browsing
- Free seller contact

## 11.2 Potential Future Revenue

### Primary — Boosted Listings
Potential micro-fee of approximately ₹29–₹49 to boost/pin listings.

### Campus Advertising
Potential advertising from relevant local/student-focused businesses such as:

- PG/hostel providers
- Mess/tiffin services
- Test-prep institutes
- Cafes

### Campus Event Ticketing
Potential future ticketing feature with a small convenience fee.

### Affiliate Links
Potential affiliate recommendations when an item cannot be found on campus.

### Optional Escrow
Potential future fee for secure transactions involving high-value electronics.

## 11.3 Current Priority
**User adoption and marketplace liquidity are the priority.**

Monetization should not be introduced until there is meaningful usage and transaction volume.

---

# 12. Current Project Status

## 12.1 Completed
- GitHub repository created.
- Frontend and backend separated.
- Initial project structure established.

## 12.2 Currently Building
- Landing page UI.
- Responsive frontend interactions.
- Initial frontend/backend connection.

## 12.3 Not Started Yet
Major marketplace functionality such as:

- Authentication
- Listings CRUD
- Search/filtering
- Resource Hub functionality
- Admin dashboard
- Cloud storage integration
- Production deployment

These should be treated as not yet implemented unless the project status is updated.

## 12.4 Immediate Development Direction
Finish and stabilize the landing page before moving into the core application flows.

---

# 13. Constraints

## 13.1 Technical
- Fully responsive on mobile and desktop.
- Mobile-first design.
- Product images should be compressed/optimized.
- Backend/database queries should be designed for low latency.
- Architecture should remain simple enough for a solo/small student team.

## 13.2 Budget
Target budget: **$0 during MVP development.**

Use free/low-cost developer tiers wherever practical.

Preferred infrastructure:

- Vercel
- Render/Railway
- Supabase
- Cloudinary

Free-tier limits must be checked before production decisions are finalized.

## 13.3 Time
Target: demo-ready MVP within a single semester/OJT evaluation period, approximately 8–12 weeks.

## 13.4 Team
Solo developer or small 2-person student team.

Architecture should prioritize:

- Development speed
- Low operational complexity
- Minimal unnecessary boilerplate
- Maintainability

## 13.5 Institutional Constraints
- Only approved institutional email domains may register.
- Marketplace content must comply with applicable campus policies.
- Prohibited goods include weapons, alcohol, hazardous chemicals, and other restricted items.
- Copyright-infringing/pirated academic content must not be hosted.

## 13.6 Technology Constraints
- Avoid expensive enterprise infrastructure during MVP.
- Avoid unnecessary cloud complexity.
- Core architecture is locked to:
  - React/Vite frontend
  - Python/FastAPI backend
  - PostgreSQL/Supabase database

---

# 14. Terminology

### Marketplace
Core buying, selling, and renting section for physical campus-related items.

### Resource Hub
Academic resource section for digital materials and physical academic assets.

### Listing
A single item or resource posted by a user.

### Seller / Lister
Verified user who publishes an item for sale, rent, or giveaway.

### Buyer / Seeker
Verified user searching for or inquiring about an item/resource.

### Resource Contributor
Verified student or approved faculty member contributing academic resources.

### Domain Whitelist
Approved list of institutional email domains allowed to create accounts.

### Campus Scope
The discovery boundary for listings/resources.

**My Campus:** User's home institution.

**Nearby Campuses:** Verified partner institutions within the configured geographic radius, planned for Phase 2.

### Direct Handshake
Off-platform transaction initiated through WhatsApp or email.

### Pickup Spot
Safe public location where buyer and seller meet for inspection and handover.

### Listing Status
- **Available:** Active and visible.
- **Reserved:** Temporarily held for a pending transaction.
- **Sold / Archived:** Transaction completed and listing removed from active discovery.

### Freebie / Giveaway
Physical item listed for ₹0 and intended to be passed to another student.

---

# 15. Product Development Rules

These rules should guide future development discussions:

1. **Do not introduce a new framework or service without a clear reason.**
2. **Do not replace PostgreSQL with MongoDB or SQLite for production without explicitly discussing the trade-off.**
3. **Do not replace FastAPI with Node.js/Express without an explicit architecture decision.**
4. **Keep the MVP lean.** Features listed as Phase 2+ should not be pulled into the MVP unless there is a deliberate decision to change scope.
5. **Prefer existing managed services over building infrastructure from scratch.**
6. **Prioritize student adoption, trust, speed, and simplicity.**
7. **Keep marketplace transactions off-platform during MVP.**
8. **Treat this document as the baseline.** If a future product decision changes something here, update the context/decision log rather than silently creating a conflicting implementation.
9. **Do not assume a feature is implemented just because it appears in this document.** Product requirements and current implementation status are separate.
10. **When making technical recommendations, optimize for a solo/small student team, an 8–12 week MVP timeline, and a $0 initial infrastructure budget.**

---

# 16. Open Decisions

These are intentionally not finalized:

- Exact Supabase Auth login mechanism: OTP vs magic link.
- SQLAlchemy vs SQLModel.
- Exact database schema.
- Exact API endpoint structure.
- Exact Cloudinary configuration.
- Exact Supabase Storage bucket structure.
- Visual identity, color palette, typography, and design system.
- Multi-campus rollout details.
- Exact production hosting configuration.
