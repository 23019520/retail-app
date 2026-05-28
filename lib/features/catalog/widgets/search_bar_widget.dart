import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/search_provider.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  const SearchBarWidget({
    super.key,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
  });

  /// If provided, the bar acts as a tappable hero — used on HomeScreen
  /// to navigate to ProductListScreen where the real search is.
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(searchQueryProvider),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: widget.onTap,
      child: AbsorbPointer(
        absorbing: widget.onTap != null,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.outline.withValues(alpha: 0.2),
            ),
          ),
          child: TextField(
            controller: _controller,
            autofocus: widget.autofocus,
            readOnly: widget.readOnly,
            onChanged: (value) =>
                ref.read(searchQueryProvider.notifier).state = value,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: Icon(
                Icons.search_rounded,
                color: colors.onSurface.withValues(alpha: 0.5),
                size: 22,
              ),
              suffixIcon: ref.watch(searchQueryProvider).isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close_rounded,
                          color: colors.onSurface.withValues(alpha: 0.5),
                          size: 20),
                      onPressed: () {
                        _controller.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ),
    );
  }
}
