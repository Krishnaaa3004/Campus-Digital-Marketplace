# Campus Marketplace & Resource Hub

## PostgreSQL Database Schema

**Database:** PostgreSQL
**Hosted by:** Supabase
**Database role:** Primary persistent data store for the MVP

---

## 1. Database Overview

This document defines the PostgreSQL database schema for the Campus Marketplace & Resource Hub MVP.

It is the source of truth for:

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

The schema is designed according to the current product scope defined in `PRODUCT_CONTEXT.md` and `ARCHITECTURE.md`.

---

# 2. Database Architecture

The application follows this architecture:

```text
React / Vite Frontend
        |
        | HTTPS / API
        v
FastAPI Backend
        |
        v
PostgreSQL Database
        |
        | hosted by
        v
Supabase
```

### Supporting services

```text
Supabase Auth
    └── User authentication

Cloudinary
    └── Marketplace listing images

Supabase Storage
    └── Resource documents / PDFs
```

The React frontend does not directly execute database queries.

The FastAPI backend is responsible for application logic and database access.

---

# 3. MVP Tables

The MVP contains the following tables:

1. `campuses`
2. `users`
3. `email_domains`
4. `categories`
5. `listings`
6. `listing_images`
7. `resources`
8. `resource_helpful_votes`
9. `reports`

Phase 2 functionality such as native messaging, favorites, ratings, payments, notifications, and the Looking For board is intentionally excluded from the MVP schema.

---

# 4. General Design Principles

## 4.1 UUID Primary Keys

All application tables use UUID primary keys.

This provides globally unique identifiers and integrates naturally with Supabase Auth user IDs.

---

## 4.2 Relational Integrity

Relationships between entities are represented using foreign keys.

The database should enforce important business rules using:

* `PRIMARY KEY`
* `FOREIGN KEY`
* `NOT NULL`
* `UNIQUE`
* `CHECK`

---

## 4.3 User Deletion Policy

Users are not physically deleted during normal application operation.

Instead:

```text
users.is_active = FALSE
```

is used to deactivate an account.

This preserves historical relationships such as listings, resources, and reports.

---

## 4.4 File Storage

Binary files are not stored directly inside PostgreSQL.

### Marketplace images

Stored in Cloudinary.

PostgreSQL stores:

* Cloudinary URL
* Cloudinary public ID
* Display order

### Resource documents

Stored in Supabase Storage.

PostgreSQL stores the relevant file reference/URL.

---

# 5. Table Definitions

# 5.1 `campuses`

Represents an institution/campus participating in the platform.

The MVP initially supports Polaris School of Technology but the schema allows additional campuses in the future.

### Columns

| Column       | Type        | Required | Default           | Description                  |
| ------------ | ----------- | -------: | ----------------- | ---------------------------- |
| `id`         | UUID        |      Yes | Generated UUID    | Primary key                  |
| `name`       | TEXT        |      Yes | —                 | Full institution name        |
| `short_name` | TEXT        |       No | NULL              | Short institution name       |
| `city`       | TEXT        |      Yes | —                 | Campus city                  |
| `is_active`  | BOOLEAN     |      Yes | TRUE              | Whether the campus is active |
| `created_at` | TIMESTAMPTZ |      Yes | Current timestamp | Creation time                |
| `updated_at` | TIMESTAMPTZ |      Yes | Current timestamp | Last update time             |

### Constraints

* `id` is the primary key.
* `name` must be unique.
* `is_active` cannot be NULL.

---

# 5.2 `users`

Represents the application's user profile.

Authentication is handled separately by Supabase Auth.

The `users.id` value corresponds to the authenticated user's Supabase Auth UUID.

### Columns

| Column         | Type        | Required | Default            | Description                      |
| -------------- | ----------- | -------: | ------------------ | -------------------------------- |
| `id`           | UUID        |      Yes | Supabase Auth UUID | Primary key                      |
| `full_name`    | TEXT        |      Yes | —                  | User's display name              |
| `email`        | TEXT        |      Yes | —                  | Institutional email              |
| `campus_id`    | UUID        |      Yes | —                  | User's campus                    |
| `role`         | TEXT        |      Yes | `student`          | `student`, `faculty`, or `admin` |
| `phone_number` | TEXT        |       No | NULL               | Optional contact number          |
| `is_active`    | BOOLEAN     |      Yes | TRUE               | Account status                   |
| `created_at`   | TIMESTAMPTZ |      Yes | Current timestamp  | Account creation time            |
| `updated_at`   | TIMESTAMPTZ |      Yes | Current timestamp  | Last update time                 |

### Relationships

```text
users.campus_id
        |
        v
campuses.id
```

### Constraints

* `id` is the primary key.
* `email` must be unique.
* `role` must be one of:

  * `student`
  * `faculty`
  * `admin`
* `is_active` cannot be NULL.

---

# 5.3 `email_domains`

Stores approved institutional email domains.

This supports the requirement that registration is restricted to approved college/institutional email domains.

### Columns

| Column       | Type        | Required | Default           | Description                         |
| ------------ | ----------- | -------: | ----------------- | ----------------------------------- |
| `id`         | UUID        |      Yes | Generated UUID    | Primary key                         |
| `domain`     | TEXT        |      Yes | —                 | Approved email domain               |
| `campus_id`  | UUID        |      Yes | —                 | Campus associated with domain       |
| `is_active`  | BOOLEAN     |      Yes | TRUE              | Whether domain is currently allowed |
| `created_at` | TIMESTAMPTZ |      Yes | Current timestamp | Creation time                       |

### Example

```text
domain = "polaris.edu"
```

### Relationships

```text
email_domains.campus_id
        |
        v
campuses.id
```

### Constraints

* `domain` must be unique.
* `campus_id` must reference an existing campus.

---

# 5.4 `categories`

Stores marketplace categories.

Example categories:

* Textbooks
* Lab Gear
* Electronics
* Dorm Essentials
* Project Kits
* Mobility / Sports
* Clothing / Event Wear

### Columns

| Column       | Type        | Required | Default           | Description                 |
| ------------ | ----------- | -------: | ----------------- | --------------------------- |
| `id`         | UUID        |      Yes | Generated UUID    | Primary key                 |
| `name`       | TEXT        |      Yes | —                 | Category name               |
| `slug`       | TEXT        |      Yes | —                 | URL/API-friendly identifier |
| `created_at` | TIMESTAMPTZ |      Yes | Current timestamp | Creation time               |

### Constraints

* `name` must be unique.
* `slug` must be unique.

---

# 5.5 `listings`

The primary Marketplace table.

One row represents one item being offered by a student or other approved user.

### Columns

| Column                 | Type          | Required | Default           | Description                      |
| ---------------------- | ------------- | -------: | ----------------- | -------------------------------- |
| `id`                   | UUID          |      Yes | Generated UUID    | Primary key                      |
| `seller_id`            | UUID          |      Yes | —                 | User who created the listing     |
| `campus_id`            | UUID          |      Yes | —                 | Campus associated with listing   |
| `category_id`          | UUID          |      Yes | —                 | Marketplace category             |
| `title`                | TEXT          |      Yes | —                 | Listing title                    |
| `description`          | TEXT          |      Yes | —                 | Item description                 |
| `price`                | NUMERIC(10,2) |      Yes | 0                 | Price in INR                     |
| `listing_type`         | TEXT          |      Yes | `sale`            | Sale, giveaway, or rental        |
| `condition`            | TEXT          |      Yes | —                 | Item condition                   |
| `status`               | TEXT          |      Yes | `available`       | `available` or `sold`            |
| `pickup_location`      | TEXT          |       No | NULL              | Preferred meetup/pickup location |
| `rental_rate`          | NUMERIC(10,2) |       No | NULL              | Rental price when applicable     |
| `security_deposit`     | NUMERIC(10,2) |       No | NULL              | Security deposit when applicable |
| `rental_duration_days` | INTEGER       |       No | NULL              | Rental duration when applicable  |
| `created_at`           | TIMESTAMPTZ   |      Yes | Current timestamp | Creation time                    |
| `updated_at`           | TIMESTAMPTZ   |      Yes | Current timestamp | Last update time                 |

### Relationships

```text
listings.seller_id
        |
        v
users.id
```

```text
listings.campus_id
        |
        v
campuses.id
```

```text
listings.category_id
        |
        v
categories.id
```

### Allowed listing types

```text
sale
giveaway
rental
```

### Allowed conditions

```text
new
like_new
good
fair
poor
```

### Allowed statuses

```text
available
sold
```

### Constraints

* `price >= 0`
* `rental_rate >= 0` when provided
* `security_deposit >= 0` when provided
* `rental_duration_days > 0` when provided
* Rental-specific values should only be used when `listing_type = rental`.

---

# 5.6 `listing_images`

Stores metadata for marketplace listing images.

The actual image files are stored in Cloudinary.

One listing can contain a maximum of **5 images**.

### Columns

| Column                 | Type        | Required | Default           | Description                 |
| ---------------------- | ----------- | -------: | ----------------- | --------------------------- |
| `id`                   | UUID        |      Yes | Generated UUID    | Primary key                 |
| `listing_id`           | UUID        |      Yes | —                 | Associated listing          |
| `image_url`            | TEXT        |      Yes | —                 | Cloudinary image URL        |
| `cloudinary_public_id` | TEXT        |      Yes | —                 | Cloudinary asset identifier |
| `display_order`        | INTEGER     |      Yes | —                 | Image order from 1 to 5     |
| `created_at`           | TIMESTAMPTZ |      Yes | Current timestamp | Upload time                 |

### Relationships

```text
listing_images.listing_id
        |
        v
listings.id
```

### Constraints

* `display_order` must be between 1 and 5.
* `(listing_id, display_order)` must be unique.
* A listing may contain no more than 5 images.
* The application/API layer must ensure that listings intended for publication contain at least one image.

---

# 5.7 `resources`

Stores Resource Hub contributions.

Resources may be digital or physical.

### Columns

| Column              | Type        | Required | Default           | Description                                |
| ------------------- | ----------- | -------: | ----------------- | ------------------------------------------ |
| `id`                | UUID        |      Yes | Generated UUID    | Primary key                                |
| `contributor_id`    | UUID        |      Yes | —                 | User who contributed resource              |
| `campus_id`         | UUID        |      Yes | —                 | Associated campus                          |
| `title`             | TEXT        |      Yes | —                 | Resource title                             |
| `description`       | TEXT        |       No | NULL              | Resource description                       |
| `resource_type`     | TEXT        |      Yes | —                 | `digital` or `physical`                    |
| `resource_category` | TEXT        |      Yes | —                 | Notes, PYQ, lab work, etc.                 |
| `department`        | TEXT        |       No | NULL              | Academic department                        |
| `course_code`       | TEXT        |       No | NULL              | Course code                                |
| `subject_name`      | TEXT        |       No | NULL              | Subject name                               |
| `semester`          | INTEGER     |       No | NULL              | Relevant semester                          |
| `access_type`       | TEXT        |      Yes | —                 | `download`, `external_link`, or `physical` |
| `file_url`          | TEXT        |       No | NULL              | Supabase Storage file reference            |
| `external_url`      | TEXT        |       No | NULL              | External resource URL                      |
| `status`            | TEXT        |      Yes | `active`          | `active` or `hidden`                       |
| `created_at`        | TIMESTAMPTZ |      Yes | Current timestamp | Creation time                              |
| `updated_at`        | TIMESTAMPTZ |      Yes | Current timestamp | Last update time                           |

### Relationships

```text
resources.contributor_id
        |
        v
users.id
```

```text
resources.campus_id
        |
        v
campuses.id
```

### Constraints

* `resource_type` must be `digital` or `physical`.
* `access_type` must be `download`, `external_link`, or `physical`.
* `status` must be `active` or `hidden`.
* `semester`, when provided, must be a positive integer.
* `file_url` and `external_url` should be validated according to `access_type`.

---

# 5.8 `resource_helpful_votes`

Records which users marked a resource as Helpful.

This is preferable to storing only a numeric counter because it prevents one user from repeatedly increasing the count.

### Columns

| Column        | Type        | Required | Default           | Description                   |
| ------------- | ----------- | -------: | ----------------- | ----------------------------- |
| `id`          | UUID        |      Yes | Generated UUID    | Primary key                   |
| `resource_id` | UUID        |      Yes | —                 | Resource being marked helpful |
| `user_id`     | UUID        |      Yes | —                 | User giving the vote          |
| `created_at`  | TIMESTAMPTZ |      Yes | Current timestamp | Vote time                     |

### Relationships

```text
resource_helpful_votes.resource_id
        |
        v
resources.id
```

```text
resource_helpful_votes.user_id
        |
        v
users.id
```

### Constraints

```text
UNIQUE(resource_id, user_id)
```

A user can therefore mark a particular resource Helpful only once.

The Helpful count can be calculated from the number of associated vote records.

---

# 5.9 `reports`

Stores moderation reports created by users.

A report can target either a marketplace listing or a Resource Hub resource.

### Columns

| Column        | Type        | Required | Default           | Description               |
| ------------- | ----------- | -------: | ----------------- | ------------------------- |
| `id`          | UUID        |      Yes | Generated UUID    | Primary key               |
| `reporter_id` | UUID        |      Yes | —                 | User who submitted report |
| `listing_id`  | UUID        |       No | NULL              | Reported listing          |
| `resource_id` | UUID        |       No | NULL              | Reported resource         |
| `reason`      | TEXT        |      Yes | —                 | Report category           |
| `description` | TEXT        |       No | NULL              | Additional explanation    |
| `status`      | TEXT        |      Yes | `pending`         | Moderation status         |
| `reviewed_by` | UUID        |       No | NULL              | Admin who reviewed report |
| `reviewed_at` | TIMESTAMPTZ |       No | NULL              | Review time               |
| `created_at`  | TIMESTAMPTZ |      Yes | Current timestamp | Report creation time      |

### Relationships

```text
reports.reporter_id
        |
        v
users.id
```

```text
reports.listing_id
        |
        v
listings.id
```

```text
reports.resource_id
        |
        v
resources.id
```

```text
reports.reviewed_by
        |
        v
users.id
```

### Allowed statuses

```text
pending
reviewed
resolved
dismissed
```

### Critical constraint

Exactly one of the following must be provided:

```text
listing_id
resource_id
```

A report cannot target both a listing and a resource, and it cannot target neither.

---

# 6. Entity Relationships

## Campus relationships

```text
campuses 1 ────────< users
campuses 1 ────────< listings
campuses 1 ────────< resources
campuses 1 ────────< email_domains
```

One campus can have many users, listings, resources, and approved email domains.

---

## User relationships

```text
users 1 ────────< listings
users 1 ────────< resources
users 1 ────────< reports
users 1 ────────< resource_helpful_votes
```

A user can create multiple listings, resources, reports, and helpful votes.

---

## Listing relationships

```text
listings 1 ────────< listing_images
```

One listing can have multiple images, up to the MVP limit of 5.

---

## Category relationship

```text
categories 1 ────────< listings
```

One category can contain many listings.

---

## Resource relationships

```text
resources 1 ────────< resource_helpful_votes
```

One resource can receive many Helpful votes.

---

# 7. Foreign-Key Delete Behavior

Foreign keys use the following deletion strategy.

| Relationship                  | Delete behavior | Reason                                 |
| ----------------------------- | --------------- | -------------------------------------- |
| `campuses → users`            | RESTRICT        | Preserve user relationships            |
| `campuses → listings`         | RESTRICT        | Preserve listing ownership/context     |
| `campuses → resources`        | RESTRICT        | Preserve resource context              |
| `campuses → email_domains`    | CASCADE         | Domains depend on campus               |
| `users → listings`            | RESTRICT        | Preserve marketplace history           |
| `users → resources`           | RESTRICT        | Preserve contributor history           |
| `users → reports`             | RESTRICT        | Preserve reporting history             |
| `users → helpful_votes`       | CASCADE         | Vote has no meaning without user       |
| `users → reports.reviewed_by` | SET NULL        | Preserve report if reviewer is removed |
| `categories → listings`       | RESTRICT        | Prevent deletion of category in use    |
| `listings → listing_images`   | CASCADE         | Images depend on listing               |
| `resources → helpful_votes`   | CASCADE         | Votes depend on resource               |
| `listings → reports`          | RESTRICT        | Preserve moderation history            |
| `resources → reports`         | RESTRICT        | Preserve moderation history            |

Normal user account removal should use account deactivation rather than physical deletion.

---

# 8. Indexes

Indexes are added primarily for fields commonly used for filtering, sorting, joining, or lookup.

## `users`

```text
UNIQUE(email)
INDEX(campus_id)
```

---

## `email_domains`

```text
UNIQUE(domain)
```

---

## `categories`

```text
UNIQUE(name)
UNIQUE(slug)
```

---

## `listings`

```text
INDEX(seller_id)
INDEX(category_id)
INDEX(campus_id)
INDEX(status)
INDEX(created_at)
INDEX(campus_id, status, created_at)
```

The composite index supports common marketplace queries such as:

```text
Find available listings for a campus,
ordered by newest first.
```

---

## `listing_images`

```text
UNIQUE(listing_id, display_order)
```

The composite unique index also supports looking up the images belonging to a listing.

---

## `resources`

```text
INDEX(contributor_id)
INDEX(campus_id)
INDEX(resource_category)
INDEX(created_at)
INDEX(campus_id, status, created_at)
```

---

## `resource_helpful_votes`

```text
UNIQUE(resource_id, user_id)
INDEX(user_id)
```

The unique constraint prevents duplicate votes.

---

## `reports`

```text
INDEX(status)
INDEX(created_at)
```

These support moderation queues and chronological report processing.

---

# 9. Supabase Integration

Supabase provides the managed infrastructure around the PostgreSQL database.

## Supabase Auth

Supabase Auth manages:

* User authentication
* Login/signup
* Sessions
* Authentication tokens

The authenticated user's UUID is used as the primary key of `public.users`.

Conceptually:

```text
auth.users.id
      =
public.users.id
```

Passwords and authentication credentials are not stored in `public.users`.

---

## Supabase PostgreSQL

PostgreSQL stores:

* Users
* Campuses
* Email domains
* Categories
* Marketplace listings
* Listing image metadata
* Resource metadata
* Helpful votes
* Reports

---

## Supabase Storage

Supabase Storage stores Resource Hub documents such as:

* PDFs
* Notes
* Academic files

PostgreSQL stores the corresponding file reference.

---

## Cloudinary

Cloudinary stores marketplace listing images.

PostgreSQL stores:

* Image URL
* Cloudinary public ID
* Display order
* Associated listing

---

# 10. Application Architecture

The intended data flow is:

```text
User
 |
 v
React / Vite
 |
 | HTTPS
 v
FastAPI
 |
 +--------------------+
 |                    |
 v                    v
PostgreSQL          Cloudinary
(Supabase)          (Images)
 |
 +--------------------+
 |
 v
Supabase Storage
(Resource Files)
```

FastAPI is responsible for application logic, authorization, validation, and database operations.

---

# 11. MVP Business Rules

The following rules are part of the database/application design:

1. Users must register using an approved institutional email domain.
2. Users belong to a campus.
3. Users can create marketplace listings.
4. Each listing belongs to one category.
5. Each listing belongs to one seller.
6. A listing can contain a maximum of 5 images.
7. Listing images are stored in Cloudinary.
8. Listing status is either `available` or `sold`.
9. Listing price cannot be negative.
10. Rental-specific fields are used only for rental listings.
11. Resources can be digital or physical.
12. Resource files are stored using Supabase Storage where applicable.
13. Users can mark resources helpful.
14. A user can mark the same resource Helpful only once.
15. Users can report listings or resources.
16. A report must target exactly one listing or resource.
17. Users are deactivated rather than normally deleted.
18. Phase 2 features are not represented in the MVP database.

---

# 12. Future Extensibility

The schema is designed so that future functionality can be added without restructuring the core MVP tables.

Potential future tables include:

```text
messages
conversations
favorites
reviews
notifications
transactions
looking_for_requests
```

These are intentionally excluded from the MVP schema.

Future multi-campus support is already accommodated through the `campuses` table and related foreign keys.

---

# 13. Schema Status

This document represents the finalized logical database design for the MVP.

The next implementation step is to translate this design into PostgreSQL SQL and create the database structure in Supabase.

No application code should be generated from an unreviewed schema.

