# GoLazy — Product Requirements Document (v0.2)

**Status:** Draft
**Scope:** Global — not tied to any single city or country
**Purpose:** Functional and technical specification for building the GoLazy MVP: a two-sided vehicle
rental marketplace connecting vehicle owners with renters/drivers.

> Business-policy values below (commission split, cancellation/deposit/dispute rules, minimum viable
> supply/demand, currency, document types) are **market-configurable**, not hard-coded assumptions. Each
> market GoLazy launches in has its own currency, vehicle mix, KYC documents, and transport regulations.
> Defaults are marked 🟡 and are starting points to instantiate per launch market, not global constants.

---

## 1. Product Summary

GoLazy is a two-sided marketplace connecting **vehicle owners** (who list eligible vehicles) with
**renters/drivers** (who need a vehicle for commercial/work use), for daily or hourly rental. GoLazy does
not own inventory — it provides discovery, booking, payment, trust/verification, and settlement
infrastructure, and earns a commission on completed rentals (default split: 5% renter-side + 5%
owner-side = 10% of base rental value).

**North Star transaction (MVP definition of done):**
Owner registers → lists vehicle → sets pricing/availability → renter searches → books → pays → owner
accepts → handover recorded → rental active → return recorded → owner inspects/confirms → booking
completed → owner settled.

This transaction must work identically regardless of which country, currency, or vehicle category it
runs in — market-specific detail (currency, document types, vehicle mix, regulation) is configuration,
never logic baked into the core flow.

---

## 2. Market Configuration Model

GoLazy is designed to operate in many independent **markets** (a market = one currency + one regulatory
jurisdiction + one operational launch area, typically a metro area or country). A `Market` entity holds
everything that varies by geography so the core product never hard-codes a country, currency, or
document type:

```
Market
 ├─ id, name, country_code, currency_code (ISO 4217, e.g. USD/EUR/INR/NGN/BRL)
 ├─ commission_config: { renter_fee_pct, owner_fee_pct }         (default 5% / 5%)
 ├─ min_hourly_booking_hours                                       (default 6)
 ├─ supported_vehicle_categories: []                                (market decides which apply)
 ├─ required_owner_documents: []           (e.g. registration doc, insurance, commercial permit)
 ├─ required_renter_documents: []          (e.g. government ID, driving license)
 └─ regulatory_notes / compliance_status
```

Every `Vehicle`, `User`, and `Booking` belongs to exactly one `Market`. Search, pricing, documents, and
compliance rules are always evaluated **within** a market — GoLazy never assumes a single global currency,
document set, or vehicle taxonomy.

**Illustrative vehicle categories** (a market enables only the subset relevant to it):
e-rickshaws and auto-rickshaws (common in South Asia), motorcycles/scooters, cabs/taxis, cars, vans,
light commercial vehicles. New markets can add categories without a code change if the taxonomy is
data-driven.

### Proposed defaults for launch-strategy questions 🟡 (per-market, to be set by whoever runs a given launch)

| # | Question | Proposed default (per market) | Rationale |
|---|---|---|---|
| 1 | First customers | Owners with 1–4 vehicles already renting informally to drivers in one dense area | Smallest gap between current behavior and platform behavior, in any market |
| 2 | Launch vehicle category | The single category with the shortest owner→renter cycle and lowest compliance burden in that market | Fastest way to learn operations before adding complexity |
| 3 | Launch geography | One focused neighborhood/metro cluster per market, not a whole country | Liquidity is a density problem everywhere — start where supply and demand already meet physically |
| 4 | Minimum viable supply/demand | ~15–20 listed vehicles and ~40–60 verified renters before public marketing, per launch area | Enough for non-empty search and repeat bookings within days |
| 5 | Cancellation policy | See §11 | — |
| 6 | Security deposit | See §12 | — |
| 7 | Damage/dispute policy | See §14 | — |
| 8 | Payment/settlement timing | Renter pays in full at booking (held by GoLazy) → owner settled T+1 after `COMPLETED`, net of owner fee, minus approved deductions | Protects both sides without building real-time split-settlement for MVP |
| 9 | Compliance | Blocking gate before **public/commercial** launch in a market, not before an invite-only pilot | Lets engineering proceed while legal review runs per-market in parallel |
| 10 | KYC level | Renter: government ID + selfie match. Owner: government ID + vehicle registration document + any commercial permit/insurance required in that market | Matches the compliance-aware architecture principle — statuses, not hard assumptions |

---

## 3. Roles & Permissions

Every account has both `owner_mode_enabled` and `renter_mode_enabled` flags (default: renter enabled;
owner enabled after first vehicle add + KYC). A user is never locked to one role; the app's home screen
is a mode switcher, not a fixed identity.

| Role | Can do |
|---|---|
| **Renter** | Search, book, pay, extend, return, rate, raise disputes |
| **Owner** | List vehicles, manage documents/pricing/availability, accept/reject bookings, confirm handover/return, view earnings, raise disputes |
| **Admin** | Verify users/vehicles/documents, view/manage all bookings & payments, resolve disputes, suspend accounts/vehicles, view analytics — scoped per market |

---

## 4. Core Entities (Data Model Sketch)

```
Market
 ├─ id, name, country_code, currency_code
 ├─ commission_config: { renter_fee_pct, owner_fee_pct }
 ├─ min_hourly_booking_hours
 ├─ supported_vehicle_categories[]
 └─ required_owner_documents[], required_renter_documents[]

User
 ├─ id, market_id, name, phone, email, password_hash
 ├─ renter_verification_status: NOT_STARTED | SUBMITTED | UNDER_REVIEW | VERIFIED | REJECTED
 ├─ owner_verification_status: (same enum)
 └─ role_flags: { renter_enabled, owner_enabled }

Vehicle
 ├─ id, market_id, owner_id, category, manufacturer, model,
 │   year, registration_number, colour, seating_capacity
 ├─ documents[]: { type, number, issue_date, expiry_date, file_url, status }   (types come from Market.required_owner_documents)
 ├─ condition: { odometer, battery_or_fuel_pct, tyres, brakes, lights, body_notes, photos[] }
 ├─ pricing: { daily_rate, hourly_rate, currency_code, min_hourly_hours }    (currency_code = market's)
 ├─ vehicle_verification_status: NOT_STARTED | SUBMITTED | UNDER_REVIEW | VERIFIED | REJECTED | SUSPENDED
 ├─ booking_eligibility: derived boolean (see §17.2)
 └─ availability_calendar: [{ start, end, blocked_by }]

Booking
 ├─ id, market_id, vehicle_id, renter_id, owner_id
 ├─ rental_mode: DAILY | HOURLY
 ├─ start_time, end_time, duration
 ├─ currency_code, base_rental, renter_fee, owner_fee, renter_total, owner_settlement, platform_revenue
 ├─ deposit_amount, deposit_status
 ├─ state: (see §9 state machine)
 ├─ handover_record_id, return_record_id
 └─ cancellation: { by, reason, at, refund_amount }

ConditionRecord (used for both handover and return)
 ├─ id, booking_id, type: HANDOVER | RETURN
 ├─ odometer, battery_or_fuel_pct, photos[], damage_notes
 └─ confirmed_by: { owner_confirmed_at, renter_confirmed_at }

Payment
 ├─ id, booking_id, type: RENTAL | DEPOSIT | EXTENSION | REFUND | SETTLEMENT
 ├─ amount, currency_code, status: INITIATED | SUCCESS | FAILED | REFUNDED
 └─ gateway_reference

Dispute
 ├─ id, booking_id, raised_by, category: DAMAGE | DEPOSIT | NO_SHOW | OTHER
 ├─ evidence[], status: OPEN | UNDER_REVIEW | RESOLVED | REJECTED
 └─ resolution_notes, resolved_by (admin)
```

---

## 5. Pricing & Commission Engine

**Rules (agreed, non-negotiable for MVP; values are per-market config, logic is universal):**
- Daily rate = price per 24 hours, set independently by owner, in the market's currency.
- Hourly rate = price per hour, set independently by owner (not derived from daily rate).
- Minimum hourly booking = a market-configured value (default **6 hours**), platform-enforced, cannot be
  reduced by an individual owner.
- Commission = market-configured renter-side % (default 5%) of base rental charged to renter (added on
  top) + market-configured owner-side % (default 5%) deducted from owner.

**Worked example (hourly, 6 hrs at a rate of 55 units of the market's currency per hour):**

| Component | Formula | Amount |
|---|---|---|
| Base rental | 55 × 6 | 330 |
| Renter platform fee | base × renter_fee_pct (5%) | 16.50 |
| **Renter pays** | base + renter fee | **346.50** |
| Owner platform fee | base × owner_fee_pct (5%) | 16.50 |
| **Owner receives** | base − owner fee | **313.50** |
| **GoLazy revenue** | base × (renter_fee_pct + owner_fee_pct) | **33.00** |

This exact calculation is a single shared module (`calculateFare(baseRental, market.commission_config)`),
used by booking, extension, and settlement — never duplicated, and never assuming a specific currency or
percentage. Extensions run the same function against the additional-duration base rental and stack onto
the original booking's totals.

---

## 6. Renter Journey (screen-by-screen)

1. **Splash → "What do you want to do?"** → `Rent a Vehicle` / `List a Vehicle`
2. **Login/Signup** — phone OTP or email; creates `User` scoped to the `Market` inferred from device
   locale/location, with both role flags off except renter.
3. **Renter Profile** — name, phone, email, photo (optional at this step).
4. **Verification** — the document set required is whatever `Market.required_renter_documents` lists
   (e.g. government ID + selfie). Status starts `SUBMITTED`; user can continue browsing while
   `UNDER_REVIEW`, but **cannot complete a booking** (i.e., cannot reach `PAYMENT_CONFIRMED`) until
   `VERIFIED`.
5. **Location** — GPS or manual area entry; determines the active `Market`.
6. **Search** — filters: category, rental mode (daily/hourly), price range, distance, rating, availability
   window. Only categories enabled for the active market are shown.
7. **Vehicle Details** — photos, pricing (daily + hourly, shown in market currency), owner rating,
   vehicle condition summary, availability.
8. **Duration selection** — daily (whole days) or hourly (≥ market minimum, in whole-hour increments);
   live fare breakdown shown (base / your fee / total) before booking, using §5 formula.
9. **Booking** — creates `Booking` in `REQUESTED`.
10. **Payment** — renter pays full `renter_total` (+ deposit if applicable) via a locally supported
    payment method; on success → `PAYMENT_CONFIRMED`.
11. **Owner Approval wait** — renter sees "Waiting for owner" state; timeout policy in §8.
12. **Handover** — renter reviews owner's condition record + photos, taps "I received the vehicle in the
    recorded condition" → booking → `ACTIVE`.
13. **Active Rental** — shows vehicle, timer/end time, owner contact, `Extend` and `Return` actions.
14. **Return** — renter submits return photos/odometer/condition → `RETURN_REQUESTED`.
15. **Completion** — once owner confirms → `COMPLETED`; renter can rate the owner/vehicle.

---

## 7. Owner Journey (screen-by-screen)

1. **List a Vehicle** entry point → Login/Signup (same account system as renter).
2. **Owner Profile** + **KYC** (identity document(s) required by the active market + payout details for
   settlement).
3. **Add Vehicle** — category (from the market's enabled list), manufacturer, model, year, registration
   number, colour, seating capacity.
4. **Vehicle Documents** — whatever `Market.required_owner_documents` specifies (typically a registration
   document, and where the vehicle is commercially classified, insurance and/or a permit); each tracked
   with `{type, number, issue_date, expiry_date, file, status}`.
5. **Vehicle Photos** — front, rear, left, right, interior, dashboard, odometer (all required).
6. **Vehicle Condition** — baseline condition record at listing time (mirrors handover record schema).
7. **Pricing** — daily rate, hourly rate (independent fields, both required, entered in market currency).
8. **Availability** — calendar: mark available dates/hours, block dates; backend is the source of truth
   (frontend calendar is a view, never authoritative — see §17.2).
9. **Submit** → vehicle status `SUBMITTED` → admin review → `VERIFIED` → vehicle **LIVE** in search.
10. **Booking Requests** — new request shows renter name, verification status, dates, base rental,
    `[Accept] [Reject]`. Accept requires renter already `PAYMENT_CONFIRMED` (see §8 ordering).
11. **Handover** — owner records condition (photos, odometer, battery/fuel, existing damage, accessories,
    keys) before physically releasing the vehicle.
12. **Active Rental view** — current renter, period, expected return.
13. **Return** — owner inspects renter's return submission, confirms or disputes → `COMPLETED` or
    `DISPUTED`.
14. **Earnings** — this period's gross rental value, platform fees, net earnings (in market currency);
    available balance, pending settlement, withdrawal history.

---

## 8. Booking State Machine

```
REQUESTED
   → PENDING_PAYMENT          (renter proceeds to pay)
   → PAYMENT_CONFIRMED         (payment success; deposit held if applicable)
   → OWNER_ACCEPTED             or  OWNER_REJECTED → refund flow (§11)
   → HANDOVER_PENDING
   → ACTIVE
        → EXTENSION_REQUESTED → EXTENDED → (back to ACTIVE, new end_time)
        → RETURN_REQUESTED → RETURNED → COMPLETED
        → OVERDUE (end_time passed, no return/extension) → notify all parties → RETURNED/COMPLETED or DISPUTED
   → CANCELLED   (only from REQUESTED / PENDING_PAYMENT / PAYMENT_CONFIRMED / OWNER_ACCEPTED — see §11)
   → DISPUTED    (raised from ACTIVE, RETURNED, or COMPLETED within dispute window)
   → EXPIRED     (REQUESTED/PENDING_PAYMENT not actioned within timeout — see below)
```

**Payment-before-approval ordering:** Renter pays **before** owner approval (`PAYMENT_CONFIRMED`
precedes `OWNER_ACCEPTED`), with funds held by GoLazy (not released to owner) until `COMPLETED`. If the
owner rejects, the renter is refunded in full automatically. This protects the renter from being publicly
"picked" without commitment, and protects the owner from approving a booking that then never pays.

**Timeout defaults 🟡:** `PENDING_PAYMENT` expires after 15 minutes → `EXPIRED`. `PAYMENT_CONFIRMED`
awaiting owner action expires after 4 hours → auto `OWNER_REJECTED` + full refund (owner non-response
should not strand renter money).

The state machine is enforced **server-side only**; no client is trusted to set booking state.

---

## 9. Handover & Return (Evidence Trail)

Both handover and return use the same `ConditionRecord` structure:

- Photos (min. 4: front/rear/left/right; odometer close-up required)
- Odometer reading
- Battery %/fuel level
- Existing damage notes (free text + optional photo markers)
- Accessories/keys/items provided (handover only)

**Handover:** Owner submits record → renter reviews → renter taps confirm → `ACTIVE`. If renter disputes
the recorded condition before confirming, booking flags `DISPUTED` and admin mediates before the rental
can start — the vehicle is not released.

**Return:** Renter submits record → owner reviews → owner confirms → `COMPLETED`. If owner disputes
(claims new damage), booking → `DISPUTED`, deposit is held (not auto-released), and the case enters the
dispute queue (§14). Owner cannot unilaterally deduct from deposit.

---

## 10. Extension Flow

1. Renter taps **Extend Rental**, selects additional duration.
2. Server checks the vehicle's availability calendar for the extended window (must not overlap another
   confirmed booking).
3. If available: run §5 fare calc on the additional duration → charge renter fee + owner fee → process
   payment → update `end_time` → state stays `ACTIVE` (transient `EXTENSION_REQUESTED` → `EXTENDED`).
4. If unavailable: reject with "This vehicle is booked after your current end time" — no partial/implicit
   extension is ever granted.

---

## 11. Cancellation Policy 🟡 (proposed default, ratify per market before pilot)

| Trigger | Refund to renter | Owner impact | Platform fee |
|---|---|---|---|
| Renter cancels, booking still `REQUESTED`/`PENDING_PAYMENT` | N/A (not yet paid) | None | N/A |
| Renter cancels after `PAYMENT_CONFIRMED`, **before** `OWNER_ACCEPTED` | 100% | None | Not charged |
| Renter cancels **after** `OWNER_ACCEPTED`, more than 2 hrs before start | 90% (10% cancellation charge to cover owner's blocked slot) | Vehicle re-listed for that slot | Platform keeps nothing extra |
| Renter cancels within 2 hrs of start, or no-show at handover | 50% | Owner may claim the other 50% as compensation | Platform fee non-refundable |
| Owner rejects or fails to act (timeout) | 100% | Owner reliability score impacted | Platform fee never charged |
| Owner cancels **after** `OWNER_ACCEPTED` (before handover) | 100% + goodwill credit (TBD) | Reliability score impacted; repeated offenses → suspension review | Platform fee not charged |
| Either party cancels during `ACTIVE` rental | Pro-rated for unused time, admin-reviewed | Case-by-case | Pro-rated |

Cancellation logic lives in one server function keyed off `(current_state, actor, time_to_start)` — never
scattered across screens, and reads its percentages from `Market` config so a market can tune them without
a code change.

---

## 12. Security Deposit 🟡 (proposed default)

- Deposit amount is owner-configurable per vehicle (flat amount in market currency), shown to renter at
  booking alongside rental cost, charged **together with** the rental payment (single payment, itemized).
- Held by GoLazy as a separate `Payment` record (`type: DEPOSIT`, `status: HELD`) — never mixed into
  owner settlement.
- On clean `COMPLETED` (owner confirms return without damage claim): deposit auto-refunds within 24h.
- On damage claim: deposit moves to `HELD_DISPUTE`, case enters §14 dispute flow; owner cannot self-serve
  a deduction — only admin resolution moves funds.

---

## 13. Overdue Handling

If `end_time` passes with no `RETURN_REQUESTED` or valid `EXTENDED`:
- Booking auto-transitions to `OVERDUE`.
- Notifications fire to renter, owner, and admin (renter: "please return or extend now"; owner: "your
  vehicle is overdue"; admin: queued for monitoring after N hours 🟡 e.g. 2 hrs).
- Overdue penalty policy (per-hour late fee, cap, etc.) is explicitly deferred — **not** in MVP scope.
  MVP ships with notifications only, no automated penalty charge.

---

## 14. Dispute Resolution

- Either party can raise a dispute on a booking (damage, deposit, no-show, other) with photo/text
  evidence, within a fixed window (🟡 48 hours post-`COMPLETED`/`RETURNED`).
- Dispute status: `OPEN → UNDER_REVIEW → RESOLVED | REJECTED`, always admin-arbitrated in MVP — no
  automated adjudication.
- While `OPEN`/`UNDER_REVIEW`, any held deposit stays frozen; admin resolution is the only path that moves
  deposit funds (full refund to renter / full or partial payout to owner / split).
- Every dispute resolution is logged with the evidence and admin's written reasoning (audit trail —
  trust is a core product feature, not an afterthought).

---

## 15. Settlement (Owner Payout)

- Owner earnings = Σ(`owner_settlement`) across bookings reaching `COMPLETED`, minus any admin-approved
  dispute deductions, in the market's currency.
- Settlement timing 🟡: T+1 calendar day after `COMPLETED`, batched daily, paid to the owner's registered
  payout method (bank transfer, mobile money, or other rails available in that market).
- Owner dashboard always shows: available balance, pending settlement (bookings completed but not yet
  paid out), lifetime earnings, transaction history — computed from the `Payment`/`Booking` tables, not a
  separately-maintained balance field, to avoid drift.

---

## 16. Admin Platform (MVP scope)

| Area | MVP capability |
|---|---|
| Users | List/search owners & renters (filterable by market); view verification status; approve/reject KYC; suspend account |
| Vehicles | List/search; approve/reject documents & listing; suspend vehicle |
| Bookings | View all bookings by state; manually intervene on `OVERDUE`/`DISPUTED` |
| Payments | View transactions, platform revenue, refunds, deposit holds — per market currency |
| Disputes | Queue, evidence viewer, resolution action (refund/payout/split) with mandatory notes |
| Analytics | Users, vehicles, bookings, GMV, platform revenue, cancellation rate — sliceable per market |
| Markets | Create/configure a `Market` (currency, commission %, document requirements, vehicle categories) |

No self-service admin roles/permissions system in MVP — a single admin role is sufficient, but every
admin action is market-scoped and logged.

---

## 17. Non-Functional Requirements

### 17.1 Compliance-Aware Architecture (mandatory design constraint)
The system must never hard-code `vehicle = always legal` or `driver = always verified`, and must never
hard-code a single country's document types or currency. Every entity that gates a transaction carries an
explicit status field, and eligibility is **derived**, not assumed:

```
booking_eligibility(vehicle) =
    vehicle.vehicle_verification_status == VERIFIED
    AND all vehicle.documents[required by market].status == VERIFIED
    AND no vehicle.documents[required] is expired
    AND vehicle.availability_calendar has no conflict for requested window

booking_eligibility(renter) =
    renter.renter_verification_status == VERIFIED
```
Both must be true server-side at the moment of `PAYMENT_CONFIRMED` and again at `OWNER_ACCEPTED` — not
just checked once at search time. An expired document between search and booking must block checkout.

### 17.2 Backend-authoritative availability
Availability/booking-conflict checks happen only in the backend, inside a transaction that also creates
the booking, to prevent double-booking race conditions. The frontend calendar is a read view.

### 17.3 Localization & currency
- Every amount is stored with an explicit `currency_code` (ISO 4217) alongside the numeric value — never
  a bare number with an assumed currency.
- Display formatting (symbol, decimal places, thousands separators) is derived from `currency_code` and
  device locale, not hard-coded.
- Dates/times are stored in UTC with the market's timezone used only for display and business-rule
  evaluation (e.g. "24 hours" for a daily rental is wall-clock in the market's timezone).

### 17.4 Security & audit
- All condition records, handovers, returns, cancellations, and dispute resolutions are immutable,
  timestamped, and attributed to an actor (audit log).
- Payment data never stored raw; handled via a PCI-compliant gateway appropriate to each market, GoLazy
  stores only references/status.
- Documents (ID, registration, insurance) stored in access-controlled storage, not publicly reachable by
  URL guessing.

### 17.5 Notifications
Booking state transitions (`OWNER_ACCEPTED`, `OWNER_REJECTED`, `HANDOVER_PENDING`, `OVERDUE`,
`DISPUTED`, `COMPLETED`, settlement paid) trigger notifications to the relevant party/parties. Channel
(SMS/push/email) may vary by market based on local reachability; the trigger table itself is a
requirement everywhere.

---

## 18. MVP Scope (in) vs. Explicitly Excluded (out)

**In:** registration/login/KYC for both roles, vehicle listing with docs/photos, daily + hourly pricing
with market-configured minimum hourly duration, availability calendar, search + filters, booking +
payment, accept/reject, handover/return with condition records, extensions, basic notifications, owner
earnings view, admin user/vehicle/booking/payment/dispute/market management, basic analytics.

**Out of v1 (do not build until the core marketplace is validated in at least one market):** GPS
tracking, AI damage detection, automated inspection, insurance integration, financing/rent-to-own,
maintenance/charging marketplaces, dynamic pricing, owner subscriptions, fleet management, corporate
accounts, advanced analytics, loyalty/referral programs, AI support, simultaneous multi-market expansion.

---

## 19. Success Metrics (MVP / Pilot)

| Category | Metric |
|---|---|
| Supply | Verified owners, live vehicles, vehicle utilization % |
| Demand | Verified renters, search volume, booking conversion rate |
| Transactions | Completed rentals, repeat rental rate, cancellation rate, extension rate |
| Financial | GMV, platform revenue, contribution margin after payment/support/verification costs |
| Trust | Dispute rate, damage claim rate, successful-return rate, avg rating, support tickets/booking |

**Definition of pilot success (per launch market):** the same owner and renter complete **more than one**
rental each through GoLazy without operational intervention — i.e., the supply/demand flywheel starts
turning on its own within the pilot area.

---

## 20. Open Items Before Public Launch in Any Market

1. Legal structure + transport-regulation review for the specific launch category and jurisdiction.
2. Insurance implications of platform-facilitated rentals in that jurisdiction.
3. Local tax/VAT/GST treatment of commission revenue and owner payouts.
4. Ratified cancellation, deposit, and dispute policies (currently 🟡 proposed in §11/§12/§14).
5. Payment gateway + payout provider selection for that market's currency and rails (compliance/KYC
   requirements they impose).

---

## 21. Next Steps

1. Ratify or override every 🟡 default in §2, §11, §12, §14 for the first launch market.
2. Finalize architecture: frontend, backend, database, auth, payments, storage, notifications, admin,
   security — all designed to be market-agnostic per §17.
3. Build the North Star transaction (§1) end-to-end, instantiated for one market, before any secondary
   feature.
4. Pilot in a single focused launch area with the minimum viable supply/demand from §2.
5. Only after validation: replicate the same `Market` configuration pattern to expand into additional
   cities, countries, and currencies without re-architecting the core product.
