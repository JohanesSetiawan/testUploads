import 'package:elangv2_jdk19/detail_outlet.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'home_page.dart';
import 'auth_provider.dart';
import 'dart:math';

class FilteringOutlet extends StatefulWidget {
  final int idSec;
  final String selectedRegion;
  final String selectedArea;
  final String selectedBranch;
  final String selectedNameFO;

  const FilteringOutlet({
    super.key,
    required this.idSec,
    required this.selectedRegion,
    required this.selectedArea,
    required this.selectedBranch,
    required this.selectedNameFO,
  });

  @override
  State<FilteringOutlet> createState() => _FOState();
}

class _FOState extends State<FilteringOutlet> {
  String _formattedDate() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]} ${now.year}';
  }

  final TextEditingController _searchController = TextEditingController();

  final String _selectedDropdown1 = 'Circle Java';
  String? _selectedDropdown2;
  String? _selectedDropdown3;
  String? _selectedDropdown4;
  String _searchText = '';

  Position? _currentPosition;

  List<Map<String, dynamic>> _FOData = [];
  List<Map<String, dynamic>> _filteredFOData = [];

  final Map<String, Map<String, dynamic>> _outletLocations = {};

  var baseURL = 'http://103.157.116.221:8088/elang-dashboard-backend/public';

  Future<void> fetchFOData() async {
    final filteringOutlet = widget.selectedNameFO;
    final mc = widget.idSec;
    final url = '$baseURL/api/v1/outlet/$filteringOutlet?mc=$mc';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> FODataReceived = data['data'];

        setState(() {
          _FOData = FODataReceived.map((fo) => {
                'qr_code': fo['qr_code'],
                'outlet_name': fo['outlet_name'],
                'partner_name': fo['partner_name'],
                'catagory': fo['catagory'],
                'brand': fo['brand'],
              }).toList();
        });
      } else {
        SnackBar(content: Text('Failed to load data: ${response.statusCode}'));
      }
    } catch (e) {
      const SnackBar(content: Text('Error fetching data'));
    }
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Show dialog to enable location services
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Location Services Disabled'),
              content: const Text(
                  'Please enable location services to see distances.'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Location Permission Denied'),
              content: const Text(
                  'Please enable location permissions in settings to see distances.'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    } catch (e) {
      const SnackBar(content: Text('Error getting location'));
    }
  }

  Future<void> _fetchOutletLocation(String qrCode) async {
    if (_outletLocations.containsKey(qrCode)) {
      return; // Already fetched this outlet's location
    }

    try {
      final url = Uri.parse('$baseURL/api/v1/outlet/detail/$qrCode');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _outletLocations[qrCode] = {
            'latitude': data['data']['latitude'],
            'longitude': data['data']['longitude'],
          };
        });
      }
    } catch (e) {
      const SnackBar(content: Text('Error fetching outlet location'));
    }
  }

  String _formatDistance(double distance) {
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)} m';
    }
    return '${distance.toStringAsFixed(1)} km';
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const int earthRadius = 6371; // Radius of the earth in km
    double latDistance = _toRadians(lat2 - lat1);
    double lonDistance = _toRadians(lon2 - lon1);
    double a = sin(latDistance / 2) * sin(latDistance / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(lonDistance / 2) *
            sin(lonDistance / 2);
    double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }

  void _filterData() {
    setState(() {
      _searchText = _searchController.text.toLowerCase();
      _filteredFOData = _FOData.where((fo) {
        final qrCode = fo['qr_code'].toString().toLowerCase();
        final outletName = fo['outlet_name'].toString().toLowerCase();

        return qrCode.contains(_searchText) || outletName.contains(_searchText);
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedDropdown2 = widget.selectedRegion;
    _selectedDropdown3 = widget.selectedArea;
    _selectedDropdown4 = widget.selectedBranch;
    fetchFOData();
    _initializeLocation();
    _searchController.addListener(_filterData);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final role = Provider.of<AuthProvider>(context).role;
    final territory = Provider.of<AuthProvider>(context).territory;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Header Section
            Column(
              children: [
                Container(
                  height: mediaQueryHeight * 0.04,
                  width: mediaQueryWidth * 1.0,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 15, bottom: 8),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        'DATA OUTLET',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: mediaQueryHeight * 0.9,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    image: DecorationImage(
                      image: AssetImage('assets/LOGO.png'),
                      fit: BoxFit.cover,
                      opacity: 0.3,
                      alignment: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CircleAvatar(
                                  radius: 35,
                                  backgroundImage: AssetImage('assets/100.png'),
                                  backgroundColor: Colors.transparent,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        territory,
                                        style: const TextStyle(
                                            fontSize: 10, color: Colors.grey),
                                      ),
                                      Text(
                                        role == 5
                                            ? 'MC'
                                            : role == 1
                                                ? 'CIRCLE'
                                                : role == 2
                                                    ? 'HOR'
                                                    : role == 3
                                                        ? 'HOS'
                                                        : role == 4
                                                            ? 'BSM'
                                                            : 'No Role',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formattedDate(),
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.grey),
                                    ),

                                    // Dropdown 1
                                    DropdownButton<String>(
                                      value: _selectedDropdown1,
                                      isDense: true,
                                      onChanged: null,
                                      items: <String>['Circle Java']
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          alignment:
                                              AlignmentDirectional.centerEnd,
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              value,
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      alignment: Alignment.centerRight,
                                    ),

                                    // Dropdown 2
                                    DropdownButton<String>(
                                      value: _selectedDropdown2,
                                      isDense: true,
                                      onChanged: null, // Disabled dropdown
                                      items: [
                                        DropdownMenuItem<String>(
                                          value: widget.selectedRegion,
                                          alignment:
                                              AlignmentDirectional.centerEnd,
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              widget.selectedRegion,
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                      alignment: Alignment.centerRight,
                                    ),

                                    // Dropdown 3
                                    DropdownButton<String>(
                                      value: _selectedDropdown3,
                                      isDense: true,
                                      onChanged: null, // Disabled dropdown
                                      items: [
                                        DropdownMenuItem<String>(
                                          value: widget.selectedArea,
                                          alignment:
                                              AlignmentDirectional.centerEnd,
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              widget.selectedArea,
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                      alignment: Alignment.centerRight,
                                    ),

                                    // Dropdown 4
                                    DropdownButton<String>(
                                      value: _selectedDropdown4,
                                      isDense: true,
                                      onChanged: null, // Disabled dropdown
                                      items: [
                                        DropdownMenuItem<String>(
                                          value: widget.selectedBranch,
                                          alignment:
                                              AlignmentDirectional.centerEnd,
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              widget.selectedBranch,
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                      alignment: Alignment.centerRight,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                                height: 13), // Add some spacing after dropdowns
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 2,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Search...',
                                    border: InputBorder.none,
                                    icon: Icon(Icons.search,
                                        color: Colors.grey[600]),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              height: mediaQueryHeight * 0.625,
                              child: ListView.builder(
                                itemCount: _searchText.isEmpty
                                    ? _FOData.length
                                    : _filteredFOData.length,
                                itemBuilder: (context, index) {
                                  final fo = _searchText.isEmpty
                                      ? _FOData[index]
                                      : _filteredFOData[index];
                                  return _buildOutletItem(fo);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 55,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.home,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Homepage()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutletItem(Map<String, dynamic> fo) {
    return FutureBuilder(
      future: _fetchOutletLocation(fo['qr_code'].toString()),
      builder: (context, snapshot) {
        String distanceText = 'Calculating distance...';

        if (_currentPosition == null) {
          distanceText = 'Waiting for location...';
        } else if (!_outletLocations.containsKey(fo['qr_code'].toString())) {
          distanceText = 'Loading distance...';
        } else {
          final location = _outletLocations[fo['qr_code'].toString()]!;
          if (location['latitude'] != null && location['longitude'] != null) {
            double distance = _calculateDistance(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              double.parse(location['latitude']),
              double.parse(location['longitude']),
            );
            distanceText = 'Distance: ${_formatDistance(distance)}';
          } else {
            distanceText = 'Distance unavailable';
          }
        }

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: const EdgeInsets.all(10),
          width: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailOutlet(
                    qrCode: fo['qr_code'].toString(),
                  ),
                ),
              );
            },
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fo['qr_code'].toString(),
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                Text(
                  fo['outlet_name'],
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                Text(
                  fo['brand'],
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                Text(
                  distanceText,
                  style: const TextStyle(fontSize: 14, color: Colors.blue),
                ),
              ],
            ),
            trailing:
                const Icon(Icons.arrow_forward_ios, color: Colors.black54),
          ),
        );
      },
    );
  }
}
