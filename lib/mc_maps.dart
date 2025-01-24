import 'package:elangv2_jdk19/detail_outlet.dart';
import 'package:elangv2_jdk19/detail_site.dart';
import 'package:elangv2_jdk19/home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'dart:async';

class McMaps extends StatefulWidget {
  final String brand;

  const McMaps({
    super.key,
    required this.brand,
  });

  @override
  State<McMaps> createState() => _McMapsState();
}

class OutletLocation {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String status;
  final String branch;
  final String brand;
  final String distance;
  final String gaKondisi;

  OutletLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.branch,
    required this.brand,
    required this.distance,
    required this.gaKondisi,
  });

  factory OutletLocation.fromJson(Map<String, dynamic> json) {
    return OutletLocation(
      id: json['id'],
      name: json['name'],
      latitude: double.parse(json['lat']),
      longitude: double.parse(json['long']),
      status: json['status'],
      branch: json['branch'],
      brand: json['brand'],
      distance: json['distance'],
      gaKondisi: json['ga_kondisi'],
    );
  }
}

class _McMapsState extends State<McMaps> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Position? userPosition;
  OutletLocation? selectedOutlet;
  StreamSubscription<Position>? _positionStreamSubscription;

  bool showInfo = false;
  bool isLoading = true;
  bool isLocationPermissionGranted = false;

  bool showOutlets = true;
  bool showSites = true;
  String gaKondisiFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _startLocationStream();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    mapController?.dispose();
    super.dispose();
  }

  void _startLocationStream() {
    const LocationSettings locationSettings = LocationSettings(
      distanceFilter: 10,
      accuracy: LocationAccuracy.high,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      setState(() {
        userPosition = position;
      });
      fetchOutletLocations();
    });
  }

  Future<void> _checkLocationPermission() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

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
        isLocationPermissionGranted = true;
      });

      await fetchOutletLocations();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location error: ${e.toString()}')),
      );
      await fetchOutletLocations();
    }
  }

  Future<void> fetchOutletLocations() async {
    try {
      final response = await http.get(Uri.parse(
          'http://103.157.116.221:8088/elang-dashboard-backend/public/api/v1/maps/site-outlet?latitude=${userPosition!.latitude}&longitude=${userPosition!.longitude}'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> locationsData = jsonResponse['data'];
        final outlets =
            locationsData.map((data) => OutletLocation.fromJson(data)).toList();

        setState(() {
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

          markers.addAll(outlets.where((outlet) {
            if (gaKondisiFilter != 'ALL' &&
                outlet.gaKondisi != gaKondisiFilter) {
              return false;
            }
            if (showOutlets && outlet.status == 'OUTLET') return true;
            if (showSites && outlet.status == 'SITE') return true;
            return false;
          }).map((outlet) {
            return Marker(
              markerId: MarkerId(outlet.id),
              position: LatLng(outlet.latitude, outlet.longitude),
              icon: outlet.status == 'OUTLET'
                  ? BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen)
                  : BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed),
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
          final bounds = LatLngBounds(
            southwest: LatLng(
              userPosition!.latitude - 0.01,
              userPosition!.longitude - 0.01,
            ),
            northeast: LatLng(
              userPosition!.latitude + 0.01,
              userPosition!.longitude + 0.01,
            ),
          );

          mapController
              ?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to load outlet locations: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load outlet locations: $e')),
      );
    }
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
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Branch: ${selectedOutlet?.branch ?? ''}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Brand: ${selectedOutlet?.brand ?? ''}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Distance: ${selectedOutlet?.distance ?? ''} km',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'GA KONDISI: ${selectedOutlet?.gaKondisi ?? ''}',
                  style: const TextStyle(fontSize: 14),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('GA Kondisi', style: TextStyle(fontSize: 16)),
                      DropdownButton<String>(
                        value: gaKondisiFilter,
                        items: const [
                          DropdownMenuItem(
                            value: 'ALL',
                            child: Text('ALL'),
                          ),
                          DropdownMenuItem(
                            value: 'GA_YA',
                            child: Text('GA YA'),
                          ),
                          DropdownMenuItem(
                            value: 'GA_TIDAK',
                            child: Text('GA TIDAK'),
                          ),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            gaKondisiFilter = newValue ?? 'ALL';
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      fetchOutletLocations();
                    },
                    child: const Text('Apply'),
                  ),
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Homepage()),
            );
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
                    target: LatLng(
                      userPosition?.latitude ?? 0.0,
                      userPosition?.longitude ?? 0.0,
                    ),
                    zoom: 15.0,
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
          Positioned(
            bottom: 20,
            left: 20,
            child: Opacity(
              opacity: 0.75,
              child: FloatingActionButton(
                onPressed: _showFilterMenu,
                backgroundColor: Colors.white,
                child: const Icon(Icons.filter_list, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
