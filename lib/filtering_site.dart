import 'package:elangv2_jdk19/detail_site.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'home_page.dart';
import 'auth_provider.dart';

class FilteringSite extends StatefulWidget {
  final String kecamatan;
  final String brand;
  final String selectedRegion;
  final String selectedArea;
  final String selectedBranch;

  const FilteringSite({
    super.key,
    required this.kecamatan,
    required this.brand,
    required this.selectedRegion,
    required this.selectedArea,
    required this.selectedBranch,
  });

  @override
  State<FilteringSite> createState() => _FSState();
}

class _FSState extends State<FilteringSite> {
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

  List<Map<String, dynamic>> _FSData = [];
  List<Map<String, dynamic>> _filteredFSData = [];

  var baseURL = 'http://103.157.116.221:8088/elang-dashboard-backend/public';

  Future<void> fetchFOData() async {
    final url =
        '$baseURL/api/v1/sites?kecamatan=${widget.kecamatan}&brand=${widget.brand}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> FSDataReceived = data['data'];

        setState(() {
          _FSData = FSDataReceived.map((fs) => {
                'id': fs['id'],
                'name': fs['name'],
                'brand': fs['brand'],
              }).toList();
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
      _filteredFSData = _FSData.where((fs) {
        final id = fs['id'].toString().toLowerCase();
        final name = fs['name'].toString().toLowerCase();

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
    fetchFOData();

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
                        'DATA SITE',
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
                              child: _FSData.isNotEmpty
                                  ? ListView.builder(
                                      itemCount: _searchText.isEmpty
                                          ? _FSData.length
                                          : _filteredFSData.length,
                                      itemBuilder: (context, index) {
                                        final fs = _searchText.isEmpty
                                            ? _FSData[index]
                                            : _filteredFSData[index];
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                          padding: const EdgeInsets.all(10),
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
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
                                                  builder: (context) =>
                                                      DetailSite(
                                                    siteId: fs['id'],
                                                    brand: fs['brand'],
                                                  ),
                                                ),
                                              );
                                            },
                                            title: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  fs['id'].toString(),
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black54),
                                                ),
                                                Text(
                                                  fs['name'],
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black54),
                                                ),
                                              ],
                                            ),
                                            trailing: const Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.black54),
                                          ),
                                        );
                                      },
                                    )
                                  : const Center(
                                      child: Text('No Data'),
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
                                builder: (context) => const Homepage(),
                              ),
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
