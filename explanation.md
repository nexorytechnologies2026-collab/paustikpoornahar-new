# How Paustik Poornahar Works

This document explains the whole Paustik Poornahar food delivery system: first the **customer app**, then the **backend** (admin panel, restaurant panel and the API that every app talks to). Every feature and flow found in the code is listed, including the small ones.

The system is built on the StackFood v9 codebase (rebranded). Names in `code style` are the real setting keys, routes or screen names, so you can search the code for them.

---

## 0. The big picture

### 0.1 The pieces

```
 Customer app (Flutter)          Restaurant app*         Delivery-man app*
 Android · iOS · Web             (separate product)      (separate product)
        │                               │                        │
        └────────────── REST API  /api/v1/... ──────────────────┘
                                │
                    Laravel backend (backend/)
          ├─ Admin panel        (/admin/...)      ← platform owner
          ├─ Restaurant panel   (/restaurant-panel/...) ← restaurant owners & staff
          ├─ Payment pages      (/payment-mobile, gateway callbacks)
          └─ MySQL database + storage (images, files)
                                │
     Firebase (push, phone OTP, Google sign-in) · Google Maps · payment gateways
     SMS gateways · SMTP mail · OpenAI (AI module) · S3 (optional)
```

`*` The restaurant app and delivery-man app are not in this repository, but the backend already contains their complete APIs, so their flows are described here too.

### 0.2 Who uses the system

| Role | Uses | Main job |
|---|---|---|
| **Customer** | Customer app / website | Find food, order, pay, track, review |
| **Guest** | Customer app / website | Browse and order without an account (if `guest_checkout_status` is on) |
| **Restaurant owner (vendor)** | Restaurant panel / restaurant app | Manage menu, accept and prepare orders, earn money |
| **Restaurant employee** | Restaurant panel | Same as owner, limited by the role the owner gives |
| **Delivery man (DM)** | Delivery-man app | Pick up and deliver orders, collect cash |
| **Admin** | Admin panel | Runs the whole platform |
| **Admin employee** | Admin panel | Same as admin, limited by a custom role |

### 0.3 Core ideas you need first

- **Zone**: a polygon drawn on the map (for example one city area). Every restaurant belongs to one zone. A customer only sees restaurants of the zone(s) their delivery location falls in. Delivery charges, the maximum cash-on-delivery amount, delivery-man incentives and extra delivery options are set per zone.
- **Restaurant business model**: each restaurant works either on **commission** (the platform takes a % of every order) or on a **subscription package** (the restaurant pays a fixed fee for a period and keeps order money).
- **Order types**: `delivery` (home delivery), `take_away` (customer picks up), `dine_in` (customer eats at the restaurant).
- **Payment methods**: `cash_on_delivery`, `digital_payment` (online gateway), `wallet`, `offline_payment` (bank transfer etc. with proof), and `partial_payment` (part wallet + part other method).
- **Everything is configurable** from the admin panel; the app downloads all settings on start from `/api/v1/config` and hides or shows features accordingly.

---

# PART 1 — CUSTOMER APP

## 1.1 Technology and structure

- Flutter app (`customer app/`), one code base for **Android, iOS and Web**.
- State management, routing and dependency injection: **GetX**.
- Every feature lives in `lib/features/<feature>/` with `controllers/`, `domain/models`, `domain/repositories`, `domain/services`, `screens/`, `widgets/`.
- Shared code: `lib/api` (HTTP client), `lib/helper` (routes, prices, dates, cart, checkout, address, notifications), `lib/util` (constants, colours, sizes, images), `lib/common` (shared widgets and models), `lib/theme` (light and dark themes).
- Local storage: `shared_preferences` (settings, token, address, language) and a **Drift (SQLite) cache** of API responses, so screens load instantly and refresh in the background.
- Every API call sends headers: auth token, `zoneId` list, latitude/longitude of the chosen address, and the language code. The server uses these to filter results by zone and translate texts.
- App identity: name **Paustik Poornahar**, package `com.poornaahar.customer`, Firebase project `paushtikpoornaahar-576be`, version 1.0.

The 33 feature folders are: address, auth, business, cart, category, chat, checkout, coupon, cuisine, dashboard, dine_in, favourite, home, html, interest, language, location, loyalty, menu, notification, onboard, order, product, profile, refer_and_earn, restaurant, review, search, splash, support, update, verification, wallet.

## 1.2 App start flow (splash)

1. **Firebase starts** (push notifications, phone auth). On Android/web the Firebase options are in `main.dart`.
2. **Config is downloaded** from `/api/v1/config` (`SplashController.getConfigData`). It contains business name, logo, currency, all feature switches, payment methods, login options, zones, app minimum versions, maintenance mode and more. It is cached per app version.
3. **Blocking checks** (`splash_route_helper.dart`):
   - If `app_minimum_version_android/ios` is higher than the app's `appVersion` → **Update screen** ("please update the app").
   - If maintenance mode is on for the customer app → **Maintenance screen**.
4. **If the app was opened from a push notification**, it jumps straight to the right place:
   - order notification → order details
   - chat message → chat screen
   - account blocked/unblocked → sign-in
   - wallet top-up, referral earning, cashback → wallet
   - anything else → notification list
5. Otherwise it decides the first screen:
   - **Logged-in user** → refreshes the push token, loads favourites, then goes **home** if an address is saved, else to **location access**.
   - **First launch** → **language picker** (if more than one language) → **onboarding slides**.
   - **Returning guest** → home (or location screen if no address).
   - **Nobody yet** → the app silently creates a **guest id** (`auth/guest/request`) so a cart can exist, then continues as a guest.
6. **Deep links** (`paustikpoornahar://` scheme) open a restaurant or food directly.
7. On web a **cookie consent** bar appears (text set by admin); acceptance is remembered.

## 1.3 Location, zones and addresses

- **Access location screen**: asks for location permission. Options: use current GPS location, pick on map, or choose a saved address (if logged in).
- **Pick map screen**: drag the map pin or search a place (Google Places autocomplete via `config/place-api-autocomplete` and `config/place-api-details`; address text via `config/geocode-api`).
- **Zone check**: the chosen point is sent to `config/get-zone-id`. If it is outside every zone the app says the area is not covered and you cannot continue. If inside, the zone ids are saved and sent with every request.
- **Address book** (`address` feature, logged-in users): list, add, edit, delete, **set default**. Each address has a type (home, office, other), contact name and phone, road, house, floor, and map point. New addresses are also zone-checked.
- The **suggested location** banner on the dashboard offers to switch to your current position if you moved.

## 1.4 Account and login

The admin decides which login methods exist (`login-settings`): **manual** (phone/email + password), **OTP** (phone code), and **social** (Google, Apple; Facebook was removed from this app). Guest checkout can be allowed.

- **Sign up**: name, phone (with country picker), email, password, optional **referral code**. After sign-up the phone and/or email may need **verification** depending on settings.
- **Sign in**: phone or email + password, with "remember me". Or OTP login: enter phone, receive a code (by the configured SMS gateway **or** Firebase phone auth), enter the code.
- **Social login**: Google (and Apple on iOS). If the email already belongs to an account, an **"existing user" sheet** asks to link it. New social users go to the **new user setup** screen to add name/phone.
- **Verification screens**: verify phone or email by code; Firebase OTP is used when "Firebase OTP" is enabled in admin.
- **Forgot password**: enter phone/email → receive code → verify → set **new password**.
- **Login suggestion sheet**: guests are gently shown a login prompt (can be dismissed).
- **Profile**: view info (name, phone, email, image, order count, wallet, loyalty points, member since), **update profile** (image, name, email), **change password**, **delete account** (`customer/remove-account`).
- **Interest screen**: after sign-up, choose favourite food categories; used for suggestions (`customer/update-interest`).
- **Logout** clears token, cart and social sessions.

## 1.5 Home screen

The home screen (and a separate **web home** layout, plus an alternative **theme1** home) is built from sections, each one controlled by admin settings and zone:

| Section | Source |
|---|---|
| **Banners** (slider) | `banners` — admin/zone banners linking to a restaurant or food |
| **Categories** | `categories` |
| **Cuisines** | `cuisine` |
| **Advertisements** | `advertisement/list` — paid restaurant ads (image/video/profile promotion) |
| **Cashback offers** | `cashback/list` — shown when active |
| **Popular foods near you** | `products/popular` |
| **Best reviewed foods** | `products/most-reviewed` |
| **Food campaigns / basic campaigns** | `campaigns/item`, `campaigns/basic` |
| **New on Paustik Poornahar** (latest restaurants) | `restaurants/latest` (shown if `new_restaurant` is enabled) |
| **Popular restaurants** | `restaurants/popular` |
| **Order again** | `customer/order-again` |
| **Visit again / recently viewed restaurants** | `restaurants/visit-again`, `restaurants/recently-viewed-restaurants` |
| **Dine-in restaurants** | `restaurants/dine-in` |
| **Refer & earn banner** | if referral is on |
| **All restaurants** (with filters) | `restaurants/get-restaurants/{filter}` |

- **Map view** shows nearby restaurants as pins.
- Sort order of every list is set by the admin in **Priority setup** (e.g. show open restaurants first, hide temporarily closed ones).
- Pull-to-refresh reloads everything.

## 1.6 Browsing food and restaurants

### Categories and cuisines
- Category screen → sub-categories → **products** tab and **restaurants** tab for that category, with filters (veg/non-veg, top rated, discounted, sorting).
- Cuisine screen → restaurants of that cuisine, with its own search.

### Restaurant list and filters
- All restaurants, popular, latest, dine-in list. Filters: veg, non-veg, top rated, discounted, open now, free delivery, rating, distance, sort options.

### Restaurant page
- Cover, logo, name, rating and review count, distance, delivery time range, minimum order, delivery fee / free delivery, **open or closed** (based on the restaurant's weekly schedule, "temporarily closed" switch and `active` status), halal badge, announcement message, characteristics/tags.
- **Coupons** available for the restaurant (`restaurants/get-coupon`).
- **Recommended items** and **set menu** items.
- **Menu by category** with pagination, and **search inside the restaurant**.
- **Reviews** tab and restaurant info (address, schedule, map).
- Share restaurant link.

### Food details (bottom sheet)
- Images, name, description, price, discount, rating, veg/non-veg, halal, **nutrition** and **allergy** info, available time window.
- **Variations**: each variation can be required or optional, single or multiple choice, with min/max selection. Each option has its own price and may have its own **stock**.
- **Add-ons**: extra items with quantity.
- **Quantity**, limited by the food's `maximum_cart_quantity` and by stock.
- Out-of-stock foods or options cannot be added.
- **Related foods** and reviews (`products/related-products`, `products/reviews`).
- Add to favourites (heart).

### Campaigns
- **Basic campaign**: a campaign page listing the restaurants that joined it.
- **Item (food) campaign**: special campaign foods with their own price, orderable directly.

### Popular foods screen
- Full list of popular / best-reviewed foods.

### Search
- Search foods **and** restaurants together (`products/food-or-restaurant-search`, `products/search`, `restaurants/search`).
- **Suggestions** while typing and **suggested foods** for the user.
- **Voice search** (speech-to-text): speak, it fills the box and auto-submits.
- **Search history** saved locally (remove single / clear).
- **Filters**: veg, non-veg, available now, new arrival, popular, discounted, free delivery, open restaurants, rating, price range (slider), cuisine, sort by (price, rating, etc.), order type (delivery/take-away) — separately for foods and restaurants. Reset filters.

## 1.7 Cart

- **One restaurant per cart**: adding food from another restaurant asks to clear the cart.
- Cart is stored **online** for both users and guests (`customer/cart/*`), so it follows the user across devices. Items keep their variations and add-ons.
- Change quantity, remove items, remove add-ons, clear cart.
- **Cutlery**: toggle "I need cutlery".
- **Extra packaging**: restaurants can charge optional or mandatory packaging (`extra_packaging_charge`); the cart shows the toggle.
- **Suggested items from the same restaurant** ("you may also like").
- **Reorder**: an old order can be put back into the cart.
- **Abandoned cart reminder**: if the cart is left, the server can send a push reminder (`cart:reminder` command).
- **Buy now**: a single item can go straight to checkout without touching the cart.

## 1.8 Checkout and placing an order

### Choices on the checkout screen
1. **Order type**: Delivery, Take away, or Dine in. Only the types enabled by admin (`home_delivery`, `take_away`, `dine_in_order_option`) **and** by the restaurant appear.
2. **Delivery address**: pick a saved address or type one (guests enter name, phone, email and address). The address must be inside the restaurant's zone.
3. **Time**: order **now** (if `instant_order` is on) or **schedule** for later using time slots (`schedule_order`, slot length from `schedule_order_slot_duration`, how many days ahead from `customer_order_date`). Slots respect the restaurant's opening hours. Dine-in asks for a **date and estimated arrival time**.
4. **Delivery option** (if the zone has "additional delivery options"): **standard**, **express** (extra fee), or **slightly delay / saver** (discounted fee, admin pays the difference as an expense).
5. **Delivery instructions** (preset list) and an **order note**.
6. **If an item is unavailable** preference (e.g. "call me", "remove it").
7. **Delivery-man tip** (if `dm_tips_status` is on): quick amounts, "most tipped" suggestion (`most-tips`), or custom.
8. **Coupon**: see available coupons or type a code; the server validates it (`coupon/apply`).
9. **Subscription order** (if `order_subscription` is on and the restaurant allows it): choose **daily / weekly / monthly**, days and time for each delivery, start and end dates. One order is placed; deliveries repeat on those days.
10. **Payment method**, see below.
11. **Bring change for**: for cash on delivery, the customer can say which note they will pay with.

### Price breakdown shown
Item price + add-ons − discounts (restaurant discount, admin discount, coupon, **new-customer discount** from referral settings) + **tax/VAT** (calculated by the server via `customer/order/get-Tax`, order-wise or product-wise/category-wise from the Tax module) + **delivery charge** + **additional charge** (a service fee with a custom name, if enabled) + **extra packaging** + **tip** = total. The screen also shows cashback you will get.

### Payment methods
- **Cash on delivery**: allowed if enabled in payment setup; blocked above the **maximum COD amount** of the zone.
- **Digital payment**: opens the payment page in a web view (`/payment-mobile`) with the chosen gateway (Stripe, Razorpay, PayPal, Paystack, Flutterwave, SSLCommerz, bKash, Paytm, LiqPay, Paymob, PayTabs, MercadoPago, SenangPay, PhonePe, Iyzico, Xendit — whichever the admin enabled). After paying, the gateway returns to success or fail pages and the app shows the result.
- **Wallet**: pays fully from the in-app wallet if the balance is enough.
- **Partial payment**: uses the whole wallet balance first, the rest with COD, digital or offline (`partial_payment_method` decides which are allowed).
- **Offline payment**: choose one of the admin's offline methods (e.g. bank transfer), see its instructions, fill in the required fields (transaction id, sender name, etc.). The admin verifies it later.

### What the server checks before accepting (`order_validation_check`)
Restaurant open and active; schedule time valid; payment method enabled; order type enabled; guest allowed; address inside a zone; single restaurant in cart; each food belongs to that restaurant; maximum cart quantity; stock of food, variations and add-ons; **minimum order amount** of the restaurant; enough wallet balance; partial payment only if wallet is lower than total; maximum COD amount. Any failure returns a clear error message the app shows.

### What happens when it is accepted
- The order is saved with status **pending**, or **confirmed** if it was paid by wallet/partial payment.
- `payment_status` = `unpaid`, `paid` or `partially_paid`.
- Wallet money is deducted (wallet transaction), partial payments are recorded as two payment rows.
- Coupon usage, new-customer discount, and tax lines are saved; the cart is cleared.
- Notifications go to the restaurant (and admin, if `admin_order_notification` is on).
- The app shows the **Order successful** screen with the order id, and for guests a tracking link.

## 1.9 After the order

### Orders screen
- Tabs: **running orders**, **subscription orders**, **history**. Guests can **track an order** by order id + phone number.

### Order details and tracking
- Items, prices, address, payment info, restaurant and delivery man contact.
- **Status steps** (see status table in Part 2): placed → confirmed/accepted → preparing (processing) → ready for handover → out for delivery (picked up) → delivered. Take-away and dine-in skip the delivery steps.
- **Live tracking map** with the delivery man's position (the DM app sends locations to `delivery-man/record-location-data`; the customer app polls `customer/order/track` on a timer).
- **Delivery verification OTP**: if `order_delivery_verification` is on, the customer sees a code and must tell it to the delivery man.
- **Order proof** photos uploaded by the delivery man.
- **Call / chat** with the restaurant or delivery man.
- **Invoice** view.

### Cancel
- Allowed only while the order is **pending** (not after the restaurant confirms). A **cancellation reason** is required (list set by admin).
- If something was already paid and wallet refunds are on, the paid amount goes back to the **wallet**; otherwise the customer is told to contact admin.

### Payment problems
- **Switch to cash on delivery** if an online payment failed (`customer/order/payment-method`).
- **Edit offline payment info** if the admin rejected it.

### Refund
- Allowed only for **delivered and paid** orders, and only if refunds are enabled (`refund_active_status`).
- Pick a **refund reason**, write a note, attach **images**. Refund amount = order amount minus delivery charge and tip.
- The admin approves or rejects it (see Part 2). Approved refunds go to the wallet (if `refund_to_wallet`) or are paid manually.

### Reviews
- After delivery, rate each **food** (stars + comment + image) and the **delivery man**. A **pending reviews** prompt reminds the user (`customer/getPendingReviews`).
- Restaurants can **reply** to reviews; replies are shown.

### Subscription orders
- See the schedule, **delivery logs** (each day's delivery and its status) and **pause logs**.
- **Pause** for a date range, **cancel**, or **edit the schedule** (`customer/subscription/*`).
- Each delivered day adds to the subscription's billed amount; if more was paid than billed, the extra goes to the wallet when it ends.

### Order again
- One tap re-adds a past order to the cart (items that are still available).

## 1.10 Wallet, loyalty, referral, cashback

- **Wallet** (if `wallet_status` is on): balance, transaction history with filters (order payments, refunds, add fund, loyalty conversion, referral earnings, cashback, admin top-ups), **add fund** by digital payment (minimum `customer_add_fund_min_amount`), and **wallet bonuses** (e.g. "add 1000, get 50 extra") shown as offers.
- **Loyalty points** (if `customer_loyalty_point` is on): earn a % of each order's value as points (`item_purchase_point`), view history, and **convert points to wallet money** at the exchange rate (`loyalty_point_exchange_rate`) once you have at least `minimun_transfer_point`.
- **Refer & earn** (if `ref_earning_status` is on): share your referral code. When a new user signs up with it and completes their first order, the referrer receives wallet money (`ref_earning_exchange_rate`). The new user can also get a **new-customer discount** on their first orders (amount or %, with a validity period).
- **Cashback**: admin offers (percentage or fixed, minimum purchase, maximum cashback, per-user limit, date range). The app shows the offer at checkout; after the order is **delivered** the cashback is added to the wallet.

## 1.11 Other features

- **Coupons screen**: all coupons the user can use, copy code.
- **Favourites**: saved restaurants and foods; remove one or clear all.
- **Notifications**: list of notifications, unread badge, clear all.
- **Chat / inbox**: conversations with **restaurants**, **delivery men** and **admin support**. Send text, **images, videos, files and PDFs**, emoji picker, search conversations, download attachments. New messages arrive by push and refresh the chat.
- **Support screen**: business phone, email and address with call/mail buttons.
- **Legal pages** (HTML viewer): Terms and conditions, Privacy policy, Refund policy, Shipping policy, Cancellation policy, About us — each text is written in the admin panel.
- **Menu / settings**: language, **dark mode**, notification toggle, links to all pages, logout.
- **Language**: switch app language (English, Arabic with right-to-left layout, Bengali, Spanish; more can be added in admin).
- **Newsletter**: subscribe with email (web footer).
- **Join as a restaurant** (restaurant registration): restaurant name and address in several languages, logo, cover, zone, map location, estimated delivery time, cuisine, tax info (TIN, expiry, certificate), owner details, login email and password, and any **extra fields** the admin added to the "join us" page. Then choose a **business plan**: commission, or a **subscription package** (pay now online, pay later, or free trial). The restaurant then waits for admin approval.
- **Join as a delivery man**: name, phone, email, password, image, **type** (freelancer or salary based), zone, **vehicle**, identity type and number and photos, preferred **shifts**, plus admin-defined extra fields. Waits for admin approval.
- **Update screen / maintenance screen** as described in 1.2.
- **Push notifications** (Firebase): order status changes, chat messages, account block/unblock, wallet top-ups, referral earnings, cashback, promotional pushes from admin, demo reset notice. On Android they use the "Paustik Poornahar" notification channel with a custom sound.
- **Web-only**: web home layout, cookie bar, hosted payment pages, SEO meta data from the backend (`get-page-meta-data`), and an optional separate React website (`useReactWebsite`).

---

# PART 2 — BACKEND

## 2.1 Technology and structure

- **Laravel 12, PHP 8.2+, MySQL**. Folder `backend/`.
- Three front doors in one application:
  - **Admin panel** (`routes/admin.php`, about 720 routes) — Blade pages.
  - **Restaurant panel** (`routes/vendor.php`, about 230 routes) — Blade pages.
  - **REST API** (`routes/api/v1/api.php`) — JSON for the customer, restaurant and delivery-man apps.
- Plus **web routes** (`routes/web.php`): home/landing page, policy pages, restaurant and delivery-man web sign-up, and **payment pages and callbacks** for every gateway.
- **Authentication**:
  - Admins and admin employees: session login (`admin` guard), with custom login URLs and optional reCAPTCHA or built-in captcha.
  - Restaurant owners and employees: session login (`vendor`, `vendor_employee` guards).
  - Customers: **Laravel Passport** tokens (`auth:api`); guests: a guest id.
  - Restaurant app and DM app: their own API tokens (`vendor.api`, `dm.api` middleware).
- **Business logic** lives mostly in `app/CentralLogics/` (`Helpers`, `OrderLogic`, `CustomerLogic`, `RestaurantLogic`, `ProductLogic`, `CouponLogic`, `CategoryLogic`, `BannerLogic`, `CampaignLogic`, `SMS_module`) and `app/Traits/` (order placing, payments, SMS gateways, notifications, reports).
- **Modules**: `AI` (OpenAI helpers) and `TaxModule` (VAT/tax engine). Payment/SMS gateway packs can be uploaded as **system addons**.
- **Settings storage**: almost every switch is a row in `business_settings` or `data_settings`; the admin panel edits them and the API sends them to apps.
- **Files**: images are stored on the `public` disk (`storage/app/public`), or on **Amazon S3** if chosen in "storage connection".
- **Languages**: English, Arabic, Bengali, Spanish translation files, plus database translations for content (food names, restaurant names in several languages).

### Deployment (current)
- Hosted on **Railway**: project `paustik-poornahar`, service `backend` built from `backend/Dockerfile` (PHP 8.3 + Apache serving `public/`), a **MySQL** service, and a **volume** for uploaded images.
- Configuration comes from Railway variables (no `.env` in the repo).
- On first start, `docker/railway-init.php` imports the seed database, creates the admin from `ADMIN_EMAIL`/`ADMIN_PASSWORD`, copies the default images, and applies the brand logo from `installation/branding/logo.png` (once per new logo file).
- Code lives on GitHub (`nexorytechnologies2026-collab/paustikpoornahar-new`); the service builds from the `/backend` folder.
- The original 6amtech licence check and web installer have been removed; the app always runs in "installed" mode.

## 2.2 Main data (what is stored)

| Area | Main tables / models |
|---|---|
| Places | `zones` (polygon, charges, payment methods, delivery options), `zone_delivery_options` |
| Restaurants | `restaurants`, `vendors` (owners), `vendor_employees`, `employee_roles`, `restaurant_schedules`, `restaurant_configs`, `restaurant_wallets`, `restaurant_subscriptions`, `restaurant_zones`, `characteristics`, `cuisines`, `restaurant_tags` |
| Menu | `categories` (with sub-categories), `foods`, `variations` + `variation_options`, `add_ons` + `addon_categories`, `attributes`, `nutritions`, `allergies`, `food_tags`, `food_seo_data`, `item_campaigns` |
| Customers | `users`, `customer_addresses`, `wishlists`, `carts`, `guests`, `user_infos`, `recent_searches`, `visitor_logs` |
| Orders | `orders`, `order_details`, `order_payments`, `order_transactions`, `order_delivery_histories`, `order_edit_logs`, `order_cancel_reasons`, `refunds` + `refund_reasons`, `offline_payments`, `subscriptions` + `subscription_schedules` + `subscription_logs` + `subscription_pauses` |
| Money | `admin_wallets`, `restaurant_wallets`, `delivery_man_wallets`, `wallet_transactions` (customer), `loyalty_point_transactions`, `account_transactions`, `withdraw_requests`, `withdrawal_methods`, `disbursements` + `disbursement_details`, `expenses`, `wallet_payments`, `cash_backs` + `cash_back_histories`, `wallet_bonuses` |
| Delivery | `delivery_men`, `delivery_man_wallets`, `vehicles`, `shifts`, `incentives` + `incentive_logs`, `provide_d_m_earnings`, `track_deliverymen`, `time_logs`, `d_m_reviews` |
| Marketing | `banners`, `campaigns` (basic), `item_campaigns`, `coupons`, `advertisements`, `notifications`, `newsletters` |
| Content | `business_settings`, `data_settings`, `email_templates`, `notification_messages`, `notification_settings`, `social_media`, `translations`, `page_seo_data`, `react_*` landing tables, `admin_*` landing tables |
| Business plans | `subscription_packages`, `restaurant_subscriptions`, `subscription_transactions`, `subscription_billing_and_refund_histories` |
| Communication | `conversations`, `messages`, `user_notifications`, `contact_messages` |

## 2.3 The order lifecycle (heart of the system)

### Statuses

| Status | Meaning | Who sets it |
|---|---|---|
| `pending` | Just placed, waiting for confirmation | System |
| `confirmed` | Confirmed (automatically for wallet/partial payments, or by restaurant/DM/admin) | Restaurant, DM or admin, depending on `order_confirmation_model` |
| `accepted` | A delivery man has accepted the order | Delivery man / admin assigns |
| `processing` | Restaurant is cooking (with a cooking time) | Restaurant |
| `handover` | Food is ready to hand over | Restaurant |
| `picked_up` | Delivery man picked it up ("out for delivery") | Delivery man |
| `delivered` | Delivered (or picked up / served for take-away and dine-in) | Delivery man, or restaurant for self-delivery, take-away, dine-in |
| `canceled` | Cancelled by customer, restaurant, DM or admin (with reason) | Various, if allowed |
| `failed` | Digital payment failed | System |
| `refund_requested` | Customer asked for refund | Customer |
| `refunded` | Refund approved | Admin |
| `refund_request_canceled` | Refund rejected | Admin |

### Step by step (home delivery)
1. **Placed** by the customer app, POS, or admin/restaurant on behalf of a customer. Status `pending` (or `confirmed` if prepaid by wallet).
2. **Restaurant is notified** (push to restaurant app, sound in panel, optional email).
3. **Confirmation**: `order_confirmation_model` decides whether the **restaurant** or the **delivery man** confirms. The restaurant can set a **processing time**.
4. **Delivery man assignment**:
   - For platform delivery, nearby available DMs in the zone get the order in "latest orders" and can **accept** it; a DM can hold at most `dm_maximum_orders` orders.
   - Admin can **assign** a DM manually from **Dispatch** (list of unassigned orders).
   - Restaurants with **self-delivery** assign their own delivery men (restaurant app/panel).
   - A DM whose **cash in hand** is over the limit (`dm_max_cash_in_hand`, if `cash_in_hand_overflow_delivery_man` is on) cannot take new orders until they pay it in.
5. **Cooking** → `processing` → `handover`.
6. **Pick up** → `picked_up`. The DM app streams its location; the customer sees it on the map.
7. **Delivery** → `delivered`. If `order_delivery_verification` is on, the DM must enter the customer's **OTP**. The DM can upload **proof photos**. For cash orders the DM marks payment collected.
8. **On delivery the money is split** (`OrderLogic::create_transaction`) — see 2.4. Loyalty points and cashback are credited, referral rewards checked, DM incentive checked.
9. **Reviews** open for the customer.

### Variations of the flow
- **Take-away**: no DM; restaurant marks it delivered when the customer collects it.
- **Dine-in**: no DM; restaurant can set a **table number** (`add-dine-in-table-number`) and marks it served/delivered.
- **Scheduled orders**: stay "scheduled" until their time; restaurants and admin see them in a scheduled list.
- **Subscription orders**: one parent order + a subscription. Each day a **subscription log** is created for that day's delivery (`Helpers::create_subscription_order_logs`, only if the restaurant is open at the chosen time). Status changes are recorded per day; on each delivery the subscription's billed amount grows. Customers can pause or cancel; admin sees all subscription orders, their logs and pauses, and can edit them.
- **POS orders**: made at the counter by the restaurant or admin (see 2.7), paid immediately.
- **Order editing**: if `can_restaurant_edit_order` is on, the restaurant (and admin) can add or remove items or change quantities before delivery. Every edit is kept in `order_edit_logs` and the customer is notified. Admin can also change the delivery address and the schedule.
- **Cancellation by restaurant or DM** is allowed only if `canceled_by_restaurant` / `canceled_by_deliveryman` are on, with a reason. Paid amounts can be refunded to the customer wallet.
- **Failed digital payments** keep the order as `failed`; the customer can switch to COD.
- **Offline payments**: the order waits in "offline payment verification" until admin **verifies** (order continues) or **denies** (customer can edit the info).
- **Refunds**: customer requests → admin sees it under **Refund requests** → **approve** (status `refunded`, money back to wallet if `refund_to_wallet`, restaurant and admin shares reversed) or **reject** with a note (`refund_request_canceled`). Refund reasons are managed in settings.

## 2.4 Money flows

### Commission and earnings on each delivered order
`OrderLogic::create_transaction` works out:
- **Order amount** without delivery charge, tax, tip, additional charge and extra packaging.
- **Admin commission** = restaurant's commission % (or the global `admin_commission`) of that amount — only for **commission-model** restaurants. Subscription-model restaurants pay no commission.
- **Commission on delivery charge** (`delivery_charge_comission`) when the platform's DMs deliver.
- **Restaurant earning** = order amount + tax + extra packaging − commission − the restaurant's own discounts and coupons.
- **Delivery man earning** = delivery charge (minus the platform's cut) + **tips**. Salary-based DMs don't earn per order.
- **Admin expenses** are recorded when the admin pays for something: free delivery, admin coupons, admin discounts, the saver ("slightly delay") delivery discount, cashback. **Restaurant expenses** are recorded when the restaurant pays for free delivery or its own coupons.
- Everything is written into the **order transaction** and the **admin, restaurant and DM wallets**.

### Cash handling
- When a DM or restaurant collects cash, that money is "**cash in hand**" and counts against their wallet.
- They pay it to the admin through **collect cash** (admin records it) or pay online from the app (`make-collected-cash-payment`).
- **Wallet adjustment** lets them settle cash in hand against the earnings the platform owes them.
- Limits: `min_amount_to_pay_dm` / `min_amount_to_pay_restaurant`, and cash-in-hand overflow blocking.

### Payouts
- **Withdraw requests**: restaurants and DMs request a payout to one of their saved **withdraw methods** (the admin defines the method types and their fields). Admin approves or denies.
- **Automatic disbursements** (`disbursement_type`): the system creates payout lists for restaurants and DMs on a schedule (daily/weekly/monthly, with minimum amount and waiting time). They run as cron commands `restaurant:disbursement` and `dm:disbursement`. Admin reviews each disbursement and marks items paid.
- **Provide DM earning**: admin can pay out a DM's earnings manually and record it.
- **Account transactions**: a log of every cash collection and payment between admin, restaurants and DMs.

### Restaurant business plans (subscription packages)
- Admin creates **packages**: price, validity (days), limits (maximum orders, maximum products), and which features are included (POS, mobile app, self-delivery, chat, reviews). Packages can be enabled or disabled.
- **Free trial** can be switched on with a trial period (`trialStatus`).
- A restaurant picks a package at sign-up or later; pays online, from its wallet, or starts a trial. When it runs out it must renew, or it can **switch back to commission**. Admin can also switch or cancel plans.
- Admin sees subscribers, their transactions and invoices, and a package overview. A restaurant can check its limits (`check-product-limits`).

### Customer money
- **Wallet**: filled by digital top-ups (with **bonus** rules), refunds, loyalty conversion, referral rewards, cashback, subscription surplus, and admin **add fund**. Spent on orders.
- **Loyalty points**, **referral**, **new-customer discount** and **cashback**, as explained in 1.10.

## 2.5 Admin panel — every section

### Dashboard
- Stats by **zone** and period: orders by status, total sales, admin commission, delivery charge earnings, restaurant and DM counts, new customers.
- Charts: business overview, order statistics, user overview.
- Top restaurants, top foods, top rated foods, top customers, top delivery men. Links into the order lists.

### POS (point of sale)
- Pick a restaurant, search and add foods (with variations and add-ons) to a cart.
- Choose or **create a customer**, choose or add a delivery address, set order type (take-away, delivery, dine-in) and **delivery type**, apply **discount**, **tax**, **extra charge**.
- Take payment (cash, card, wallet) and place the order; print the invoice. See POS order history.

### Orders
- Lists by status: all, scheduled, pending, accepted, processing, food on the way, delivered, cancelled, payment failed, refunded, refund requested, offline payments, dine-in, subscription orders.
- Filters (zone, restaurant, date, order type), search and **export** (Excel/CSV).
- **Order details**: change status, **assign a delivery man**, change payment status, add **payment reference code**, add or remove **order proof** images, **edit the order** (add or remove foods), **edit the delivery address**, **change the schedule**, set a **dine-in table number**, print or **generate the invoice**, see the edit log.
- **Dispatch**: orders still waiting for a delivery man, by zone.
- **Refund requests**: approve or reject.
- **Offline payment verification** list: verify or deny.
- **Subscription orders**: list, details, day logs, pause logs (delete a pause), change status, edit.

### Restaurants
- **Add restaurant** (all the details of the app sign-up, plus commission % and business plan).
- **List** with filters and export; **bulk import / export** by spreadsheet.
- **New joining requests**: pending and denied applications → approve or deny.
- **Restaurant details** tabs:
  - overview (earnings, orders, wallet)
  - orders, foods, reviews
  - **discount** (restaurant-wide discount with min and max and dates)
  - **settings**: enabled order types, self-delivery, free delivery, free delivery by distance, minimum order, delivery time, veg/non-veg, cutlery, extra packaging, halal, scheduled orders, instant orders, subscription orders, reviews on/off, POS on/off, chat on/off, **commission %**, tax, **schedule**, temporarily closed
  - **transactions** (cash, digital, withdraw)
  - **business plan**, **conversations**, **meta/SEO data**, **QR code**
- **Withdraw requests** of restaurants.
- **Messages**: read restaurants' conversations.

### Food management
- **Categories** and **sub-categories** (image, priority, status, multilingual names, bulk import/export).
- **Attributes** (used to build variations).
- **Add-on categories** and **Add-ons** (price, stock, restaurant).
- **Foods**: add or edit with multilingual name and description, images, category and sub-category, **variations** (required/optional, single/multiple, min/max, option prices, **option stock**), add-ons, price, **discount** (amount or %), **available time from/to**, veg/non-veg, **halal**, **nutrition**, **allergies**, tags, **stock type** (unlimited, daily, limited), **maximum cart quantity**, recommended flag, SEO data. The **AI module** can fill in title, description, variations, prices and SEO from a name or an image.
- **Stock-out list** and **update stock**; **bulk import / export**; **food reviews** (list, status, export).
- **Cuisines**: add, edit, status.

### Promotions / marketing
- **Campaigns**:
  - **Basic campaign**: title, dates, times, image; restaurants join or are added, admin confirms or removes them.
  - **Food campaign**: special items with their own price, stock and dates.
- **Banners**: zone-wise, link to a restaurant or a single food (`restaurant_wise` / `item_wise`), plus a **promotional banner**.
- **Coupons**: types `default`, `first_order`, `free_delivery`, `zone_wise`, `restaurant_wise`; discount **amount or percent**, minimum purchase, maximum discount, per-user **limit**, start/end dates, optionally for chosen customers. Created by admin (or by restaurants for themselves).
- **Cashback offers**: percentage or amount, minimum purchase, maximum cashback, same-user limit, dates, optional customer.
- **Advertisements**: restaurants request **restaurant promotion** or **video promotion** ads with dates. Admin reviews the requests, **approves or denies**, sets **paid status**, sets **priority**, edits dates, copies ads, and can create ads directly.
- **Push notifications**: send to **customers, restaurants, delivery men or everyone** in a zone, with title, text and image; resend or delete.
- **Marketing / analytics**: add tracking scripts (Google Analytics, Meta Pixel and similar) and switch them on or off.

### Customers
- **Customer list** (block/unblock), **customer details**: orders, addresses (add or edit), wish-list, reviews, **loyalty point** history, **referral** history, **wallet history**, top items, visitor logs.
- **Customer overview** analytics: onboarding stats, order stats, top customers.
- **Wallet**: **add fund** to any customer, **wallet report**, and **bonus** rules for top-ups.
- **Loyalty point report**.
- **Newsletter subscribers** (list and export).
- **Contact messages** from the website "contact us" form: read, reply by email, delete.
- **Customer settings**: wallet, refund to wallet, add fund, loyalty points, referral earnings, new-customer discount, guest checkout.

### Delivery men
- **Add** a delivery man (type **freelancer** earning per order or **salary based**, zone, vehicle, identity documents, shift, login), **list**, **new applications** (approve or deny), **edit**, block, delete, export.
- **Details**: orders, earnings, **wallet/cash in hand**, reviews, conversations, disbursements.
- **Reviews** of delivery men.
- **Vehicles**: vehicle types with a starting and maximum coverage distance and an **extra charge** added to the delivery fee.
- **Shifts**: working shifts DMs pick.
- **Incentives**: earning targets (set per zone in zone settings) that pay a bonus; requests and history of incentives paid.
- **Bonus**: add bonus to a DM.
- **Provide earnings** and **DM disbursements**.
- **Messages**: read DM conversations.

### Employees
- **Custom roles** (choose which admin sections the role can access), **employees** (assign a role and zone), export.

### Zones
- **Draw zones** on the map, set a default zone, enable/disable.
- **Zone settings**: per-km delivery charge, minimum and maximum delivery charge, **increased delivery fee** (e.g. during rain, with a message shown to customers), **maximum COD amount**, **additional delivery options** (express with extra charge and shorter delivery time, slightly delay/saver with reduced charge and longer time, plus standard), minimum delivery time, and **delivery-man incentives** (earning targets and bonus) for the zone.

### Transactions and reports
- **Transaction report**, **order report**, **food-wise report**, **restaurant report**, **campaign order report**, **day-wise report**, **expense report**.
- **Admin earning report** (summary, breakdown, expenses, monthly, zone-wise, top earning restaurants, transactions).
- **Restaurant earning report** and **delivery-man earning report** (summary, breakdown, expenses, trends, transactions).
- **Disbursement report**, **subscription report**, **tax reports** (vendor-wise taxes, admin tax report).
- **Customer wallet report**, **loyalty point report**, **generate statements** (PDF) for a restaurant or subscription.
- Everything can be filtered by zone, restaurant and date and exported.

### Business settings (business setup tabs)
- **Business info**: name, logo, favicon, email, phone, address, country, map location, timezone, time format, currency and symbol position, decimal digits, **admin commission %**, **commission on delivery charge**, **additional charge** (name, amount, on/off), footer text, cookies text, country picker.
- **Maintenance mode**: turn on for chosen parts (admin panel, restaurant panel, customer app, website, restaurant app, DM app, React website), with duration or start/end dates and a message.
- **Order settings**: home delivery / take-away / **dine-in** on or off, **instant order**, **scheduled orders** and slot duration, how many days ahead a customer can order, **order subscription**, **repeat order**, **order confirmation model** (restaurant or DM), **delivery verification OTP**, restaurants can **edit orders**, cancellation by restaurant or DM, **admin order notifications** (sound, and firebase or manual refresh), **free delivery** by admin (for all restaurants, or over an amount / within a distance), **order cancellation reasons** (per user type, multilingual).
- **Restaurant settings**: self-registration, review replies, **extra packaging charge**, cash-in-hand overflow limit, minimum amount to pay.
- **Delivery-man settings**: self-registration, **tips**, show earnings in app, max orders at once, picture upload, max cash in hand, minimum amount to pay.
- **Customer settings**: see Customers.
- **Food settings**: veg/non-veg on or off.
- **Priority settings**: how every list is sorted and whether closed or unavailable items are shown.
- **Disbursement settings**: manual or automatic, periods, minimum amounts, waiting days, PHP path for cron.
- **Payment setup**: cash on delivery, digital payment, offline payment, partial payment and which methods can be combined.
- **Refund settings**: refund on/off, refund reasons.

### Pages, media and landing pages
- **Pages**: Terms and conditions, Privacy policy, Refund policy, Shipping policy, Cancellation policy, About us (each with on/off where relevant).
- **Social media links**.
- **Admin landing page** (the default website): header, about us, features, services, why choose us, earn money, testimonials, available zones, fixed texts, links, background colour, meta data, or upload a fully **custom landing page**.
- **React landing page** (for the optional React website): header, categories, services, promotional banners, testimonials, FAQ, gallery, download-app section, earn-money section, registration section, stepper, location picker, available zones, meta data.
- **Registration page** content: hero, stepper, opportunities, FAQs.
- **Join-us page setup** for restaurant and delivery-man registration: add custom extra fields (text, number, date, file, checkbox).

### 3rd-party and configuration
- **Payment methods**: turn each gateway on or off, test or live mode, keys, logo and title.
- **Offline payment methods**: name, payment information to show, and the fields customers must fill in.
- **SMS module**: Twilio, Nexmo/Vonage, 2Factor, MSG91, and many more; choose one active gateway.
- **Mail config** (SMTP) with a test mail.
- **Firebase**: service account for push (FCM), **push message templates** for every event (order placed, confirmed, processing, handover, picked up, delivered, cancelled, refund, etc.), and **Firebase OTP** settings.
- **Map API keys** (client and server) for Google Maps.
- **reCAPTCHA** (for admin and restaurant logins).
- **Social login**: Google, Apple (and Facebook, not used in this app).
- **Storage connection**: local or Amazon S3.
- **OpenAI**: API key and on/off for the AI module, plus AI settings.
- **Email templates**: design every automatic email (for admin, restaurants, delivery men, customers), with logo, title, body, button, footer and on/off per template.
- **Notification settings**: for each event and each user type (customer, restaurant, delivery man), choose push / mail / SMS on or off.
- **Login setup**: which login methods customers have (manual, OTP, social) and whether email/phone verification is required. **Login URLs**: custom secret paths for admin, admin-employee, restaurant and restaurant-employee login pages.
- **App settings**: minimum app versions for Android and iOS (customer, restaurant, DM apps) and store links.
- **Invoice setup**: invoice logo and footer text.

### System
- **Languages**: add languages, set default, enable/disable, **translate every text** in the admin panel (with **auto-translate** by Google), direction LTR/RTL.
- **System addons**: upload and publish payment/SMS gateway addon packs.
- **File manager**: browse, upload and download files in storage.
- **Clean database**: delete test data from chosen tables.
- **SEO / web master**: page meta data for each page, **robots.txt** editor, **sitemap**, **404 logs**, Google Search Console verification.
- **Theme settings** and site direction.

## 2.6 Restaurant panel — every section

Restaurant owners (and employees with the right role) get their own web panel, and the same features in the restaurant app through `/api/v1/vendor/*`.

- **Dashboard**: order stats (confirmed, cooking, ready, on the way, delivered, refunded, scheduled, all), earnings, top-selling and top-rated foods, charts.
- **POS**: same as the admin POS, for their own restaurant.
- **Orders**: all order lists by status, order details, **change status** (confirm, processing with cooking time, handover, delivered for self-delivery/take-away/dine-in), **assign their own delivery men** (self-delivery), **edit order** (if allowed), add payment reference, **order proof**, **dine-in table number**, **send order OTP**, invoice, export, **subscription orders**.
- **Food**: categories (view the admin's categories and sub-categories), **add-ons**, **foods** (full add/edit like admin, **recommended** flag, stock update, stock-out list), **bulk import/export**, **reviews** and **replies**.
- **Campaigns**: see basic campaigns and **join or leave** them; see food campaigns.
- **Coupons**: create own coupons.
- **Advertisements**: request ads (restaurant promotion or video), see their status, copy, edit, delete.
- **Wallet**: balance, earnings, **cash in hand**, **withdraw request**, **withdraw methods** (bank accounts etc., set default), **pay collected cash** online, **wallet adjustment**, disbursement list.
- **Business plan / subscription**: current package, usage, transactions, invoices, buy or renew, **switch to commission**, cancel.
- **Reports**: expense, transaction (with PDF statement), order, food-wise, campaign order, disbursement, earning (summary, breakdown, trends), tax report.
- **Delivery men** (self-delivery restaurants): add, list, edit, status, earnings.
- **Employees** and **custom roles** for their staff.
- **Chat**: talk with customers (and admin), with files and images.
- **Restaurant settings / business setup**: open or closed now (**temporarily closed**), **opening schedule** per weekday (several time slots), enabled order types, delivery time, minimum order, free delivery, self-delivery, veg/non-veg, cutlery, extra packaging, halal, scheduled, instant and subscription orders, **announcement** message, meta/SEO data, **notification settings**.
- **My restaurant**: edit info, logo, cover, **QR code** (menu QR to print or download as PDF).
- **Profile**: owner info, password, **bank info**.
- Restaurant app extras: login/forgot password, **register** as a restaurant, update FCM token, notifications, earning info, **remove account**, update profile and basic info, characteristic suggestions.

## 2.7 Delivery-man app (API `delivery-man/*`)

- **Login** (phone + password), **biometric login**, forgot/reset password (SMS or Firebase OTP), self-registration (`auth/delivery-man/store`).
- **Profile**, update profile, **online/offline** switch (`update-active-status`), choose **shift**, remove account.
- **Latest orders** (available to accept), **accept order**, **current orders**, **all orders**, order details, **order delivery history**.
- **Update order status** (picked up, delivered), **update payment status** (cash collected), **send order OTP**, upload **proof**.
- **Location tracking**: sends location every few seconds (`record-location-data`); last location is readable by admin and customers. A **websocket handler** (`DMLocationSocketHandler`) can stream it live.
- **Earnings report**, **wallet** (cash in hand, **pay collected cash**, **wallet adjustment**, payment list, provided earnings list), **withdraw methods**, **disbursement report**.
- **Chat** with customers and restaurants, **notifications**, reviews received.
- Topic subscription for zone-wide pushes (`dm-topic`).

## 2.8 Customer API (used by the customer app)

Grouped by purpose (all under `/api/v1`):
- **Config and places**: `config`, `config/get-zone-id`, place autocomplete/details, geocode, distance, analytic scripts, `zone/list`, `zone/check`.
- **Content**: policy pages, landing page data, page meta data, `get-PaymentMethods`, `offline_payment_method_list`, `get-vehicles`, `vehicle/extra_charge`, `most-tips`, `dm-shifts`, allergy and nutrition name lists, add-on categories, advertisements, banners.
- **Auth**: sign up, login, phone verification, update info, forgot/verify/reset password, Firebase verification, guest request.
- **Catalogue**: categories (+ children, products, restaurants), cuisines, restaurants (list, latest, popular, dine-in, details, reviews, search, recently viewed, recommended, visit again, coupons), products (latest, popular, restaurant popular, recommended, most reviewed, set menu, search, details, related, reviews, rating, combined food-or-restaurant search), campaigns (basic, basic details, item), coupons, cashback.
- **Customer** (logged in): info, update profile, interests, FCM token, suggested foods, notifications, remove account, zone update, addresses, wish-list, **wallet** (transactions, bonuses, add fund), **loyalty** (transactions, convert), **messages**, **subscriptions**.
- **Orders** (users and guests): place, **get tax**, **check restaurant validation**, list, running, subscription list, details, track, cancel, cancellation reasons, refund reasons, refund request, change payment method, offline payment and its update, pending reviews, food list, order again, order notification.
- **Cart** (users and guests): list, add, add multiple, update, remove item, clear.
- **Other**: newsletter subscribe, DM reviews submit, food review submit.

## 2.9 Notifications and messaging

- **Push** via Firebase Cloud Messaging: to single devices (customer, restaurant, DM) and to **topics** (zone-wide, all customers, all restaurants, all DMs). Message texts come from **push notification templates**, per language.
- **Email** via SMTP with the **email templates**.
- **SMS** via the active SMS gateway (OTP, order updates).
- Which channel fires for which event is controlled in **notification settings** (per user type), and restaurants can adjust their own.
- **In-app notifications** list for customers, restaurants and DMs.
- **Chat**: conversations between customer ↔ restaurant, customer ↔ delivery man, customer ↔ admin, restaurant ↔ admin, with images, files and videos.
- **Admin order alerts**: new-order sound in the admin and restaurant panels.

## 2.10 Modules and add-ons

- **AI module** (OpenAI): in the food form, generate the title, description, general setup, price and other fields, variations and SEO, **analyze a food image** to fill the form, and suggest titles. Works in the admin and restaurant panels and the restaurant app (`api/v1/ai/*`). Needs an OpenAI key.
- **Tax module**: VAT/tax setup. Tax can be calculated **order-wise**, **product-wise** or **category-wise**, on the billing address location, with optional tax on packaging and additional charges. Produces tax reports.
- **System addons**: extra payment and SMS gateway packs can be uploaded and published.

## 2.11 Background jobs and commands

| Command | What it does | How it runs |
|---|---|---|
| `restaurant:disbursement` | Creates automatic payout batches for restaurants | Cron (set up from disbursement settings) |
| `dm:disbursement` | Same for delivery men | Cron |
| `cart:reminder` | Push reminder to users with abandoned carts | Cron |
| `database:refresh` | Resets the demo database (demo mode only) | Cron |
| `generate:admin-route` / `generate:restaurant-route` | Build the search index of panel pages (`admin_formatted_routes.json`) | Manually |

Laravel's own scheduler is empty, so these must be added as cron jobs. On Railway that means a separate cron service or a scheduled job.

Other automatic behaviour runs on requests rather than cron, for example the daily subscription order logs and customer subscription checks.

## 2.12 Security and access control

- Admin sections are protected by **module permissions** (`module:` middleware + custom roles); employees only see what their role allows.
- Restaurant employees are limited by the owner's roles.
- Separate login pages with **custom URLs**, **reCAPTCHA** or built-in captcha, and rate limiting on login, OTP and order placing.
- API tokens are checked for restaurants (`vendor.api`) and delivery men (`dm.api`); customers use Passport tokens; guests use a guest id.
- Admin can block customers, restaurants and delivery men; a blocked customer gets a push notification and the app sends them to the sign-in screen.
- **Maintenance mode** can lock any part of the system.
- The web installer and the vendor licence check were removed for this deployment.

---

## Appendix — quick maps

### A. "Where is this set?" cheat-sheet

| I want to change… | Go to (admin panel) |
|---|---|
| Logo, name, currency, timezone, commission | Business settings → Business info |
| Order types, scheduling, OTP delivery, who confirms orders | Business settings → Order settings |
| Wallet, loyalty, referral, guest checkout | Business settings → Customer settings |
| Payment gateways / COD / partial payment | 3rd party → Payment methods, Business settings → Payment setup |
| Delivery charges by area, max COD, express/saver delivery, DM incentives | Zones → Zone settings |
| Push message texts | Notification messages (Firebase) |
| Which alerts go by push/mail/SMS | Notification settings |
| App forced update | App settings → minimum versions |
| Login options | Login setup |
| Website texts | Landing page settings / Pages |

### B. One order, end to end
Customer adds food to cart → checkout (type, address, time, tip, coupon, payment) → server validation → order `pending` → restaurant notified → confirmed → DM accepts (or admin/restaurant assigns) → restaurant cooks (`processing`) → `handover` → DM `picked_up`, customer tracks live → DM enters customer OTP → `delivered` → money split to admin, restaurant and DM wallets, points and cashback credited → customer reviews food and DM → (optional) refund request → admin decides.

### C. One restaurant, end to end
Restaurant signs up (app, website or admin adds it) → chooses commission or a subscription package → admin approves → restaurant sets schedule, menu, settings → receives and handles orders → earns into its restaurant wallet → pays in collected cash → gets paid through withdraw requests or automatic disbursements → sees reports, runs coupons, joins campaigns, buys ads.

### D. Design system (Paustik Poornahar)

All colours come from the logo.

| Token | Hex | Used for |
|---|---|---|
| Primary (green) | `#0E9E31` | Buttons, links, active tabs, highlights, icons, app `primaryColor` |
| Primary dark | `#0B7F27` | Hover and pressed states, `--bs-primary` in the panels |
| Primary on dark mode | `#22B04A` | App dark theme primary |
| Accent (red) | `#BE0A24` | Offer and discount tags, refer-and-earn banner, illustration accents |
| Accent light | `#E8566A` | Gradient partner of the red accent |
| Warning (yellow) | `#F9B802` | Ratings, warnings |
| Leaf | `#94BC0C` | Secondary green in the logo mark |
| Sidebar / headings | `#0B3D1F` | Admin and restaurant panel sidebar, dark headings |
| Ink | `#061611` | Darkest text |
| Tints | `#E7F5EA`, `#D2EEDA`, `#86D49A` | Selected, hover and light backgrounds |

Font: **Poppins** in the web panels; the app uses its `fontFamily` constant (`AppConstants.fontFamily`).

Status colours (info blue, success, danger red, order-status colours) are left as standard so their meaning stays clear.

Where it lives:
- **App**: `lib/theme/light_theme.dart`, `lib/theme/dark_theme.dart`, SVG and PNG icons in `assets/image`, logos `assets/image/logo.png` (mark) and `logo_name.png` (wordmark), launcher icons for Android, iOS and web.
- **Panels**: CSS variables at the top of `public/assets/admin/css/style.css`, plus `theme.minc619.css`, `custom.css`, `vendor.css`, `bootstrap.min.css`, inline colours in Blade views, icons in `public/assets/admin/img`.
- **Business logo and favicon**: `backend/installation/branding/logo.png` and `icon.png`, applied on deploy.
