# Tico Market

An open-source iOS marketplace app for Costa Rica: post items for a fixed price ("ask") or
run real-time auctions where buyers bid live. Built with SwiftUI and Firebase, styled to read
close to iOS 26's Liquid Glass design language.

> **Status**: early MVP. CI is green — see [No Mac? Use CI](#no-mac-use-ci-to-compile-check--see-screenshots)
> below for how that was verified without any of us touching a Mac.

## No Mac? Use CI to compile-check + see screenshots

`.github/workflows/ci.yml` builds the app on a free GitHub-hosted macOS runner on every push
and pull request — no local Mac required to find out whether it compiles or what it looks like.
Push to GitHub and check the **Actions** tab after each push:

- It runs `xcodegen generate` then `xcodebuild build` against the iOS Simulator SDK (no code
  signing needed).
- It drops in a **fake, non-functional** `GoogleService-Info.plist`
  (`Resources/GoogleService-Info.ci.plist`) purely so `FirebaseApp.configure()` doesn't crash
  on launch — no real secrets involved, and your real config stays gitignored.
- It boots an iPhone 16 Simulator, installs and launches the app, and uploads a screenshot of
  the sign-in screen as a workflow artifact (bottom of the run's summary page, under
  **Artifacts**). That's a real rendered screenshot of the actual UI, not a mockup.

Treat CI as your primary feedback loop until you have interactive access to a Mac or simulator.

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
- **Liquid Glass–styled UI** via `.ultraThinMaterial` in `Sources/Components/GlassModifiers.swift`.
  The real iOS 26 `.glassEffect()` API isn't used yet: that symbol doesn't exist in SDKs older
  than Xcode 26, so referencing it fails to *compile* on any older toolchain regardless of
  `#available` checks — and GitHub's macOS CI runners currently ship Xcode 16.4. Swap the
  modifier body for `.glassEffect(...)` once you're building with Xcode 26, locally or in CI.
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

   `GoogleService-Info.plist` must already be sitting in the repo root before you run
   `xcodegen generate` (step 2) — `project.yml` lists it as a required resource, so
   generation fails loudly if it's missing rather than silently shipping an app that
   crashes on launch with "could not find a valid GoogleService-Info.plist". If you add or
   replace the file later, rerun `xcodegen generate` to pick it up.

5. **Add `GoogleService-Info.plist` to the Xcode target** if it wasn't picked up automatically
   (drag it into the project navigator, make sure "Copy items if needed" and the TicoMarket
   target are checked).

6. Build and run on a simulator or device running iOS 17+.

## Known caveats

- **No real Liquid Glass yet** — see the Stack section above. It's `.ultraThinMaterial` for now.
- **Firebase SPM versions**: `project.yml` pins `firebase-ios-sdk` from `11.0.0`. Bump this if
  a newer major version is out by the time you build.
- **No asset catalog yet**: there's no `Assets.xcassets` in this scaffold (App Icon, accent
  color). Add one in Xcode — it's much easier to do with the icon-generation tooling built
  into Xcode than to hand-author it.
- CI verifies the app compiles and boots to the sign-in screen in the Simulator. It does not
  exercise sign-in, listing creation, or bidding — those all need a real Firebase project
  behind them, so treat them as untested until you click through them yourself.

## Roadmap ideas (post-MVP)

- Push notifications when you're outbid
- In-app messaging between buyer and seller
- Search and category browsing
- Ratings/reviews after a completed sale
- Sign in with Apple
- Report/block, content moderation for listings

## License

MIT — see [LICENSE](LICENSE). Contributions welcome.
