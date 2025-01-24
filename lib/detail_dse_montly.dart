import 'package:elangv2_jdk19/home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailDseMontly extends StatefulWidget {
  final String dseId;
  final String branchName;

  const DetailDseMontly({
    super.key,
    required this.dseId,
    required this.branchName,
  });

  @override
  State<DetailDseMontly> createState() => _DetailDseMontlyState();
}

class _DetailDseMontlyState extends State<DetailDseMontly> {
  String? outletPjp;
  String? mtdDt;

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

  var baseURL = 'http://103.157.116.221:8088/elang-dashboard-backend/public';

  Future<void> _fetchData() async {
    final dseId = widget.dseId;
    final url = Uri.parse(
      '$baseURL/api/v1/dse/pjp-outlet/$dseId',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          outletPjp = data['data'][0]['outlet_pjp'].toString();
          mtdDt = data['data'][0]['mtd_dt'].toString();
        });
      } else {
        SnackBar(content: Text('Failed to load data: ${response.statusCode}'));
      }
    } catch (error) {
      const SnackBar(content: Text('Error fetching data'));
    }
  }

  Future<void> _fetchSellinVoucherData() async {
    final dseId = widget.dseId;
    final url = Uri.parse(
      '$baseURL/api/v1/dse/pjp-sellin-voucher/$dseId',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          sellinVouLmtd = data['data'][0]['vo_net_lmtd'];
          sellinVouMtd = data['data'][0]['vo_net_mtd'];
          gVoNet = data['data'][0]['g_vo_net'];
          sellinVouHitsLmtd = data['data'][0]['vo_hits_lmtd'];
          sellinVouHitsMtd = data['data'][0]['vo_hits_mtd'];
          gVoHits = data['data'][0]['g_vo_hits'];
        });
      } else {
        SnackBar(content: Text('Failed to load data: ${response.statusCode}'));
      }
    } catch (error) {
      const SnackBar(content: Text('Error fetching data'));
    }
  }

  Future<void> _fetchSellinMoboData() async {
    final dseId = widget.dseId;
    final url = Uri.parse(
      '$baseURL/api/v1/dse/pjp-sellin-mobo/$dseId',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          sellinMoboLmtd = data['data'][0]['sellin_mobo_lmtd'];
          sellinMoboMtd = data['data'][0]['sellin_mobo_mtd'];
          gMobo = data['data'][0]['g_mobo'];
        });
      } else {
        SnackBar(content: Text('Failed to load data: ${response.statusCode}'));
      }
    } catch (error) {
      const SnackBar(content: Text('Error fetching data'));
    }
  }

  Future<void> _fetchSellinSPData() async {
    final dseId = widget.dseId;
    final url = Uri.parse(
      '$baseURL/api/v1/dse/pjp-sellin-sp/$dseId',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          sellinSPLmtd = data['data'][0]['sp_net_lmtd'];
          sellinSPMtd = data['data'][0]['sp_net_mtd'];
          gSpNet = data['data'][0]['g_sp_net'];
          sellinSPHitsLmtd = data['data'][0]['sp_hits_lmtd'];
          sellinSPHitsMtd = data['data'][0]['sp_hits_mtd'];
          gSpHits = data['data'][0]['g_sp_hits'];
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
    _fetchData();
    _fetchSellinVoucherData();
    _fetchSellinMoboData();
    _fetchSellinSPData();
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
                        'MONTLY DSE',
                        style: TextStyle(
                            fontSize: 20,
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
                    child: Padding(
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
                                            widget.dseId,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black),
                                          ),
                                          Text(
                                            widget.branchName,
                                            style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                ...[
                                  {
                                    'title': 'Outlet PJP',
                                    'data': [
                                      {
                                        'label': 'Jumlah Data',
                                        'value': outletPjp ?? 'Loading...',
                                      },
                                      {
                                        'label': 'Last Update',
                                        'value': mtdDt ?? 'Loading...',
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
                                        'value':
                                            sellinVouHitsMtd ?? 'Loading...',
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
                                        'value':
                                            sellinSPHitsLmtd ?? 'Loading...',
                                      },
                                      {
                                        'label': 'SP Hits MTD',
                                        'value':
                                            sellinSPHitsMtd ?? 'Loading...',
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
                                                          child: Text(
                                                            subItem['value'] ??
                                                                '',
                                                            style: const TextStyle(
                                                                fontSize: 14,
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
