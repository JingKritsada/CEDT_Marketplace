# CEDT Community Marketplace

## Project Instruction Document

**Backend:** Node.js | **Frontend:** SwiftUI (iOS)

---

## 1. Project Overview

CEDT Community Marketplace is a mobile platform application designed to facilitate the buying, selling, and free-giving of hardware and robotics equipment among engineering students at the Faculty of Engineering (CEDT). The platform replaces the current fragmented LINE group-based system with a structured, searchable, and trustworthy marketplace ecosystem.

| Field           | Detail                                          |
| --------------- | ----------------------------------------------- |
| Project Name    | CEDT Community Marketplace                      |
| Platform        | iOS Mobile Application                          |
| Frontend        | Swift + SwiftUI                                 |
| Backend         | Node.js (REST API)                              |
| Target Users    | CEDT Engineering Students (Buyers & Sellers)    |
| Version Control | Git (regular commits for coursework milestones) |

---

## 2. Problem Statement

Engineering students accumulate hardware and robotics equipment from coursework but have no efficient platform to resell or give away these items. Junior students must purchase new equipment at high cost, even when affordable used options exist.

Current pain points with the LINE group workaround:

- No structured search — users must scroll through historical messages
- No item status tracking — buyers repeatedly ask if items are still available
- No categorisation by course or equipment type
- No identity verification — no trust mechanism between strangers
- Pickup coordination is disorganised

---

## 3. Solution & Key Differentiators

CEDT Community Marketplace addresses each pain point with purpose-built features:

| Pain Point                                 | Solution                                             |
| ------------------------------------------ | ---------------------------------------------------- |
| Unstructured LINE search                   | Category & course-code filtering system              |
| No item status tracking                    | Available / Reserved / Sold status badges            |
| No verification                            | Student account authentication (CU account)          |
| Off-campus unsafe pickups                  | On-Campus Pickup Points (e.g., Larn Gear, buildings) |
| General platforms (Kaidee, FB Marketplace) | CEDT-specific taxonomy: courses, hardware types      |

---

## 4. Core Features

### 4.1 Listing Management

- Post items for sale or free giveaway
- Attach photos, description, condition, and price
- Tag listings with course codes (e.g., 2110101, 2110427) and hardware category
- Item status lifecycle: **Available → Reserved → Sold**

### 4.2 Search & Discovery

- Filter by course code, hardware type, price range, and condition
- Full-text search across listing titles and descriptions
- Browse by category: Microcontrollers, Sensors, Robotics Kits, PCBs, etc.

### 4.3 Profile

- Coordinate on-campus pickup directly in chat
- Seller can mark item as Reserved after agreeing with a buyer
- Seller can add thier social media link such as line, instragram, facebook for contact with buyer

### 4.4 User Authentication

- Student login via university account (MCV account)
- Profile page: listings posted, transaction history, ratings

### 4.5 Pickup Location System

- Predefined on-campus pickup spots (Lang Gear, Engineering buildings, etc.)
- Seller specifies preferred pickup location when posting a listing

---

## 5. Backend — Node.js

### 5.1 Tech Stack

| Layer          | Technology                                    |
| -------------- | --------------------------------------------- |
| Runtime        | Node.js (v18+)                                |
| Framework      | Express.js                                    |
| Database       | PostgreSQL (primary) + Redis (sessions/cache) |
| ORM            | Prisma                                        |
| Authentication | JWT (Access + Refresh tokens)                 |
| File Storage   | AWS S3 or Cloudinary (listing images)         |
| API Style      | RESTful JSON API                              |
| Validation     | Zod / Joi                                     |
| Testing        | Jest + Supertest                              |

### 5.2 Project Structure

```text
/cedt-marketplace-backend
├── src/
│   ├── config/          # DB, env, constants
│   ├── controllers/     # Route handler logic
│   ├── middlewares/     # Auth, validation, error handler
│   ├── models/          # Prisma schema / DB models
│   ├── routes/          # Express routers
│   ├── services/        # Business logic layer
│   ├── sockets/         # Socket.io chat handlers
│   └── utils/           # Helpers, formatters
├── prisma/
│   └── schema.prisma    # Database schema
├── tests/               # Unit & integration tests
├── .env                 # Environment variables
└── server.js            # Entry point
```

### 5.3 Database Schema (Key Models)

```text
User            id, studentId, email, displayName, avatarUrl, createdAt
Listing         id, sellerId, title, description, price, isFree,
                status (AVAILABLE | RESERVED | SOLD),
                categoryId, courseCode, pickupLocationId, images[], createdAt
Category        id, name, slug (e.g., microcontroller, sensor, robotics-kit)
ChatRoom        id, listingId, buyerId, sellerId, createdAt
Message         id, chatRoomId, senderId, content, createdAt
PickupLocation  id, name, building, description
```

### 5.4 API Endpoints

| Method + Path           | Description                     | Auth Required |
| ----------------------- | ------------------------------- | ------------- |
| `POST /auth/login`      | Student login, returns JWT      | No            |
| `POST /auth/refresh`    | Refresh access token            | No            |
| `GET /listings`         | Fetch all listings (filterable) | No            |
| `POST /listings`        | Create new listing              | Yes           |
| `GET /listings/:id`     | Get single listing detail       | No            |
| `PATCH /listings/:id`   | Update listing or status        | Yes (owner)   |
| `DELETE /listings/:id`  | Delete listing                  | Yes (owner)   |
| `GET /listings/search`  | Full-text search + filters      | No            |
| `GET /categories`       | List all categories             | No            |
| `GET /users/me`         | Get current user profile        | Yes           |
| `GET /pickup-locations` | List pickup spots               | No            |

### 5.5 WebSocket Events (Chat via Socket.io)

| Event                | Direction       | Description                            |
| -------------------- | --------------- | -------------------------------------- |
| `join_room`          | Client → Server | Join a chat room                       |
| `send_message`       | Client → Server | Send a message                         |
| `receive_message`    | Server → Client | Broadcast message to room              |
| `typing`             | Client → Server | Typing indicator                       |
| `item_status_update` | Server → Client | Notify when seller updates item status |

### 5.6 Authentication Flow

1. Student submits university email + password (or OAuth via CU SSO)
2. Server validates credentials, issues short-lived **Access Token** (15 min) + **Refresh Token** (7 days)
3. iOS app stores tokens securely in **Keychain**
4. All protected endpoints validate `Bearer <token>` in the `Authorization` header
5. Expired access token → app uses refresh token to silently re-authenticate

### 5.7 Environment Variables (`.env`)

```env
DATABASE_URL=postgresql://user:pass@localhost:5432/cedt_marketplace
REDIS_URL=redis://localhost:6379
JWT_SECRET=<strong_random_secret>
JWT_REFRESH_SECRET=<another_secret>
STORAGE_BUCKET=<s3-or-cloudinary-config>
PORT=3000
NODE_ENV=development
```

---

## 6. Frontend — SwiftUI (iOS)

### 6.1 Tech Stack

| Layer            | Technology                               |
| ---------------- | ---------------------------------------- |
| Language         | Swift 5.9+                               |
| UI Framework     | SwiftUI                                  |
| Architecture     | MVVM (Model-View-ViewModel)              |
| Networking       | URLSession + async/await (or Alamofire)  |
| Real-time Chat   | URLSessionWebSocketTask / Starscream     |
| Image Loading    | SDWebImageSwiftUI or AsyncImage          |
| Secure Storage   | Keychain (for tokens)                    |
| State Management | Combine + @StateObject / @ObservedObject |
| Min iOS Version  | iOS 16+                                  |

### 6.2 Project Structure

```text
/CEDTMarketplace.xcodeproj
├── App/
│   ├── CEDTMarketplaceApp.swift    # @main entry point
│   └── ContentView.swift           # Root navigation
├── Features/
│   ├── Auth/                       # Login, register views + VM
│   ├── Home/                       # Feed, search, category browse
│   ├── Listing/                    # Detail, create, edit listing
│   ├── Chat/                       # Chat room list + message view
│   └── Profile/                    # User profile + my listings
├── Core/
│   ├── Network/                    # APIClient, endpoints, WebSocket
│   ├── Models/                     # Codable data models
│   ├── Services/                   # AuthService, ListingService, etc.
│   └── Storage/                    # Keychain wrapper
├── Components/                     # Reusable SwiftUI views
└── Resources/                      # Assets, fonts, colors
```

### 6.3 Screen Map

| Screen                 | Key Components                                  | Navigation          |
| ---------------------- | ----------------------------------------------- | ------------------- |
| `LoginView`            | Email field, login button, CU SSO               | → HomeView          |
| `HomeView` (Tab 1)     | ListingGrid, SearchBar, CategoryFilter          | → ListingDetailView |
| `ListingDetailView`    | ImageCarousel, StatusBadge, ChatButton          | → ChatRoomView      |
| `CreateListingView`    | Form, ImagePicker, CoursePicker, CategoryPicker | Modal sheet         |
| `ChatListView` (Tab 2) | ChatRoomRow with last message preview           | → ChatRoomView      |
| `ChatRoomView`         | MessageBubbles, InputBar, WebSocket stream      | Push                |
| `ProfileView` (Tab 3)  | My Listings, sold history, settings             | → MyListingView     |
| `SearchView`           | SearchBar, FilterSheet, ResultsList             | Push                |

### 6.4 MVVM Pattern Example — Listings

```swift
// ListingViewModel.swift
@MainActor
class ListingViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: ListingService

    func fetchListings(category: String? = nil, course: String? = nil) async {
        isLoading = true
        defer { isLoading = false }
        do {
            listings = try await service.getListings(category: category, course: course)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

### 6.5 Key SwiftUI Components

- **ListingCard** — image thumbnail, title, price/free tag, status badge, course tag
- **CategoryFilterBar** — horizontal scrollable category chips
- **StatusBadge** — coloured pill (green = Available, yellow = Reserved, grey = Sold)
- **MessageBubble** — sender/receiver differentiated bubbles with timestamp
- **ImageCarousel** — TabView-based multi-image viewer for listing photos
- **CoursePicker** — searchable list of CEDT course codes

### 6.6 Networking Layer

```swift
// APIClient.swift
struct APIClient {
    static let baseURL = URL(string: "https://api.cedt-marketplace.app")!

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        var req = URLRequest(url: Self.baseURL.appendingPathComponent(endpoint.path))
        req.httpMethod = endpoint.method.rawValue
        req.setValue("Bearer \(TokenStore.accessToken)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body = endpoint.body {
            req.httpBody = try JSONEncoder().encode(body)
        }
        let (data, response) = try await URLSession.shared.data(for: req)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw APIError.serverError
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
```

---

## 7. Git Workflow

### 7.1 Branch Strategy

| Branch           | Purpose                                              |
| ---------------- | ---------------------------------------------------- |
| `main`           | Production-ready, protected                          |
| `develop`        | Integration branch for feature merges                |
| `feature/<name>` | Individual features (e.g., `feature/chat-websocket`) |
| `fix/<name>`     | Bug fix branches                                     |

### 7.2 Commit Convention

```text
feat: add listing category filter
fix: resolve JWT token expiry crash on iOS
chore: update Prisma schema with PickupLocation model
docs: update API endpoint table in README
refactor: extract ChatService from ChatViewModel
```

### 7.3 Milestone Commits

Commit checkpoints aligned with coursework presentation schedule:

| Milestone   | Deliverable                                   |
| ----------- | --------------------------------------------- |
| Milestone 1 | Project setup, auth endpoints, login screen   |
| Milestone 2 | Listing CRUD API + Home/Listing UI            |
| Milestone 3 | Real-time chat (WebSocket backend + iOS)      |
| Milestone 4 | Search & filter, status management            |
| Final       | Full integration, bug fixes, demo-ready build |

---

## 8. Development Setup

### 8.1 Backend

```bash
# 1. Clone and install
git clone <repo-url> && cd backend
npm install

# 2. Configure environment
cp .env.example .env
# Fill in DATABASE_URL, JWT_SECRET, etc.

# 3. Run migrations and seed
npx prisma migrate dev
npm run seed

# 4. Start dev server
npm run dev   # uses nodemon
```

### 8.2 Frontend (iOS)

1. Open `CEDTMarketplace.xcodeproj` in **Xcode 15+**
2. Resolve Swift packages: **File → Packages → Resolve Packages**
3. Set `BASE_URL` in `Config.swift` to your local backend (`http://localhost:3000`)
4. Select a simulator (iPhone 15, iOS 16+) and run with **Cmd + R**

---

## 9. Non-Functional Requirements

| Requirement | Specification                                                       |
| ----------- | ------------------------------------------------------------------- |
| Security    | JWT auth, HTTPS only, student-only access, rate limiting            |
| Performance | API response < 500ms for listing queries; lazy image loading on iOS |
| Scalability | Stateless REST API, connection pooling via Prisma                   |
| Reliability | Input validation on both server (Zod) and client (SwiftUI Form)     |
| Usability   | Native iOS HIG-compliant UI, supports Dark Mode                     |
| Privacy     | No personal data exposed in public listing API responses            |

---
