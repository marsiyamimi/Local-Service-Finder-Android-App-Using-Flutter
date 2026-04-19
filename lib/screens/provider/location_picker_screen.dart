import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_button.dart';

class LocationPickerScreen extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final String? initialAddress;

  const LocationPickerScreen({
    super.key,
    this.initialLat = 0,
    this.initialLng = 0,
    this.initialAddress,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _pickedLocation;
  String _address = 'Tap on the map to pick location';
  bool _isLoadingLocation = false;
  bool _isGeocoding = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != 0 || widget.initialLng != 0) {
      _pickedLocation = LatLng(widget.initialLat, widget.initialLng);
      _address = widget.initialAddress ?? 'Current location';
    }
  }

  // ── Get device current GPS location ──────────────────────────────────
  Future<void> _useCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('Location services are disabled. Please enable GPS.');
        setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permission denied.');
          setState(() => _isLoadingLocation = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showError(
            'Location permission permanently denied. Enable in Settings.');
        setState(() => _isLoadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final latLng = LatLng(position.latitude, position.longitude);
      await _updateLocation(latLng);

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 15),
        ),
      );
    } catch (e) {
      _showError('Could not get location: $e');
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  // ── Reverse-geocode a LatLng to readable address ──────────────────────
  Future<void> _updateLocation(LatLng latLng) async {
    setState(() {
      _pickedLocation = latLng;
      _isGeocoding = true;
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [
          if (p.street?.isNotEmpty == true) p.street,
          if (p.subLocality?.isNotEmpty == true) p.subLocality,
          if (p.locality?.isNotEmpty == true) p.locality,
          if (p.administrativeArea?.isNotEmpty == true) p.administrativeArea,
          if (p.country?.isNotEmpty == true) p.country,
        ];
        setState(() => _address = parts.join(', '));
      }
    } catch (_) {
      setState(() => _address =
          '${latLng.latitude.toStringAsFixed(5)}, ${latLng.longitude.toStringAsFixed(5)}');
    } finally {
      if (mounted) setState(() => _isGeocoding = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.rejected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final initialCamera = CameraPosition(
      target: _pickedLocation ??
          const LatLng(37.7749, -122.4194), // Default: San Francisco
      zoom: _pickedLocation != null ? 15 : 10,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          if (_pickedLocation != null)
            TextButton(
              onPressed: () => Navigator.pop(context, {
                'lat': _pickedLocation!.latitude,
                'lng': _pickedLocation!.longitude,
                'address': _address,
              }),
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: initialCamera,
            onMapCreated: (ctrl) => _mapController = ctrl,
            onTap: (latLng) => _updateLocation(latLng),
            markers: _pickedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('picked'),
                      position: _pickedLocation!,
                      infoWindow: InfoWindow(
                        title: 'Your Location',
                        snippet: _address,
                      ),
                    ),
                  }
                : {},
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapType: MapType.normal,
          ),

          // ── Instruction overlay (shown before tap) ─────────────────
          if (_pickedLocation == null)
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withOpacity(0.75)
                      : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app_rounded,
                        color: theme.colorScheme.primary, size: 22),
                    const SizedBox(width: 10),
                    const Flexible(
                      child: Text(
                        'Tap anywhere on the map to set your location',
                        style: TextStyle(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Bottom address bar ──────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Address display
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: _isGeocoding
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : Icon(
                                Icons.location_on_rounded,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Location',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontSize: 11),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _address,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Use current location button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          _isLoadingLocation ? null : _useCurrentLocation,
                      icon: _isLoadingLocation
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.primary,
                              ),
                            )
                          : Icon(Icons.my_location_rounded,
                              size: 18, color: theme.colorScheme.primary),
                      label: Text(
                        _isLoadingLocation
                            ? 'Getting location...'
                            : 'Use My Current Location',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Confirm button
                  GradientButton(
                    text: _pickedLocation == null
                        ? 'Tap map to select location'
                        : 'Confirm This Location',
                    onPressed: _pickedLocation == null
                        ? null
                        : () => Navigator.pop(context, {
                              'lat': _pickedLocation!.latitude,
                              'lng': _pickedLocation!.longitude,
                              'address': _address,
                            }),
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
