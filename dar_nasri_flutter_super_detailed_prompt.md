# Super Detailed Single-Prompt Specification: Build the Complete Flutter App for متجر دار نصري (Dar Nasri Perfume Store)

**You are an expert Flutter developer. Generate a complete, production-ready Flutter project for the customer-facing mobile app of "دار نصري" perfume store.**

The app must match the provided design system, screen structure, and backend API contract **exactly**. Do not invent fields, endpoints, colors, or UI patterns outside this specification. Admin panel is out of scope.

**Base API URL:** `https://e-smart.nmo.marketing/api/v1`

All responses are **not** wrapped in a `data` object unless the actual response shows wrapping. Monetary values on the wire are in minor units (`*Minor` fields = cents/qirsh). Display price as `priceMinor / 100` with the `currency` code.

## Mandatory Design System (Closed Values — Do Not Approximate)

Create a `AppColors` class and use these exact values everywhere. No Material default purple/blue, no random colors, no heavy black shadows, no glassmorphism, no neon, no large gold glows.

```dart
class AppColors {
  static const primary = Color(0xFF490D0E);
  static const primaryHover = Color(0xFF3A0A0B);
  static const primaryActive = Color(0xFF2E0809);
  static const primaryMid = Color(0xFF5B1A2B); // New badge
  static const pageBackground = Color(0xFFFAF6F7);
  static const surface = Color(0xFFFFFFFF);
  static const navStrip = Color(0xFFF4F0EC);
  static const text = Color(0xFF1C1115);
  static const textSecondary = Color(0xFF756B6D);
  static const textBody = Color(0xFF5E4B48);
  static const textOnDark = Color(0xFFE8DDE1);
  static const cream = Color(0xFFFBF4E8);
  static const border = Color(0xFFE8DDE1);
  static const borderWarm = Color(0xFFE8E1DC);
  static const gold = Color(0xFFD89B2B);
  static const goldLight = Color(0xFFF5ECD0);
  static const goldDark = Color(0xFFB07820);
  static const success = Color(0xFF2E7D32);
  static const error = Color(0xFFD32F2F);
}
```

**Typography (Mandatory):** Use Google Fonts **Cairo** with weights 400, 500, 600, 700, 800. Never use Roboto or platform default for Arabic text.

```dart
// In theme or via GoogleFonts.cairo(...)
textTheme: GoogleFonts.cairoTextTheme().copyWith(
  // Define styles matching sizes below
)
```

**Direction & Language:** Default `Directionality` is RTL, locale `ar`. When language is `en` or `tr`, switch to LTR while keeping identical colors.

**Radii:**
- Small: 8
- Medium: 10
- Large: 16
- Product card: 14
- Pill (search button, account, assistant): 9999

**Shadows:** Light card shadow only: `BoxShadow(offset: Offset(0, 4), blurRadius: 16, color: Color(0xFF490D0E).withOpacity(0.10))` on hover/press. No heavy black floating cards without borders.

**Buttons:**
- Primary: background `#490D0E`, white text, full pill, fontWeight 600.
- Gold button only for secondary confirmation: background `#D89B2B`.

**Forbidden:**
- System `AlertDialog` for success/error. Use custom top toast that auto-dismisses after ~3.2 seconds.
- Confirmation dialogs: two buttons (Confirm / Cancel) inside a custom notification.
- Generating or drawing Arabic calligraphy. Use the provided pattern image only.

## Background Pattern (bg-nuqoosh.jpg)

**Asset:** Place the provided `bg-nuqoosh.jpg` file in `assets/images/bg-nuqoosh.jpg` and declare it in `pubspec.yaml`.

This is a light Arabic calligraphy tile on white. Repeat it **exactly as-is**. Do not crop to logo, do not recolor to burgundy, do not replace with SVG.

**Layer order on store pages (content screens only):**
1. Page background: `#FAF6F7`
2. On top: the image tiled with `ImageRepeat.repeat`, alignment `Alignment.topCenter`, logical tile width **520** (height auto), opacity **0.72**. The layer must ignore pointer events (`IgnorePointer`).
3. Content above the pattern.

On mobile, keep tile width 520 — do not shrink until the pattern disappears. Maximum opacity 0.72.

Create a reusable `PatternBackground` widget that wraps any screen content.

## Screen Structure & Header

Header is fixed at top with white background. Content below. Pattern only behind content.

1. **Top bar** (height 36): background `#490D0E`, text `#E8DDE1` size 12. Any link inside is gold `#D89B2B` with underline.
2. **Brand row**: Logo image + "دار نصري" in `#490D0E`, weight 700, size 24. Do not distort logo aspect ratio. (If no logo asset is provided, use a simple circular placeholder with the primary color and initials, and add a comment that the real logo should replace it.)
3. **Search pill**: background `#FAF6F7`. Search button inside the field is primary color. Placeholder: «صف العطر: صيفي خفيف برائحة الحمضيات».
4. Icons: Cart, Wishlist, Notifications (bell), then language switcher, then Login or Create Account. Count badge is a circle `#490D0E` with white text.
5. **Category strip** on `#F4F0EC`: الرئيسية، العطور، المنتجات، الفروع، البراندات. Current section has a gold underline.

**Product cards** (grid): On mobile 2 columns, gap 12. Card: white, border `#E8DDE1`, radius 14. Image is square on `#FAF6F7` background. Name in `#490D0E`. Price weight 700. Rating stars in gold `#D89B2B`. If `averageRating == null`, show text «بدون تقييم» with **no** invented filled stars. Never show fake "80+ طلب" or hardcoded 4.6.

**Status badges on image:**
- New: `#5B1A2B`
- Best seller: `#D89B2B` with text `#1C1115`
- Discount: `#490D0E`

## Floating AI Assistant

- Circular icon 44×44, solid background `#490D0E`, white icon, light shadow. **No** gold halo.
- On first app open in the session only: the icon expands and shows the text «استخدم المساعد الذكي» (size 12, weight 600) for ~3 seconds, then collapses back to icon.
- The chat window opens **below the header** and does not cover header buttons. Background `#FFFDF8`, border `#D7C4A2`, radius 18. Header of window is `#490D0E`.
- Close button is `✕` inside the header. Assistant replies are plain text — **never** interpret as HTML.
- Suggested perfume cards: image, name, brand, price — tapping opens product details.

## Custom Toast System

Top-of-screen white toast, border `#ECECEC`, light shadow, auto-dismiss after ~3.2 seconds. Success and error messages must use this, never system dialogs.

## Required Screens (Arabic titles as shown to user)

Build all of these with proper navigation (use `go_router` recommended):

- **الرئيسية** (Home): Banners, categories, product grid, brands.
- **قائمة المنتجات** with category filtering.
- **تفاصيل العطر** (Product details): Image gallery (cover + angles), price, add to cart, published reviews, review form.
- **البراندات** and individual brand page.
- **الفروع** and individual branch page. Branches are **operational entities**, not brands. Do not merge them.
- **البحث بالوصف** (Description search / AI search).
- **السلة** (Cart).
- **إتمام الطلب** (Checkout) → Success or Failure screens.
- **الحساب** (Account): Overview, My Orders, Wishlist, My Addresses, Conversations.
- **التحقق من الأصالة** (Authenticity verification).
- Static text pages: من نحن، الشحن، الخصوصية، الشروط، الأسئلة، طرق الدفع، تواصل معنا، تتبع الطلب.

**Branches:** Fetch from `GET /branches`. There are exactly 4 active branches. Display name from `translations.ar.name`. Current real data example: names are "Dar Nasri Store 1", "Dar Nasri Store 2", etc. Phone is currently `null` — when phone is null or empty, show «لا يوجد هاتف مسجّل». Never invent city addresses or phone numbers.

## Backend Contract (Strict)

**Every request:**
- Headers: `Accept: application/json`
- `Accept-Language: ar` (unless UI language is `en` or `tr`)
- Protected routes: `Authorization: Bearer <accessToken>`

**Auth refresh:** On 401 and if `refreshToken` exists, call `POST /auth/refresh` once, then retry the original request. If refresh fails, clear session.

**Endpoints:**

- `POST /auth/login` body `{ email, password }` → `{ accessToken, refreshToken, user }`
- `POST /auth/register` body: `email`, `password`, `fullName`, `locale` (ar|en|tr), `acceptTerms: true`, optional `phone`
- `POST /auth/forgot-password` `{ email }`
- `POST /auth/reset-password` `{ token, password }`

**Products** require `branchId`. Always take the **first active** branch from `GET /branches`. Never hardcode a fake ID.

- `GET /products?branchId&page&limit` → `{ items, page, limit, total }`
- Product fields to use:
  - `id`
  - Name/description: `translations.ar.name` / `.description`, fallback to `en` then `tr`
  - Display price: `priceMinor / 100` + `currency` (example real data: 1100 → 11.00 SAR)
  - Cover image: `attributes.imageUrl`
  - Angle images: `attributes.angleFront`, then `angleRight`, then `angleBack`, then `angleLeft` (all strings, may be relative)
  - `brand` (string)
  - `category.slug`
  - `stockQuantity`
  - `averageRating` (number or null)
  - `reviewCount` (number)

- `GET /products/{id}` same shape.

**Reviews:**
- `GET /products/{id}/reviews?page&limit` (public, approved only) → `{ items, page, limit, total, averageRating, ratingDistribution }`
- Review item: `id`, `rating`, `displayName`, `text`, `createdAt`, optional `verifiedPurchase`. If true, show «شراء موثّق».
- `POST /products/{id}/reviews` (auth required): `{ rating (1-5), text? (max 2000), displayName? (max 80) }`
- Success toast: «وصل تقييمك وسيظهر في المتجر بعد الاعتماد»
- On 409 with conflict message: toast «التقييم متاح بعد طلب مدفوع ومُسلَّم لهذا العطر، ومرة واحدة لكل عميل»

**Cart** (auth + branchId):
- `GET /cart?branchId`
- `POST /cart/items` `{ branchId, productId, quantity }`
- `PATCH /cart/items/{productId}?branchId` `{ quantity }`
- `DELETE /cart/items/{productId}?branchId`
- `POST /cart/coupon-quote/{branchId}/{code}`

**Checkout** `POST /cart/checkout`:
```json
{
  "branchId": "uuid",
  "addressId": "uuid",
  "paymentMethod": "cash_on_delivery",
  "couponCode": "optional",
  "shippingQuoteId": "optional"
}
```
Allowed `paymentMethod`: `stripe` | `cash_on_delivery` | `bank_transfer` | `cash_at_branch`.
If card is not enabled, show toast: «الدفع بالبطاقة غير مفعّل حالياً. اختر الدفع عند الاستلام.»

**Orders:** `GET /orders`, `GET /orders/{id}`. Display `orderNumber` to the user. Never show UUID as order number. UUID is only for routing.

**Addresses:** `GET/POST /users/me/addresses`. Add body: `label`, `recipientName`, `phone`, `country`, `city`, `details` (min 5 chars), optional `isDefault`.

**Wishlist:** `GET /users/me/wishlist`, `POST /users/me/wishlist/{productId}`, `DELETE /users/me/wishlist/{productId}`.

**Support conversations** (auth required — these are support chats, not the AI assistant):
- `GET /support/conversations`
- `POST /support/conversations` `{ "kind": "support" | "report", "subject": "...", "message": "..." }`
- `GET /support/conversations/{id}`
- `POST /support/conversations/{id}/messages` `{ "body": "..." }`

**Authenticity:** `GET /authenticity/verify/{token}`

**Newsletter:** `POST /marketing/newsletter/subscribe` `{ email, consent: true, locale: "ar" }`

**Branches:** `GET /branches` → array. Use: `id`, `code`, `active`, `translations.ar.name`, `phone`.

### AI Assistant & Search

**Never** put any Gemini/API key inside the app or store it on device.

- `GET /ai/status` → `{ "available": false, "reason": "not_configured" }` or `{ "available": true, "reason": "ready" }`
- If `available == false`, do not call search or assistant. Local name search remains available, with the line: «البحث والمساعد بالذكاء الاصطناعي غير مفعّلين بعد»
- `POST /ai/search` and `POST /ai/assistant` body:
```json
{
  "branchId": "uuid",
  "query": "بدي عطر صيفي خفيف برائحة الحمضيات",
  "locale": "ar",
  "limit": 8
}
```
- Assistant additionally sends `history`: last 10 previous messages only, each `{ "role": "user"|"assistant", "content": "..." }`. Current message goes in `query` and is **not** repeated in history.
- Response:
```json
{
  "answer": "plain text",
  "items": [],
  "total": 0,
  "catalogTruncated": false,
  "catalogProductsConsidered": 0
}
```
- `items` are same as product items. Render `answer` as plain text.
- If `catalogTruncated == true`, show: «البحث غطّى أحدث {n} عطراً في هذا الفرع» where n = `catalogProductsConsidered`.
- 503 with code: `AI_NOT_CONFIGURED` = not enabled; `AI_UNAVAILABLE` = «المساعد غير متاح مؤقتاً»

## What Is Forbidden

- Building any admin panel
- Inventing fields or endpoints not listed
- Putting AI keys in the app
- Drawing a new pattern instead of using `bg-nuqoosh.jpg`
- Showing UUID as order number or customer name
- Merging branches into brands
- Hardcoded ratings or order counts
- System alerts instead of the custom toast

## Implementation Requirements for the Generated Project

1. **Project setup**: Flutter 3.x, null-safety. Recommended packages:
   - `flutter_riverpod` (or `provider`) for state
   - `dio` for HTTP with interceptors
   - `go_router` for navigation
   - `google_fonts`
   - `flutter_secure_storage` for tokens
   - `intl` for localization
   - `cached_network_image`
   - `shared_preferences` if needed

2. **Architecture**: Feature-based or layered (data / domain / presentation). Create models that match the API exactly (including optional fields).

3. **Theme**: Full custom `ThemeData` using the colors and Cairo font. Support light only (as specified).

4. **Localization**: Arabic default. Prepare for en/tr with Directionality switch.

5. **State**: Global branch selection (first active), auth state, cart state, wishlist.

6. **Error handling**: Network errors, 401 refresh, 409 review conflict, AI status checks — all with proper toasts.

7. **Assets**: Declare `assets/images/bg-nuqoosh.jpg` and a logo placeholder if needed.

8. **Generate complete files**: `pubspec.yaml`, `main.dart`, theme, models, API service, all screens, widgets (ProductCard, PatternBackground, CustomToast, FloatingAssistant, etc.), navigation.

9. **Code quality**: Clean, commented where non-obvious, no hardcoded fake data, respect all constraints.

Generate the full Flutter project structure and all necessary code so the app can be run after adding the `bg-nuqoosh.jpg` asset and (optionally) the real logo.

Start by creating the folder structure and core files, then implement screens one by one following this specification with maximum fidelity.

## Detailed Models (Generate Exact Matching Classes)

Create Dart models with `fromJson` / `toJson` for:

### Branch
```dart
class Branch {
  final String id;
  final String code;
  final bool active;
  final Map<String, Map<String, String>> translations; // ar/en/tr -> {name}
  final String? phone;
  // other fields optional
}
```
Display name: `translations['ar']?['name'] ?? translations['en']?['name'] ?? code`

### Product (critical)
```dart
class Product {
  final String id;
  final String? sku;
  final Map<String, Map<String, String>> translations;
  final ProductAttributes attributes;
  final int priceMinor;
  final String currency;
  final String brand;
  final CategoryRef category;
  final int stockQuantity;
  final double? averageRating;
  final int reviewCount;
  final bool featured;
  // salePriceMinor, basePriceMinor, etc.
}

class ProductAttributes {
  final String? imageUrl;
  final String? angleFront;
  final String? angleRight;
  final String? angleBack;
  final String? angleLeft;
  final String? gender;
  final String? volume;
}
```
Name getter: prefer ar, then en, then tr.
Price display: `(priceMinor / 100).toStringAsFixed(2) $currency`

### Other models
- User, AuthResponse (accessToken, refreshToken, user)
- Cart / CartItem
- Order (with orderNumber)
- Address
- Review
- AI Status / AI Search Response
- Conversation / Message

## API Client Requirements

Use Dio with:
- Base URL constant
- Interceptor that adds Accept and Accept-Language
- Auth interceptor: attach Bearer token from secure storage
- On 401: attempt refresh once, retry, or clear tokens
- Methods for every endpoint listed above
- Proper error mapping to user-friendly Arabic messages

## Critical Widgets to Implement Exactly

### PatternBackground
```dart
class PatternBackground extends StatelessWidget {
  final Widget child;
  const PatternBackground({required this.child});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppColors.pageBackground),
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.72,
              child: Image.asset(
                'assets/images/bg-nuqoosh.jpg',
                repeat: ImageRepeat.repeat,
                alignment: Alignment.topCenter,
                width: 520, // logical
                fit: BoxFit.none,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
```
Note: Adjust Image width handling so the tile is approximately 520 logical pixels wide.

### ProductCard
- 2-column grid on mobile
- White card, border AppColors.border, radius 14
- Square image with CachedNetworkImage, background pageBackground
- Name in primary color
- Price bold
- Rating: if null → "بدون تقييم", else gold stars + number
- Status badges positioned on image

### CustomToast
Top snackbar-like overlay, white, border #ECECEC, auto-dismiss 3200ms. Use Overlay or a simple package if needed, but prefer custom to match design.

### FloatingAssistant
Stateful widget that:
- On first build of session: expands with text for 3 seconds
- Opens a bottom or side sheet-style window under header
- Handles chat history (max 10 for AI request)
- Checks AI status first
- Renders suggested products as cards

## Screen Layout Details

**Home Screen:**
- PatternBackground
- Fixed Header (top bar + brand + search + icons + category strip)
- Body: horizontal banners (if any from API or static), category chips, product grid (latest or featured), brand logos/row
- FloatingAssistant always present

**Product Details:**
- Image gallery (PageView with cover + angles, handle relative URLs by prefixing base if needed)
- Name, brand, price, stock
- Add to cart button (primary pill)
- Description
- Reviews list + average
- Review form (stars + text, only if logged in)

**Cart & Checkout:**
- List of items with quantity steppers
- Coupon field
- Address selection or add new
- Payment method selector (respect enabled methods)
- Place order button

**Account sections:**
- Tab or list navigation: نظرة عامة, طلباتي (show orderNumber), المفضلة, عناويني, المحادثات

**Branches page:**
- List of 4 branches
- Name from translations.ar.name
- Phone: if null → "لا يوجد هاتف مسجّل"
- Tap to branch details page (not brand)

## Additional Implementation Notes

- Use `Directionality(textDirection: TextDirection.rtl)` at root for Arabic.
- Language switcher updates locale and direction.
- All user-facing strings in Arabic by default.
- Handle image URLs that may be absolute or relative (prefix with API origin if relative).
- Stock quantity: disable add to cart if 0.
- Empty states with proper Arabic messages.
- Loading indicators in primary color.
- Pull-to-refresh on lists.
- Pagination for products and reviews.

## Final Generation Instructions

Generate a complete, runnable Flutter project with:
- All folders: lib/core, lib/features (auth, products, cart, orders, account, branches, ai, etc.), lib/widgets, assets
- Complete pubspec.yaml with dependencies
- main.dart with ProviderScope / Riverpod and router
- All models, services, screens, and widgets
- Comments in critical places explaining design constraints
- No TODOs that break functionality — implement everything listed

After generation, the only manual steps should be:
1. Copy `bg-nuqoosh.jpg` into `assets/images/`
2. Optionally replace logo placeholder
3. `flutter pub get && flutter run`

This prompt is self-contained. Follow it with maximum precision and no deviations from the design system or API contract.
