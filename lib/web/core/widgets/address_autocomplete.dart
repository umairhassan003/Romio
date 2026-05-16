import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_colors.dart';

class AddressSuggestion {
  final String displayName;
  final String address;
  final String city;
  final double latitude;
  final double longitude;

  AddressSuggestion({
    required this.displayName,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
  });
}

class AddressAutocomplete extends StatefulWidget {
  final String hintText;
  final String? initialValue;
  final void Function(AddressSuggestion) onSelected;
  final String? Function(String?)? validator;

  const AddressAutocomplete({
    super.key,
    required this.hintText,
    this.initialValue,
    required this.onSelected,
    this.validator,
  });

  @override
  State<AddressAutocomplete> createState() => _AddressAutocompleteState();
}

class _AddressAutocompleteState extends State<AddressAutocomplete> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<AddressSuggestion> _suggestions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void didUpdateWidget(AddressAutocomplete oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue && widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().length < 3) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=5');
      final response = await http.get(url, headers: {'User-Agent': 'RomioAdminApp/1.0'});

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final suggestions = data.map((item) {
          final addressData = item['address'] ?? {};
          final display = item['display_name'] ?? '';
          final lat = double.tryParse(item['lat']?.toString() ?? '0') ?? 0;
          final lon = double.tryParse(item['lon']?.toString() ?? '0') ?? 0;
          
          final city = addressData['city'] ?? addressData['town'] ?? addressData['village'] ?? addressData['county'] ?? '';
          final road = addressData['road'] ?? '';
          final houseNumber = addressData['house_number'] ?? '';
          
          final streetAddress = houseNumber.isNotEmpty ? '\$houseNumber \$road' : road;
          final finalAddress = streetAddress.isNotEmpty ? streetAddress : display.split(',').first;

          return AddressSuggestion(
            displayName: display,
            address: finalAddress,
            city: city,
            latitude: lat,
            longitude: lon,
          );
        }).toList();

        if (mounted) {
          setState(() {
            _suggestions = suggestions;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSuggestionSelected(AddressSuggestion suggestion) {
    _controller.text = suggestion.address.isNotEmpty ? suggestion.address : suggestion.displayName;
    _focusNode.unfocus();
    setState(() => _suggestions = []);
    widget.onSelected(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hintText,
            suffixIcon: _isLoading 
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : const Icon(Icons.location_on_outlined),
          ),
          onChanged: (val) {
            // Debounce in a real app, but for simplicity we just search directly if long enough
            _search(val);
          },
        ),
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              separatorBuilder: (c, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final s = _suggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(s.displayName, maxLines: 2, overflow: TextOverflow.ellipsis),
                  onTap: () => _onSuggestionSelected(s),
                );
              },
            ),
          ),
      ],
    );
  }
}
