# Dar Nasri UI Polish Report

## Summary — visual direction

The polish keeps Dar Nasri calm, luxurious, and trustworthy: burgundy primary, cream/white surfaces, gold only as a quiet accent. Breathing room, a clearer type scale, and consistent page insets make screens feel like one system. No new colors, gradients, glass, neon, or heavy black shadows were introduced. Cairo, RTL default, PatternBackground contract, custom top toast, product-card rating rules, and floating-assistant behavior stay intact.

## Problems found before polish

1. Incomplete type scale — brand/body/caption only; page and section titles reused product styles inconsistently.
2. Uneven spacing — mixed 8/12/16/24 without a shared rhythm.
3. Product cards felt tight — image corners not clipped; little hierarchy between name, brand, price, rating.
4. Header looked utilitarian — search and actions lacked quiet structure; category selected state was easy to miss.
5. Auth forms sat flat on the page background with little focus.
6. Details page stacked controls without grouping; quantity and reviews felt unfinished.
7. Empty/error states were plain text, not intentional panels.
8. Branches/brands were bare ListTiles without visual ownership.
9. Cart/wishlist titles alone with no empty treatment.
10. Search answer/notice lacked a surface container.

Checkout and account screens are still out of scope (blocked on missing API/copy). They were not invented.

## Screens improved

| Screen | Status |
|--------|--------|
| Home / product listing (catalog) | Polished |
| Product details | Polished |
| Brands + brand products | Polished |
| Branches + branch details | Polished |
| Search | Polished |
| Login / Register / Forgot / Reset | Polished |
| Cart (placeholder empty) | Polished |
| Wishlist (placeholder empty) | Polished |
| Store shell + header + assistant + toast | Polished |
| Checkout / Account / Legal | Not built (contract gaps) — unchanged |

## Key changes by screen

### Catalog / Home grid
- Shared page padding (`16` + bottom `96` for the assistant).
- Grid gap `12`, aspect ratio tuned for brand line + price + rating.
- Empty state uses the new cream icon panel.
- Loading indicator tightened (primary, thinner stroke).

### Product details
- Rounded gallery (`radius 16`).
- Page title + quieter brand line + larger price.
- Pill quantity stepper with border.
- Full-width primary Add to cart; outlined secondary wishlist.
- Reviews as bordered surface cards; review form in a SurfaceCard.
- Section titles at weight 600.

### Brands
- Page title + cream/gold-light list cards with chevron.
- Brand products grid matches catalog spacing.

### Branches
- Page title + cream storefront tiles.
- Details in a SurfaceCard with phone row and gold-dark icon.

### Search
- Query as page title.
- AI notice/answer in SurfaceCards.
- Same product grid metrics; empty state panel when no matches.

### Auth
- Centered brand + page title.
- Form fields inside a white bordered SurfaceCard.
- Consistent field spacing; full-width primary actions.

### Cart / Wishlist
- Page title + intentional empty panel (rows still blocked until response JSON exists).

### Header / shell
- Bottom hairline under the white header.
- Search pill with light border and circular primary search control.
- Category strip: gold underline, selected weight 600, muted inactive text.
- Compact header icons; language menu with bordered surface.

### Floating assistant
- Spacing tokens; denser input; suggested products with clipped thumbnails and Material ink.

## Components refined

| Component | Change |
|-----------|--------|
| `AppSpacing` | New spacing scale (`xxs`–`xl`, page, gridGap, pageBottom). |
| `AppTextStyles` | Added `pageTitle`, `sectionTitle`, `priceLarge`, `label`, `navLink`; body height 1.55. |
| `AppTheme` | Taller buttons (52), hover/press overlays from primary variants, refined inputs/checkbox/text buttons. |
| `AppPrimaryButton` / `AppGoldButton` | Full-width by default; gold reserved for confirmations. |
| `AppSecondaryButton` | New outlined secondary for quieter actions. |
| `ProductCard` | Clipped image, brand caption, press animation, clearer rating stars. |
| `SurfaceCard` | Shared white bordered surface. |
| `EmptyState` | Cream icon panel + optional action. |
| `BrandTitle` | Slightly larger mark with gold-light ring. |
| `AsyncPage` / `LoadFailure` | Use EmptyState; quieter loader. |
| Custom toast | Same contract; spacing tokens only. |

## Design-system confirmation

| Requirement | Preserved |
|-------------|-----------|
| Colors `#490D0E`, `#FAF6F7`, `#FFFFFF`, `#D89B2B`, text/border/success/error | Yes — only existing `AppColors` |
| Cairo 400–800 | Yes |
| RTL default / locale switch | Yes |
| PatternBackground opacity 0.72 / tile 520 contract | Yes — flat `#FAF6F7` until `bg-nuqoosh.jpg` is added (file still missing; asset not declared) |
| Custom top toast (no AlertDialog/SnackBar for success/error) | Yes |
| Product card: null rating → «بدون تقييم»; no fake ratings/counts | Yes |
| Floating assistant size, colors, intro hint, panel styling | Yes |
| Radii 8/10/16/14/pill/18; press shadow only | Yes |
| No API / model / business-logic changes | Yes |

## Remaining polish / future

1. Add `assets/images/bg-nuqoosh.jpg` and wire the painter in `PatternBackground`.
2. Replace initials with the real logo when available.
3. Cart/checkout/account UI after response JSON and copy are confirmed.
4. Optional subtle page transitions once navigation feels complete.
5. Dedicated empty-cart copy if product wants a sentence beyond the screen title.
6. Device QA on small phones for header action overflow and 2-column card density.

## Analysis note

`flutter analyze lib test` was clean after removing one unused import.
