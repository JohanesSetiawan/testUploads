import 'package:elangv2_jdk19/detail_outlet.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';

class DetailOutletValid extends StatefulWidget {
  final String siteId;
  final String brand;

  const DetailOutletValid({
    super.key,
    required this.siteId,
    required this.brand,
  });

  @override
  State<DetailOutletValid> createState() => _DetailOutletValidState();
}

class _DetailOutletValidState extends State<DetailOutletValid> {
  List<Map<String, dynamic>> detailOutletValidData = [];
  bool isLoading = true;

  Future<void> fetchDetailOutletValidData() async {
    setState(() {
      isLoading = true;
    });
    try {
      const baseURL =
          'http://103.157.116.221:8088/elang-dashboard-backend/public';
      final url = Uri.parse(
        '$baseURL/api/v1/sites/${widget.siteId}/detail/outlet?brand=${widget.brand}',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          setState(() {
            detailOutletValidData =
                List<Map<String, dynamic>>.from(data['data']);
            isLoading = false;
          });
        } else {
          setState(() {
            detailOutletValidData = [];
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No data available')),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load data: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching data')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDetailOutletValidData();
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
                        'DETAIL OUTLET VALID',
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
                                      "${widget.siteId} - ${widget.brand}",
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
                              child: detailOutletValidData.isNotEmpty
                                  ? Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 12),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Data Outlet Valid List - ${detailOutletValidData.length}',
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
                                              rows: (detailOutletValidData
                                                          .isNotEmpty
                                                      ? detailOutletValidData
                                                      : [])
                                                  .map(
                                                    (dov) => DataRow(
                                                      cells: [
                                                        DataCell(
                                                          InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          DetailOutlet(
                                                                    qrCode: dov[
                                                                        'qr_code'],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: Text(
                                                              dov['outlet_name'] ??
                                                                  '',
                                                              style: const TextStyle(
                                                                  fontSize: 10,
                                                                  color: Colors
                                                                      .blue,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline),
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
                                                        'QR CODE',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'BRAND',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'GA MTD',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'SEC SALDO MTD',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'SUPPLY SP MTD',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'SUPPLY VO MTD',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                  rows: (detailOutletValidData
                                                              .isNotEmpty
                                                          ? detailOutletValidData
                                                          : [])
                                                      .map(
                                                        (dov) => DataRow(
                                                          cells: [
                                                            DataCell(
                                                              Container(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: Text(
                                                                  dov['qr_code'] ??
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
                                                                  dov['brand'] ??
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
                                                                  dov['ga_mtd'] ??
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
                                                                  dov['sec_saldo_mtd'] ??
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
                                                                  dov['supply_sp_mtd'] ??
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
                                                                  dov['supply_vo_mtd'] ??
                                                                      '0',
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

  // Add these helper methods to the _DetailDseOutletState class
  Widget _buildHeaderCell(String text, double width) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, double width) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: const TextStyle(fontSize: 10),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}
