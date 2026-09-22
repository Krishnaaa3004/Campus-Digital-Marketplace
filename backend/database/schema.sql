-- Campus Marketplace & Resource Hub
-- PostgreSQL schema for Supabase
-- MVP schema: 9 tables

create extension if not exists pgcrypto;

create table public.campuses (
    id uuid primary key default gen_random_uuid(),
    name text not null unique,
    short_name text,
    city text not null,
    is_active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table public.users (
    id uuid primary key references auth.users(id) on delete restrict,
    full_name text not null,
    email text not null unique,
    campus_id uuid not null references public.campuses(id) on delete restrict,
    role text not null default 'student'
        check (role in ('student', 'faculty', 'admin')),
    phone_number text,
    is_active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table public.email_domains (
    id uuid primary key default gen_random_uuid(),
    domain text not null unique,
    campus_id uuid not null references public.campuses(id) on delete cascade,
    is_active boolean not null default true,
    created_at timestamptz not null default now()
);

create table public.categories (
    id uuid primary key default gen_random_uuid(),
    name text not null unique,
    slug text not null unique,
    created_at timestamptz not null default now()
);

create table public.listings (
    id uuid primary key default gen_random_uuid(),
    seller_id uuid not null references public.users(id) on delete restrict,
    campus_id uuid not null references public.campuses(id) on delete restrict,
    category_id uuid not null references public.categories(id) on delete restrict,
    title text not null,
    description text not null,
    price numeric(10,2) not null default 0
        check (price >= 0),
    listing_type text not null default 'sale'
        check (listing_type in ('sale', 'giveaway', 'rental')),
    condition text not null
        check (condition in ('new', 'like_new', 'good', 'fair', 'poor')),
    status text not null default 'available'
        check (status in ('available', 'sold')),
    pickup_location text,
    rental_rate numeric(10,2)
        check (rental_rate is null or rental_rate >= 0),
    security_deposit numeric(10,2)
        check (security_deposit is null or security_deposit >= 0),
    rental_duration_days integer
        check (rental_duration_days is null or rental_duration_days > 0),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint rental_fields_only_for_rentals check (
        listing_type = 'rental'
        or (
            rental_rate is null
            and security_deposit is null
            and rental_duration_days is null
        )
    )
);

create table public.listing_images (
    id uuid primary key default gen_random_uuid(),
    listing_id uuid not null references public.listings(id) on delete cascade,
    image_url text not null,
    cloudinary_public_id text not null,
    display_order integer not null
        check (display_order between 1 and 5),
    created_at timestamptz not null default now(),
    constraint unique_listing_image_order unique (listing_id, display_order)
);

create table public.resources (
    id uuid primary key default gen_random_uuid(),
    contributor_id uuid not null references public.users(id) on delete restrict,
    campus_id uuid not null references public.campuses(id) on delete restrict,
    title text not null,
    description text,
    resource_type text not null
        check (resource_type in ('digital', 'physical')),
    resource_category text not null,
    department text,
    course_code text,
    subject_name text,
    semester integer
        check (semester is null or semester > 0),
    access_type text not null
        check (access_type in ('download', 'external_link', 'physical')),
    file_url text,
    external_url text,
    status text not null default 'active'
        check (status in ('active', 'hidden')),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint resource_access_fields check (
        (access_type = 'download' and file_url is not null and external_url is null)
        or
        (access_type = 'external_link' and external_url is not null and file_url is null)
        or
        (access_type = 'physical' and file_url is null and external_url is null)
    )
);

create table public.resource_helpful_votes (
    id uuid primary key default gen_random_uuid(),
    resource_id uuid not null references public.resources(id) on delete cascade,
    user_id uuid not null references public.users(id) on delete cascade,
    created_at timestamptz not null default now(),
    constraint unique_resource_helpful_vote unique (resource_id, user_id)
);

create table public.reports (
    id uuid primary key default gen_random_uuid(),
    reporter_id uuid not null references public.users(id) on delete restrict,
    listing_id uuid references public.listings(id) on delete restrict,
    resource_id uuid references public.resources(id) on delete restrict,
    reason text not null,
    description text,
    status text not null default 'pending'
        check (status in ('pending', 'reviewed', 'resolved', 'dismissed')),
    reviewed_by uuid references public.users(id) on delete set null,
    reviewed_at timestamptz,
    created_at timestamptz not null default now(),
    constraint report_exactly_one_target check (
        (listing_id is not null and resource_id is null)
        or
        (listing_id is null and resource_id is not null)
    )
);

-- Indexes

create index idx_users_campus_id
    on public.users(campus_id);

create index idx_listings_seller_id
    on public.listings(seller_id);

create index idx_listings_category_id
    on public.listings(category_id);

create index idx_listings_campus_id
    on public.listings(campus_id);

create index idx_listings_status
    on public.listings(status);

create index idx_listings_created_at
    on public.listings(created_at);

create index idx_listings_campus_status_created
    on public.listings(campus_id, status, created_at);

create index idx_resources_contributor_id
    on public.resources(contributor_id);

create index idx_resources_campus_id
    on public.resources(campus_id);

create index idx_resources_category
    on public.resources(resource_category);

create index idx_resources_created_at
    on public.resources(created_at);

create index idx_resources_campus_status_created
    on public.resources(campus_id, status, created_at);

create index idx_helpful_votes_user_id
    on public.resource_helpful_votes(user_id);

create index idx_reports_status
    on public.reports(status);

create index idx_reports_created_at
    on public.reports(created_at);

-- Keep updated_at current when rows are modified.

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
    new.updated_at = now();
    return new;
end;
$$;

create trigger set_campuses_updated_at
before update on public.campuses
for each row execute function public.set_updated_at();

create trigger set_users_updated_at
before update on public.users
for each row execute function public.set_updated_at();

create trigger set_listings_updated_at
before update on public.listings
for each row execute function public.set_updated_at();

create trigger set_resources_updated_at
before update on public.resources
for each row execute function public.set_updated_at();
