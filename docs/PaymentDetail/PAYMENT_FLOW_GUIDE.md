# CEDT Marketplace - Payment & Seller Onboarding Flow Documentation

This folder contains comprehensive PlantUML diagrams documenting the payment processing and seller onboarding flows for the CEDT Marketplace application.

## 📊 Diagram Files Overview

### 1. **marketplace-er-diagram.puml**

**Entity Relationship Diagram**

- Shows all database entities and their relationships
- Includes: User, SellerProfile, Listing, Payment, PayoutLedger, SellerBalance, Category, Review, Cart, CartItem, PickupLocation
- Helps understand data structure and dependencies
- **Use this when**: Designing database schema or understanding data relationships

### 2. **01-seller-onboarding-flow.puml**

**Seller Onboarding Flow**

- Sequential flow from seller registration to becoming active seller
- Shows Stripe Connect account creation process
- Includes identity and bank verification steps
- Error handling for failed verification
- **Key states**:
    - PENDING → ACTIVE → RESTRICTED (if issues)
- **Use this when**: Understanding how sellers enable payouts

### 3. **02-buyer-checkout-flow.puml**

**Buyer Checkout & Payment Flow**

- Sequence diagram showing buyer-to-seller-to-Stripe interaction
- Covers validation, PaymentIntent creation, payment confirmation
- Shows what happens on success and failure
- Includes webhook processing for payment status updates
- **Use this when**: Building checkout UI or debugging payment issues

### 4. **03-money-distribution-flow.puml**

**Money Distribution Flow**

- Detailed sequence of fund movement after payment
- Shows fee calculation and balance updates
- Includes payout ledger creation
- Bank transfer initiation through Stripe Connect
- **Use this when**: Understanding how seller earnings are calculated and transferred

### 5. **04-webhook-processing-flow.puml**

**Webhook Processing Flow**

- Handles all Stripe webhook events
- Covers:
    - `payment_intent.succeeded` → Update payment & balances
    - `payment_intent.payment_failed` → Release listing
    - `charge.refunded` → Reverse balances
    - `account.updated` → Refresh seller status
    - `payout.paid` → Mark funds as received
    - `payout.failed` → Flag for manual intervention
- **Critical for**: Webhook implementation and security verification
- **Use this when**: Implementing webhook handlers

### 6. **06-seller-status-state-diagram.puml**

**Seller Status State Machine**

- State transitions for seller onboarding and payment cycles
- Shows progression from USER_REGISTERED → ACTIVE → PAYMENT_PENDING → SELLER_PAID
- Includes error states and recovery paths
- Helps visualize complete seller lifecycle
- **Use this when**: Understanding seller account states

### 7. **07-architecture-overview.puml**

**System Architecture Overview**

- High-level view of all system components:
    - iOS Frontend
    - Backend Server (Node.js)
    - Stripe (Payment & Connect)
    - PostgreSQL Database
    - External Services
- Shows data flow between components
- Clarifies responsibilities of each part
- **Use this when**: Planning implementation or onboarding new developers

### 8. **08-complete-transaction-dataflow.puml**

**Complete Transaction Data Flow**

- End-to-end flow from checkout to payout completion
- 7 major steps with detailed data movement
- Shows all database operations and state changes
- Includes bank transfer and confirmation
- **Use this when**: Debugging a payment that's stuck or understanding complete flow

---

## 🔄 Flow Summary

### Quick Reference: A Payment Transaction

```
1. CHECKOUT
   Buyer clicks "Buy Now"
   → Backend validates listing & seller
   → Creates Stripe PaymentIntent
   → Returns clientSecret to frontend

2. PAYMENT ENTRY
   Frontend shows Stripe payment UI
   → User enters card info (on Stripe, not your server)
   → Stripe processes payment

3. PAYMENT CONFIRMED
   Stripe sends payment_intent.succeeded webhook
   → Backend verifies signature
   → Updates payment status to SUCCEEDED
   → Updates listing status to SOLD
   → Creates payout ledger entry
   → Increases seller pending balance

4. PAYOUT SCHEDULING
   Backend checks payout schedule
   → Creates Stripe payout to seller's connected account
   → Payout status set to PENDING

5. BANK TRANSFER
   Stripe processes payout batch (on its schedule)
   → Sends to seller's bank via ACH/Wire
   → Bank receives and deposits

6. PAYOUT CONFIRMED
   Stripe sends payout.paid webhook
   → Backend marks payout as PAID
   → Moves funds from pending to available balance
   → Seller sees deposit in app

7. CYCLE REPEATS
   Seller can now list more items or request new payout
```

---

## 💾 Database Schema Quick Reference

### Core Tables

**User**

- `id`, `email`, `password_hash`, `full_name`, `student_id`

**SellerProfile**

- `id`, `user_id`, `stripe_connect_account_id`
- `connect_status` (PENDING, ACTIVE, RESTRICTED)
- `charges_enabled`, `payouts_enabled`, `identity_verified`, `bank_verified`

**Listing**

- `id`, `seller_id`, `name`, `price`, `status` (AVAILABLE, SOLD, ARCHIVED)
- `category_id`, `description`, `condition`, `images`

**Payment**

- `id`, `buyer_id`, `listing_id`, `seller_id`
- `stripe_payment_intent_id`, `amount`, `platform_fee`, `seller_amount`
- `status` (PENDING, SUCCEEDED, FAILED, REFUNDED)

**PayoutLedger**

- `id`, `seller_id`, `stripe_payout_id`, `amount`
- `status` (PENDING, PAID, FAILED)
- Tracks all seller payouts

**SellerBalance**

- `id`, `seller_id`
- `pending_balance` (waiting for payout)
- `available_balance` (already paid to bank)
- `total_earned` (lifetime total)

---

## 🔐 Security Considerations

### What Your App Stores

✅ Stripe IDs (paymentIntentId, stripeConnectAccountId, payoutId)
✅ Status flags (PENDING, SUCCEEDED, PAID, etc.)
✅ Amounts and fee calculations
✅ User information (email, name, student ID)

### What Your App NEVER Stores

❌ Full credit card numbers
❌ CVV or card PINs
❌ Bank account numbers (Stripe handles this)
❌ Raw sensitive payout credentials

### Webhook Security

- Always verify Stripe webhook signature before processing
- Use `STRIPE_WEBHOOK_SECRET` from environment variables
- Reject unsigned webhooks with 400 error
- Log all webhook events for debugging

---

## 🚀 Implementation Checklist

### Seller Onboarding

- [ ] Create SellerProfile table with Stripe account tracking
- [ ] Implement `POST /seller/onboard` endpoint
- [ ] Generate Stripe onboarding link
- [ ] Handle onboarding redirect callback
- [ ] Listen for `account.updated` webhook

### Buyer Checkout

- [ ] Implement `POST /checkout` endpoint
- [ ] Validate listing availability
- [ ] Create PaymentIntent on Stripe
- [ ] Store pending payment in database
- [ ] Return clientSecret to frontend

### Webhook Processing

- [ ] Setup Stripe webhook endpoint at `/webhooks/stripe`
- [ ] Verify all webhook signatures
- [ ] Handle payment_intent events
- [ ] Handle payout events
- [ ] Handle account update events

### Payout Management

- [ ] Create PayoutLedger table
- [ ] Implement payout creation logic
- [ ] Track payout status
- [ ] Handle failed payouts
- [ ] Update seller balance on success

---

## 📝 Common Issues & Solutions

### Issue: "Webhook signature verification failed"

**Solution**:

- Ensure `STRIPE_WEBHOOK_SECRET` is correct (from Stripe dashboard)
- Check that you're using the raw request body (not parsed JSON)

### Issue: "Payment succeeded but seller wasn't credited"

**Solution**:

- Check webhook logs - was the event received?
- Verify seller's Stripe Connect account is ACTIVE
- Check database for Payment and PayoutLedger records
- Manually trigger webhook replay from Stripe dashboard

### Issue: "Seller can't complete onboarding"

**Solution**:

- Check if stripeConnectAccountId was created
- Verify Stripe onboarding link is valid
- Check Stripe dashboard for account restrictions
- Review identity verification requirements

### Issue: "Payout stuck in PENDING status"

**Solution**:

- Check payout schedule in Stripe settings
- Verify seller bank account is verified
- Check for payout failures in Stripe dashboard
- Review webhooks for payout.failed events

---

## 🔄 State Transitions Reference

### Seller States

```
USER_REGISTERED
  ↓
SELLER_ONBOARDING_REQUESTED
  ↓
STRIPE_ACCOUNT_CREATED
  ↓
ONBOARDING_IN_PROGRESS ← → RESTRICTED
  ↓
ACTIVE ← ← ← (ready for transactions)
```

### Payment States

```
PENDING (PaymentIntent created, awaiting confirmation)
  ├→ SUCCEEDED (payment confirmed, funds credited)
  ├→ FAILED (payment declined)
  └→ REFUNDED (refund issued)
```

### Payout States

```
PENDING (created, waiting for Stripe schedule)
  ├→ PAID (successfully deposited to bank)
  └→ FAILED (bank account issue, needs manual intervention)
```

---

## 📞 API Endpoints Reference

### Seller Onboarding

- `POST /seller/onboard` - Initiate seller onboarding
- `GET /seller/onboarding-status` - Check onboarding progress
- `POST /seller/onboarding-refresh` - Refresh status from Stripe

### Payments

- `POST /checkout` - Create PaymentIntent for purchase
- `GET /payments` - List user's payments
- `POST /payments/:id/refund` - Refund a payment

### Payouts

- `GET /seller/balance` - Get seller balance info
- `GET /seller/payouts` - List seller payouts
- `POST /seller/request-payout` - Manual payout request (if implemented)

### Webhooks

- `POST /webhooks/stripe` - Stripe webhook receiver

---

## 🎯 Next Steps

1. **Review the diagrams** in order (ER diagram first)
2. **Understand the state machine** (seller-status-state-diagram)
3. **Implement the backend endpoints** following the flow diagrams
4. **Setup webhook handling** with proper signature verification
5. **Test with Stripe's test mode** before going live
6. **Monitor webhook logs** in Stripe dashboard

---

## 📚 Additional Resources

- [Stripe Payment Intents API](https://stripe.com/docs/payments/payment-intents)
- [Stripe Connect Documentation](https://stripe.com/docs/connect)
- [Stripe Webhook Documentation](https://stripe.com/docs/webhooks)
- [Stripe Testing](https://stripe.com/docs/testing)

---

**Last Updated**: May 2026
**Project**: CEDT Marketplace
**Version**: 1.0
