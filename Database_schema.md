# Campus Marketplace & Resource Hub

## PostgreSQL Database Schema

**Database:** PostgreSQL
**Hosted by:** Supabase
**Database role:** Primary persistent data store for the MVP

---

## 1. Database Overview

This document defines the PostgreSQL database schema for the Campus Marketplace & Resource Hub MVP.

It serves as the source of truth for:

* Database tables
* Columns and data types
* Primary keys
* Foreign keys
* Relationships
* Required and optional fields
* Constraints
* Indexes
* Supabase integration
* Storage strategy

The database is designed around the current MVP scope defined in `PRODUCT_CONTEXT.md` and `ARCHITECTURE.md`.

---

## 2. Database Architecture

The application uses PostgreSQL hosted through Supabase.

The backend architecture is:

React Frontend
↓
FastAPI Backend
↓
PostgreSQL Database (Supabase)

Supabase Auth is responsible for user authentication.

PostgreSQL stores application-level user profiles and marketplace/resource data.

Cloudinary stores marketplace listing images.

Supabase Storage stores uploaded documents and resource files.

---

## 3. MVP Tables

The initial MVP database consists of the following tables:

1. `users`
2. `campuses`
3. `email_domains`
4. `categories`
5. `listings`
6. `listing_images`
7. `resources`
8. `resource_helpful_votes`
9. `reports`

---

## 4. Design Principles

### 4.1 Relational Design

Related data is separated into appropriate tables and connected using foreign keys.

### 4.2 UUID Primary Keys

UUIDs are used for primary keys, particularly because Supabase Auth identifies users using UUIDs.

### 4.3 Data Integrity

The database should enforce important rules using:

* `NOT NULL`
* `UNIQUE`
* `CHECK`
* Foreign key constraints

### 4.4 Minimal MVP Scope

Only functionality required by the MVP is represented in the initial schema.

Phase 2 functionality such as native messaging, favorites, ratings, payments, and a Looking For board is intentionally excluded.

### 4.5 External File Storage

Binary files and images are not stored directly inside PostgreSQL.

Marketplace images are stored in Cloudinary.

Resource documents are stored in Supabase Storage.

PostgreSQL stores the metadata and references required to access those files.

---

## 5. Table Design

Detailed table definitions will be added after each table has been reviewed and finalized.

### 5.1 Users

### 5.2 Campuses

### 5.3 Email Domains

### 5.4 Categories

### 5.5 Listings

### 5.6 Listing Images

### 5.7 Resources

### 5.8 Resource Helpful Votes

### 5.9 Reports

---

## 6. Relationships

The finalized entity relationships will be documented here after the individual tables have been designed.

---

## 7. Constraints

Database-level constraints will be documented here after the table designs have been finalized.

---

## 8. Indexes

Indexes will be selected based on the application's expected search, filtering, sorting, and relationship queries.

---

## 9. Supabase Integration

This section will document:

* Supabase Auth
* PostgreSQL
* Supabase Storage
* Backend database connectivity
* Security considerations

---

## 10. Future Extensibility

The schema should support future expansion without unnecessarily implementing Phase 2 functionality in the MVP.

Potential future functionality includes:

* Native messaging
* Favorites
* Ratings and reviews
* Notifications
* Looking For requests
* Additional campus/institution support
* Advanced marketplace features

