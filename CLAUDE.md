# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ruby on Rails 8.0.1 application for managing DJ studio room reservations at "The Site DeeJay Academy". Students book time slots in rooms based on their subscription plan. The application is in Spanish.

- **Ruby:** 3.3.6
- **Rails:** 8.0.1
- **Dev/Test DB:** SQLite3
- **Production DB:** MySQL 8.0
- **Auth:** Devise (Student model only — no self-registration)
- **Frontend:** Bootstrap 4.4.1, Turbolinks 5, CoffeeScript, jQuery

## Common Commands

```bash
bundle install          # Install dependencies
bin/rails s             # Start development server (port 3000)
bin/rails db:migrate    # Run pending migrations
bin/rails db:seed       # Seed the database
bin/rails console       # Open Rails console
bin/rails routes        # List all routes
```

**Docker (production):**
```bash
docker-compose up       # Start dev with Docker
docker-compose -f docker-compose.prod.yml up   # Production
```
Migrations run automatically on container startup via `docker-entrypoint.sh`.

**Deployment to VPS:**
```bash
DEPLOY_TARGET=usuario@ip ./deploy.sh   # Rsync + Docker rebuild on remote
```

**Tests:**
There is no active test suite configured. Capybara is in the Gemfile but no specs/tests exist.

## Architecture

### Authentication & Authorization

Two separate user types:
- **`Student`** — Devise model (email + password). Used for login only.
- **`User`** — Application model with roles: `estudiante`, `instructor`, `admin`.

`ApplicationController` links them: after Devise authenticates a `Student`, it looks up the matching `User` by email and stores it as `@user_conected`. Role-based access uses `before_action :require_instructor_or_admin`.

Email-based password recovery is **disabled** (recent commit). Students change passwords via `/mi_cuenta/cambiar_contrasena`. New accounts get the password from `ENV["DEFAULT_STUDENT_PASSWORD"]`.

`SchedulesController` has `before_action :require_instructor_or_admin`, meaning only instructors and admins can access the booking calendar. The business logic inside still distinguishes roles (`@user_conected.rol != "estudiante"`) because admins/instructors book on behalf of students by passing a `suscription_id` parameter.

### Core Business Logic

All reservation logic lives in `SchedulesController`:
- `#index` — Returns JSON of reservations for calendar display
- `#new` (GET, not POST) — Creates a reservation with validations, returns JSON
- `#destroy` — Cancels a reservation with validations

**Reservation rules enforced:**
- No double-booking a room/slot
- Student can't exceed subscription hour allowance
- Students can only book rooms linked to their subscription (stored as comma-separated room IDs in `suscriptions.rooms`)
- No booking past dates; weekday/weekend hour restrictions apply
- Cancellations require 1-hour notice
- Instructors/admins bypass most restrictions

**JSON status codes** from `SchedulesController`:
- `0` — error
- `1` — success
- `2` — no hours remaining
- `3` — past date
- `4` — time restriction

**Slot size is hardcoded to 2 hours** throughout the app (controller and JS both use `count * 2` and `start_hour + 2`).

### Data Model

```
User (admin/instructor/student role)
  └── has_many :suscriptions

Suscription
  ├── belongs_to :user
  ├── name: enum (MV1, MV1N2, MV2, MV2N2, MV3, MV3N2, P1–P5, Bloque, Demo, Otro)
  ├── hours: enum (Dos=2, Cuatro=4, Diez=10, Doce=12, Full=24)
  └── rooms: comma-separated room IDs (NOT a foreign key)

Room
  └── has_many :schedules

Schedule (available time slots — largely vestigial)
  ├── belongs_to :room
  ├── day (date), hour (integer)
  └── has_many :reservations

Reservation (actual booking)
  ├── belongs_to :schedule  (FK exists but mostly unused)
  ├── belongs_to :suscription
  ├── start_hour (integer), reserve_date (date)
  └── room (string — denormalized room ID, NOT a FK to Room)
```

The `Schedule` table is largely vestigial. Actual bookings are stored with `start_hour`, `reserve_date`, and `room` (a string) directly on `Reservation`. The `schedule_id` FK is populated but the schedule records are not queried for business logic.

Note: `Suscription` is intentionally misspelled this way throughout the codebase (table name, model, controller, routes).

### Frontend

The calendar view (`schedules#index`) is fully client-side and driven by AJAX. All key JS lives in `app/assets/javascripts/application.js`. Libraries loaded via Sprockets/vendor:

- **FullCalendar v4** — Weekly/daily calendar for viewing and creating reservations
- **DataTables** — Sortable tables on admin list pages (`/users`, `/suscriptions`, `/reservations`)
- **Moment.js + moment-timezone** — Date math, defaulting to `America/Bogota`
- **SweetAlert2 (Swal)** — All modal dialogs (confirmations, error messages)
- **Air Datepicker** — Date picker input on the calendar page

Hidden inputs on the schedule view pass context to JS: `#roow_id` (note double-o typo — this is the room ID), `#suscription_id`, and `#user_rol`. Booking and cancellation go through AJAX calls to `SchedulesController#new` (GET) and `#destroy` (DELETE).

### Routes

- Root: `rooms#index`
- Nested: `rooms/:room_id/schedules` (index + new + destroy)
- Devise: `devise_for :students, skip: [:registrations]`
- Admin CRUD: `/users`, `/suscriptions`, `/reservations`
- Password change: `/mi_cuenta/cambiar_contrasena`
- Admin password reset: `GET/PATCH users/:id/edit_password` and `PATCH users/:id/update_password`

### Environment Variables

Defined in `.env` (based on `.env.example`). Managed by `figaro`.

Key vars:
- `DEFAULT_STUDENT_PASSWORD` — Initial password for new student accounts
- `SECRET_KEY_BASE` — Required in production
- `MYSQL_HOST`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_DATABASE` — Production DB
- `FORCE_SSL` / `DISABLE_SSL` — SSL toggle

### Timezone

Application timezone is `America/Bogota` (`config/application.rb`). The JS also sets `moment.tz.setDefault("America/Bogota")` and FullCalendar uses `timeZone: 'America/Bogota'`.
