import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_text_field.dart';
import '../providers/checkout_provider.dart';

class AddressForm extends ConsumerStatefulWidget {
  const AddressForm({super.key});

  @override
  ConsumerState<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<AddressForm> {
  late final TextEditingController _streetCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _postalCtrl;
  final _cityFocus = FocusNode();
  final _postalFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final state = ref.read(checkoutProvider);
    _streetCtrl = TextEditingController(text: state.street);
    _cityCtrl = TextEditingController(text: state.city);
    _postalCtrl = TextEditingController(text: state.postalCode);
  }

  @override
  void dispose() {
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _postalCtrl.dispose();
    _cityFocus.dispose();
    _postalFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final notifier = ref.read(checkoutProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Delivery Address',
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        AppTextField(
          label: 'Street address',
          hint: '123 Main Street',
          controller: _streetCtrl,
          prefixIcon: Icons.location_on_outlined,
          textInputAction: TextInputAction.next,
          onChanged: notifier.setStreet,
          onFieldSubmitted: (_) => _cityFocus.requestFocus(),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Street is required' : null,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: AppTextField(
                label: 'City',
                hint: 'Johannesburg',
                controller: _cityCtrl,
                focusNode: _cityFocus,
                textInputAction: TextInputAction.next,
                onChanged: notifier.setCity,
                onFieldSubmitted: (_) => _postalFocus.requestFocus(),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: AppTextField(
                label: 'Postal code',
                hint: '2000',
                controller: _postalCtrl,
                focusNode: _postalFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onChanged: notifier.setPostalCode,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
