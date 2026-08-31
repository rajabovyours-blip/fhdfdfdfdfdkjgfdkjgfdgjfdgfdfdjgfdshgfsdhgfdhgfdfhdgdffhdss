import 'package:flutter/material.dart';

class AdminPageHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onAdd;
  final String? addLabel;
  final IconData? addIcon;
  final List<Widget>? extraActions;

  const AdminPageHeader({
    super.key,
    required this.title,
    this.onAdd,
    this.addLabel,
    this.addIcon,
    this.extraActions,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 640;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (extraActions != null && extraActions!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: extraActions!,
                  ),
                ],
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Row(
                  children: [
                    if (extraActions != null) ...extraActions!,
                    if (extraActions != null && extraActions!.isNotEmpty && onAdd != null)
                      const SizedBox(width: 16),
                    if (onAdd != null)
                      ElevatedButton.icon(
                        onPressed: onAdd,
                        icon: Icon(addIcon ?? Icons.add),
                        label: Text(addLabel ?? 'Add'),
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}
