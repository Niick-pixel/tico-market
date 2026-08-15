# Tico Market

An open-source iOS marketplace app for Costa Rica: post items for a fixed price ("ask") or
run real-time auctions where buyers bid live. Built with SwiftUI, Firebase, and iOS 26's
Liquid Glass design system (with a graceful fallback on older iOS versions).

> **Status**: early MVP scaffold. It has been written carefully but has **not been compiled**
> — this repo was generated on a machine without Xcode. See [Known caveats](#known-caveats)
> before you start.

## No Mac? Use CI to compile-check

`.github/workflows/ci.yml` builds the app on a free GitHub-hosted macOS runner on every push
and pull request — no local Mac required to find out whether it compiles. Push this repo to
GitHub and check the **Actions** tab after each push; it runs `xcodegen generate` then
`xcodebuild build` against the iOS Simulator SDK (no code signing, no Firebase secrets needed
for a plain compile check). Treat red CI as your primary feedback loop until you have access
to a Mac for interactive development and simulator testing.

## Features (MVP)

- Email/password auth (Firebase Auth)
- Browse listings, filter by "Todos / Subastas / Precio fijo"
- Fixed-price listings ("Comprar ahora" / contact seller)
- Live auctions: real-time bid feed, countdown timer, atomic bid placement
  (a Firestore transaction re-checks the current price and auction end time on every bid,
  so two people bidding at the same instant can't both "win")
- Create a listing (fixed price or auction) with photos uploaded to Firebase Storage
- Basic profile screen

## Stack

- **SwiftUI**, iOS 17+ deployment target
- **Liquid Glass** (`.glassEffect()`, `.buttonStyle(.glass...)`) on iOS 26+, with an
  `.ultraThinMaterial` fallback on iOS 17–25 — see `Sources/Components/GlassModifiers.swift`
- **Firebase**: Auth, Firestore (realtime listeners), Storage
- **[XcodeGen](https://github.com/yonaskolb/XcodeGen)** generates the `.xcodeproj` from
  `project.yml` — the generated project is gitignored, so the repo only tracks source files
  and everyone regenerates it locally. This avoids Xcode project-file merge conflicts, which
  is the standard approach for open-source Swift projects.

## Project structure

```
Sources/
  TicoMarketApp.swift        # App entry point, Firebase configuration
  Models/                    # Listing, Bid, UserProfile (Codable, mirror Firestore docs)
  Services/                  # AuthService, ListingService, BidService, StorageService
  Views/
    RootView.swift           # Auth-state gate (sign in vs main tabs)
    Auth/                    # Sign in / sign up
    Main/                    # Tab bar
    Home/                    # Feed + listing row
    Listing/                 # Listing detail, create listing form
    Auction/                 # Live auction screen, countdown views
    Profile/
  Components/                # Glass modifiers, price tag, status badge
  Utilities/                 # Currency + relative-date formatters (es_CR locale)
Resources/
  Info.plist
firestore.rules              # Security rules — deploy these to your Firebase project
firestore.indexes.json       # Composite indexes the queries above need
project.yml                  # XcodeGen spec — generates TicoMarket.xcodeproj
```

## Setup (requires a Mac with Xcode 26)

1. **Install tooling**
   ```bash
   brew install xcodegen firebase-cli
   ```
   Install Xcode 26 (or later) from the App Store — needed for the real Liquid Glass APIs
   and the iOS 26 SDK. On earlier Xcode versions the app still builds, but `.glassEffect()`
   calls will fall back to `.ultraThinMaterial` automatically.

2. **Create a Firebase project**
   - Go to the [Firebase console](https://console.firebase.google.com/) and create a project.
   - Add an iOS app with bundle ID `com.ticomarket.app`.
   - Download the generated `GoogleService-Info.plist` and drop it in the repo root
     (it's gitignored — never commit your real one).
   - In **Authentication → Sign-in method**, enable **Email/Password**.
   - In **Firestore Database**, create a database (start in production mode — the rules
     below lock it down properly).
   - In **Storage**, enable it (used for listing photos).

3. **Deploy the security rules and indexes**
   ```bash
   firebase login
   firebase init firestore   # point it at your project; keep the existing rules/indexes files
   firebase deploy --only firestore:rules,firestore:indexes
   ```

4. **Generate and open the Xcode project**
   ```bash
   xcodegen generate
   open TicoMarket.xcodeproj
   ```
   Xcode will resolve the Firebase Swift Package on first build — this can take a few minutes.

5. **Add `GoogleService-Info.plist` to the Xcode target** if it wasn't picked up automatically
   (drag it into the project navigator, make sure "Copy items if needed" and the TicoMarket
   target are checked).

6. Build and run on a simulator or device running iOS 17+.

## Known caveats

Since this scaffold was written without access to Xcode or a Mac, a few things to double-check
on first build:

- **Liquid Glass API surface**: `Sources/Components/GlassModifiers.swift` uses
  `.glassEffect(.regular.tint(_:).interactive(), in:)` and friends based on the public iOS 26
  API shape. Confirm the exact method names against the iOS 26 SDK you have installed and
  adjust if Apple's final API differs slightly.
- **Firebase SPM versions**: `project.yml` pins `firebase-ios-sdk` from `11.0.0`. Bump this if
  a newer major version is out by the time you build.
- **No asset catalog yet**: there's no `Assets.xcassets` in this scaffold (App Icon, accent
  color). Add one in Xcode — it's much easier to do with the icon-generation tooling built
  into Xcode than to hand-author it.
- Nothing here has been run in the iOS Simulator. Treat the first build as the real
  smoke test, and expect to fix a handful of small compile errors.

## Roadmap ideas (post-MVP)

- Push notifications when you're outbid
- In-app messaging between buyer and seller
- Search and category browsing
- Ratings/reviews after a completed sale
- Sign in with Apple
- Report/block, content moderation for listings

## License

MIT — see [LICENSE](LICENSE). Contributions welcome.
