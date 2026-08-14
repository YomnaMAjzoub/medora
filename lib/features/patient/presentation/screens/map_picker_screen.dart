import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/core/theme/app_theme.dart';

/// Result of picking a location on [MapPickerScreen].
class MapPickResult {
  const MapPickResult({required this.latitude, required this.longitude, required this.address});

  final double latitude;
  final double longitude;
  final String address;
}

enum _PermissionResult { granted, denied, deniedForever, serviceDisabled }

extension on _PermissionResult {
  String? get message {
    switch (this) {
      case _PermissionResult.granted:
        return null;
      case _PermissionResult.denied:
        return 'location_permission_denied'.tr();
      case _PermissionResult.deniedForever:
        return 'location_permission_denied_forever'.tr();
      case _PermissionResult.serviceDisabled:
        return 'location_services_disabled'.tr();
    }
  }
}

/// Full-screen Google Map location picker used by the Home Visit booking
/// step. The patient can search for an address, tap the current-location
/// button or simply drag the map to line up the centre pin; the address is
/// reverse-geocoded automatically and confirmed with the bottom button.
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key, this.initialLocation, this.initialAddress});

  final LatLng? initialLocation;
  final String? initialAddress;

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  static const _fallbackCenter = LatLng(33.8938, 35.5018);

  final TextEditingController _searchController = TextEditingController();

  GoogleMapController? _mapController;
  LatLng _center = _fallbackCenter;
  bool _isResolvingAddress = false;
  bool _isLocating = false;
  bool _isSearching = false;
  String? _locationError;
  String _address = '';
  bool _permissionDeniedForever = false;

  @override
  void initState() {
    super.initState();
    _center = widget.initialLocation ?? _fallbackCenter;
    _address = widget.initialAddress ?? '';
    _searchController.text = _address;
    if (widget.initialLocation == null) {
      _useCurrentLocation();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLocating = true;
      _locationError = null;
      _permissionDeniedForever = false;
    });
    try {
      final permissionResult = await _ensureLocationPermission();
      if (permissionResult != _PermissionResult.granted) {
        setState(() {
          _locationError = permissionResult.message;
          _permissionDeniedForever =
              permissionResult == _PermissionResult.deniedForever;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final target = LatLng(position.latitude, position.longitude);

      _center = target;
      // Also moves the camera when this runs before onMapCreated (null
      // controller is a no-op); onMapCreated re-animates as a fallback.
      await _mapController?.animateCamera(CameraUpdate.newLatLng(target));
      await _resolveAddress(target);
    } catch (_) {
      if (mounted) {
        setState(() => _locationError = 'location_error'.tr());
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<_PermissionResult> _ensureLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return _PermissionResult.serviceDisabled;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return _PermissionResult.deniedForever;
    }
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return _PermissionResult.granted;
    }
    return _PermissionResult.denied;
  }

  Future<void> _searchAddress() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _isSearching = true;
      _locationError = null;
    });
    try {
      final locations = await geocoding.locationFromAddress(query);
      if (locations.isEmpty) {
        setState(() => _locationError = 'no_address_found'.tr());
        return;
      }
      final first = locations.first;
      final target = LatLng(first.latitude, first.longitude);
      _center = target;
      await _mapController?.animateCamera(CameraUpdate.newLatLng(target));
      await _resolveAddress(target);
    } catch (_) {
      if (mounted) {
        setState(() => _locationError = 'no_address_found'.tr());
      }
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _resolveAddress(LatLng target) async {
    setState(() => _isResolvingAddress = true);
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(
        target.latitude,
        target.longitude,
      );
      if (placemarks.isEmpty) return;

      final placemark = placemarks.first;
      final parts = [
        placemark.street,
        placemark.subLocality,
        placemark.locality,
        placemark.country,
      ].where((part) => part != null && part.isNotEmpty);
      final resolved = parts.join(', ');
      setState(() {
        _address = resolved;
        _searchController.text = resolved;
      });
    } catch (_) {
      // Reverse geocoding can fail (offline, no result for these
      // coordinates) -- non-fatal, the patient can type the address by hand.
    } finally {
      if (mounted) setState(() => _isResolvingAddress = false);
    }
  }

  void _confirm() {
    final address = _address.trim().isEmpty
        ? _searchController.text.trim()
        : _address.trim();
    if (address.isEmpty) {
      Get.snackbar('warning'.tr(), 'address_required'.tr());
      return;
    }
    Navigator.pop(
      context,
      MapPickResult(
        latitude: _center.latitude,
        longitude: _center.longitude,
        address: address,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 16),
            onMapCreated: (map) {
              _mapController = map;
              // Re-animate in case the camera was moved before the map
              // finished initialising (e.g. by _useCurrentLocation).
              map.animateCamera(CameraUpdate.newLatLng(_center));
            },
            onCameraMove: (position) => _center = position.target,
            onCameraIdle: () => _resolveAddress(_center),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
          ),
          // Fixed centre pin -- the map moves underneath it. The pin is
          // shifted up by half its height so its TIP sits exactly on the
          // map centre, which is the coordinate saved on confirm.
          IgnorePointer(
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, -24),
                child: const Icon(
                  Icons.location_pin,
                  size: 48,
                  color: AppColors.primary700,
                  shadows: [
                    Shadow(color: Colors.white70, blurRadius: 6),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.primary700,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: colors.surface,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _searchAddress(),
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: colors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'search_address_hint'.tr(),
                            hintStyle: GoogleFonts.roboto(
                              fontSize: 13,
                              color: colors.textHint,
                            ),
                            prefixIcon: _isSearching
                                ? const Padding(
                                    padding: EdgeInsets.all(13),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary700,
                                    ),
                                  )
                                : const Icon(
                                    Icons.search_rounded,
                                    color: AppColors.primary700,
                                  ),
                            filled: true,
                            fillColor: colors.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: colors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: colors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: AppColors.primary700),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_locationError != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: AppColors.primary700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _locationError!,
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                          if (_permissionDeniedForever)
                            TextButton(
                              onPressed: Geolocator.openAppSettings,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                              ),
                              child: Text(
                                'settings'.tr(),
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 200,
            child: FloatingActionButton.small(
              heroTag: 'map-picker-locate-me',
              backgroundColor: colors.surface,
              foregroundColor: AppColors.primary700,
              elevation: 2,
              onPressed: _isLocating ? null : () => _useCurrentLocation(),
              child: _isLocating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary700,
                      ),
                    )
                  : const Icon(Icons.my_location_rounded),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 14, 20, 20 +
                  MediaQuery.of(context).padding.bottom),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary900.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.place_outlined,
                          size: 18, color: AppColors.primary700),
                      const SizedBox(width: 6),
                      Text(
                        'selected_address'.tr(),
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    minLines: 1,
                    maxLines: 3,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: colors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: _isResolvingAddress
                          ? 'finding_address'.tr()
                          : 'address_hint'.tr(),
                      hintStyle: GoogleFonts.roboto(
                        fontSize: 13,
                        color: colors.textHint,
                      ),
                      filled: true,
                      fillColor: colors.inputFill,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.primary700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _searchController.text.trim().isEmpty
                          ? null
                          : _confirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary900,
                        disabledBackgroundColor: colors.border,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'confirm_location'.tr(),
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
