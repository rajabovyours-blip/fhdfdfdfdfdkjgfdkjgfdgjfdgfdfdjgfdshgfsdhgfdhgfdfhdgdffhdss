import 'package:flutter/material.dart';
import 'dart:async';
import 'package:milliy_metr/shared/widgets/app_snackbar.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class LocationSelector extends StatefulWidget {
  const LocationSelector({super.key});

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  String? _location; // Now nullable to use translation
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      await _fetchLocation();
    }
  }

  Future<void> _fetchLocation() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        if (!mounted) return;
        final Placemark place = placemarks.first;
        final String locality = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? '';
        final String country = place.country ?? '';
        String address = [locality, country].where((s) => s.isNotEmpty).join(', ');
        
        if (address.isEmpty) address = context.l10n.tashkentUzbekistan;

        if (mounted) {
          setState(() {
            _location = address;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, context.l10n.errorOccurred);
        setState(() {
          _location = context.l10n.tashkentUzbekistan;
        });
      }
    }
  }

  Future<void> _requestLocation() async {
    setState(() => _isLoading = true);
    
    // Block background touches while permission dialog might be open
    unawaited(showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: SizedBox.expand(),
      ),
    ));

    try {
      final status = await Permission.location.request();

      if (status.isGranted) {
        await _fetchLocation();
      } else if (status.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.pleaseAllowFromSettings),
              action: SnackBarAction(
                label: context.l10n.settings,
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, context.l10n.errorOccurred);
      }
    } finally {
      if (mounted) {
        // Pop the barrier dialog
        Navigator.of(context, rootNavigator: true).pop();
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _requestLocation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(Icons.location_on, color: context.colors.primary, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.deliveryAddress,
                  style: TextStyle(
                    color: context.colors.textMedium,
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [
                    _isLoading
                        ? SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.colors.primary,
                            ),
                          )
                        : Text(
                            _location ?? context.l10n.determineLocation,
                            style: TextStyle(
                              color: context.colors.textHigh,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                    if (!_isLoading)
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: context.colors.textDisabled,
                        size: 18,
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
