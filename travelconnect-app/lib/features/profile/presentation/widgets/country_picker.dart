import 'package:flutter/material.dart';

import '../../../../core/constants/countries.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

/// A form field that opens a searchable bottom sheet to pick a country.
class CountryPickerFormField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final InputDecoration? decoration;

  const CountryPickerFormField({
    super.key,
    required this.value,
    required this.onChanged,
    this.decoration,
  });

  String _countryName(String code) {
    final match = kCountries.where((c) => c['code'] == code);
    return match.isNotEmpty ? match.first['name']! : code;
  }

  Future<void> _openPicker(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const _CountrySearchSheet(),
    );
    if (result != null) {
      onChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveDecoration = (decoration ?? const InputDecoration()).copyWith(
      suffixIcon: const Icon(Icons.arrow_drop_down),
    );

    return InkWell(
      onTap: () => _openPicker(context),
      child: InputDecorator(
        decoration: effectiveDecoration,
        child: Text(
          _countryName(value),
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}

class _CountrySearchSheet extends StatefulWidget {
  const _CountrySearchSheet();

  @override
  State<_CountrySearchSheet> createState() => _CountrySearchSheetState();
}

class _CountrySearchSheetState extends State<_CountrySearchSheet> {
  final _searchController = TextEditingController();
  List<Map<String, String>> _filtered = kCountries;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = kCountries;
      } else {
        _filtered = kCountries
            .where((c) => c['name']!.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Rechercher un pays...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.lgAll,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final country = _filtered[index];
                  return ListTile(
                    leading: Text(
                      _flagEmoji(country['code']!),
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      country['name']!,
                      style: theme.textTheme.bodyLarge,
                    ),
                    onTap: () => Navigator.pop(context, country['code']),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Converts a country code (e.g. "FR") to its flag emoji.
  String _flagEmoji(String countryCode) {
    return countryCode.toUpperCase().codeUnits.map((c) {
      return String.fromCharCode(0x1F1E6 + c - 0x41);
    }).join();
  }
}
