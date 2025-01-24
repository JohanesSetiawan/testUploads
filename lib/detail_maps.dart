import 'package:elangv2_jdk19/detail_outlet.dart';
import 'package:elangv2_jdk19/detail_site.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'dart:math' as math;

class DetailMaps extends StatefulWidget {
  final String kecamatan;
  final String brand;

  const DetailMaps({
    super.key,
    required this.kecamatan,
    required this.brand,
  });

  @override
  State<DetailMaps> createState() => _DetailMapsState();
}

// Model class for outlet location
class OutletLocation {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  double? distance;
  final String status;

  OutletLocation(
      {required this.id,
      required this.name,
      required this.latitude,
      required this.longitude,
      this.distance,
      required this.status});

  factory OutletLocation.fromJson(Map<String, dynamic> json) {
    return OutletLocation(
      id: json['id'],
      name: json['name'],
      latitude: double.parse(json['lat']),
      longitude: double.parse(json['long']),
      status: json['status'],
    );
  }
}

class _DetailMapsState extends State<DetailMaps> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Position? userPosition;
  OutletLocation? selectedOutlet;

  bool showInfo = false;
  bool isLoading = true;
  bool isLocationPermissionGranted = false;

  // Filter variables
  bool showOutlets = true;
  bool showSites = true;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied'),
          ),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        userPosition = position;
      });

      setState(() {
        isLocationPermissionGranted = true;
      });

      await fetchOutletLocations();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location error: ${e.toString()}')),
      );
      // Still fetch outlets even if location access fails
      await fetchOutletLocations();
    }
  }

  Future<void> fetchOutletLocations() async {
    try {
      final response = await http.get(Uri.parse(
          'http://103.157.116.221:8088/elang-dashboard-backend/public/api/v1/maps/${widget.kecamatan}/site-outlet?brand=${widget.brand}'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> locationsData = jsonResponse['data'];
        final outlets =
            locationsData.map((data) => OutletLocation.fromJson(data)).toList();

        // Calculate distance if user location is available
        if (userPosition != null) {
          for (var outlet in outlets) {
            outlet.distance = calculateDistance(
              userPosition!.latitude,
              userPosition!.longitude,
              outlet.latitude,
              outlet.longitude,
            );
          }
        }

        setState(() {
          // Add user location marker
          markers = {};
          if (userPosition != null) {
            markers.add(
              Marker(
                markerId: const MarkerId('user_location'),
                position:
                    LatLng(userPosition!.latitude, userPosition!.longitude),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue),
                infoWindow: const InfoWindow(title: 'Your Location'),
              ),
            );
          }

          // Add outlet markers
          markers.addAll(outlets.where((outlet) {
            if (showOutlets && outlet.status == 'OUTLET') return true;
            if (showSites && outlet.status == 'SITE') return true;
            return false;
          }).map((outlet) {
            // Define marker color based on status
            BitmapDescriptor markerIcon;
            if (outlet.status == 'SITE') {
              markerIcon = BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed);
            } else if (outlet.status == 'OUTLET') {
              markerIcon = BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen);
            } else {
              markerIcon = BitmapDescriptor.defaultMarker; // Default red marker
            }

            return Marker(
              markerId: MarkerId(outlet.id),
              position: LatLng(outlet.latitude, outlet.longitude),
              icon: markerIcon,
              onTap: () {
                setState(() {
                  selectedOutlet = outlet;
                  showInfo = true;
                });
              },
            );
          }));

          isLoading = false;
        });

        if (markers.isNotEmpty) {
          final bounds =
              boundsFromLatLngList(markers.map((m) => m.position).toList());
          mapController?.animateCamera(
            CameraUpdate.newLatLngBounds(bounds, 50.0),
          );
        }
      } else {
        SnackBar(
            content:
                Text('Failed to load outlet locations ${response.statusCode}'));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      const SnackBar(content: Text('Failed to load outlet locations'));
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Radius of Earth in kilometers

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c; // Distance in kilometers
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180;
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }

  void navigateToDetail(String status, String id) {
    if (status == 'OUTLET') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailOutlet(qrCode: id),
        ),
      );
    } else if (status == 'SITE') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailSite(siteId: id, brand: widget.brand),
        ),
      );
    }
  }

  Widget _buildInfoWindow() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: showInfo ? 70 : -200,
      left: 20,
      right: 20,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: showInfo ? 1.0 : 0.0,
        child: GestureDetector(
          onTap: () {
            setState(() {
              showInfo = false;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedOutlet?.name ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ID: ${selectedOutlet?.id ?? ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    if (selectedOutlet != null) {
                      navigateToDetail(
                          selectedOutlet!.status, selectedOutlet!.id);
                    }
                  },
                  child: Text(
                    'Status: ${selectedOutlet?.status ?? ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (selectedOutlet?.distance != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Distance: ${selectedOutlet!.distance!.toStringAsFixed(2)} km',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: const Text('Show Outlets'),
                  value: showOutlets,
                  onChanged: (bool? value) {
                    setState(() {
                      showOutlets = value ?? true;
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Show Sites'),
                  value: showSites,
                  onChanged: (bool? value) {
                    setState(() {
                      showSites = value ?? true;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    fetchOutletLocations();
                  },
                  child: const Text('Apply Filters'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target:
                        LatLng(userPosition!.latitude, userPosition!.longitude),
                    zoom: 10.0,
                  ),
                  markers: markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: true,
                  onTap: (_) {
                    setState(() {
                      showInfo = false;
                    });
                  },
                ),
          if (selectedOutlet != null) _buildInfoWindow(),
        ],
      ),
      floatingActionButton: Opacity(
        opacity: 0.75,
        child: FloatingActionButton(
          onPressed: _showFilterMenu,
          backgroundColor: Colors.white,
          child: const Icon(Icons.filter_list, color: Colors.black),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
