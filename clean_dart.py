import sys

def replace_in_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Remove the ?? '...' fallbacks
    content = content.replace("context.l10n.guestModeTitle ?? 'Tizimga kiring'", "context.l10n.guestModeTitle")
    content = content.replace("context.l10n.guestCartDesc ?? 'Savatchani ko\\'rish uchun tizimga kiring.'", "context.l10n.guestCartDesc")
    content = content.replace("context.l10n.guestWishlistDesc ?? 'Sevimlilarni ko\\'rish uchun tizimga kiring.'", "context.l10n.guestWishlistDesc")
    content = content.replace("context.l10n.login ?? 'Tizimga kirish'", "context.l10n.login")

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

replace_in_file('lib/features/checkout/presentation/views/cart_screen.dart')
replace_in_file('lib/features/wishlist/presentation/views/wishlist_screen.dart')

print('Dart files cleaned!')
