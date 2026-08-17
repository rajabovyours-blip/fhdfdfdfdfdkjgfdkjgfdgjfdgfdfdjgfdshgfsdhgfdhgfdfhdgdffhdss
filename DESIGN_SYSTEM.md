# MILLIY METR - Enterprise Design System

> **Tagline:** Yuqori Sifat
> **Type:** Multi-Vendor Construction Materials Marketplace
> **Design Philosophy:** Premium, Modern, Clean, Trustworthy, Material Design 3

This document defines the complete Design System and UI Foundation for Milliy Metr. It serves as the source of truth for both Figma design tokens and the Flutter `ThemeData` implementation.

---

## 1. Color System

The palette is engineered for high contrast, trustworthiness (deep industrial blue), and action (high-visibility safety orange).

### Light Theme
- **Primary:** `#0F3A59` (Deep Slate Blue - Trust, Enterprise)
- **On Primary:** `#FFFFFF`
- **Primary Container:** `#E2F1FF`
- **Secondary:** `#FF6B00` (Safety Orange - Action, Construction)
- **On Secondary:** `#FFFFFF`
- **Success:** `#008A27` (Green)
- **Warning:** `#FFB800` (Yellow)
- **Danger/Error:** `#DE3730` (Red)
- **Info:** `#2E7D32`
- **Background:** `#F8F9FA` (Off-white for reduced eye strain)
- **Surface:** `#FFFFFF` (Cards, Dialogs)
- **Surface Variant:** `#F0F3F5` (Search fields, inactive tabs)
- **Outline (Borders):** `#DCE2E6`
- **Divider:** `#EBF0F3`
- **Text High Emphasis:** `#11181C`
- **Text Medium Emphasis:** `#687783`
- **Text Disabled:** `#A1B0BD`

### Dark Theme
- **Primary:** `#82BDEB`
- **On Primary:** `#0F3A59`
- **Primary Container:** `#0B283D`
- **Secondary:** `#FF8F3D`
- **Background:** `#0D1117` (Deep GitHub/Linear dark)
- **Surface:** `#161B22`
- **Surface Variant:** `#21262D`
- **Outline:** `#30363D`
- **Text High Emphasis:** `#ECF2F8`
- **Text Medium Emphasis:** `#8B949E`

---

## 2. Typography (Material 3)

Typeface: **Inter** or **Roboto**. Engineered for maximum legibility of numbers (prices, dimensions) and dense data.

- **Display Large:** 57px, -0.25px letter spacing, W400 (Hero banners)
- **Display Medium:** 45px, 0px, W400
- **Display Small:** 36px, 0px, W400
- **Headline Large:** 32px, 0px, W400 (Page Titles)
- **Headline Medium:** 28px, 0px, W400
- **Headline Small:** 24px, 0px, W400 (Section Headers)
- **Title Large:** 22px, 0px, W500 (Dialog Titles)
- **Title Medium:** 16px, 0.15px, W500 (List items, App bar)
- **Title Small:** 14px, 0.1px, W500
- **Body Large:** 16px, 0.5px, W400 (Long descriptions)
- **Body Medium:** 14px, 0.25px, W400 (Standard text)
- **Body Small:** 12px, 0.4px, W400
- **Label Large:** 14px, 0.1px, W500 (Buttons)
- **Label Medium:** 12px, 0.5px, W500 (Chips, Tags)
- **Label Small:** 11px, 0.5px, W500 (Captions, Bottom Nav)

---

## 3. Spacing System (4dp Grid)

Strict adherence to a 4-point grid system.
- `spacing4` (4dp) - Inside tight components (Icon to Text)
- `spacing8` (8dp) - Between list items
- `spacing12` (12dp) - Small padding
- `spacing16` (16dp) - Standard App Padding (Screen edges)
- `spacing20` (20dp) - Loose padding
- `spacing24` (24dp) - Section gaps
- `spacing32` (32dp) - Major section gaps
- `spacing40` (40dp) - Form groups
- `spacing48` (48dp) - Screen bottom spacing (above nav)
- `spacing64` (64dp) - Empty state margins
- `spacing80` (80dp) - Huge gaps (Splash, Onboarding)

---

## 4. Border Radius

- **Radius XS (4dp):** Checkboxes, Status Badges
- **Radius S (8dp):** Buttons, TextFields, Dropdowns, Category Chips
- **Radius M (12dp):** Product Cards, Store Cards, Small Dialogs
- **Radius L (16dp):** Standard Dialogs, Bottom Sheets (top corners), Banner Cards
- **Radius XL (24dp):** Large modal sheets
- **Radius Full (999dp):** FABs, Avatar circles, Pill buttons

---

## 5. Elevation System (Material 3 Surface Tints)

Using M3 color surface tints rather than hard drop shadows for a premium, clean look.

- **Level 0 (0dp):** Standard Background
- **Level 1 (1dp):** Cards (Subtle tint/shadow)
- **Level 2 (3dp):** Contained Buttons, Search App Bar
- **Level 3 (6dp):** FAB, Bottom Navigation, Dialogs
- **Level 4 (8dp):** Bottom Sheets
- **Level 5 (12dp):** Modals, high-priority popups

---

## 6. Icon System

- **Family:** Material Symbols (Rounded & Filled variants)
- **Inactive State:** Outlined (e.g., Unliked Favorite, Inactive Tab)
- **Active State:** Filled (e.g., Liked Favorite, Active Tab)
- **Construction Specific:** Custom SVGs for highly specific items (e.g., specific icons for Cement bags, Rebar, Roofing tiles) converted to `SvgPicture`.

---

## 7. Buttons

- **Sizes:** 
  - `Large` (Height: 48dp, full width, Label Large)
  - `Medium` (Height: 40dp, Label Large)
  - `Small` (Height: 32dp, Label Medium)
- **Variants:**
  - `Primary`: Solid Primary color background, White text.
  - `Secondary`: Solid Secondary (Orange) background, White text.
  - `Outlined`: Transparent, Primary outline, Primary text.
  - `Text`: Transparent, Primary text, subtle hover/pressed tint.
  - `Danger`: Solid Danger background, White text.
- **States:** Default, Hover, Pressed (Ripple), Loading (Shows circular indicator), Disabled (Grey background, low opacity).

---

## 8. Text Fields

- **Style:** `OutlinedInputBorder` (Modern, clean, enterprise standard).
- **Default State:** Outline `#DCE2E6`, Text `#11181C`.
- **Focused State:** Outline Primary `#0F3A59`, 2px width.
- **Error State:** Outline Danger `#DE3730`.
- **Variants:**
  - `Search`: Prefix search icon, suffix clear/filter icon, grey filled background (`Surface Variant`), no border.
  - `Password`: Obscured text, suffix eye icon to toggle.
  - `Phone`: Prefix country code (+998), auto-formatting.
  - `OTP`: 4-6 box grid (`PinCodeTextField`), auto-focus.
  - `Dropdown`: Suffix chevron down, opens bottom sheet or dropdown menu.

---

## 9. Cards

- **Product Card:** Image aspect ratio 1:1, Price (Headline Small, bold), Title (Body Medium, maxLines 2), Rating row, Cart FAB on bottom right.
- **Category Card:** Square or Rectangular, icon/image centered, Label Medium text. Surface Level 1.
- **Store Card:** Banner image background, Store Logo overlay (circle), Verified Badge, Rating, "View Store" button.
- **Review Card:** User Avatar, Stars, Date, Comment text (Body Medium).
- **Order Card:** Order ID, Status Badge (Color coded), Total Amount, Item thumbnails, Date.

---

## 10. Navigation Components

- **Bottom Navigation (Mobile):** `NavigationBar` (M3). Home, Catalog, Cart, Profile. Active indicator pill.
- **Navigation Rail (Tablet/Foldable):** Left side, vertical icons.
- **Drawer:** For Admin/Seller panels. Profile header, list tiles with icons.
- **Top App Bar:** Center title, no elevation when scrolled to top, elevates on scroll.
- **Search App Bar:** Persistent search bar pinned to top of Home/Catalog.

---

## 11. Feedback Components

- **Dialogs:** `AlertDialog` for confirmations (Delete, Log out). Title Large, Body Medium, Action text buttons.
- **Bottom Sheets:** Modal bottom sheets for complex inputs (Filters, Sorting, Select Variant). Drag handle indicator at top.
- **Snackbars:** Floating `SnackBar`, rounded corners (8dp), gap from bottom. Success (Green), Error (Red), Info (Dark).
- **Loading:** `CircularProgressIndicator` (Primary color).
- **Skeleton (Shimmer):** `Surface Variant` color, rounded rectangles mimicking text/images during network loads.
- **Empty State:** Large illustration (SVG), Title, Subtitle, Primary Action Button (e.g., "Start Shopping").
- **Error/Offline State:** Illustration, "No Internet Connection", "Retry" button.

---

## 12. Construction Marketplace Specific Components

- **Price Widget:** Formatted large number (e.g., `12,500,000 UZS`), optional crossed-out old price, `/ ton` or `/ unit` suffix.
- **Discount Badge:** Absolute top-left of image, Red background, White text, "-15%".
- **Stock Badge:** "In Stock" (Green), "Low Stock" (Warning), "Out of Stock" (Grey).
- **Verified Seller Badge:** Blue shield with checkmark icon, placed next to Store Name.
- **Product Rating:** Star icon (Yellow) + Number (e.g., `4.8`) + Review count `(124)`.
- **Delivery Badge:** "Free Delivery" or "Express truck icon".
- **Favorite Button:** Heart icon overlay on product images (top-right).
- **Quantity Selector:** `[ - ] [ 1 ] [ + ]` button group, prevents going below Minimum Order Quantity (MOQ).
- **Product Label:** "Wholesale", "Retail", "Premium".

---

## 13. Motion System

- **Fast (Micro-interactions):** 200ms (Buttons, switches, hovers). Curve: `Curves.easeInOut`.
- **Medium (Screen transitions):** 300ms (Dialogs, Bottom Sheets). Curve: `Curves.easeOutCubic`.
- **Slow (Hero animations):** 500ms (Image expansion to product details). Curve: `Curves.fastOutSlowIn`.
- **Ripple:** Standard Material splash effect on all clickable items (constrained to border radii).

---

## 14. Responsive Rules

- **Phone (< 600dp):** Bottom Navigation, 2-column Product Grid, full-width Bottom Sheets.
- **Tablet / Foldable (600dp - 900dp):** Navigation Rail, 3 or 4-column Product Grid, Dialogs instead of Bottom Sheets for filters.
- **Landscape:** Hide Bottom Navigation (use Rail), side-by-side layouts (e.g., Order List on left, Order Details on right).

---

## 15. Accessibility

- **Contrast:** Minimum 4.5:1 ratio for text on backgrounds.
- **Font Scaling:** App supports system text size scaling without breaking layout (use `Expanded` and scrollable views).
- **Touch Targets:** Minimum 48x48dp interactive area for ALL buttons, icon buttons, and links.
- **Screen Reader:** All custom components wrapped in `Semantics` widget with descriptive labels.

---

## 16. Figma Tokens to Flutter Theme Structure

The design system maps directly to Flutter's `ThemeData`:

```dart
// Generated from Figma Tokens
final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme(
    primary: Color(0xFF0F3A59),
    onPrimary: Colors.white,
    secondary: Color(0xFFFF6B00),
    onSecondary: Colors.white,
    error: Color(0xFFDE3730),
    onError: Colors.white,
    surface: Colors.white,
    onSurface: Color(0xFF11181C),
    // ... other tokens mapped
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: Color(0xFF11181C)),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF687783)),
    // ... other tokens mapped
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 48), // Large by default
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFDCE2E6)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF0F3A59), width: 2),
    ),
    filled: true,
    fillColor: Colors.white,
  ),
  extensions: [
    AppColorsExtension(
      success: const Color(0xFF008A27),
      warning: const Color(0xFFFFB800),
    ),
  ],
);
```
---
*End of Design System Document for Milliy Metr.*
