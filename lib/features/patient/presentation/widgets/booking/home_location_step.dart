import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medora_git/core/const/app_colors.dart';
import 'package:medora_git/features/patient/business_layer/controller/booking_controller.dart';

/// Step 3 of the booking flow -- only shown for [VisitType.home] (see
/// [BookingController.steps]). The patient drags the map to line up a
/// fixed centre pin with where the doctor should come; the address field
/// below stays in sync via reverse geocoding but can also be edited by
/// hand. Confirming calls [BookingController.confirmHomeLocation], which
/// stores the pick and advances to date & time.
class HomeLocationStep extends StatefulWidget {
  const HomeLocationStep({super.key});

  @override
  State<HomeLocationStep> createState() => _HomeLocationStepState();
}

class _HomeLocationStepState extends State<HomeLocationStep> {
  // Beirut -- only used as a starting point if GPS is unavailable/denied
  // and the patient hasn't picked a location yet.
  static const _fallbackCenter = LatLng(33.8938, 35.5018);

  final BookingController controller = Get.find<BookingController>();
  final TextEditingController _addressController = TextEditingController();

  GoogleMapController? _mapController;
  LatLng _center = _fallbackCenter;
  bool _isResolvingAddress = false;
  bool _isLocating = false;
  String? _locationError;
  bool _permissionDeniedForever = false;

  @override
  void initState() {
    super.initState();
    final existingLocation = controller.homeVisitLatLng.value;
    if (existingLocation != null) {
      _center = existingLocation;
      _addressController.text = controller.homeVisitAddress.value ?? '';
    } else {
      // moveCamera stays true: if GPS resolves *after* the map finishes
      // creating, this animates the camera to it. If GPS resolves
      // *before* onMapCreated fires (map still null here, so this call
      // is a no-op), onMapCreated below re-checks `_center` and syncs
      // the camera itself -- either ordering ends with the pin and the
      // resolved address pointing at the same place.
      _useCurrentLocation();
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation({bool moveCamera = true}) async {
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
      if (moveCamera) {
        await _mapController?.animateCamera(CameraUpdate.newLatLng(target));
      }
      await _resolveAddress(target);
    } catch (_) {
      if (mounted) {
        setState(
          () => _locationError =
              "Couldn't get your location. You can still drag the map or type the address.",
        );
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
      _addressController.text = parts.join(', ');
    } catch (_) {
      // Reverse geocoding can fail (offline, no result for these
      // coordinates) -- non-fatal, the patient can type the address by hand.
    } finally {
      if (mounted) setState(() => _isResolvingAddress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Home Visit Location',
                style: GoogleFonts.roboto(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Drag the map to pin exactly where the doctor should come',
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  color: AppColors.grey300,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 320,
          child: Stack(
            alignment: Alignment.center,
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 16,
                ),
                onMapCreated: (map) {
                  _mapController = map;
                  // GPS may have already resolved a real location before
                  // the native map finished initializing -- if so, `_center`
                  // has moved on from the fallback but the map was built
                  // with the old `initialCameraPosition`, so sync it now.
                  if (_center != _fallbackCenter) {
                    map.animateCamera(CameraUpdate.newLatLng(_center));
                  }
                },
                onCameraMove: (position) => _center = position.target,
                onCameraIdle: () => _resolveAddress(_center),
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
              // Fixed centre pin -- the map moves underneath it, so its tip
              // (not its centre) always marks the currently selected point.
              const IgnorePointer(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 36),
                  child: Icon(
                    Icons.location_pin,
                    size: 44,
                    color: AppColors.primary700,
                  ),
                ),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton.small(
                  heroTag: 'home-visit-locate-me',
                  backgroundColor: AppColors.white,
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
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Address',
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey300,
                ),
              ),
              if (_locationError != null) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            color: AppColors.grey400,
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
                            'Settings',
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
              ],
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                minLines: 1,
                maxLines: 3,
                onChanged: (_) => setState(
                  () {},
                ), // keeps the Confirm button's enabled state in sync
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: AppColors.grey500,
                ),
                decoration: InputDecoration(
                  hintText: _isResolvingAddress
                      ? 'Finding address…'
                      : 'e.g. Building 12, Hamra Street, Beirut',
                  hintStyle: GoogleFonts.roboto(
                    fontSize: 13,
                    color: AppColors.grey200,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.neutral200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.neutral200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary700),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addressController.text.trim().isEmpty
                      ? null
                      : () => controller.confirmHomeLocation(
                          location: _center,
                          address: _addressController.text.trim(),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary900,
                    disabledBackgroundColor: AppColors.neutral300,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Confirm Location',
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
      ],
    );
  }
}

enum _PermissionResult { granted, denied, deniedForever, serviceDisabled }

extension on _PermissionResult {
  String? get message {
    switch (this) {
      case _PermissionResult.granted:
        return null;
      case _PermissionResult.denied:
        return "Location permission was declined. You can still drag the map or type the address by hand.";
      case _PermissionResult.deniedForever:
        return "Location access is disabled for this app. Enable it in Settings, or drag the map / type the address.";
      case _PermissionResult.serviceDisabled:
        return "Location services are off on this device. Turn them on, or drag the map / type the address.";
    }
  }
}
