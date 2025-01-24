import 'package:elangv2_jdk19/switch_dse.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'home_page.dart';
import 'auth_provider.dart';

class MC extends StatefulWidget {
  final int mcId;
  final String selectedRegion;
  final String selectedArea;
  final String selectedBranch;

  const MC({
    super.key,
    required this.mcId,
    required this.selectedRegion,
    required this.selectedArea,
    required this.selectedBranch,
  });

  @override
  State<MC> createState() => _MCState();
}

class _MCState extends State<MC> {
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

  List<Map<String, dynamic>> _dseData = [];
  List<Map<String, dynamic>> _filteredDSEData = [];

  var baseURL = 'http://103.157.116.221:8088/elang-dashboard-backend/public';

  // AMBIL DSE DATA
  Future<void> fetchDSEData(String? token) async {
    final url = '$baseURL/api/v1/dse/${widget.mcId}';
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> dseDataReceived = data['data'];

        setState(() {
          _dseData = dseDataReceived
              .map((dse) => {
                    'id': dse['id'],
                    'name': dse['name'],
                    'mc_id': dse['mc_id'],
                    'mc_name': dse['mc_name'],
                    'pjp': dse['pjp'],
                    'actual_pjp': dse['actual_pjp'],
                    'zero': dse['zero'],
                    'sp': dse['sp'],
                    'vou': dse['vou'],
                    'salmo': dse['salmo'],
                    'mtd_dt': dse['mtd_dt'],
                    'checkin': dse['checkin'],
                    'checkout': dse['checkout'],
                  })
              .toList();
        });
      } else {
        SnackBar(content: Text('Failed to load data: ${response.statusCode}'));
      }
    } catch (e) {
      const SnackBar(content: Text('Error fetching data'));
    }
  }

  void _filterData() {
    setState(() {
      _searchText = _searchController.text.toLowerCase();
      _filteredDSEData = _dseData.where((dse) {
        final id = dse['id'].toString().toLowerCase();
        final name = dse['mc_name'].toString().toLowerCase();

        return id.contains(_searchText) || name.contains(_searchText);
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedDropdown2 = widget.selectedRegion;
    _selectedDropdown3 = widget.selectedArea;
    _selectedDropdown4 = widget.selectedBranch;
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    fetchDSEData(token);
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
                        'DATA DSE',
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

                            // Search Bar
                            const SizedBox(height: 13),
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

                            // Data Table
                            const SizedBox(height: 15),
                            Container(
                              constraints: BoxConstraints(
                                  minHeight: 100,
                                  maxHeight: mediaQueryHeight * 0.605),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
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
                                child: _dseData.isNotEmpty
                                    ? (_searchText.isEmpty ||
                                            _filteredDSEData.isNotEmpty)
                                        ? Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 12),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    'Last Update : ${_dseData.isNotEmpty ? _dseData[0]['mtd_dt'] : 'N/A'}',
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                          'DSE ID',
                                                          style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ],
                                                    rows: (_searchText.isEmpty
                                                            ? _dseData
                                                            : _filteredDSEData)
                                                        .map(
                                                          (dse) => DataRow(
                                                            cells: [
                                                              DataCell(
                                                                InkWell(
                                                                  onTap: () {
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                SwitchDse(
                                                                          selectedRegion:
                                                                              widget.selectedRegion,
                                                                          selectedArea:
                                                                              widget.selectedArea,
                                                                          selectedBranch:
                                                                              widget.selectedBranch,
                                                                          dseId:
                                                                              dse['id'],
                                                                          branchName:
                                                                              dse['mc_name'],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                  child: Text(
                                                                    dse['id'],
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          10,
                                                                      color: Colors
                                                                          .blue,
                                                                      decoration:
                                                                          TextDecoration
                                                                              .underline,
                                                                    ),
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
                                                    child:
                                                        SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: DataTable(
                                                        horizontalMargin: 12,
                                                        columnSpacing: 8,
                                                        headingRowHeight: 30,
                                                        columns: const [
                                                          DataColumn(
                                                            label: Text(
                                                              'C IN',
                                                              style: TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          DataColumn(
                                                            label: Text(
                                                              'C OUT',
                                                              style: TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          DataColumn(
                                                            label: Text(
                                                              '#PJP',
                                                              style: TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          DataColumn(
                                                            label: Text(
                                                              'ACT PJP',
                                                              style: TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          DataColumn(
                                                            label: Text(
                                                              '0 SELLIN',
                                                              style: TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          DataColumn(
                                                            label: Text(
                                                              'SP',
                                                              style: TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          DataColumn(
                                                            label: Text(
                                                              'VOU',
                                                              style: TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          DataColumn(
                                                            label: Text(
                                                              'SALMO',
                                                              style: TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                        ],
                                                        rows: (_searchText
                                                                    .isEmpty
                                                                ? _dseData
                                                                : _filteredDSEData)
                                                            .map(
                                                              (dse) => DataRow(
                                                                cells: [
                                                                  DataCell(
                                                                    Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerRight,
                                                                      child:
                                                                          Text(
                                                                        dse['checkin'] ??
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
                                                                      alignment:
                                                                          Alignment
                                                                              .centerRight,
                                                                      child:
                                                                          Text(
                                                                        dse['checkout'] ??
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
                                                                      alignment:
                                                                          Alignment
                                                                              .centerRight,
                                                                      child:
                                                                          Text(
                                                                        dse['pjp'] ??
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
                                                                      alignment:
                                                                          Alignment
                                                                              .centerRight,
                                                                      child:
                                                                          Text(
                                                                        dse['actual_pjp'] ??
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
                                                                      alignment:
                                                                          Alignment
                                                                              .centerRight,
                                                                      child:
                                                                          Text(
                                                                        dse['zero'] ??
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
                                                                      alignment:
                                                                          Alignment
                                                                              .centerRight,
                                                                      child:
                                                                          Text(
                                                                        dse['sp'] ??
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
                                                                      alignment:
                                                                          Alignment
                                                                              .centerRight,
                                                                      child:
                                                                          Text(
                                                                        dse['vou'] ??
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
                                                                      alignment:
                                                                          Alignment
                                                                              .centerRight,
                                                                      child:
                                                                          Text(
                                                                        dse['salmo'] ??
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
                                          )
                                    : const Center(
                                        child: Text(
                                          'No Data',
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
}
