import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:haribon/theme/app_colors.dart';

class CompactTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final String? initialValue;
  final Function(Map<String, dynamic>)? onLocationSelected;

  const CompactTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.onLocationSelected,
    this.initialValue,
  });

  @override
  State<CompactTextField> createState() => _CompactTextFieldState();
}

class _CompactTextFieldState extends State<CompactTextField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  List<Map<String, dynamic>> _results = [];
  bool _isSearching = false;
  bool _locationSelected = false;

  OverlayEntry? _overlayEntry;
  Timer? _debounce;

  // ── Search ──────────────────────────────────────────────────────
  void _onTextChanged(String query) {
    _debounce?.cancel();
    if (_locationSelected) {
      setState(() => _locationSelected = false);
    }
    if (query.trim().length < 3) {
      _removeOverlay();
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () => _search(query));
  }

  Future<void> _search(String query) async {
    if (!mounted) return;
    setState(() => _isSearching = true);
    _showOrUpdateOverlay(); // show spinner immediately

    try {
      // Photon is a great alternative to Nominatim that supports CORS natively
      // making it much more reliable for Web apps without needing a proxy.
      final url = Uri.parse(
          'https://photon.komoot.io/api/?q=${Uri.encodeComponent(query)}&limit=6&lang=en');
      
      final res = await http.get(url);

      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes, allowMalformed: true));
        final features = data['features'] as List;
        
        final List<Map<String, dynamic>> mappedResults = features.map((f) {
          final props = f['properties'] as Map<String, dynamic>;
          final geom = f['geometry']['coordinates'] as List;
          
          // Build a readable display name
          final name = props['name'] ?? '';
          final city = props['city'] ?? props['town'] ?? props['district'] ?? '';
          final state = props['state'] ?? '';
          
          String displayName = name;
          if (city.isNotEmpty) displayName += ', $city';
          if (state.isNotEmpty && state != city) displayName += ', $state';

          return {
            'display_name': displayName,
            'lat': geom[1].toString(),
            'lon': geom[0].toString(),
          };
        }).toList();

        setState(() {
          _results = mappedResults;
          _isSearching = false;
        });
      } else {
        debugPrint('Photon HTTP ${res.statusCode}');
        setState(() => _isSearching = false);
      }
    } catch (e) {
      debugPrint('Photon search error: $e');
      if (mounted) setState(() => _isSearching = false);
    }

    _showOrUpdateOverlay();
  }

  // Removed localSearch fallback as requested

  // ── Overlay ──────────────────────────────────────────────────────
  void _showOrUpdateOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
      return;
    }
    _overlayEntry = _buildOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _buildOverlayEntry() {
    return OverlayEntry(
      builder: (ctx) {
        return Positioned(
          width: _boxWidth(),
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 48),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              child: _buildDropdown(),
            ),
          ),
        );
      },
    );
  }

  double _boxWidth() {
    final box = context.findRenderObject() as RenderBox?;
    return box?.size.width ?? 300;
  }

  Widget _buildDropdown() {
    if (_isSearching && _results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Searching…', style: TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      );
    }

    if (!_isSearching && _results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: Text(
          'No results found.',
          style: TextStyle(fontSize: 12, color: Colors.black45),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 230),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: _results.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.grey.shade100),
        itemBuilder: (_, index) {
          final place = _results[index];
          final name = place['display_name'] as String? ?? '';
          // Split into primary (first segment) and secondary (rest)
          final parts = name.split(', ');
          final primary = parts.first;
          final secondary =
              parts.length > 1 ? parts.skip(1).join(', ') : '';

          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _selectPlace(place),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(Icons.location_on_outlined,
                        size: 15, color: AppColors.blueAccent),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          primary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
                        ),
                        if (secondary.isNotEmpty)
                          Text(
                            secondary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.black45),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _selectPlace(Map<String, dynamic> place) {
    final name = place['display_name'] as String? ?? '';
    final parts = name.split(', ');
    _controller.text = parts.take(2).join(', ');
    setState(() {
      _locationSelected = true;
      _results = [];
      _isSearching = false;
    });
    _removeOverlay();
    _focusNode.unfocus();
    widget.onLocationSelected?.call(place);
  }

  void _clearSelection() {
    _controller.clear();
    setState(() {
      _locationSelected = false;
      _results = [];
    });
    _removeOverlay();
    widget.onLocationSelected?.call({});
  }

  // ── Lifecycle ───────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
      _locationSelected = true;
    }
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // slight delay so tap on overlay item registers first
        Future.delayed(const Duration(milliseconds: 120), () {
          if (mounted && !_focusNode.hasFocus) _removeOverlay();
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant CompactTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != null && widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue!;
      _locationSelected = true;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.primaryMain,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: _locationSelected || _controller.text.isNotEmpty
                    ? AppColors.primaryMain
                    : AppColors.primaryMain.withValues(alpha: 0.5),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _locationSelected ? Icons.check_circle_outline : widget.prefixIcon,
                  size: 16,
                  color: AppColors.primaryMain,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryMain.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      suffixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(8),
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryMain),
                              ),
                            )
                          : _locationSelected || _controller.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: _clearSelection,
                                  child: const Icon(Icons.close, size: 15, color: AppColors.primaryMain),
                                )
                              : null,
                      suffixIconConstraints:
                          const BoxConstraints(maxWidth: 30, maxHeight: 30),
                    ),
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryMain,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    onChanged:
                        widget.onLocationSelected != null ? _onTextChanged : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
