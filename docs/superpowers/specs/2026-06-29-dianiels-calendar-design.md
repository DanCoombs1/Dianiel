# Dianiel's Calendar — Design Spec

**Date:** 2026-06-29
**Status:** Approved for planning

## Overview

Dianiel's Calendar is a shared calendar app for a couple — Diana and Dan. It works
like a digital wall calendar: each month is presented as a grid with a large hero
photo at the top, and both partners can add, see, and edit events in a single shared
calendar with live sync between their phones.

The app is a Flutter mobile app, iOS-first, distributed via TestFlight. The backend
is Firebase (Blaze plan, which stays free at this usage scale). The theme is baby
pink throughout. 🌸

## Goals

- A single shared calendar that both Diana and Dan can read and write.
- A wall-calendar feel: month grid with a swappable hero photo per calendar month.
- Events can belong to Diana, to Dan, or to both ("Together", marked with a heart).
- Be as functional as leading calendar apps for the core flows (month + agenda
  views, recurring events, reminders, color-coding).
- Live realtime sync, plus a push notification when one partner adds/changes an event.
- Idiomatic Flutter architecture that is testable and maintainable.

## Non-Goals (deferred beyond v1)

- Week view and drag-to-reschedule.
- Importing/syncing external calendars (Google / Apple / Outlook).
- Shared to-do lists, shopping lists, recipes.
- AI scheduling suggestions.
- Android / web builds (iOS/TestFlight first; Flutter keeps these open later).
- Multi-couple / multi-tenant support — the app serves exactly one couple.

## Users & Identity

- Exactly two users: **Diana** and **Dan**.
- Sign in with **Apple** (one tap on iOS, no passwords).
- Each user has a profile: display name, an assigned color, and an FCM token for push.
- Security rules restrict all reads/writes to these two authenticated accounts.

## Features (v1)

### Month view (primary screen)
- Styled like a wall calendar: a large **hero photo** at the top, the month grid below.
- Each day cell shows color-coded dots/indicators for that day's events.
- "Together" events are marked with a heart ❤️.
- Navigate between months (forward/back).

### Month photos
- **12 photo slots, one per calendar month** (January–December). A month's photo
  **repeats every year** (e.g. June 2026 and June 2027 show the same June photo).
- Either partner can **upload, swap, or remove** any month's photo.
- Photos are stored in Cloud Storage; the Firestore doc records the storage path,
  who uploaded it, and when.

### Events
An event has:
- **Title** (required)
- **Date** (required); optional **start time**, or an **all-day** toggle
- **Location** (optional, free text)
- **Ownership**: `diana` | `dan` | `together` — color-coded; `together` shows a heart
- **Notes** (optional, free text)
- **Reminder**: none | at time | 10 min before | 1 hr before | 1 day before
- **Recurrence**: none | weekly | monthly | yearly (yearly covers birthdays/anniversaries)
- Metadata: `createdBy`, created/updated timestamps

Users can add, edit, and delete events.

### Day agenda
- Tapping a day opens an **agenda list** of that day's events (chronological,
  all-day first), each showing ownership color and heart where relevant.

### Countdown strip
- A small strip surfacing the **next big upcoming dates** (e.g. next anniversary,
  trip, birthday) as countdowns — a couple-focused touch.
- v1: derive countdowns from upcoming events (optionally a flag marking an event as
  a "big date"). Exact selection rule to be finalized in the implementation plan.

### Notifications
- **Personal reminders** (e.g. "1 hr before") → **on-device local notifications**
  via `flutter_local_notifications`. No backend cost, work offline.
- **Partner activity** ("Diana added an event") → **Firebase Cloud Messaging**,
  triggered by a **Cloud Function** on Firestore event create/update, sent to the
  *other* partner's device.

### Theme
- Baby pink throughout — cohesive light theme with baby pink as the primary color.

## Architecture

### Client (Flutter)
Layered for isolation and testability:

- **UI layer** — screens (Month view, Day agenda, Event editor, Photo manager,
  Settings) plus reusable widgets, all in the baby-pink theme. The UI never touches
  Firebase directly.
- **State management** — **Riverpod**. Providers expose data streams and actions to
  the UI; well-suited to Firestore's realtime streams and easy to test.
- **Data layer** — repositories wrapping Firebase services, exposing plain Dart
  models and streams. Swapping or mocking Firebase happens here.

### Backend (Firebase, Blaze plan)
- **Auth** — Sign in with Apple.
- **Firestore** — a single shared calendar (one couple). Realtime listeners drive
  live sync between devices.
- **Cloud Storage** — the 12 month photos.
- **Cloud Functions** — one function: on event create/update, send an FCM push to
  the partner who did not make the change.
- **Security rules** — restrict all access to the two authenticated accounts.

### Data model (Firestore)
```
events/{id}:
  title: string
  date: timestamp (the day)
  startTime: string|null     // e.g. "18:30", null if all-day
  allDay: bool
  location: string|null
  owner: "diana" | "dan" | "together"
  notes: string|null
  reminder: "none" | "at_time" | "10_min" | "1_hour" | "1_day"
  recurrence: "none" | "weekly" | "monthly" | "yearly"
  isBigDate: bool            // surfaced in countdown strip
  createdBy: string (uid)
  createdAt: timestamp
  updatedAt: timestamp

monthPhotos/{1..12}:         // doc id = month number 1–12
  storagePath: string
  uploadedBy: string (uid)
  updatedAt: timestamp

users/{uid}:
  displayName: string
  color: string              // hex
  fcmToken: string|null
```

### Notifications design
- Local notifications scheduled on-device from each event's reminder setting.
  Rescheduled when events change; cleared when events are deleted.
- FCM push from the Cloud Function for partner activity, delivered to the other
  user's `fcmToken`.

## Testing

- **Unit tests** — models (serialization) and repositories, run against the
  **Firebase emulator suite**.
- **Widget tests** — key screens (Month view, Event editor, Day agenda) with mocked
  repositories/providers.
- Idiomatic Flutter testing throughout (`flutter_test`, Riverpod overrides for
  injecting fakes).

## Open Items (to resolve during planning)
- Exact selection rule for the countdown strip (how many dates, how far ahead).
- Recurrence expansion strategy (store rule + expand in client vs. materialize
  instances) — lean toward storing the rule and expanding in the client for v1.
- Color assignment defaults for Diana / Dan / Together.

## Addendum (2026-06-29): To-do list & Photo vault

Two features added after the initial v1 design was approved. The app's post-sign-in
home becomes a **HomeShell** with a bottom navigation bar of three tabs:
**Calendar** (the existing Month view), **To-dos**, and **Vault**.

### Shared to-do list
- A single **shared, flat** to-do list (no per-person tagging — unlike events).
- A to-do has: **title**, **done** (checkbox), an optional **scheduledDate** (set when
  it has been added to the calendar), and metadata (`createdBy`, `createdAt`).
- Add a to-do via a simple text field; tick to complete; delete via swipe/long-press.
- **"Add to calendar"** on a to-do: pick a date → creates a `CalendarEvent` (all-day,
  owner `together` by default) and sets the to-do's `scheduledDate`. The to-do **stays
  in the list** and shows a **"Scheduled · <date>"** badge. It is not removed.
- Stored in Firestore collection `todos`; live-synced like events.

### Photo vault (gimmick-gated)
- A playful "secret vault" of photos, **separate** from the 12 month photos.
- **Entry gimmick (not real security):** the Vault tab shows a fake fingerprint pad;
  the user must **press and hold it for 3 seconds** (a circular progress ring fills) to
  unlock and reveal the gallery. Releasing early resets. This is purely a gimmick — no
  biometric/auth is involved.
- After unlocking: a **shared** photo grid. Either partner can **upload** (image_picker),
  **view** full-screen, and **delete** photos. Both see the same vault.
- Photos stored in **Cloud Storage** under `vault/{id}.jpg`; metadata in Firestore
  collection `vaultPhotos` (`storagePath`, `downloadUrl`, `uploadedBy`, `createdAt`).
- The unlock state is per-session/in-memory (re-locks when leaving the tab/app); the
  hold gesture is the only gate.

### Data model additions (Firestore)
```
todos/{id}:
  title: string
  done: bool
  scheduledDate: timestamp|null   // set when added to the calendar
  createdBy: string (uid)
  createdAt: timestamp

vaultPhotos/{id}:
  storagePath: string
  downloadUrl: string
  uploadedBy: string (uid)
  createdAt: timestamp
```

### Security rules additions
- `todos/{id}` and `vaultPhotos/{id}`: read/write restricted to the two couple UIDs
  (same `isCouple()` rule as events). Storage `vault/{file}`: same restriction as
  `monthPhotos`.

## Tech Stack Summary
- **Flutter** (Dart), iOS-first via TestFlight
- **Riverpod** for state management
- **Firebase**: Auth (Sign in with Apple), Firestore, Cloud Storage, Cloud
  Functions, Cloud Messaging — Blaze plan
- **flutter_local_notifications** for on-device reminders
