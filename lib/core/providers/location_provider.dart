import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/constants/uzbekistan_regions.dart';
import 'package:milliy_metr/core/services/location_service.dart';
import 'package:milliy_metr/core/storage/preferences.dart';

class LocationState {
  final RegionItem? region;
  final DistrictItem? district;
  final bool isLoading;

  const LocationState({
    this.region,
    this.district,
    this.isLoading = false,
  });

  LocationState copyWith({
    RegionItem? region,
    DistrictItem? district,
    bool? isLoading,
  }) {
    return LocationState(
      region: region ?? this.region,
      district: district ?? this.district,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  final LocationService _locationService;

  LocationNotifier(this._locationService) : super(const LocationState()) {
    _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    final regionId = PreferencesManager.getString('selected_region_id');
    final districtId = PreferencesManager.getString('selected_district_id');

    if (regionId != null && districtId != null) {
      try {
        final region = uzbekistanRegionsData.firstWhere((r) => r.id == regionId);
        final district = region.districts.firstWhere((d) => d.id == districtId);
        state = state.copyWith(region: region, district: district);
      } catch (e) {
        // Fallback if not found
        _setFallbackLocation();
      }
    } else {
      _setFallbackLocation();
    }
  }

  void _setFallbackLocation() {
    final region = uzbekistanRegionsData.firstWhere((r) => r.id == 'tashkent_city');
    final district = region.districts.first;
    state = state.copyWith(region: region, district: district);
  }

  Future<void> updateLocation(RegionItem region, DistrictItem district) async {
    state = state.copyWith(region: region, district: district);
    await PreferencesManager.setString('selected_region_id', region.id);
    await PreferencesManager.setString('selected_district_id', district.id);
  }

  Future<void> determineLocation() async {
    state = state.copyWith(isLoading: true);
    
    final position = await _locationService.getCurrentPosition();
    if (position != null) {
      final placemark = await _locationService.getPlacemarkFromCoordinates(
          position.latitude, position.longitude,);

      if (placemark != null) {
        final String? locality = placemark.locality;
        final String? subAdministrativeArea = placemark.subAdministrativeArea;
        final String? administrativeArea = placemark.administrativeArea;

        RegionItem? matchedRegion;
        DistrictItem? matchedDistrict;

        // Simple fuzzy match
        for (var region in uzbekistanRegionsData) {
          if (_matches(region.nameUz, administrativeArea) ||
              _matches(region.nameRu, administrativeArea) ||
              _matches(region.nameEn, administrativeArea)) {
            matchedRegion = region;
            for (var district in region.districts) {
              if (_matches(district.nameUz, locality) ||
                  _matches(district.nameUz, subAdministrativeArea) ||
                  _matches(district.nameRu, locality) ||
                  _matches(district.nameEn, locality)) {
                matchedDistrict = district;
                break;
              }
            }
            break;
          }
        }

        if (matchedRegion != null && matchedDistrict != null) {
          await updateLocation(matchedRegion, matchedDistrict);
        } else {
          // If we can't match it perfectly, default to Tashkent
          _setFallbackLocation();
        }
      }
    }

    state = state.copyWith(isLoading: false);
  }

  bool _matches(String name, String? query) {
    if (query == null) return false;
    final normalizedName = name.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    final normalizedQuery = query.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    return normalizedName.contains(normalizedQuery) || normalizedQuery.contains(normalizedName);
  }
}

final locationServiceProvider = Provider((ref) => LocationService());

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  final service = ref.watch(locationServiceProvider);
  return LocationNotifier(service);
});
