import 'package:elangv2_jdk19/home_page.dart';
import 'package:elangv2_jdk19/detail_dse_outlet.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class DetailDseDaily extends StatefulWidget {
  final String dseId;
  final String branchName;
  final String selectedRegion;
  final String selectedArea;
  final String selectedBranch;

  const DetailDseDaily({
    super.key,
    required this.dseId,
    required this.branchName,
    required this.selectedRegion,
    required this.selectedArea,
    required this.selectedBranch,
  });

  @override
  State<DetailDseDaily> createState() => _DetailDseDailyState();
}

class _DetailDseDailyState extends State<DetailDseDaily> {
  String? outletPjp;
  String? lastUpdateDaily;
  String? g_rgu_ga;
  String? g_sec_saldo;
  String? g_sup_sp;
  String? g_sup_vou_net;
  String? g_sup_rebuy;

  String? rgu_ga_ltd;
  String? rgu_ga_dtd;
  String? sec_saldo_ltd;
  String? sec_saldo_dtd;
  String? sup_sp_ltd;
  String? sup_sp_dtd;
  String? sup_vou_net_ltd;
  String? sup_vou_net_dtd;
  String? sup_rebuy_ltd;
  String? sup_rebuy_dtd;
  String? outlet_hari_ini;
  String? outlet_kemarin;
  String? g_outlet;

  String? sup_sp_hits_ltd;
  String? sup_sp_hits_dtd;
  String? g_sup_sp_hits;
  String? sup_vou_hits_ltd;
  String? sup_vou_hits_dtd;
  String? g_sup_vou_hits;

  int parseNumberWithDots(String? value) {
    if (value == null) return 0;
    // Remove all dots and parse
    return int.tryParse(value.replaceAll('.', '')) ?? 0;
  }

  String formatWithDots(int number) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(number).replaceAll(',', '.');
  }

  List<Map<String, dynamic>> productList = [];

  var baseURL = 'http://103.157.116.221:8088/elang-dashboard-backend/public';

  Future<void> _fetchDataDaily() async {
    final dseId = widget.dseId;
    final url = Uri.parse('$baseURL/api/v1/dse/pjp-dse-daily/$dseId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        setState(() {
          // Basic values
          rgu_ga_ltd = data['rgu_ga_ltd'];
          rgu_ga_dtd = data['rgu_ga_dtd'];
          g_rgu_ga = data['g_rgu_ga'];

          // Values with dots
          sec_saldo_ltd = data['sec_saldo_net_ltd'];
          sec_saldo_dtd = data['sec_saldo_net_dtd'];
          g_sec_saldo = data['g_sec_saldo_net'];

          sup_sp_ltd = data['supply_sp_net_ltd'];
          sup_sp_dtd = data['supply_sp_net_dtd'];
          g_sup_sp = data['g_supply_sp_net'];

          sup_sp_hits_ltd = data['supply_sp_hits_ltd'];
          sup_sp_hits_dtd = data['supply_sp_hits_dtd'];
          g_sup_sp_hits = data['g_supply_sp_hits'];

          sup_vou_net_ltd = data['supply_vo_net_ltd'];
          sup_vou_net_dtd = data['supply_vo_net_dtd'];
          g_sup_vou_net = data['g_supply_vo_net'];

          sup_vou_hits_ltd = data['supply_vo_hits_ltd'];
          sup_vou_hits_dtd = data['supply_vo_hits_dtd'];
          g_sup_vou_hits = data['g_supply_vo_hits'];

          sup_rebuy_ltd = data['supply_rebuy_net_ltd'];
          sup_rebuy_dtd = data['supply_rebuy_net_dtd'];
          g_sup_rebuy = data['g_supply_rebuy_net'];

          outlet_hari_ini = data['outlet_pjp_hari_ini'];
          outlet_kemarin = data['outlet_pjp_kemarin'];
          g_outlet = data['g_outlet'];
          lastUpdateDaily = data['mtd_dt'];
        });
      } else {
        const SnackBar(content: Text('Failed to load data'));
      }
    } catch (error) {
      const SnackBar(content: Text('Error fetching data'));
    }
  }

  Future<void> _fetchDataProduct() async {
    final dseId = widget.dseId;
    final url = Uri.parse('$baseURL/api/v1/dse/pjp-dse-product/$dseId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          productList = List<Map<String, dynamic>>.from(data['data']);
        });
      } else {
        SnackBar(content: Text('Failed to load data ${response.statusCode}'));
      }
    } catch (error) {
      const SnackBar(content: Text('Error fetching data'));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDataDaily();
    _fetchDataProduct();
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
                        'DSE DAILY',
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
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                          top: 10.0,
                          bottom:
                              40.0 // Tambahkan padding bottom yang lebih besar
                          ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget
                                          .dseId, // Dynamically display DSE name
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                    Text(
                                      widget
                                          .branchName, // Dynamically display branch name
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
                                  'label': 'DTD',
                                  'value': outlet_hari_ini ?? 'Loading...',
                                },
                                {
                                  'label': 'LTD',
                                  'value': outlet_kemarin ?? 'Loading...',
                                },
                                {
                                  'label': 'GROWTH',
                                  'value': '${g_outlet?.toString()}%',
                                },
                                {
                                  'label': 'Last Update',
                                  'value': lastUpdateDaily ?? 'Loading...',
                                },
                              ]
                            },
                            {
                              'title': 'RGU GA',
                              'data': [
                                {
                                  'label': 'DTD',
                                  'value': rgu_ga_dtd ?? 'Loading...',
                                },
                                {
                                  'label': 'LTD',
                                  'value': rgu_ga_ltd ?? 'Loading...',
                                },
                                {
                                  'label': 'GROWTH',
                                  'value': '${g_rgu_ga?.toString()}%',
                                },
                              ]
                            },
                            {
                              'title': 'SALDO NET',
                              'data': [
                                {
                                  'label': 'DTD',
                                  'value': sec_saldo_dtd ?? 'Loading...',
                                },
                                {
                                  'label': 'LTD',
                                  'value': sec_saldo_ltd ?? 'Loading...',
                                },
                                {
                                  'label': 'GROWTH',
                                  'value': '${g_sec_saldo?.toString()}%',
                                },
                              ]
                            },
                            {
                              'title': 'SUPPLY SP',
                              'data': [
                                {
                                  'label': 'DTD NET',
                                  'value': sup_sp_dtd ?? 'Loading...',
                                },
                                {
                                  'label': 'LTD NET',
                                  'value': sup_sp_ltd ?? 'Loading...',
                                },
                                {
                                  'label': 'GROWTH NET',
                                  'value': '${g_sup_sp?.toString()}%',
                                },
                                {
                                  'label': 'DTD HIT',
                                  'value': sup_sp_hits_dtd ?? 'Loading...'
                                },
                                {
                                  'label': 'LTD HIT',
                                  'value': sup_sp_hits_ltd ?? 'Loading...'
                                },
                                {
                                  'label': 'GROWTH HIT',
                                  'value': '${g_sup_sp_hits?.toString()}%',
                                },
                              ]
                            },
                            {
                              'title': 'SUPPLY VOU',
                              'data': [
                                {
                                  'label': 'DTD NET',
                                  'value': sup_vou_net_dtd ?? 'Loading...',
                                },
                                {
                                  'label': 'LTD NET',
                                  'value': sup_vou_net_ltd ?? 'Loading...',
                                },
                                {
                                  'label': 'GROWTH NET',
                                  'value': '${g_sup_vou_net?.toString()}%',
                                },
                                {
                                  'label': 'DTD HIT',
                                  'value': sup_vou_hits_dtd ?? 'Loading...',
                                },
                                {
                                  'label': 'LTD HIT',
                                  'value': sup_vou_hits_ltd ?? 'Loading...',
                                },
                                {
                                  'label': 'GROWTH HIT',
                                  'value': '${g_sup_vou_hits?.toString()}%',
                                },
                              ]
                            },
                            {
                              'title': 'REBUY NET',
                              'data': [
                                {
                                  'label': 'DTD',
                                  'value': sup_rebuy_dtd ?? 'Loading...',
                                },
                                {
                                  'label': 'LTD',
                                  'value': sup_rebuy_ltd ?? 'Loading...',
                                },
                                {
                                  'label': 'GROWTH',
                                  'value': '${g_sup_rebuy?.toString()}%',
                                },
                              ]
                            },
                          ].map((item) {
                            return Card(
                              color: Colors.white,
                              elevation: 5,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] as String,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    // Menggunakan Table untuk menampilkan data
                                    Table(
                                      border: TableBorder.all(
                                        color: Colors.grey,
                                        width: 1,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      children: [
                                        // Data Rows tanpa header
                                        ...(item['data']! as List).map(
                                          (subItem) {
                                            bool isOutletPjp =
                                                item['title'] == 'Outlet PJP';
                                            bool isDtdOrLtd =
                                                subItem['label'] == 'DTD' ||
                                                    subItem['label'] == 'LTD';
                                            return TableRow(
                                              children: [
                                                TableCell(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      subItem['label'] ?? '',
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: isOutletPjp &&
                                                            isDtdOrLtd
                                                        ? InkWell(
                                                            onTap: () {
                                                              String status =
                                                                  subItem['label'] ==
                                                                          'DTD'
                                                                      ? 'today'
                                                                      : 'yesterday';
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          DetailDseOutlet(
                                                                    selectedRegion:
                                                                        widget
                                                                            .selectedRegion,
                                                                    selectedArea:
                                                                        widget
                                                                            .selectedArea,
                                                                    selectedBranch:
                                                                        widget
                                                                            .selectedBranch,
                                                                    dseId: widget
                                                                        .dseId,
                                                                    status:
                                                                        status,
                                                                    title:
                                                                        '${widget.dseId} - ${subItem['label']}',
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: Text(
                                                              subItem['value'] ??
                                                                  '',
                                                              style: const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .blue),
                                                            ),
                                                          )
                                                        : Text(
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
                          Card(
                            color: Colors.white,
                            elevation: 5,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Product Information',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Last Update: ${productList.isNotEmpty ? productList[0]['dt_id'] : 'Loading...'}', // Menampilkan data dt_id
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SingleChildScrollView(
                                    scrollDirection: Axis
                                        .vertical, // Mengubah scrolling menjadi vertikal
                                    child: Table(
                                      border: TableBorder.all(
                                        color: Colors.grey,
                                        width: 1,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      columnWidths: const {
                                        1: FlexColumnWidth(
                                            0.6), // Product name column
                                        2: FlexColumnWidth(
                                            0.5), // Total hits column
                                      },
                                      children: [
                                        // Header row
                                        TableRow(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                          ),
                                          children: const [
                                            TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Product Name',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Total Hits',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Data rows
                                        ...productList.map(
                                          (product) => TableRow(
                                            children: [
                                              TableCell(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                      product['product_name'] ??
                                                          ''),
                                                ),
                                              ),
                                              TableCell(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                      product['total_hits']
                                                              ?.toString() ??
                                                          '0'),
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
