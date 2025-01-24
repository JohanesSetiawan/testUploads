import 'package:elangv2_jdk19/detail_outlet_valid.dart';
import 'package:elangv2_jdk19/home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DetailSite extends StatefulWidget {
  final String siteId;
  final String brand;

  const DetailSite({
    super.key,
    required this.siteId,
    required this.brand,
  });

  @override
  State<DetailSite> createState() => _DetSitelateState();
}

class _DetSitelateState extends State<DetailSite> {
  String? siteName;
  String? ptName;
  String? category;
  String? brand;
  String? latitude;
  String? longitude;
  String? asOfDt;

  int? revLmtd;
  int? revMtd;
  int? rgu90Ltmd;
  int? rgu90Mtd;
  int? gaLmtd;
  int? gaMtd;
  int? vlrLmtd;
  int? vlrMtd;
  int? outletValid;

  double? growthRev;
  double? growthRgu;
  double? growthGa;
  double? growthVlr;

  String _formatNumber(int? number) {
    if (number == null) return 'Loading...';
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  var baseURL = 'http://103.157.116.221:8088/elang-dashboard-backend/public';

  Future<void> _fetchDataSortSiteDetail() async {
    final url = Uri.parse(
      '$baseURL/api/v1/sites/${widget.siteId}/detail?brand=${widget.brand}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          siteName = data['data']['site_name'];
          ptName = data['data']['pt_name'];
          category = data['data']['category'];
          brand = data['data']['brand'];
          latitude = data['data']['lat'];
          longitude = data['data']['long'];
          asOfDt = data['data']['asof_dt'];
          outletValid =
              int.tryParse(data['data']['outlet_valid'].toString()) ?? 0;
        });
      } else {
        SnackBar(content: Text('Failed to load data: ${response.statusCode}'));
      }
    } catch (error) {
      const SnackBar(content: Text('Error fetching data'));
    }
  }

  Future<void> _fetchDataSiteGADetail() async {
    final url = Uri.parse(
      '$baseURL/api/v1/sites/${widget.siteId}/detail/ga?brand=${widget.brand}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          gaLmtd = data['data']['ga_lmtd'] as int;
          gaMtd = data['data']['ga_mtd'] as int;
          growthGa = (data['data']['growth'] as num).toDouble();
        });
      } else {
        SnackBar(content: Text('Failed to load data: ${response.statusCode}'));
      }
    } catch (error) {
      const SnackBar(content: Text('Error fetching data'));
    }
  }

  Future<void> _fetchDataSiteRevDetail() async {
    final url = Uri.parse(
      '$baseURL/api/v1/sites/${widget.siteId}/detail/revenue?brand=${widget.brand}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          revLmtd = data['data']['rev_lmtd'];
          revMtd = data['data']['rev_mtd'];
          growthRev = data['data']['growth'];
        });
      } else {
        SnackBar(content: Text('Failed to load data: ${response.statusCode}'));
      }
    } catch (error) {
      const SnackBar(content: Text('Error fetching data'));
    }
  }

  Future<void> _fetchDataSiteRGUDetail() async {
    final url = Uri.parse(
      '$baseURL/api/v1/sites/${widget.siteId}/detail/rgu?brand=${widget.brand}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          growthRgu = (data['data']['growth'] as num).toDouble();
          rgu90Ltmd = data['data']['rgu90_lmtd'] as int;
          rgu90Mtd = data['data']['rgu90_mtd'] as int;
        });
      } else {
        SnackBar(content: Text('Failed to load data: ${response.statusCode}'));
      }
    } catch (error) {
      const SnackBar(content: Text('Error fetching data'));
    }
  }

  Future<void> _fetchDataSiteVLRDetail() async {
    final url = Uri.parse(
      '$baseURL/api/v1/sites/${widget.siteId}/detail/vlr?brand=${widget.brand}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          vlrLmtd = data['data']['vlr_lmtd'] as int;
          vlrMtd = data['data']['vlr_mtd'] as int;
          growthVlr = (data['data']['growth'] as num).toDouble();
        });
      } else {
        SnackBar(content: Text('Failed to load data: ${response.statusCode}'));
      }
    } catch (error) {
      const SnackBar(content: Text('Error fetching data'));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDataSortSiteDetail();
    _fetchDataSiteGADetail();
    _fetchDataSiteRevDetail();
    _fetchDataSiteRGUDetail();
    _fetchDataSiteVLRDetail();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
                        'DETAIL SITE',
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.siteId,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black),
                                        ),
                                        Text(
                                          widget
                                              .brand, // Dynamically display branch name
                                          style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Location Card with Map
                              Card(
                                color: Colors.white,
                                elevation: 5,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Location',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        height: 200,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: latitude != null &&
                                                  longitude != null
                                              ? GoogleMap(
                                                  initialCameraPosition:
                                                      CameraPosition(
                                                    target: LatLng(
                                                      double.parse(latitude!),
                                                      double.parse(longitude!),
                                                    ),
                                                    zoom: 15,
                                                  ),
                                                  markers: {
                                                    Marker(
                                                      markerId: const MarkerId(
                                                          'outlet_location'),
                                                      position: LatLng(
                                                        double.parse(latitude!),
                                                        double.parse(
                                                            longitude!),
                                                      ),
                                                      icon: BitmapDescriptor
                                                          .defaultMarkerWithHue(
                                                        BitmapDescriptor.hueRed,
                                                      ),
                                                    ),
                                                  },
                                                  myLocationEnabled: false,
                                                  zoomControlsEnabled: true,
                                                  mapType: MapType.normal,
                                                )
                                              : const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ...[
                                {
                                  'title': 'Site Detail',
                                  'data': [
                                    {
                                      'label': 'Site ID',
                                      'value': widget.siteId,
                                    },
                                    {
                                      'label': 'Site Name',
                                      'value': siteName,
                                    },
                                    {
                                      'label': 'PT Name',
                                      'value': ptName ?? 'Loading...',
                                    },
                                    {
                                      'label': 'Outlet Valid',
                                      'value': GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailOutletValid(
                                                siteId: widget.siteId,
                                                brand: widget.brand,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          outletValid?.toString() ??
                                              'Loading...',
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    },
                                    {
                                      'label': 'Category',
                                      'value': category ?? 'Loading...',
                                    },
                                    {
                                      'label': 'Brand',
                                      'value': brand ?? 'Loading...',
                                    },
                                    {
                                      'label': 'Last Update',
                                      'value': asOfDt ?? 'Loading...',
                                    },
                                  ]
                                },
                                {
                                  'title': 'Site GA',
                                  'data': [
                                    {
                                      'label': 'GA LMTD',
                                      'value': _formatNumber(gaLmtd),
                                    },
                                    {
                                      'label': 'GA MTD',
                                      'value': _formatNumber(gaMtd),
                                    },
                                    {
                                      'label': 'GROWTH GA',
                                      'value':
                                          '${growthGa?.toStringAsFixed(2)}%',
                                    },
                                  ]
                                },
                                {
                                  'title': 'Site Revenue',
                                  'data': [
                                    {
                                      'label': 'REV LMTD',
                                      'value': _formatNumber(revLmtd),
                                    },
                                    {
                                      'label': 'REV MTD',
                                      'value': _formatNumber(revMtd),
                                    },
                                    {
                                      'label': 'GROWTH',
                                      'value':
                                          '${growthRev?.toStringAsFixed(2)}%',
                                    },
                                  ]
                                },
                                {
                                  'title': 'Site RGU 90',
                                  'data': [
                                    {
                                      'label': 'RGU 90 LMTD',
                                      'value': _formatNumber(rgu90Ltmd),
                                    },
                                    {
                                      'label': 'RGU 90 MTD',
                                      'value': _formatNumber(rgu90Mtd),
                                    },
                                    {
                                      'label': 'GROWTH RGU',
                                      'value':
                                          '${growthRgu?.toStringAsFixed(2)}%',
                                    },
                                  ]
                                },
                                {
                                  'title': 'VLR',
                                  'data': [
                                    {
                                      'label': 'VLR LMTD',
                                      'value': _formatNumber(vlrLmtd),
                                    },
                                    {
                                      'label': 'VLR MTD',
                                      'value': _formatNumber(vlrMtd),
                                    },
                                    {
                                      'label': 'GROWTH',
                                      'value':
                                          '${growthVlr?.toStringAsFixed(2)}%',
                                    },
                                  ]
                                },
                              ].map((item) {
                                return Card(
                                  color: Colors.white,
                                  elevation: 5,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title'] as String,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Menggunakan Table untuk menampilkan data
                                        Table(
                                          border: TableBorder.all(
                                            color: Colors.grey,
                                            width: 1,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          children: [
                                            // Data Rows tanpa header
                                            ...(item['data']! as List).map(
                                              (subItem) {
                                                return TableRow(
                                                  children: [
                                                    TableCell(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          subItem['label'] ??
                                                              '',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                      ),
                                                    ),
                                                    TableCell(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: subItem['value']
                                                                is Widget
                                                            ? subItem['value']
                                                            : Text(
                                                                subItem['value']
                                                                        ?.toString() ??
                                                                    '',
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
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
}
