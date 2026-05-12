# CEDT Community Marketplace — iOS Frontend

## Project Instruction Document

**Frontend:** SwiftUI (iOS) | **Backend:** Node.js REST API

---

## 1. Project Overview

CEDT Community Marketplace is a native iOS application designed for engineering students to buy, sell, and give away hardware and robotics equipment. The app replaces the fragmented LINE group system with a structured, searchable, and trustworthy marketplace experience — built entirely in SwiftUI with a clean MVVM architecture.

| Field           | Detail                                          |
| --------------- | ----------------------------------------------- |
| Project Name    | CEDT Community Marketplace                      |
| Platform        | iOS (16+)                                       |
| Language        | Swift 5.9+                                      |
| UI Framework    | SwiftUI                                         |
| Architecture    | MVVM (Model–View–ViewModel)                     |
| Backend         | Node.js REST API (see `backend.md`)             |
| Target Users    | CEDT Engineering Students (Buyers & Sellers)    |
| UI/UX Designs   | Figma — see `/docs/UXUI-Figma`                  |
| Version Control | Git (regular commits for coursework milestones) |

---

## 2. Problem Statement

Engineering students accumulate hardware and robotics equipment from coursework but have no efficient platform to resell or give away these items. The current LINE group workaround is fragmented, unverified, and hard to search.

This iOS app solves that by providing:

- Structured listings with status tracking
- Verified student-only accounts
- On-campus pickup coordination
- Cart and checkout flow

---

## 3. Tech Stack

| Layer                | Technology / Library                                      |
| -------------------- | --------------------------------------------------------- |
| Language             | Swift 5.9+                                                |
| UI Framework         | SwiftUI                                                   |
| Architecture         | MVVM                                                      |
| Networking           | `URLSession` + `async/await` (Swift Concurrency)          |
| Auth Token Storage   | `Keychain` (via `Security` framework or wrapper library)  |
| Image Loading        | `AsyncImage` / `SDWebImageSwiftUI`                        |
| State Management     | `@StateObject`, `@ObservableObject`, `@EnvironmentObject` |
| Navigation           | `NavigationStack` + `NavigationPath`                      |
| Dependency Injection | Environment-based service injection                       |
| Linting/Formatting   | SwiftLint                                                 |

> If any patterns, libraries, or architecture decisions are missing or you see a loophole in the above stack, please add or implement them in the best practice way.

---

## 4. Project Structure

Follow MVVM with clear separation of concerns. If additional folders are needed for a scalable, maintainable structure, please add them.

```text
/CEDTMarketplace
├── CEDTMarketplaceApp.swift          # App entry point
├── ContentView.swift                 # Root navigation/tab view
│
├── Config/
│   └── AppConfig.swift               # Base URL, environment flags
│
├── Network/
│   ├── APIClient.swift               # URLSession wrapper, request builder
│   ├── Endpoint.swift                # Enum of all API endpoints
│   ├── HTTPMethod.swift
│   ├── NetworkError.swift
│   └── TokenInterceptor.swift        # Attach Bearer token, handle 401 refresh
│
├── Keychain/
│   └── KeychainManager.swift         # Store/retrieve/delete access & refresh tokens
│
├── Models/                           # Codable structs matching API responses
│   ├── User.swift
│   ├── Listing.swift
│   ├── Category.swift
│   ├── PickupLocation.swift
│   ├── CartItem.swift
│   ├── Review.swift
│   └── Notification.swift
│
├── Services/                         # Business logic — calls APIClient, returns models
│   ├── AuthService.swift
│   ├── ListingService.swift
│   ├── UserService.swift
│   ├── CartService.swift
│   ├── ReviewService.swift
│   ├── CategoryService.swift
│   ├── PickupLocationService.swift
│   └── NotificationService.swift
│
├── ViewModels/
│   ├── Auth/
│   │   ├── LoginViewModel.swift
│   │   └── RegisterViewModel.swift
│   ├── Listing/
│   │   ├── HomeViewModel.swift
│   │   ├── ListingDetailViewModel.swift
│   │   ├── PostItemViewModel.swift
│   │   └── FilterViewModel.swift
│   ├── Profile/
│   │   ├── ProfileViewModel.swift
│   │   ├── PostedItemsViewModel.swift
│   │   ├── PurchasedItemsViewModel.swift
│   │   ├── SoldItemsViewModel.swift
│   │   └── ConfirmedItemsViewModel.swift
│   ├── Cart/
│   │   ├── CartViewModel.swift
│   │   └── CheckoutViewModel.swift
│   └── Notification/
│       └── NotificationViewModel.swift
│
├── Views/
│   ├── Onboarding/
│   │   └── OnboardingView.swift
│   ├── Auth/
│   │   ├── LoginView.swift
│   │   └── RegisterView.swift
│   ├── Home/
│   │   ├── HomeView.swift
│   │   ├── ListingCardView.swift
│   │   └── FilterModalView.swift
│   ├── Listing/
│   │   ├── ListingDetailView.swift
│   │   └── PostItemView.swift
│   ├── Profile/
│   │   ├── ProfileView.swift
│   │   ├── PostedItemsView.swift
│   │   ├── PurchasedItemsView.swift
│   │   ├── SoldItemsView.swift
│   │   └── ConfirmedItemsView.swift
│   ├── Cart/
│   │   ├── CartView.swift
│   │   └── CheckoutView.swift
│   ├── Notification/
│   │   └── NotificationView.swift
│   └── Components/                   # Reusable UI components
│       ├── PrimaryButton.swift
│       ├── StatusBadge.swift
│       ├── ImageCarousel.swift
│       ├── RatingStarsView.swift
│       ├── ListingRowView.swift
│       └── EmptyStateView.swift
│
├── Extensions/
│   ├── View+Extensions.swift
│   ├── Color+Extensions.swift
│   └── Date+Extensions.swift
│
└── Resources/
    ├── Assets.xcassets
    └── Info.plist
```

> If you find any missing folders, files, or patterns required for a well-structured SwiftUI project, please add or implement them in the best practice way.

---

## 5. UI/UX & Screens

All screen designs are defined in Figma. Reference the file at `/docs/UXUI-Figma` before implementing any screen. The app uses a pink/red primary accent colour with a white background and native iOS HIG-compliant components throughout.

### 5.1 Screen Inventory

| Screen               | Figma Layer Name                    | Description                                                |
| -------------------- | ----------------------------------- | ---------------------------------------------------------- |
| Onboarding           | Onboarding                          | Welcome splash with Register / Login entry points          |
| Register             | Register                            | Student email, display name, student ID, password          |
| Login                | Login                               | Email + password login                                     |
| Homepage             | Homepage                            | Feed of available listings with search bar                 |
| Filter Modal         | Filter Modal (Adjusted Radius)      | Slide-up sheet for category, price range, condition filter |
| Item Detail          | Item Details (Updated Seller Links) | Listing info, images, seller profile, Add to Cart / Buy    |
| Post Item            | Post Item Page                      | Form for creating a new listing                            |
| Cart                 | Cart Page (No Total)                | Cart items list, proceed to checkout                       |
| Checkout             | Checkout                            | Pickup location selection and order confirmation           |
| Notifications        | Notifications                       | In-app alerts for status changes                           |
| Profile              | Profile                             | User stats, listings history, social links, ratings        |
| Posted Items List    | Posted Items List                   | Seller's active and past listings                          |
| Purchased Items List | Purchased Items List                | Buyer's order history                                      |
| Sold Items List      | Sold Items List                     | Seller's completed transactions                            |
| Confirmed Items List | Confirmed Items List                | Pending pickups awaiting buyer confirmation                |

> If additional screens are implied by the user flow or backend status transitions and are missing from the list above, please add or implement them in the best practice way.

### 5.2 Navigation Structure

```
Root
├── Unauthenticated
│   ├── OnboardingView
│   ├── LoginView
│   └── RegisterView
│
└── Authenticated (TabView)
    ├── Tab: Home
    │   ├── HomeView
    │   │   ├── FilterModalView (sheet)
    │   │   └── ListingDetailView
    │   │       └── CheckoutView
    ├── Tab: Cart
    │   └── CartView
    │       └── CheckoutView
    ├── Tab: Notifications
    │   └── NotificationView
    └── Tab: Profile
        ├── ProfileView
        ├── PostItemView
        ├── PostedItemsView
        ├── PurchasedItemsView
        ├── SoldItemsView
        └── ConfirmedItemsView
```

---

## 6. Network Layer

### 6.1 Base Configuration

All API calls target a single `BASE_URL` defined in `AppConfig.swift`. The `APIClient` is a singleton (or environment-injected) that wraps `URLSession` and handles:

- Building `URLRequest` from `Endpoint` enum values
- Attaching `Authorization: Bearer <accessToken>` to protected requests
- Automatically refreshing the access token on 401 responses using the stored refresh token (via `TokenInterceptor`)
- Decoding `Decodable` responses and mapping network errors to `NetworkError`

```swift
// Example Endpoint enum
enum Endpoint {
    case login
    case register
    case listings(query: ListingQuery?)
    case listingDetail(id: String)
    case createListing
    case updateListing(id: String)
    case deleteListing(id: String)
    case confirmReceived(id: String)
    case search(query: String)
    case categories
    case pickupLocations
    case me
    case updateProfile
    case cart
    case addToCart
    case removeFromCart(listingId: String)
    case clearCart
    case reviewsByListing(listingId: String)
    case reviewsBySeller(sellerId: String)
    case createReview
    case refreshToken
    case logout
}
```

> If additional endpoints are required by the app's features or are implied by the backend routes, please add or implement them in the best practice way.

### 6.2 Token Management

| Action           | Implementation                                                             |
| ---------------- | -------------------------------------------------------------------------- |
| Store tokens     | `KeychainManager.save(accessToken:)`, `save(refreshToken:)`                |
| Read tokens      | `KeychainManager.accessToken`, `KeychainManager.refreshToken`              |
| Delete on logout | `KeychainManager.clearAll()`                                               |
| Auto-refresh     | `TokenInterceptor` retries the original request after `POST /auth/refresh` |

### 6.3 Error Handling

All service functions throw typed `NetworkError` cases. ViewModels catch errors and expose a `String?` `errorMessage` published property for the view layer to display alerts.

```swift
enum NetworkError: Error {
    case unauthorized           // 401 — trigger token refresh
    case forbidden              // 403
    case notFound               // 404
    case validationError(String)// 422 — Zod error from backend
    case serverError            // 500
    case decodingFailed
    case noInternet
    case unknown
}
```

---

## 7. Feature Modules

### 7.1 Authentication

**Screens:** Onboarding → Register / Login

**API Calls:**

| Action   | Endpoint              | Method | Auth |
| -------- | --------------------- | ------ | ---- |
| Register | `POST /auth/register` | POST   | No   |
| Login    | `POST /auth/login`    | POST   | No   |
| Refresh  | `POST /auth/refresh`  | POST   | No   |
| Logout   | `POST /auth/logout`   | POST   | No   |

**Rules:**

- Registration requires `studentId`, `email` (must be `@student.chula.ac.th`), `displayName`, `password`
- On success, store `accessToken` and `refreshToken` in Keychain and navigate to the main tab view
- On logout, clear Keychain and return to Onboarding
- If there are missing validation rules or edge cases in auth flow, please add or implement them in the best practice way

### 7.2 Homepage & Listings

**Screens:** HomeView, FilterModalView, ListingDetailView

**API Calls:**

| Action           | Endpoint                              | Method | Auth        |
| ---------------- | ------------------------------------- | ------ | ----------- |
| Fetch listings   | `GET /listings`                       | GET    | No          |
| Search           | `GET /listings/search?q=`             | GET    | No          |
| Listing detail   | `GET /listings/:id`                   | GET    | No          |
| Confirm received | `POST /listings/:id/confirm-received` | POST   | Yes (buyer) |

**Filter Parameters (via query string):**

| Parameter    | Type   | Description                     |
| ------------ | ------ | ------------------------------- |
| `categoryId` | String | Filter by category              |
| `courseCode` | String | Filter by course code           |
| `isFree`     | Bool   | Free items only                 |
| `minPrice`   | Int    | Minimum price                   |
| `maxPrice`   | Int    | Maximum price                   |
| `status`     | String | `AVAILABLE`, `RESERVED`, `SOLD` |

**Listing Status (Seller View):**
`Available → Reserved → Sold → Waiting for Pickup → Sent → Rated`

**Listing Status (Buyer View):**
`Available → Waiting for Payment → Paid → Waiting for Pickup → Received → Rated`

> StatusBadge component should map each status to the correct colour and label. If additional statuses are implied by the flow, please add or implement them.

### 7.3 Post Item

**Screen:** PostItemView

**API Calls:**

| Action               | Endpoint                | Method | Auth        |
| -------------------- | ----------------------- | ------ | ----------- |
| Create listing       | `POST /listings`        | POST   | Yes         |
| Update listing       | `PATCH /listings/:id`   | PATCH  | Yes (owner) |
| Delete listing       | `DELETE /listings/:id`  | DELETE | Yes (owner) |
| Get categories       | `GET /categories`       | GET    | No          |
| Get pickup locations | `GET /pickup-locations` | GET    | No          |

**Form Fields:**

| Field              | Type     | Required | Notes                               |
| ------------------ | -------- | -------- | ----------------------------------- |
| `title`            | String   | Yes      |                                     |
| `description`      | String   | Yes      |                                     |
| `price`            | Int      | Yes      | 0 if `isFree` is true               |
| `isFree`           | Bool     | Yes      |                                     |
| `courseCode`       | String   | No       | e.g. `2110101`                      |
| `categoryId`       | String   | Yes      | Selected from GET /categories       |
| `pickupLocationId` | String   | Yes      | Selected from GET /pickup-locations |
| `images`           | [String] | No       | URLs (upload flow TBD)              |

> If image upload to cloud storage (e.g., Cloudinary/S3) is required, please add or implement the upload flow in the best practice way.

### 7.4 Cart & Checkout

**Screens:** CartView, CheckoutView

**API Calls:**

| Action      | Endpoint                        | Method | Auth |
| ----------- | ------------------------------- | ------ | ---- |
| Get cart    | `GET /cart`                     | GET    | Yes  |
| Add to cart | `POST /cart/items`              | POST   | Yes  |
| Remove item | `DELETE /cart/items/:listingId` | DELETE | Yes  |
| Clear cart  | `DELETE /cart/clear`            | DELETE | Yes  |

**Rules:**

- A listing already `RESERVED` or `SOLD` cannot be added to the cart (show an alert)
- CartView shows item images, titles, and prices; CheckoutView shows pickup location selection and confirms the order
- If cart total logic, payment integration placeholders, or checkout confirmation steps are missing, please add or implement them in the best practice way

### 7.5 Profile

**Screen:** ProfileView

**API Calls:**

| Action         | Endpoint          | Method | Auth |
| -------------- | ----------------- | ------ | ---- |
| Get profile    | `GET /users/me`   | GET    | Yes  |
| Update profile | `PATCH /users/me` | PATCH  | Yes  |

**Profile Page Shows:**

- Avatar, display name, student ID
- Stats: listings posted, total sold, average rating
- Social links (LINE, Instagram, Facebook)
- Navigation to Posted Items, Purchased Items, Sold Items, Confirmed Items

**Editable Fields:**

| Field             | Notes                             |
| ----------------- | --------------------------------- |
| `displayName`     |                                   |
| `avatarUrl`       | Upload flow (TBD, same as images) |
| `lineId`          | Social link                       |
| `instagramHandle` | Social link                       |
| `facebookUrl`     | Social link                       |

> If additional profile fields are required by the backend or Figma design, please add or implement them in the best practice way.

### 7.6 Transaction History Screens

**Screens:** PostedItemsView, PurchasedItemsView, SoldItemsView, ConfirmedItemsView

| Screen          | Data Source                                            | Description                              |
| --------------- | ------------------------------------------------------ | ---------------------------------------- |
| Posted Items    | `GET /listings` (filter by `sellerId = me`)            | All listings the current user has posted |
| Sold Items      | `GET /listings` (filter by `status = SOLD`)            | Completed sales by current user          |
| Purchased Items | Derived from cart/order history                        | Items the current user has bought        |
| Confirmed Items | `GET /listings` (filter `status = WAITING_FOR_PICKUP`) | Pending pickups to be confirmed          |

> If dedicated endpoints for order/transaction history are missing from the backend, please note them as required backend additions or implement a client-side workaround in the best practice way.

### 7.7 Reviews

**API Calls:**

| Action             | Endpoint                  | Method | Auth |
| ------------------ | ------------------------- | ------ | ---- |
| Reviews by listing | `GET /reviews?listingId=` | GET    | No   |
| Reviews by seller  | `GET /reviews?sellerId=`  | GET    | No   |
| Create review      | `POST /reviews`           | POST   | Yes  |

**Rules:**

- A buyer can only leave a review after the transaction is marked as `RATED` / `RECEIVED`
- Average rating is shown on the listing detail page and on the seller's profile
- Review form includes a 1–5 star rating and an optional text comment

### 7.8 Notifications

**Screen:** NotificationView

**API Calls:**

| Action            | Endpoint                        | Method | Auth |
| ----------------- | ------------------------------- | ------ | ---- |
| Get notifications | `GET /notifications`            | GET    | Yes  |
| Mark as read      | `PATCH /notifications/:id/read` | PATCH  | Yes  |

**Notification Triggers (based on status changes):**

- Item reserved by a buyer → notify seller
- Payment confirmed → notify seller
- Item marked as waiting for pickup → notify buyer
- Buyer confirms received → notify seller

> If notification endpoints are missing from the backend spec, please flag them as required additions and implement the in-app display layer regardless, reading from a local or API-based queue. Add or implement any missing pieces in the best practice way.

---

## 8. Authentication Flow (iOS Side)

1. User submits email + password on `LoginView`
2. `AuthService.login()` calls `POST /auth/login`, receives `accessToken` + `refreshToken`
3. Both tokens stored in **Keychain** via `KeychainManager`
4. App state flips to `.authenticated` → root navigation shows `TabView`
5. All subsequent requests attach `Authorization: Bearer <accessToken>` header
6. On 401 response, `TokenInterceptor` calls `POST /auth/refresh` with the stored refresh token
7. New tokens saved to Keychain, original request retried transparently
8. On logout, `POST /auth/logout` called, Keychain cleared, state set to `.unauthenticated`

---

## 9. Data Models (Codable)

Below are the core Swift model structs. If any fields are missing compared to the backend schema or Figma, please add or implement them in the best practice way.

```swift
struct User: Codable, Identifiable {
    let id: String
    let studentId: String
    let email: String
    let displayName: String
    let avatarUrl: String?
    let lineId: String?
    let instagramHandle: String?
    let facebookUrl: String?
    let averageRating: Double?
    let createdAt: Date
}

struct Listing: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let price: Int
    let isFree: Bool
    let status: ListingStatus
    let courseCode: String?
    let images: [String]
    let seller: User
    let category: Category
    let pickupLocation: PickupLocation
    let createdAt: Date
}

enum ListingStatus: String, Codable {
    case available       = "AVAILABLE"
    case reserved        = "RESERVED"
    case sold            = "SOLD"
    case waitingPickup   = "WAITING_FOR_PICKUP"
    case sent            = "SENT"
    case rated           = "RATED"
}

struct Category: Codable, Identifiable {
    let id: String
    let name: String
    let slug: String
}

struct PickupLocation: Codable, Identifiable {
    let id: String
    let name: String
    let building: String
    let description: String?
}

struct CartItem: Codable, Identifiable {
    let id: String
    let listingId: String
    let listing: Listing
    let quantity: Int
}

struct Review: Codable, Identifiable {
    let id: String
    let rating: Int               // 1–5
    let comment: String?
    let reviewer: User
    let listing: Listing
    let createdAt: Date
}

struct AppNotification: Codable, Identifiable {
    let id: String
    let title: String
    let body: String
    let isRead: Bool
    let createdAt: Date
}
```

---

## 10. Non-Functional Requirements

If any requirements are missing or you identify a loophole in the list below, please add or implement them in the best practice way.

| Requirement   | Specification                                                                  |
| ------------- | ------------------------------------------------------------------------------ |
| Security      | Tokens stored in Keychain only, never in `UserDefaults`; HTTPS enforced        |
| Performance   | Lazy image loading (`AsyncImage`); paginated listing fetches to reduce payload |
| Usability     | Compliant with iOS Human Interface Guidelines (HIG); Dark Mode supported       |
| Accessibility | VoiceOver labels on all interactive elements; minimum tap target 44×44 pt      |
| Scalability   | Stateless service layer; no business logic in Views                            |
| Reliability   | All form fields validated client-side before API call; graceful error alerts   |
| Privacy       | No sensitive user data logged; Keychain used for all credential storage        |
| Offline UX    | Show cached data where possible; display clear offline/error states            |

---

## 11. Git Workflow

### 11.1 Branch Strategy

| Branch           | Purpose                                              |
| ---------------- | ---------------------------------------------------- |
| `main`           | Production-ready, protected                          |
| `develop`        | Integration branch for feature merges                |
| `feature/<name>` | Individual features (e.g., `feature/post-item-form`) |
| `fix/<name>`     | Bug fix branches                                     |

### 11.2 Commit Convention

```text
feat: implement listing detail view with image carousel
fix: resolve token refresh race condition on 401
chore: add SwiftLint config
docs: update screen inventory in frontend instruction
refactor: extract CartService from CartViewModel
ui: match filter modal to Figma design
```

---

## 12. Excluded Features (Out of Scope)

| Feature         | Reason                                         |
| --------------- | ---------------------------------------------- |
| In-app Chat     | Out of project requirements                    |
| Social SSO      | Deferred (backend JWT only for now)            |
| Payment Gateway | Future integration (Stripe/PayPal placeholder) |

> If dependencies on excluded features create gaps in the user flow, please note them and implement placeholder screens or graceful fallbacks in the best practice way.
