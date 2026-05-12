# CEDT Community Marketplace - iOS Frontend

## Project Title and Description

CEDT Community Marketplace is a native iOS app for engineering students to buy, sell, and give away robotics and hardware equipment. It integrates with the Node.js backend to provide verified student accounts, structured listings, cart checkout, and pickup coordination.

## Tech Stack

- Language: Swift 5.9+
- UI: SwiftUI (iOS 16+)
- Architecture: MVVM
- Networking: URLSession + async/await
- Auth: JWT access/refresh tokens stored in Keychain
- Navigation: NavigationStack + TabView
- State: @StateObject, @EnvironmentObject
- Linting: SwiftLint (optional)

## Getting Started

### Prerequisites

- Xcode 15+
- iOS 16+ simulator or device
- Backend running at http://localhost:3003

### Setup

1. Open the project in Xcode: frontend/CEDT Marketplace/CEDT Marketplace.xcodeproj
2. Confirm the backend base URL in AppConfig.swift
3. Build and run on a simulator or device

## Environment Variables

The iOS app uses configuration values in AppConfig.swift instead of environment variables.

- baseURL: http://localhost:3003
- studentEmailDomain: student.chula.ac.th

## Flow Example

1. User opens the app and lands on the Onboarding screen.
2. User registers with a student email and password.
3. Access/refresh tokens are stored in Keychain.
4. User browses listings, applies filters, and opens listing details.
5. User adds an item to the cart and proceeds to checkout.
6. User manages listings and social links in Profile.

## Project Structure

```text
/CEDT Marketplace
├── CEDT_MarketplaceApp.swift
├── ContentView.swift
├── Config/
│   └── AppConfig.swift
├── Network/
│   ├── APIClient.swift
│   ├── Endpoint.swift
│   ├── HTTPMethod.swift
│   ├── NetworkError.swift
│   └── TokenInterceptor.swift
├── Keychain/
│   └── KeychainManager.swift
├── Models/
│   ├── AuthModels.swift
│   ├── User.swift
│   ├── Listing.swift
│   ├── Category.swift
│   ├── PickupLocation.swift
│   ├── CartItem.swift
│   ├── Review.swift
│   └── Notification.swift
├── Services/
│   ├── AuthService.swift
│   ├── ListingService.swift
│   ├── UserService.swift
│   ├── CartService.swift
│   ├── ReviewService.swift
│   ├── CategoryService.swift
│   ├── PickupLocationService.swift
│   └── NotificationService.swift
├── ViewModels/
│   ├── SessionViewModel.swift
│   ├── Auth/
│   ├── Listing/
│   ├── Profile/
│   ├── Cart/
│   └── Notification/
├── Views/
│   ├── Onboarding/
│   ├── Auth/
│   ├── Home/
│   ├── Listing/
│   ├── Profile/
│   ├── Cart/
│   ├── Notification/
│   └── Components/
└── Extensions/
	├── View+Extensions.swift
	├── Color+Extensions.swift
	└── Date+Extensions.swift
```

## Page / View Structure

- Onboarding: entry point for Login and Register
- Auth: LoginView, RegisterView
- Home: listing feed with search and filter modal
- Listing Detail: item details, seller info, add to cart
- Post Item: create listing form
- Cart: cart list and checkout
- Checkout: pickup location selection and confirmation
- Notifications: in-app alerts list
- Profile: user info, social links, posted/purchased/sold/confirmed listings

## Auth

- Register: POST /auth/register
- Login: POST /auth/login
- Refresh: POST /auth/refresh
- Logout: POST /auth/logout

Social login buttons (Google, Facebook) are included as UI placeholders and can be wired once backend support is available.

Tokens are stored in Keychain and attached to protected endpoints. Access tokens are refreshed automatically when a 401 occurs.

## Notes

- UI uses default SwiftUI components (Form, TextField, NavigationStack, List) for performance.
- Status badges map all backend listing statuses to user-friendly labels.
