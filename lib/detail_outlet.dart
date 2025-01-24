import 'package:elangv2_jdk19/detail_site.dart';
import 'package:elangv2_jdk19/home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DetailOutlet extends StatefulWidget {
  final String qrCode;

  const DetailOutlet({super.key, required this.qrCode});

  @override
  State<DetailOutlet> createState() => _DetOutlateState();
}

class _DetOutlateState extends State<DetailOutlet> {
  String? partnerName;
  String? outletName;
  String? category;
  String? brand;
  String? latitude;
  String? longitude;
  String? lastupdateOutlet;
  String? siteId;

  late int gaLmtd = 0;
  late int gaMtd = 0;
  late int QSSOLmtd = 0;
  late int QSSOMtd = 0;
  late int QUROLmtd = 0;
  late int QUROMtd = 0;
  late int secSPHitsLmtd = 0;
  late int secSPhitsMtd = 0;
  late int secVouHitsLmtd = 0;
  late int secVouhitsMtd = 0;
  late int supplySPLmtd = 0;
  late int supplySPMtd = 0;
  late int supplyVouLmtd = 0;
  late int supplyVouMtd = 0;
  late int tertSPLmtd = 0;
  late int tertSPMtd = 0;
  late int tertVouLmtd = 0;
  late int tertVouMtd = 0;

  late double gaGrowth = 0.0;
  late double qssoGrowth = 0.0;
  late double quroGrowth = 0.0;
  late double secSpHitsGrowth = 0.0;
  late double secVouHitsGrowth = 0.0;
  late double supplySpGrowth = 0.0;
  late double supplyVouGrowth = 0.0;
  late double tertSpGrowth = 0.0;
  late double tertVouGrowth = 0.0;

  String _formatNumber(int? number) {
    if (number == null) return 'Loading...';
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  var baseURL = 'http://103.157.116.221:8088/elang-dashboard-backend/public';

  Future<void> _fetchDataOutletDetail() async {
    final qrcode = widget.qrCode;
    final url = Uri.parse(
      '$baseURL/api/v1/outlet/detail/$qrcode',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          siteId = data['data']['site_id'];
          outletName = data['data']['outlet_name'];
          partnerName = data['data']['partner_name'];
          category = data['data']['category'];
          brand = data['data']['brand'];
          latitude = data['data']['latitude'];
          longitude = data['data']['longitude'];
          lastupdateOutlet = data['data']['mtd_dt'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: ${response.statusCode}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error fetching data'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _fetchDataGADetail() async {
    final qrcode = widget.qrCode;
    final url = Uri.parse('$baseURL/api/v1/outlet/detail/$qrcode/ga');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['data'] != null) {
          setState(() {
            gaLmtd = data['data']['ga_lmtd']?.toInt() ?? 0;
            gaMtd = data['data']['ga_mtd']?.toInt() ?? 0;
            gaGrowth = (data['data']['ga_growth']?.toDouble() ?? 0.0);
            QSSOLmtd = data['data']['q_sso_lmtd']?.toInt() ?? 0;
            QSSOMtd = data['data']['q_sso_mtd']?.toInt() ?? 0;
            qssoGrowth = (data['data']['q_sso_growth']?.toDouble() ?? 0.0);
            QUROLmtd = data['data']['q_uro_lmtd']?.toInt() ?? 0;
            QUROMtd = data['data']['q_uro_mtd']?.toInt() ?? 0;
            quroGrowth = (data['data']['q_uro_growth']?.toDouble() ?? 0.0);
          });
          print("Data2: $data");
        }
      } else {
        SnackBar(content: Text('Failed to load data: ${response.statusCode}'));
      }
    } catch (error) {
      const SnackBar(content: Text('Error fetching data'));
    }
  }

  Future<void> _fetchDataSECDetail() async {
    final qrcode = widget.qrCode;
    final url = Uri.parse(
      '$baseURL/api/v1/outlet/detail/$qrcode/sec',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          secSPHitsLmtd = data['data']['sec_sp_hits_lmtd']?.toInt() ?? 0;
          secSPhitsMtd = data['data']['sec_sp_hits_mtd']?.toInt() ?? 0;
          secSpHitsGrowth =
              data['data']['sec_sp_hits_growth']?.toDouble() ?? 0.0;
          secVouHitsLmtd = data['data']['sec_vou_hits_lmtd']?.toInt() ?? 0;
          secVouhitsMtd = data['data']['sec_vou_hits_mtd']?.toInt() ?? 0;
          secVouHitsGrowth =
              data['data']['sec_vou_hits_growth']?.toDouble() ?? 0.0;
        });
      } else {
        SnackBar(content: Text('Failed to load data: ${response.statusCode}'));
      }
    } catch (error) {
      const SnackBar(content: Text('Error fetching data'));
    }
  }

  Future<void> _fetchDataSUPPYDetail() async {
    final qrcode = widget.qrCode;
    final url = Uri.parse(
      '$baseURL/api/v1/outlet/detail/$qrcode/supply',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          supplySPLmtd = data['data']['supply_sp_lmtd']?.toInt() ?? 0;
          supplySPMtd = data['data']['supply_sp_mtd']?.toInt() ?? 0;
          supplySpGrowth = data['data']['supply_sp_growth']?.toDouble() ?? 0.0;
          supplyVouLmtd = data['data']['supply_vo_lmtd']?.toInt() ?? 0;
          supplyVouMtd = data['data']['supply_vo_mtd']?.toInt() ?? 0;
          supplyVouGrowth = data['data']['supply_vo_growth']?.toDouble() ?? 0;
        });
      } else {
        SnackBar(content: Text('Failed to load data: ${response.statusCode}'));
      }
    } catch (error) {
      const SnackBar(content: Text('Error fetching data'));
    }
  }

  Future<void> _fetchDataDEMANDDetail() async {
    final qrcode = widget.qrCode;
    final url = Uri.parse(
      '$baseURL/api/v1/outlet/detail/$qrcode/demand',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          tertSPLmtd = data['data']['tert_sp_lmtd']?.toInt() ?? 0;
          tertSPMtd = data['data']['tert_sp_mtd']?.toInt() ?? 0;
          tertSpGrowth = data['data']['tert_sp_growth']?.toDouble() ?? 0.0;
          tertVouLmtd = data['data']['tert_vo_lmtd']?.toInt() ?? 0;
          tertVouMtd = data['data']['tert_vo_mtd']?.toInt() ?? 0;
          tertVouGrowth = data['data']['tert_vo_growth']?.toDouble() ?? 0.0;
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
    _fetchDataOutletDetail();
    _fetchDataGADetail();
    _fetchDataSECDetail();
    _fetchDataSUPPYDetail();
    _fetchDataDEMANDDetail();
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
                        'DETAIL OUTLET',
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
                                          widget.qrCode.toString(),
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black),
                                        ),
                                        Text(
                                          outletName ?? 'Loading...',
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
                                          fontSize: 14,
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
                                  'title': 'Outlet Detail',
                                  'data': [
                                    {
                                      'label': 'QR Code',
                                      'value': widget.qrCode,
                                    },
                                    {
                                      'label': 'Site ID',
                                      'value': siteId != null
                                          ? GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        DetailSite(
                                                      siteId: siteId!,
                                                      brand: brand!,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                siteId!,
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            )
                                          : 'Loading...',
                                    },
                                    {
                                      'label': 'Outlet Name',
                                      'value': outletName ?? 'Loading...',
                                    },
                                    {
                                      'label': 'Partner Name',
                                      'value': partnerName ?? 'Loading...',
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
                                      'value': lastupdateOutlet ?? 'Loading...',
                                    },
                                  ]
                                },
                                {
                                  'title': 'Outlet GA',
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
                                      'label': 'GROWTH',
                                      'value':
                                          '${gaGrowth.toStringAsFixed(2)}%',
                                    },
                                  ]
                                },
                                {
                                  'title': 'QSSO',
                                  'data': [
                                    {
                                      'label': 'QSSO LMTD',
                                      'value': _formatNumber(QSSOLmtd),
                                    },
                                    {
                                      'label': 'QSSO MTD',
                                      'value': _formatNumber(QSSOMtd),
                                    },
                                    {
                                      'label': 'GROWTH',
                                      'value':
                                          '${qssoGrowth.toStringAsFixed(2)}%',
                                    },
                                  ]
                                },
                                {
                                  'title': 'QURO',
                                  'data': [
                                    {
                                      'label': 'QURO LMTD',
                                      'value': _formatNumber(QUROLmtd),
                                    },
                                    {
                                      'label': 'QURO MTD',
                                      'value': _formatNumber(QUROMtd),
                                    },
                                    {
                                      'label': 'GROWTH',
                                      'value':
                                          '${quroGrowth.toStringAsFixed(2)}%',
                                    },
                                  ]
                                },
                                {
                                  'title': 'Outlet SEC',
                                  'data': [
                                    {
                                      'label': 'SEC SP LMTD',
                                      'value': _formatNumber(secSPHitsLmtd),
                                    },
                                    {
                                      'label': 'SEC SP MTD',
                                      'value': _formatNumber(secSPhitsMtd),
                                    },
                                    {
                                      'label': 'GROWTH SP',
                                      'value':
                                          '${secSpHitsGrowth.toStringAsFixed(2)}%',
                                    },
                                    {
                                      'label': 'SEC VOU LMTD',
                                      'value': _formatNumber(secVouHitsLmtd),
                                    },
                                    {
                                      'label': 'SEC VOU MTD',
                                      'value': _formatNumber(secVouhitsMtd),
                                    },
                                    {
                                      'label': 'GROWTH VOU',
                                      'value':
                                          '${secVouHitsGrowth.toStringAsFixed(2)}%',
                                    },
                                  ]
                                },
                                {
                                  'title': 'Outlet SUPPLY',
                                  'data': [
                                    {
                                      'label': 'SUPPLY SP LMTD',
                                      'value': _formatNumber(supplySPLmtd),
                                    },
                                    {
                                      'label': 'SUPPLY SP MTD',
                                      'value': _formatNumber(supplySPMtd),
                                    },
                                    {
                                      'label': 'GROWTH SP',
                                      'value':
                                          '${supplySpGrowth.toStringAsFixed(2)}%',
                                    },
                                    {
                                      'label': 'SUPPLY VOU LMTD',
                                      'value': _formatNumber(supplyVouLmtd),
                                    },
                                    {
                                      'label': 'SUPPLY VOU MTD',
                                      'value': _formatNumber(supplyVouMtd),
                                    },
                                    {
                                      'label': 'GROWTH VOU',
                                      'value':
                                          '${supplyVouGrowth.toStringAsFixed(2)}%',
                                    },
                                  ]
                                },
                                {
                                  'title': 'Outlet DEMAND',
                                  'data': [
                                    {
                                      'label': 'TERT SP LMTD',
                                      'value': _formatNumber(tertSPLmtd),
                                    },
                                    {
                                      'label': 'TERT SP MTD',
                                      'value': _formatNumber(tertSPMtd),
                                    },
                                    {
                                      'label': 'GROWTH SP',
                                      'value':
                                          '${tertSpGrowth.toStringAsFixed(2)}%',
                                    },
                                    {
                                      'label': 'TERT VOU LMTD',
                                      'value': _formatNumber(tertVouLmtd),
                                    },
                                    {
                                      'label': 'TERT VOU MTD',
                                      'value': _formatNumber(tertVouMtd),
                                    },
                                    {
                                      'label': 'GROWTH VOU',
                                      'value':
                                          '${tertVouGrowth.toStringAsFixed(2)}%',
                                    },
                                  ]
                                },
                              ].map(
                                (item) {
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
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
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
                                                                    fontSize:
                                                                        14,
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
                                                          child: subItem[
                                                                      'value']
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
                                },
                              ),
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
                height: 50,
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
