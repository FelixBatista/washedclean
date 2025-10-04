import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../core/theme/app_theme.dart';

class AppSearchBar extends HookWidget {
  const AppSearchBar({
    super.key,
    this.hintText,
    this.controller,
    this.onSearch,
    this.onChanged,
    this.enabled = true,
  });

  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onSearch;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textController = controller ?? useTextEditingController();
    final focusNode = useFocusNode();

    return TextField(
      controller: textController,
      focusNode: focusNode,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText ?? 'Search stains, fabrics, or products...',
        prefixIcon: const Icon(
          Icons.search,
          color: AppTheme.mediumGray,
        ),
        suffixIcon: textController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: AppTheme.mediumGray,
                ),
                onPressed: () {
                  textController.clear();
                  onChanged?.call('');
                },
              )
            : null,
        filled: true,
        fillColor: AppTheme.lightGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      onChanged: (value) {
        onChanged?.call(value);
      },
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          onSearch?.call(value);
        }
      },
      textInputAction: TextInputAction.search,
    );
  }
}
