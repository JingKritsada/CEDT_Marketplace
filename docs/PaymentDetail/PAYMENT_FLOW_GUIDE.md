# CEDT Marketplace — Payment & Seller Onboarding Guide

This folder documents how the CEDT Marketplace integrates with **Stripe Connect (Express, country=TH)** to handle buyer payments and seller payouts.

The marketplace is an **in-person pickup** marketplace for used electronics on campus. The payment design reflects that: funds are **authorized at checkout, then captured only after the buyer confirms physical receipt** at pickup. This protects buyers against no-show sellers without the platform holding customer funds itself.

> ⚠️ Read this guide alongside the PUML files. The guide is the prose explanation; the PUMLs are the canonical flow.

---

## 1. Architecture in one paragraph

iOS app talks HTTPS REST + JWT to a Node.js / Express / Prisma backend. The backend talks to **Stripe** for everything money-related: connected-account onboarding (`stripe.accounts`, `stripe.accountLinks`), payments (`stripe.paymentIntents` with `capture_method: 'manual'`, `application_fee_amount`, `transfer_data.destination`), and reads live seller balances/payouts on demand (`stripe.balance.retrieve`, `stripe.payouts.list`). Stripe pushes async state changes back to `POST /webhooks/stripe`, which is idempotent via a `StripeWebhookEvent` table keyed on `event.id`. Card details **never** touch our backend — the iOS app uses Stripe's PaymentSheet, which collects card data directly into Stripe.

---

## 2. Diagram index

| File | What it covers |
|---|---|
| `marketplace-er-diagram.puml` | Database entities & relationships (final shape) |
| `01-seller-onboarding-flow.puml` | Express onboarding via AccountLink → `account.updated` webhook |
| `02-buyer-checkout-flow.puml` | `POST /checkout` → PaymentIntent → PaymentSheet → auth captured-pending |
| `03-money-distribution-flow.puml` | Buyer confirms receipt → capture → Stripe auto-payout |
| `04-webhook-processing-flow.puml` | Every Stripe event we handle, with idempotency |
| `05-seller-receiving-money-flow.puml` | Seller's-eye view of when/where money lands |
| `06-seller-status-state-diagram.puml` | `SellerProfile.connectStatus` lifecycle |
| `07-architecture-overview.puml` | All components in one picture |
| `08-complete-transaction-dataflow.puml` | End-to-end checkout → bank deposit |

---

## 3. Why this design (key decisions)

### 3.1 Destination charges, not Separate Charges & Transfers
We create **one** PaymentIntent that does everything atomically:
```ts
stripe.paymentIntents.create({
  amount: amountSatang, currency: 'thb',
  capture_method: 'manual',
  payment_method_types: ['card', 'promptpay'],
  application_fee_amount: platformFeeSatang,
  transfer_data: { destination: sellerStripeAcctId },
  on_behalf_of: sellerStripeAcctId,
  metadata: { listingId, buyerId },
});
```
Stripe routes `amount - applicationFee` to the seller's connected-account balance and retains `applicationFee` on the platform side. **We never call `stripe.transfers.create` or `stripe.payouts.create`.** Stripe automatically pays out the seller's connected-account balance to their Thai bank on its T+7 schedule.

### 3.2 Manual capture (escrow-shaped)
`capture_method: 'manual'` means the buyer's card is **authorized** but not charged at checkout. The actual money movement happens when **the buyer taps "Confirm Receipt"** in the app after pickup, which calls `stripe.paymentIntents.capture(...)`. If the seller never shows up:
- Within ~6 days: buyer (or admin, or a background job) cancels the PI → listing returns to `AVAILABLE` → buyer's card is never charged.
- After ~7 days: the card auth expires automatically; we cancel the PI in the same hourly job.

This means the platform **never holds customer funds** and disputes are rare.

### 3.3 Live balances, not local mirrors
Earlier drafts had a `SellerBalance` table with `pending_balance` / `available_balance` updated on every webhook. We **dropped that**. A missed or out-of-order webhook would permanently desync those numbers. Instead:
- For the seller wallet UI: backend calls `stripe.balance.retrieve({ stripeAccount })` live.
- For payout history: backend calls `stripe.payouts.list({ stripeAccount })` live.
- We only store **lifetime totals** (`totalEarnedSatang`, `totalPaidOutSatang`) on `SellerProfile` for analytics.

### 3.4 Idempotent webhooks
Stripe retries webhooks aggressively. Every handler:
1. Verifies `stripe-signature` against `STRIPE_WEBHOOK_SECRET` using the **raw** request body.
2. `INSERT INTO StripeWebhookEvent (id, type, payload)` where `id = event.id`. A unique-violation = "we already processed this" → return 200 immediately.
3. Mutates state in the **same DB transaction** as the insert.

### 3.5 Currency: THB satang, end-to-end
Stripe represents THB in **satang** (1 THB = 100 satang). Every money column in our DB is `Int` (or `BigInt` for lifetime totals) and named with the `Satang` suffix. **Never use floats.**

### 3.6 Listing race protection
`POST /checkout` runs in a Prisma transaction with `SELECT … FOR UPDATE`:
1. Lock the listing row.
2. Assert `status == AVAILABLE`, `buyer != seller`, seller `payoutsEnabled`.
3. Create the PaymentIntent.
4. Set listing `status = WAITING_FOR_PAYMENT`, `currentPaymentIntentId = pi.id`.
5. Insert `Payment`.
6. COMMIT.

Two concurrent buyers can't both reach step 3 because step 1 blocks.

---

## 4. The full state machine

### 4.1 `SellerProfile.connectStatus`

```
NONE  ──onboarding→  PENDING  ──account.updated(ok)──→  ACTIVE
                       │  ↑                                │
                       ↓  │                                ↓
                    RESTRICTED  ←──────────────────────────┘
                       │
                       ↓
                    REJECTED  (terminal)
```

| State | charges | payouts | Can sell? |
|---|---|---|---|
| `NONE` | – | – | No (no Stripe account yet) |
| `PENDING` | false | false | No |
| `ACTIVE` | true | true | **Yes** |
| `RESTRICTED` | varies | false | No (show requirements) |
| `REJECTED` | false | false | No (terminal) |

### 4.2 `Listing.status` during a sale

```
AVAILABLE
   ↓ POST /checkout
WAITING_FOR_PAYMENT
   ↓ payment_intent.amount_capturable_updated
PAID                  ← authorized & locked, NO money has moved yet
   ↓ (seller marks shipped / hands over)
WAITING_FOR_PICKUP   (optional step depending on flow)
   ↓ POST /listings/:id/confirm-receipt → stripe.paymentIntents.capture
RECEIVED              ← funds captured: platform fee + seller net split atomically
   ↓ buyer leaves review
RATED → SOLD (terminal)
```

Failure / cancel paths return the listing to `AVAILABLE` and clear `currentPaymentIntentId`.

### 4.3 `Payment.status` (mirrors Stripe's PaymentIntent.status, plus our terminal refund states)

```
REQUIRES_PAYMENT_METHOD
   ├→ REQUIRES_ACTION          (3DS / SCA needed)
   ├→ PROCESSING               (PromptPay async)
   ├→ REQUIRES_CAPTURE         (card auth held — waiting for pickup)
   │    ├→ SUCCEEDED           (captured)
   │    └→ CANCELED            (no-show / expired auth)
   ├→ FAILED                   (card declined)
   └→ CANCELED                 (buyer canceled before auth)

SUCCEEDED
   ├→ PARTIALLY_REFUNDED
   └→ REFUNDED
```

---

## 5. Database schema additions

Brief sketch — see `marketplace-er-diagram.puml` for the full shape and `schema.prisma` for the real source of truth once implemented.

### New tables
- **`SellerProfile`** — 1:1 with User. Holds `stripeConnectAccountId`, `connectStatus`, capability flags, requirement strings, and lifetime totals.
- **`Payment`** — one row per checkout attempt. Holds Stripe IDs (`paymentIntent`, `charge`, `applicationFee`, `transfer`), the satang-denominated amounts, status, capture mode, and timestamps.
- **`Refund`** — child of Payment, mirrors Stripe refund objects.
- **`StripeWebhookEvent`** — idempotency table, PK = Stripe `event.id`.

### Modified tables
- **`Listing`** — adds `currentPaymentIntentId String?`. Reuses existing `ListingStatus` enum (no new values needed).

### Not added
- ❌ `SellerBalance` — Stripe is the source of truth.
- ❌ `PayoutLedger` — fetched live from `stripe.payouts.list` when needed.

---

## 6. API surface

All endpoints below are mounted under the standard `/api` prefix and require JWT auth **except** `/webhooks/stripe`.

### Seller onboarding (`/sellers`)
| Method | Path | Description |
|---|---|---|
| POST | `/sellers/onboarding` | Create connected account (if absent) + AccountLink, return onboarding URL |
| POST | `/sellers/onboarding/refresh` | Force re-pull from Stripe (in case a webhook was lost) |
| GET  | `/sellers/me` | Current `SellerProfile` + `requirementsCurrentlyDue` |
| GET  | `/sellers/me/balance` | Live `stripe.balance.retrieve` (proxied) |
| GET  | `/sellers/me/payouts` | Live `stripe.payouts.list` (proxied) |

### Payments (`/payments`)
| Method | Path | Description |
|---|---|---|
| POST | `/checkout` | Body: `{ listingId }`. Returns `{ paymentIntentId, clientSecret, publishableKey }` |
| GET  | `/payments` | List current user's payments (as buyer or seller) |
| GET  | `/payments/:id` | Single payment detail |
| POST | `/payments/:id/cancel` | Buyer cancels before capture |
| POST | `/payments/:id/refund` | Seller or admin refunds after capture |
| POST | `/listings/:id/confirm-receipt` | Buyer confirms receipt → triggers `paymentIntents.capture` |

### Webhook
| Method | Path | Description |
|---|---|---|
| POST | `/webhooks/stripe` | Stripe webhook receiver. **Mounted with `express.raw()` before `express.json()`.** |

---

## 7. Webhook events we handle

| Stripe event | What it means | What we do |
|---|---|---|
| `payment_intent.requires_action` | 3DS needed | `Payment.status = REQUIRES_ACTION` |
| `payment_intent.processing` | PromptPay async pending | `Payment.status = PROCESSING` |
| `payment_intent.amount_capturable_updated` | Card auth succeeded | `Payment.status = REQUIRES_CAPTURE`, `Listing.status = PAID` |
| `payment_intent.succeeded` | Captured | `Payment.status = SUCCEEDED`, set `succeededAt` |
| `payment_intent.payment_failed` | Declined | `Payment.status = FAILED`, free listing |
| `payment_intent.canceled` | Canceled / expired | `Payment.status = CANCELED`, free listing |
| `charge.succeeded` | Charge object materialized | Store `stripeChargeId` |
| `charge.refunded` | Refund settled | Mark Payment refunded, upsert Refund rows |
| `application_fee.refunded` | Platform fee returned | Mark `Refund.refundApplicationFee = true` |
| `transfer.reversed` | Seller's portion clawed back | Decrement `totalEarnedSatang`, mark `Refund.reverseTransfer` |
| `charge.dispute.created` | Chargeback | Freeze listing, admin alert |
| `account.updated` | Connect account changed | Refresh `SellerProfile` flags + `requirementsCurrentlyDue` |
| `payout.paid` (Connect) | Payout landed in bank | `totalPaidOutSatang += amount`, push notification |
| `payout.failed` (Connect) | Payout failed | Admin alert + seller notification |

---

## 8. Security

### What we store
✅ Stripe IDs (`pi_*`, `acct_*`, `ch_*`, `po_*`, `fee_*`, `tr_*`, `re_*`)
✅ Status enums and amounts in satang
✅ Lifetime aggregates (`totalEarnedSatang`, `totalPaidOutSatang`)

### What we **never** store
❌ Card PAN, CVV, expiry — PaymentSheet sends these straight to Stripe
❌ Thai bank account numbers — Stripe Connect holds these
❌ National ID / passport numbers — Stripe Identity holds these
❌ Live balances — fetched live from Stripe each time

### Webhook security
- Raw body verification with `stripe.webhooks.constructEvent`.
- `STRIPE_WEBHOOK_SECRET` env-only, never in code or logs.
- Idempotency table prevents replay double-credit.
- Non-2xx response on signature failure triggers Stripe's retry, which is the intended behavior — failed sig usually means a misconfigured environment, and the operator will see retries piling up.

### Rate limiting
- `/checkout` and `/sellers/onboarding`: tight limits (e.g. 10/min/user).
- `/webhooks/stripe`: no app-level rate limit (Stripe controls this; we trust signed payloads).

---

## 9. Environment variables

```bash
STRIPE_SECRET_KEY=sk_test_…
STRIPE_PUBLISHABLE_KEY=pk_test_…        # exposed to iOS app via bootstrap endpoint
STRIPE_WEBHOOK_SECRET=whsec_…
STRIPE_API_VERSION=2025-…               # pin explicitly in code, don't drift
PLATFORM_FEE_BPS=500                    # 5% (basis points)
STRIPE_CONNECT_RETURN_URL=cedtmkt://stripe/return
STRIPE_CONNECT_REFRESH_URL=cedtmkt://stripe/refresh
PAYMENT_AUTH_EXPIRE_HOURS=144           # ~6 days before stale-auth job cancels
```

---

## 10. Thailand-specific constraints

- **Currency**: Connected Thai accounts can be paid out **only in THB**. Cross-border payouts are not supported.
- **Payout schedule**: T+7 business days (rolling). This is set by Stripe Thailand and not configurable to "instant".
- **Payment methods worth enabling**: `card` (Visa / Mastercard / JCB) and `promptpay`. PromptPay is huge for Thai students and is fully async — handle the `processing` state in both the webhook and the iOS UI.
- **3DS**: Most Thai-issued cards now require 3DS. PaymentSheet handles the challenge in-flow; backend just needs to handle the `requires_action` and `succeeded` events arriving in either order.

---

## 11. Implementation order

1. ✅ Diagrams (`docs/PaymentDetail/*.puml`) — done.
2. ✅ This guide — done.
3. Prisma migration: `SellerProfile`, `Payment`, `Refund`, `StripeWebhookEvent`, `Listing.currentPaymentIntentId`.
4. `stripe-service.ts` (SDK wrapper) + seller onboarding endpoints.
5. Checkout + manual-capture endpoints.
6. Webhook handler with idempotency.
7. Refund / dispute / cron paths.
8. **Hand off to frontend** — PaymentSheet on iOS, seller onboarding via `SFSafariViewController`.

---

## 12. Common issues & solutions

### "Webhook signature verification failed"
- Verify `STRIPE_WEBHOOK_SECRET` matches the endpoint in Stripe Dashboard.
- Ensure `/webhooks/stripe` is registered with `express.raw({ type: 'application/json' })` **before** `express.json()`. JSON-parsed bodies fail verification.

### "Payment succeeded but seller wasn't credited"
- Verify `transfer_data.destination` was set correctly on the PaymentIntent (you can `stripe.paymentIntents.retrieve(id)` to confirm).
- Verify seller's `connectStatus = ACTIVE`.
- Check `transfer.created` was received and `Payment.stripeTransferId` is populated.

### "Seller can't finish onboarding"
- Check `requirementsCurrentlyDue` on `SellerProfile` — that's exactly what Stripe is waiting for.
- Re-run `POST /sellers/onboarding` to get a fresh AccountLink (AccountLinks expire).

### "Payout stuck"
- Stripe TH payouts are T+7 business days. Check the connected account's payout schedule in Stripe Dashboard.
- Check `payout.failed` webhook log; usually the seller's bank account needs re-verification.

### "I want to test without real cards"
- Use Stripe test mode (`sk_test_…`).
- Cards: `4242 4242 4242 4242` (no 3DS), `4000 0027 6000 3184` (3DS required), see Stripe docs.
- PromptPay test mode: a fake QR with a "pay" button in Stripe Dashboard.

---

## 13. References

- [Stripe Connect — Build a marketplace](https://docs.stripe.com/connect/end-to-end-marketplace)
- [Destination charges](https://docs.stripe.com/connect/destination-charges)
- [Application fees](https://docs.stripe.com/connect/marketplace/tasks/app-fees)
- [PaymentIntents API](https://docs.stripe.com/payments/payment-intents)
- [Stripe Thailand: marketplace support](https://support.stripe.com/questions/stripe-thailand-support-for-marketplaces)
- [Stripe Thailand: payout schedule & currency](https://support.stripe.com/questions/payout-schedule-and-currency-for-stripe-accounts-in-thailand)
- [Stripe Thailand: supported methods](https://support.stripe.com/questions/supported-payment-methods-currencies-and-businesses-for-stripe-accounts-in-thailand)

---

**Last updated**: 2026-05-14
**Project**: CEDT Marketplace
**Doc version**: 2.0 (post-redesign)
