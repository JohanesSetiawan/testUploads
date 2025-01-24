import 'package:elangv2_jdk19/home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class DetailMitra extends StatefulWidget {
  final String partnerName;
  final String category;

  const DetailMitra({
    super.key,
    required this.partnerName,
    required this.category,
  });

  @override
  State<DetailMitra> createState() => _DetSitelateState();
}

class _DetSitelateState extends State<DetailMitra> {
  String? partner_name;
  String? mc;
  String? brand;
  String? category;
  int? outletPjp;
  String? lastUpdateMitra;

  String? sellinVouMtd;
  String? sellinVouLmtd;
  String? sellinVouHitsLmtd;
  String? sellinVouHitsMtd;

  String? sellinMoboLmtd;
  String? sellinMoboMtd;

  String? sellinSPLmtd;
  String? sellinSPMtd;
  String? sellinSPHitsLmtd;
  String? sellinSPHitsMtd;

  String? gVoNet;
  String? gVoHits;
  String? gSpNet;
  String? gSpHits;
  String? gMobo;

  String _formatNumber(int? number) {
    if (number == null) return 'Loading...';
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  var baseURL = 'http://103.157.116.221:8088/elang-dashboard-backend/public';

  Future<void> _fetchDataMitraDetail() async {
    final url = Uri.parse(
      '$baseURL/api/v1/mitra/detail?partner_name=${widget.partnerName}&category=${widget.category}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          partner_name = data['partner_name'];
          mc = data['mc'];
          brand = data['brand'];
          category = data['category'];
          outletPjp = data['outlet_pjp'];
          lastUpdateMitra = data['mtd_dt'];
        });
      } else {
        SnackBar(content: Text('Failed to load data: ${response.statusCode}'));
      }
    } catch (error) {
      const SnackBar(content: Text('Error fetching data'));
    }
  }

  Future<void> _fetchDataMitraSellinVoucherDetail() async {
    final url = Uri.parse(
      '$baseURL/api/v1/mitra/detail/sellin-voucher?partner_name=${widget.partnerName}&category=${widget.category}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          sellinVouLmtd = data['vo_net_lmtd'];
          sellinVouMtd = data['vo_net_mtd'];
          gVoNet = data['g_vo_net'];
          sellinVouHitsLmtd = data['vo_hits_lmtd'];
          sellinVouHitsMtd = data['vo_hits_mtd'];
          gVoHits = data['g_vo_hits'];
        });
      } else {
        SnackBar(content: Text('Failed to load data: ${response.statusCode}'));
      }
    } catch (error) {
      const SnackBar(content: Text('Error fetching data'));
    }
  }

  Future<void> _fetchDataMitraSellinMoboDetail() async {
    final url = Uri.parse(
      '$baseURL/api/v1/mitra/detail/sellin-mobo?partner_name=${widget.partnerName}&category=${widget.category}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          sellinMoboLmtd = data['sellin_mobo_lmtd'];
          sellinMoboMtd = data['sellin_mobo_mtd'];
          gMobo = data['g_mobo'];
        });
      } else {
        SnackBar(content: Text('Failed to load data: ${response.statusCode}'));
      }
    } catch (error) {
      const SnackBar(content: Text('Error fetching data'));
    }
  }

  Future<void> _fetchDataMitraSellinSPDetail() async {
    final url = Uri.parse(
      '$baseURL/api/v1/mitra/detail/sellin-sp?partner_name=${widget.partnerName}&category=${widget.category}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          sellinSPLmtd = data['sp_net_lmtd'];
          sellinSPMtd = data['sp_net_mtd'];
          gSpNet = data['g_sp_net'];
          sellinSPHitsLmtd = data['sp_hits_lmtd'];
          sellinSPHitsMtd = data['sp_hits_mtd'];
          gSpHits = data['g_sp_hits'];
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
    _fetchDataMitraDetail();
    _fetchDataMitraSellinVoucherDetail();
    _fetchDataMitraSellinMoboDetail();
    _fetchDataMitraSellinSPDetail();
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
                        'DETAIL MITRA',
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
                              const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ...[
                                {
                                  'title': 'Mitra Detail',
                                  'data': [
                                    {
                                      'label': 'Partner Name',
                                      'value': partner_name ?? 'Loading...',
                                    },
                                    {
                                      'label': 'MC',
                                      'value': mc ?? 'Loading...',
                                    },
                                    {
                                      'label': 'Brand',
                                      'value': brand ?? 'Loading...',
                                    },
                                    {
                                      'label': 'Category',
                                      'value': category ?? 'Loading...',
                                    },
                                    {
                                      'label': 'Outlet PJP',
                                      'value': _formatNumber(outletPjp),
                                    },
                                    {
                                      'label': 'Last Update',
                                      'value': lastUpdateMitra ?? 'Loading...',
                                    },
                                  ]
                                },
                                {
                                  'title': 'Sellin Voucher',
                                  'data': [
                                    {
                                      'label': 'Vou Net LMTD',
                                      'value': sellinVouLmtd ?? 'Loading...',
                                    },
                                    {
                                      'label': 'Vou Net MTD',
                                      'value': sellinVouMtd ?? 'Loading...',
                                    },
                                    {
                                      'label': 'Growth Vou Net',
                                      'value': '${gVoNet?.toString()}%',
                                    },
                                    {
                                      'label': 'Vou Hits LMTD',
                                      'value':
                                          sellinVouHitsLmtd ?? 'Loading...',
                                    },
                                    {
                                      'label': 'Vou Hits MTD',
                                      'value': sellinVouHitsMtd ?? 'Loading...',
                                    },
                                    {
                                      'label': 'Growth Vou Hits',
                                      'value': '${gVoHits?.toString()}%',
                                    },
                                  ]
                                },
                                {
                                  'title': 'Sellin Mobo',
                                  'data': [
                                    {
                                      'label': 'Demand MTD',
                                      'value': sellinMoboLmtd ?? 'Loading...',
                                    },
                                    {
                                      'label': 'Demand MTD',
                                      'value': sellinMoboMtd ?? 'Loading...',
                                    },
                                    {
                                      'label': 'Growth Demand',
                                      'value': '${gMobo?.toString()}%',
                                    },
                                  ]
                                },
                                {
                                  'title': 'Sellin SP',
                                  'data': [
                                    {
                                      'label': 'SP Net LMTD',
                                      'value': sellinSPLmtd ?? 'Loading...',
                                    },
                                    {
                                      'label': 'SP Net MTD',
                                      'value': sellinSPMtd ?? 'Loading...',
                                    },
                                    {
                                      'label': 'Growth SP Net',
                                      'value': '${gSpNet?.toString()}%',
                                    },
                                    {
                                      'label': 'SP Hits LMTD',
                                      'value': sellinSPHitsLmtd ?? 'Loading...',
                                    },
                                    {
                                      'label': 'SP Hits MTD',
                                      'value': sellinSPHitsMtd ?? 'Loading...',
                                    },
                                    {
                                      'label': 'Growth SP Hits',
                                      'value': '${gSpHits?.toString()}%',
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
