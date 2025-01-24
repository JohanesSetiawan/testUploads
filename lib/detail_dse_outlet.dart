import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'home_page.dart';

class DetailDseOutlet extends StatefulWidget {
  final String dseId;
  final String status;
  final String title;
  final String selectedRegion;
  final String selectedArea;
  final String selectedBranch;

  const DetailDseOutlet({
    super.key,
    required this.dseId,
    required this.status,
    required this.title,
    required this.selectedRegion,
    required this.selectedArea,
    required this.selectedBranch,
  });

  @override
  State<DetailDseOutlet> createState() => _DetailDseOutletState();
}

class _DetailDseOutletState extends State<DetailDseOutlet> {
  List<Map<String, dynamic>> outletList = [];

  final formatter = NumberFormat('#,###', 'id_ID');
  String errorMessage = '';
  bool isLoading = true;

  String formatNumber(dynamic value) {
    if (value == null) return '0';
    int? number = int.tryParse(value.toString());
    if (number == null) return '0';
    return formatter.format(number).replaceAll(',', '.');
  }

  Future<void> fetchOutletData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      const baseURL =
          'http://103.157.116.221:8088/elang-dashboard-backend/public';
      final url = Uri.parse(
        '$baseURL/api/v1/dse/pjp-dse-daily/${widget.dseId}/outlet?status=${widget.status}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          setState(() {
            outletList = List<Map<String, dynamic>>.from(data['data']);
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load data: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOutletData();
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
                        'SUMMARY DSE OUTLET',
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
                                      widget.title,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Data Table
                          const SizedBox(height: 15),
                          Container(
                            constraints: BoxConstraints(
                                minHeight: 100,
                                maxHeight: mediaQueryHeight * 0.785),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 2,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),

                            // Data Table Content
                            child: SingleChildScrollView(
                              child: outletList.isNotEmpty
                                  ? Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 12),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Outlet List - ${outletList.length} outlets',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            DataTable(
                                              horizontalMargin: 12,
                                              columnSpacing: 8,
                                              headingRowHeight: 30,
                                              columns: const [
                                                DataColumn(
                                                  label: Text(
                                                    'OUTLET NAME',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                              rows: (outletList.isNotEmpty
                                                      ? outletList
                                                      : [])
                                                  .map(
                                                    (outlet) => DataRow(
                                                      cells: [
                                                        DataCell(
                                                          Text(
                                                            outlet['nama_outlet'] ??
                                                                '',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 10,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                  .toList(),
                                            ),

                                            // Scrollable parameters columns
                                            Expanded(
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: DataTable(
                                                  horizontalMargin: 12,
                                                  columnSpacing: 8,
                                                  headingRowHeight: 30,
                                                  columns: const [
                                                    DataColumn(
                                                      label: Text(
                                                        'RGU',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'SEC SALDO',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'SP HIT',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'VOU NET',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'REBUY',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'QURO',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'QSSO',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                  rows: (outletList.isNotEmpty
                                                          ? outletList
                                                          : [])
                                                      .map(
                                                        (outlet) => DataRow(
                                                          cells: [
                                                            DataCell(
                                                              Container(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: Text(
                                                                  outlet[
                                                                      'rgu_ga'],
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            DataCell(
                                                              Container(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: Text(
                                                                  formatNumber(
                                                                      outlet[
                                                                          'sec_saldo_net']),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            DataCell(
                                                              Container(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: Text(
                                                                  formatNumber(
                                                                      outlet[
                                                                          'supply_sp_hits']),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            DataCell(
                                                              Container(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: Text(
                                                                  outlet['supply_vo_net'] ??
                                                                      '0',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            DataCell(
                                                              Container(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: Text(
                                                                  formatNumber(
                                                                      outlet[
                                                                          'supply_rebuy_net']),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            DataCell(
                                                              Container(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: Text(
                                                                  formatNumber(
                                                                      outlet[
                                                                          'quro']),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            DataCell(
                                                              Container(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: Text(
                                                                  formatNumber(
                                                                      outlet[
                                                                          'qsso']),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                      .toList(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : const Center(
                                      child: Text(
                                        'No Data Found',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey,
                                        ),
                                      ),
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
