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
- Item status lifecycle (Show for sellers): **Available → Reserved → Sold → Waiting for Pickup → Sent → Rated**
- Item status lifecycle (Show for buyers): **Available → Waiting for Payment → Paid → Waiting for Pickup → Received (Buyer should click to confirm and rate or review) → Rated**
- After rating, the listing is archived and no longer visible in the main feed but can be accessed in the user’s profile history. Adn the rating will be shown as average rating in the listing detail page and the seller profile page. The buyer can also write a review for the seller after the transaction is completed, and the review will be shown in the seller profile page.

### 4.2 Search & Discovery

- Filter by course code, hardware type, price range, and condition
- Full-text search across listing titles and descriptions
- Browse by category: Microcontrollers, Sensors, Robotics Kits, PCBs, etc.

### 4.3 Profile

- Coordinate on-campus pickup directly in chat
- Seller can mark item as Reserved after agreeing with a buyer
- Seller can add their social media link such as line, instagram, facebook for contact with buyer

### 4.4 User Authentication

- Student register with university email and password
- User should be able to login via other Social SSO (Google, Facebook)
- Profile page: listings posted, transaction history, ratings

### 4.5 Pickup Location System

- Predefined on-campus pickup spots (Lang Gear, Engineering buildings, etc.)
- Seller specifies preferred pickup location when posting a listing

### 4.6 Cart System

- Buyers can add listings to a cart for easier checkout
- Buyers can view and manage their cart items

### 4.7 Payment Integration

- Integrate with a payment gateway (e.g., Stripe, PayPal) for secure transactions

### 4.8 Alert System

- The application should be able to send notifications when the status of the item changes, such as when a paid item is marked as waiting for pickup.
- The application should be able to send notifications by in-app alerts

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

should be in the best practice structure for a Node.js REST API with clear separation of concerns and scalability in mind:

```text
/cedt-marketplace-backend
├── package.json
├── package-lock.json
├── tsconfig.json
├── eslint.config.mjs
├── prisma.config.ts
├── prisma
│   ├── migrations
│   ├── schema.prisma
│   └── seed.ts
├── src
│   ├── app.ts
│   ├── config
│   ├── controllers
│   ├── middlewares
│   ├── models
│   ├── routes
│   ├── server.ts
│   ├── services
│   ├── sockets
│   └── utils
├── tests
│   └── app.test.ts
```

### 5.3 Database Schema (Key Models)

The text below outlines only some database tables and their fields, if you think some fields or some tables are missing, please add them in the best practice way. The actual Prisma schema file should be more detailed with relations, indexes, and constraints.

```text
User            id, studentId, email, displayName, avatarUrl, createdAt
Listing         id, sellerId, title, description, price, isFree, status, categoryId, courseCode, pickupLocationId, images[], createdAt
Category        id, name, slug (e.g., microcontroller, sensor, robotics-kit)
ChatRoom        id, listingId, buyerId, sellerId, createdAt
Message         id, chatRoomId, senderId, content, createdAt
PickupLocation  id, name, building, description
```

### 5.4 API Endpoints

the table below outlines only some REST API endpoints for the backend, such as authentication, listing management, search, and user profile. Each endpoint specifies the HTTP method, path, description, and whether authentication is required. Please think some and please add the missing ones in the best practice way. or you can seperate the endpoints into different tables based on their functionality for make it more clear and maintainable.

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

### 5.6 Authentication Flow

1. Student submits university email + password or via Social SSO (Google, Facebook)
2. Server validates credentials, issues short-lived **Access Token** (15 min) + **Refresh Token** (7 days)
3. iOS app stores tokens securely in **Keychain**
4. All protected endpoints validate `Bearer <token>` in the `Authorization` header
5. Expired access token → app uses refresh token to silently re-authenticate

### 5.7 Environment Variables (`.env`)

```env
# Application Environment
NODE_ENV=development
PORT=3003
CORS_ORIGIN=http://localhost:3000

# Database Configuration (Used by Prisma)
DATABASE_URL="postgresql://username:password@localhost:5432/cedt_marketplace?schema=public"

# Security & Authentication
BCRYPT_SALT_ROUNDS=12
JWT_SECRET="example"
JWT_REFRESH_SECRET="example"
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

---

## 8. Non-Functional Requirements

The table below summarises the key non-functional requirements for the CEDT Community Marketplace, covering security, performance, scalability, reliability, usability, and privacy aspects. If you think some requirements are missing, please add them in the best practice way.

| Requirement | Specification                                                       |
| ----------- | ------------------------------------------------------------------- |
| Security    | JWT auth, HTTPS only, student-only access, rate limiting            |
| Performance | API response < 500ms for listing queries; lazy image loading on iOS |
| Scalability | Stateless REST API, connection pooling via Prisma                   |
| Reliability | Input validation on both server (Zod) and client (SwiftUI Form)     |
| Usability   | Native iOS HIG-compliant UI, supports Dark Mode                     |
| Privacy     | No personal data exposed in public listing API responses            |

---
