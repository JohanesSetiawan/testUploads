import 'package:elangv2_jdk19/cari_maps.dart';
import 'package:elangv2_jdk19/dse.dart';
import 'package:elangv2_jdk19/mc_maps.dart';
import 'package:elangv2_jdk19/mitra.dart';
import 'package:elangv2_jdk19/outlet.dart';
import 'package:elangv2_jdk19/site.dart';
import 'package:elangv2_jdk19/login.dart';
import 'package:elangv2_jdk19/update_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

// Mixin to handle auto-logout
mixin AutoLogoutMixin<T extends StatefulWidget> on State<T> {
  Timer? _inactivityTimer;
  Timer? _tokenExpirationTimer;
  static const inactivityDuration = Duration(minutes: 90);

  void _showLogoutDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sesi Berakhir'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _setupTokenExpirationTimer() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final expirationTime = authProvider.getTokenExpirationTime();

    if (expirationTime != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final timeUntilExpiration = expirationTime - now;

      if (timeUntilExpiration > 0) {
        _tokenExpirationTimer = Timer(
          Duration(milliseconds: timeUntilExpiration),
          () {
            _performAutoLogout(
                'Token telah kadaluarsa, silahkan login kembali.');
          },
        );
      }
    }
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(inactivityDuration, () {
      _performAutoLogout(
          'Anda tidak aktif selama ${inactivityDuration.inMinutes} menit, silahkan login kembali.');
    });
  }

  Future<void> _performAutoLogout(String message) async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (!mounted) return;

    _showLogoutDialog(message);
  }

  @override
  void initState() {
    super.initState();
    _setupTokenExpirationTimer();
    _resetInactivityTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    _tokenExpirationTimer?.cancel();
    super.dispose();
  }
}

class _HomepageState extends State<Homepage> with AutoLogoutMixin {
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

  final PageController _pageController = PageController();
  Timer? _autoScrollTimer;

  String? _selectedDropdown1 = 'Circle Java';
  String? _selectedDropdown2 = 'ALL';
  String? _selectedDropdown3 = 'ALL';
  String? _selectedDropdown4 = 'ALL';
  String? _selectedDropdown5 = 'ALL';
  String? lastUpdate;

  int _selectedTabIndex = 0;
  int _currentPage = 0;

  bool _isLoadingTable = false;
  bool _isDropdownLocked(int dropdownNumber) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.role == 5) {
      return dropdownNumber <= 5; // Locks dropdowns 1-5
    } else if (authProvider.role == 1) {
      return dropdownNumber == 1; // Only locks dropdown 1 for role 1
    }
    return false; // No locks for other roles
  }

  List<Map<String, dynamic>> _regions = [];
  List<Map<String, dynamic>> _subRegions = [];
  List<Map<String, dynamic>> _subAreas = [];
  List<Map<String, dynamic>> _mcList = [];
  List<Map<String, dynamic>> _statusTableData = [];
  List<Map<String, dynamic>> _profileTableData = [];
  List<Map<String, dynamic>> _manPowerTableData = [];

  final Map<String, String> _regionUrls = {
    'REGION EAST JAVA': 'https://bit.ly/3Ojn5w2',
    'REGION CENTRAL JAVA': 'https://bit.ly/3V5Zu5T',
    'REGION BALI NUSRA': 'https://bit.ly/4fCuqTL',
  };

  var baseURL = 'http://103.157.116.221:8088/elang-dashboard-backend/public';

  static const autoScrollDuration = Duration(seconds: 5);

  Future<void>? _launched;

  // Last update
  Future<void> _fetchLastUpdate(String? token) async {
    final url = Uri.parse(
      '$baseURL/api/v1/dashboard/as-of-date',
    );

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          lastUpdate = data['data']['asof_dt'];
        });
      } else {
        SnackBar(content: Text('Failed to load data: ${response.statusCode}'));
      }
    } catch (error) {
      const SnackBar(content: Text('Error fetching data'));
    }
  }

  // REGION DATA (Dropdown 2)
  Future<void> fetchRegions(String? token) async {
    final url = '$baseURL/api/v1/dropdown/get-region-dashboard?circle=1';

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> regionsData = data['data'];

        setState(() {
          _regions = regionsData
              .map((region) => {'id': region['id'], 'name': region['name']})
              .toList();
          // Tambahkan 'ALL' sebagai pilihan pertama
          _regions.insert(0, {'id': null, 'name': 'ALL'});
          _selectedDropdown2 =
              _regions.isNotEmpty ? _regions[0]['name'] : 'ALL';
        });
      } else {
        SnackBar(
            content: Text('Failed to load regions: ${response.statusCode}'));
      }
    } catch (e) {
      const SnackBar(content: Text('Error fetching data'));
    }
  }

  // AREA DATA (Dropdown 3)
  Future<void> fetchSubRegions(int regionId) async {
    final url =
        '$baseURL/api/v1/dropdown/get-region-dashboard?circle=1&region=$regionId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> subRegionsData = data['data'];

        setState(() {
          _subRegions = subRegionsData
              .map((subRegion) =>
                  {'id': subRegion['id'], 'name': subRegion['name']})
              .toList();
          // Tambahkan 'ALL' sebagai pilihan pertama
          _subRegions.insert(0, {'id': null, 'name': 'ALL'});
          _selectedDropdown3 =
              _subRegions.isNotEmpty ? _subRegions[0]['name'] : 'ALL';
        });
      } else {
        SnackBar(
            content:
                Text('Failed to load sub-regions: ${response.statusCode}'));
      }
    } catch (e) {
      const SnackBar(content: Text('Error fetching data'));
    }
  }

  // BRANCH DATA (Dropdown 4)
  Future<void> fetchAreas(int regionId, int subRegionId) async {
    final url =
        '$baseURL/api/v1/dropdown/get-region-dashboard?circle=1&region=$regionId&area=$subRegionId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> areasData = data['data'];

        setState(() {
          _subAreas = areasData
              .map((area) => {'id': area['id'], 'name': area['name']})
              .toList();
          // Tambahkan 'ALL' sebagai pilihan pertama
          _subAreas.insert(0, {'id': null, 'name': 'ALL'});
          _selectedDropdown4 =
              _subAreas.isNotEmpty ? _subAreas[0]['name'] : 'ALL';
        });
      } else {
        SnackBar(content: Text('Failed to load areas: ${response.statusCode}'));
      }
    } catch (e) {
      const SnackBar(content: Text('Error fetching data'));
    }
  }

  // MC DATA (Dropdown 5)
  Future<void> fetchMC(
      int circleId, int regionId, int areaId, int branchId) async {
    final url =
        '$baseURL/api/v1/dropdown/get-region-dashboard?circle=$circleId&region=$regionId&area=$areaId&branch=$branchId';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> mcData = data['data'];

        setState(() {
          _mcList = mcData
              .map((mc) => {
                    'id': mc['id'],
                    'id_secondary': mc['id_secondary'],
                    'name': mc['name'],
                    'display_name': '${mc['name']} (${mc['id']})'
                  })
              .toList();

          // Add 'ALL' as first option
          _mcList.insert(0, {
            'id': null,
            'id_secondary': null,
            'name': 'ALL',
            'display_name': 'ALL'
          });

          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          if (authProvider.mc != 0) {
            final mcEntry = _mcList.firstWhere(
                (mc) => mc['id'] == authProvider.mc,
                orElse: () => _mcList[0]);
            _selectedDropdown5 = mcEntry['name'];
          } else {
            _selectedDropdown5 = _mcList[0]['name'];
          }
        });
      } else {
        SnackBar(content: Text('Failed to load MCs: ${response.statusCode}'));
      }
    } catch (e) {
      const SnackBar(content: Text('Error fetching data'));
    }
  }

  // LAUNCH BROWSER
  Future<void> _launchInBrowserView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $url');
    }
  }

  // Status table data
  Future<void> fetchStatusTable({
    int? circleId,
    int? regionId,
    int? areaId,
    int? branchId,
    int? mcId,
    String? token,
  }) async {
    setState(() {
      _isLoadingTable = true;
    });

    circleId = 1;
    String url = '$baseURL/api/v1/dashboard/status?circle=$circleId';

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    // Add parameters based on selection hierarchy
    if (_selectedDropdown2 != 'ALL') {
      if (branchId != null && _selectedDropdown3 != 'ALL') {
        areaId = _subRegions
            .firstWhere((sr) => sr['name'] == _selectedDropdown3)['id'];
      }

      if (areaId != null) {
        regionId =
            _regions.firstWhere((r) => r['name'] == _selectedDropdown2)['id'];
      }

      if (regionId != null &&
          areaId == null &&
          branchId == null &&
          mcId == null) {
        url += '&region=$regionId';
      } else if (regionId != null &&
          areaId != null &&
          branchId == null &&
          mcId == null) {
        url += '&region=$regionId&area=$areaId';
      } else if (regionId != null &&
          areaId != null &&
          branchId != null &&
          mcId == null) {
        url += '&region=$regionId&area=$areaId&branch=$branchId';
      } else if (regionId != null &&
          areaId != null &&
          branchId != null &&
          mcId != null) {
        url += '&region=$regionId&area=$areaId&branch=$branchId&mc=$mcId';
      }
    }

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _statusTableData = List<Map<String, dynamic>>.from(data['data']);
          _isLoadingTable = false;
        });
      } else {
        setState(() {
          _statusTableData = [];
          _isLoadingTable = false;
        });
        SnackBar(
          content: Text('Failed to load status table: ${response.statusCode}'),
        );
      }
    } catch (e) {
      setState(() {
        _statusTableData = [];
        _isLoadingTable = false;
      });
      const SnackBar(content: Text('Error fetching data'));
    }
  }

  // Profiles table data
  Future<void> fetchProfileTable({
    int? circleId,
    int? regionId,
    int? areaId,
    int? branchId,
    int? mcId,
    String? token,
  }) async {
    setState(() {
      _isLoadingTable = true;
    });

    circleId = 1;
    String url = '$baseURL/api/v1/dashboard/profile?circle=$circleId';

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    // Add parameters based on selection hierarchy
    if (_selectedDropdown2 != 'ALL') {
      if (branchId != null && _selectedDropdown3 != 'ALL') {
        areaId = _subRegions
            .firstWhere((sr) => sr['name'] == _selectedDropdown3)['id'];
      }
      if (areaId != null) {
        regionId =
            _regions.firstWhere((r) => r['name'] == _selectedDropdown2)['id'];
      }

      if (regionId != null &&
          areaId == null &&
          branchId == null &&
          mcId == null) {
        url += '&region=$regionId';
      } else if (regionId != null &&
          areaId != null &&
          branchId == null &&
          mcId == null) {
        url += '&region=$regionId&area=$areaId';
      } else if (regionId != null &&
          areaId != null &&
          branchId != null &&
          mcId == null) {
        url += '&region=$regionId&area=$areaId&branch=$branchId';
      } else if (regionId != null &&
          areaId != null &&
          branchId != null &&
          mcId != null) {
        url += '&region=$regionId&area=$areaId&branch=$branchId&mc=$mcId';
      }
    }

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _profileTableData = List<Map<String, dynamic>>.from(data['data']);
          _manPowerTableData = List<Map<String, dynamic>>.from(data['data']);
          _isLoadingTable = false;
        });
      } else {
        setState(() {
          _profileTableData = [];
          _manPowerTableData = [];
          _isLoadingTable = false;
        });
        SnackBar(
          content:
              Text('Failed to load profiles table: ${response.statusCode}'),
        );
      }
    } catch (e) {
      setState(() {
        _profileTableData = [];
        _manPowerTableData = [];
        _isLoadingTable = false;
      });
      const SnackBar(content: Text('Error fetching data'));
    }
  }

  // LOCKED DROPDOWNS
  Future<void> _initializeLockedDropdowns() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    await authProvider.fetchLockedDropdown();

    if (!mounted) return;

    setState(() {
      _selectedDropdown1 = 'Circle Java';
    });

    // Initialize region dropdown dan tunggu sampai selesai
    await fetchRegions(token);
    if (!mounted) return;

    setState(() {
      final regionName = _regions.firstWhere(
          (r) => r['id'] == authProvider.region,
          orElse: () => {'id': null, 'name': 'ALL'})['name'];
      _selectedDropdown2 = regionName;
    });

    // Initialize area dropdown jika ada region
    if (authProvider.region != 0) {
      await fetchSubRegions(authProvider.region);
      if (!mounted) return;

      setState(() {
        final areaName = _subRegions.firstWhere(
            (a) => a['id'] == authProvider.area,
            orElse: () => {'id': null, 'name': 'ALL'})['name'];
        _selectedDropdown3 = areaName;
      });

      // Initialize branch dropdown jika ada area
      if (authProvider.area != 0) {
        await fetchAreas(authProvider.region, authProvider.area);
        if (!mounted) return;

        setState(() {
          final branchName = _subAreas.firstWhere(
              (b) => b['id'] == authProvider.branch,
              orElse: () => {'id': null, 'name': 'ALL'})['name'];
          _selectedDropdown4 = branchName;
        });

        // Initialize MC dropdown jika ada branch
        if (authProvider.branch != 0) {
          await fetchMC(authProvider.circle, authProvider.region,
              authProvider.area, authProvider.branch);
          if (!mounted) return;

          setState(() {
            final mcData = _mcList.firstWhere(
                (mc) => mc['id'] == authProvider.mc,
                orElse: () => {'id': null, 'name': 'ALL'});
            _selectedDropdown5 = mcData['name'];
          });
        }
      }
    }
  }

  // LOGOUT
  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Tampilkan dialog konfirmasi
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await authProvider.logout();
        if (!mounted) return;

        // Redirect ke halaman login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during logout: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    // Pastikan widget sudah ter-mount sepenuhnya
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('Homepage mounted, starting update check...');

      // Berikan sedikit delay untuk memastikan context sudah siap
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      // Lanjutkan dengan inisialisasi lainnya
      if (authProvider.role == 5) {
        await _initializeLockedDropdowns();
        if (mounted) {
          await fetchStatusTable(
            token: token,
            circleId: authProvider.circle,
            regionId: authProvider.region,
            areaId: authProvider.area,
            branchId: authProvider.branch,
            mcId: authProvider.mc,
          );
          await fetchProfileTable(
            token: token,
            circleId: authProvider.circle,
            regionId: authProvider.region,
            areaId: authProvider.area,
            branchId: authProvider.branch,
            mcId: authProvider.mc,
          );
        }
      } else {
        await fetchRegions(token);
        await fetchStatusTable(token: token);
        await fetchProfileTable(token: token);
      }

      await _fetchLastUpdate(token);
      _startAutoScroll();

      // Lakukan pengecekan update
      await UpdateService().checkForUpdate(context);
      if (!mounted) return;
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Handle map click
  void _handleMapClick() {
    if (_selectedDropdown2 == 'ALL') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Peringatan'),
            content: const Text(
                'Tidak tersedia. Silahkan Anda memilih Region di Dropdown nomor 2'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Get URL for selected region
      final url = _regionUrls[_selectedDropdown2];
      if (url != null) {
        _launchInBrowserView(Uri.parse(url));
      }
    }
  }

  // Auto scroll images
  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(autoScrollDuration, (Timer timer) {
      if (_pageController.hasClients) {
        if (_currentPage < 2) {
          _pageController.animateToPage(
            _currentPage + 1,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;
    final role = Provider.of<AuthProvider>(context).role;
    final territory = Provider.of<AuthProvider>(context).territory;
    final brand = Provider.of<AuthProvider>(context).brand;
    final Uri whatsappUrl = Uri.parse(
        'https://api.whatsapp.com/send?phone=6285851715758&text=ELANG');
    final Uri grafikUrl = Uri.parse("https://tabsoft.co/4fZU0Sw");
    final Uri pbiUrl = Uri.parse(
        "https://app.powerbi.com/Redirect?action=openreport&context=Annotate&ctid=77080246-342c-482e-a864-447a4f6133f1&pbi_source=mobile_android&groupObjectId=&reportObjectId=0ab5c9ce-7fe5-41ae-aaca-ae3683ac3f48&reportPage=063cc12a75b6f21c5097&bookmarkGuid=bf2a4452-e680-4048-bb8d-4cfd9d0321bb&fullScreen=0");

    return GestureDetector(
      onTap: _resetInactivityTimer, // Reset timer on any tap
      onPanDown: (_) => _resetInactivityTimer(), // Reset timer on any pan
      onPanUpdate: (_) => _resetInactivityTimer(), // Reset timer on pan update
      child: Scaffold(
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
                          'ELANG JAVA DASHBOARD',
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
                    width: mediaQueryWidth,
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
                                    backgroundImage:
                                        AssetImage('assets/100.png'),
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
                                      _buildDropdown1(),

                                      // Dropdown 2
                                      _buildDropdown2(),

                                      // Dropdown 3
                                      _buildDropdown3(),

                                      // Dropdown 4
                                      _buildDropdown4(),

                                      // Dropdown 5
                                      _buildDropdown5(),
                                    ],
                                  ),
                                ],
                              ),

                              // Tabs (Status and Profile)
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedTabIndex = 0;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: _selectedTabIndex == 0
                                            ? Colors.grey[300]
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'Status',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),

                                  // TAB PROFILE
                                  const SizedBox(width: 20),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedTabIndex = 1;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: _selectedTabIndex == 1
                                            ? Colors.grey[300]
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'Profile',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 5),
                              _selectedTabIndex == 0
                                  ? SizedBox(
                                      height: mediaQueryHeight * 0.233,
                                      width: mediaQueryWidth * 0.9,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            // IM3 Table
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: _buildTableCard(
                                                  'IM3 (Last Update: $lastUpdate)',
                                                  true),
                                            ),
                                            // 3ID Table
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(1.0),
                                              child: _buildTableCard(
                                                  '3ID (Last Update: $lastUpdate)',
                                                  false),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : SizedBox(
                                      height: mediaQueryHeight * 0.253,
                                      width: mediaQueryWidth * 0.9,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            // Profile Total Table
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: _buildProfileTableCard(
                                                  'TOTAL (Last Update: $lastUpdate)'),
                                            ),

                                            // Man Power Table
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(1.0),
                                              child: _buildManPowerTableCard(
                                                  'MAN_POWER (Last Update: $lastUpdate)'
                                                      .toString()),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                              // Information Gambar
                              const SizedBox(height: 6),
                              SizedBox(
                                height: mediaQueryHeight * 0.20,
                                width: mediaQueryWidth * 0.9,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: PageView(
                                        controller: _pageController,
                                        onPageChanged: (int page) {
                                          setState(() {
                                            _currentPage = page;
                                          });
                                        },
                                        physics:
                                            const PageScrollPhysics(), // Enables snapping behavior
                                        children: [
                                          // Step 1
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 2.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    spreadRadius: 1,
                                                    blurRadius: 2,
                                                    offset: const Offset(0, 1),
                                                  ),
                                                ],
                                              ),
                                              child: Stack(
                                                fit: StackFit
                                                    .expand, // Make stack fill container
                                                children: [
                                                  InkWell(
                                                    onTap: () async {
                                                      final Uri url = Uri.parse(
                                                          'http://bit.ly/40fU8ae');
                                                      try {
                                                        if (!await launchUrl(
                                                            url,
                                                            mode: LaunchMode
                                                                .externalApplication)) {
                                                          throw Exception(
                                                              'Could not launch $url');
                                                        }
                                                      } catch (e) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                              content: Text(
                                                                  'Could not open website: $e')),
                                                        );
                                                      }
                                                    },
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      child: Image.asset(
                                                        'assets/promo_kilat.jpg',
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                        height: double
                                                            .infinity, // Ensure image fills height
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          // Step 2
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 2.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    spreadRadius: 1,
                                                    blurRadius: 2,
                                                    offset: const Offset(0, 1),
                                                  ),
                                                ],
                                              ),
                                              child: Stack(
                                                children: [
                                                  InkWell(
                                                    onTap: () async {
                                                      final Uri url = Uri.parse(
                                                          'http://bit.ly/3PzBi8J');
                                                      try {
                                                        if (!await launchUrl(
                                                            url,
                                                            mode: LaunchMode
                                                                .externalApplication)) {
                                                          throw Exception(
                                                              'Could not launch $url');
                                                        }
                                                      } catch (e) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                              content: Text(
                                                                  'Could not open website: $e')),
                                                        );
                                                      }
                                                    },
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      child: Image.asset(
                                                        'assets/pelanggan_baru_3id.jpg',
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          // Step 3
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 2.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    spreadRadius: 1,
                                                    blurRadius: 2,
                                                    offset: const Offset(0, 1),
                                                  ),
                                                ],
                                              ),
                                              child: Stack(
                                                children: [
                                                  InkWell(
                                                    onTap: () async {
                                                      final Uri url = Uri.parse(
                                                          'http://bit.ly/3PthkMY');
                                                      try {
                                                        if (!await launchUrl(
                                                            url,
                                                            mode: LaunchMode
                                                                .externalApplication)) {
                                                          throw Exception(
                                                              'Could not launch $url');
                                                        }
                                                      } catch (e) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                              content: Text(
                                                                  'Could not open website: $e')),
                                                        );
                                                      }
                                                    },
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      child: Image.asset(
                                                        'assets/pelanggan_baru_im3.jpg',
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Page Indicators
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        3,
                                        (index) => Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _currentPage == index
                                                ? const Color.fromARGB(
                                                    255, 250, 45, 208)
                                                : Colors.grey.withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ICON BUTTONS
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // BUTTON DSE
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 35,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 250, 45, 208),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                  child: IconButton(
                                                      onPressed: () {
                                                        Navigator
                                                            .pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    const DSE(),
                                                          ),
                                                        );
                                                      },
                                                      icon: const FaIcon(
                                                        FontAwesomeIcons
                                                            .motorcycle,
                                                        color: Colors.white,
                                                        size: 15,
                                                      )),
                                                ),
                                                const Text('DSE',
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.black)),
                                              ],
                                            ),

                                            // BUTTON OUTLET
                                            const SizedBox(width: 10),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 35,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 250, 45, 208),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                  child: IconButton(
                                                      onPressed: () {
                                                        Navigator
                                                            .pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const OUTLET(),
                                                          ),
                                                        );
                                                      },
                                                      icon: const FaIcon(
                                                        FontAwesomeIcons.home,
                                                        color: Colors.white,
                                                        size: 15,
                                                      )),
                                                ),
                                                const Text('OUTLET',
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.black)),
                                              ],
                                            ),

                                            // BUTTON SITE
                                            const SizedBox(width: 10),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 35,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 250, 45, 208),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                  child: IconButton(
                                                      onPressed: () {
                                                        Navigator
                                                            .pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const SITE(),
                                                          ),
                                                        );
                                                      },
                                                      icon: const FaIcon(
                                                        FontAwesomeIcons
                                                            .towerCell,
                                                        color: Colors.white,
                                                        size: 15,
                                                      )),
                                                ),
                                                const Text('SITE',
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.black)),
                                              ],
                                            ),

                                            // BUTTON GRAFIK
                                            const SizedBox(width: 10),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 35,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 250, 45, 208),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                  child: IconButton(
                                                      onPressed: () =>
                                                          setState(() {
                                                            _launched =
                                                                _launchInBrowserView(
                                                                    grafikUrl);
                                                          }),
                                                      icon: const FaIcon(
                                                        FontAwesomeIcons
                                                            .chartLine,
                                                        color: Colors.white,
                                                        size: 15,
                                                      )),
                                                ),
                                                const Text('GRAFIK',
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.black)),
                                              ],
                                            ),

                                            // BUTTON MAPS
                                            const SizedBox(width: 10),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 35,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 250, 45, 208),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                  child: IconButton(
                                                      onPressed: () {
                                                        Navigator
                                                            .pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const CariMaps(),
                                                          ),
                                                        );
                                                      },
                                                      icon: const FaIcon(
                                                        FontAwesomeIcons
                                                            .mapLocationDot,
                                                        color: Colors.white,
                                                        size: 15,
                                                      )),
                                                ),
                                                const Text(
                                                  'MAPS',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),

                                            // BUTTON NEARME
                                            const SizedBox(width: 8),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 35,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 250, 45, 208),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                  child: IconButton(
                                                      onPressed: () {
                                                        Navigator
                                                            .pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    McMaps(
                                                              brand: brand,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      icon: const FaIcon(
                                                        FontAwesomeIcons.mapPin,
                                                        color: Colors.white,
                                                        size: 15,
                                                      )),
                                                ),
                                                const Text('NEAR ME',
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.black)),
                                              ],
                                            ),

                                            const SizedBox(width: 8),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 35,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 250, 45, 208),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                  child: IconButton(
                                                      onPressed: () {
                                                        Navigator
                                                            .pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const Mitra(),
                                                          ),
                                                        );
                                                      },
                                                      icon: const FaIcon(
                                                        FontAwesomeIcons
                                                            .handshake,
                                                        color: Colors.white,
                                                        size: 15,
                                                      )),
                                                ),
                                                const Text('MITRA',
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.black)),
                                              ],
                                            ),
                                            const SizedBox(width: 7.5),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            // AI ELANG PRO Button
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 35,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 255, 0, 0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                  child: IconButton(
                                                      onPressed: _handleLogout,
                                                      icon: const FaIcon(
                                                        FontAwesomeIcons
                                                            .arrowRightFromBracket,
                                                        color: Colors.white,
                                                        size: 15,
                                                      )),
                                                ),
                                                const Text(
                                                  'LOGOUT',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),

                                            // PBI Button
                                            const SizedBox(width: 7.5),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 35,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 250, 45, 208),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                  child: IconButton(
                                                      onPressed: () =>
                                                          setState(() {
                                                            _launched =
                                                                _launchInBrowserView(
                                                                    pbiUrl);
                                                          }),
                                                      icon: const FaIcon(
                                                        FontAwesomeIcons
                                                            .chartColumn,
                                                        color: Colors.white,
                                                        size: 15,
                                                      )),
                                                ),
                                                const Text('PBI',
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.black)),
                                              ],
                                            ),

                                            // AI ELANG PRO Button
                                            const SizedBox(width: 11.5),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 35,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 250, 45, 208),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                  child: IconButton(
                                                    onPressed: () {
                                                      launchUrl(Uri.parse(
                                                          'https://elangpro.com/login'));
                                                    },
                                                    icon: const ImageIcon(
                                                      AssetImage(
                                                          'assets/LOGO.png'),
                                                      color: Colors.white,
                                                      size: 85,
                                                    ),
                                                  ),
                                                ),
                                                const Text(
                                                  'PRO',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),

                                            // FB-MS Button
                                            const SizedBox(width: 14.5),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 35,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 250, 45, 208),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                  child: IconButton(
                                                    onPressed: _handleMapClick,
                                                    icon: const ImageIcon(
                                                      AssetImage(
                                                          'assets/fbmsmap.png'),
                                                      color: Colors.white,
                                                      size: 85,
                                                    ),
                                                  ),
                                                ),
                                                const Text(
                                                  'FB-MS',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),

                                            // CHATBOT button
                                            const SizedBox(width: 4.5),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                    width: 35,
                                                    height: 35,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              37,
                                                              211,
                                                              102),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                    ),
                                                    child: IconButton(
                                                      onPressed: () =>
                                                          setState(() {
                                                        _launched =
                                                            _launchInBrowserView(
                                                                whatsappUrl);
                                                      }),
                                                      icon: const FaIcon(
                                                          FontAwesomeIcons
                                                              .whatsapp,
                                                          color: Colors.white,
                                                          size: 15),
                                                    )),
                                                const Text(
                                                  'CHATBOT',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.home, color: Colors.black),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //_buildProfileTableCard
  Widget _buildProfileTableCard(String title) {
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Container(
        padding: const EdgeInsets.all(4),
        width: mediaQueryWidth * 0.875,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),

            // Table
            const SizedBox(height: 5),
            Expanded(
              child: _isLoadingTable
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Table(
                        border: TableBorder(
                          horizontalInside: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(0.75), // PROFILE
                          1: FlexColumnWidth(0.75), // TOTAL
                        },
                        children: [
                          // Header Row
                          TableRow(
                            children: [
                              TableCell(
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text(
                                    'PROFILE',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 7,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text(
                                    'JUMLAH',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 7,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Data Rows
                          ..._profileTableData.map(
                            (row) {
                              return TableRow(
                                children: [
                                  TableCell(
                                    child: Container(
                                      padding: const EdgeInsets.all(3.7),
                                      child: Text(
                                        row['PROFILE'] ?? 'No Data',
                                        style: const TextStyle(fontSize: 7),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Container(
                                      padding: const EdgeInsets.all(3.7),
                                      child: Text(
                                        row['TOTAL'] ?? 'No Data',
                                        style: const TextStyle(fontSize: 7),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(
              height: 12,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "Next >",
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //_buildManPowerTableCard
  Widget _buildManPowerTableCard(String title) {
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Container(
        padding: const EdgeInsets.all(4),
        width: mediaQueryWidth * 0.875,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),

            // Table
            const SizedBox(height: 5),
            Expanded(
              child: _isLoadingTable
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Table(
                        border: TableBorder(
                          horizontalInside: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(0.75), // PROFILE
                          1: FlexColumnWidth(0.75), // TOTAL
                        },
                        children: [
                          // Header Row
                          TableRow(
                            children: [
                              TableCell(
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text(
                                    'PROFILE',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 7,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Text(
                                    'JUMLAH',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 7,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Data Rows
                          ..._manPowerTableData.map(
                            (row) {
                              return TableRow(
                                children: [
                                  TableCell(
                                    child: Container(
                                      padding: const EdgeInsets.all(3.7),
                                      child: Text(
                                        row['MAN_POWER'] ?? 'No Data',
                                        style: const TextStyle(fontSize: 7),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Container(
                                      padding: const EdgeInsets.all(3.7),
                                      child: Text(
                                        row['JUMLAH'] ?? 'No Data',
                                        style: const TextStyle(fontSize: 7),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(
              height: 12,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "< Prev",
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //_buildTableCard
  Widget _buildTableCard(String title, bool isIM3) {
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Container(
        padding: const EdgeInsets.all(4),
        width: mediaQueryWidth * 0.875,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),

            // Table
            const SizedBox(height: 5),
            Expanded(
              child: _isLoadingTable
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Table(
                        border: TableBorder(
                          horizontalInside: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(0.55), // ITEM
                          1: FlexColumnWidth(0.75), // MTD
                          2: FlexColumnWidth(0.75), // LMTD
                          3: FlexColumnWidth(0.75), // GROWTH
                        },
                        children: [
                          // Header Row
                          TableRow(
                            children: [
                              TableCell(
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  child: const Text(
                                    'ITEM',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 7,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  child: const Text(
                                    'MTD',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 7,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  child: const Text(
                                    'LMTD',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 7,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  child: const Text(
                                    'GROWTH',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 7,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Data Rows
                          ..._statusTableData.map((row) {
                            String prefix = isIM3 ? '_IM3' : '_3ID';
                            return TableRow(
                              children: [
                                TableCell(
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    child: Text(
                                      row['ITEM$prefix'] ?? 'No Data',
                                      style: const TextStyle(fontSize: 7),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    child: Text(
                                      row['MTD$prefix'] ?? 'No Data',
                                      style: const TextStyle(fontSize: 7),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    child: Text(
                                      row['LMTD$prefix'] ?? 'No Data',
                                      style: const TextStyle(fontSize: 7),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    child: Text(
                                      row['GROWTH$prefix'] ?? 'No Data',
                                      style: const TextStyle(fontSize: 7),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
            ),
            SizedBox(
              height: 10,
              child: Align(
                alignment: isIM3 ? Alignment.bottomRight : Alignment.bottomLeft,
                child: Text(
                  isIM3 ? "Next >" : "< Prev",
                  style: const TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dropdown 1
  Widget _buildDropdown1() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return DropdownButton<String>(
          value: _selectedDropdown1,
          isDense: true,
          onChanged: _isDropdownLocked(1)
              ? null
              : (String? newValue) {
                  setState(() {
                    _selectedDropdown1 = newValue;
                  });
                },
          items: <String>['Circle Java']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              alignment: AlignmentDirectional.centerEnd,
              child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 10,
                    color: _isDropdownLocked(1) ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
          alignment: Alignment.centerRight,
        );
      },
    );
  }

  // Dropdown 2
  Widget _buildDropdown2() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return DropdownButton<String>(
          value: _selectedDropdown2,
          isDense: true,
          onChanged: _isDropdownLocked(2)
              ? null
              : (String? newValue) {
                  setState(() {
                    _selectedDropdown2 = newValue;
                    final token =
                        Provider.of<AuthProvider>(context, listen: false).token;

                    // Reset dropdowns 3-5 for role 1
                    if (authProvider.role == 1) {
                      _selectedDropdown3 = 'ALL';
                      _selectedDropdown4 = 'ALL';
                      _selectedDropdown5 = 'ALL';
                      _subRegions.clear();
                      _subAreas.clear();
                      _mcList.clear();
                      _statusTableData.clear();
                      _profileTableData.clear();
                      _manPowerTableData.clear();
                    }

                    // Jika "ALL" dipilih
                    if (newValue == 'ALL') {
                      _selectedDropdown3 = 'ALL';
                      _selectedDropdown4 = 'ALL';
                      _selectedDropdown5 = 'ALL';
                      _subRegions.clear();
                      _subAreas.clear();
                      _mcList.clear();
                      _statusTableData.clear();
                      _profileTableData.clear();
                      _manPowerTableData.clear();

                      fetchStatusTable(token: token);
                      fetchProfileTable(token: token);
                    } else {
                      int regionId = _regions
                          .firstWhere((r) => r['name'] == newValue)['id'];

                      // Fetch sub-regions with reset for role 1
                      fetchSubRegions(regionId).then((_) {
                        if (authProvider.role == 1) {
                          setState(() {
                            _selectedDropdown3 = 'ALL';
                            _subAreas.clear();
                            _mcList.clear();
                          });
                        } else if (_selectedDropdown3 != 'ALL') {
                          // For other roles, check if current area selection exists
                          if (!_subRegions
                              .any((sr) => sr['name'] == _selectedDropdown3)) {
                            _selectedDropdown3 = 'ALL';
                          }
                        }
                      });

                      fetchStatusTable(regionId: regionId, token: token);
                      fetchProfileTable(regionId: regionId, token: token);
                    }
                  });
                },
          items: _regions
              .map<DropdownMenuItem<String>>((Map<String, dynamic> region) {
            return DropdownMenuItem<String>(
              value: region['name'],
              alignment: AlignmentDirectional.centerEnd,
              child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  region['name'],
                  style: TextStyle(
                    fontSize: 10,
                    color: _isDropdownLocked(2) ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
          alignment: Alignment.centerRight,
        );
      },
    );
  }

  // Dropdown 3
  Widget _buildDropdown3() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return DropdownButton<String>(
          value: _selectedDropdown3,
          isDense: true,
          onChanged: _isDropdownLocked(3)
              ? null
              : (String? newValue) {
                  setState(() {
                    _selectedDropdown3 = newValue;
                    final token =
                        Provider.of<AuthProvider>(context, listen: false).token;

                    // Reset dropdown 4 and 5 when changing area
                    if (newValue == 'ALL') {
                      _selectedDropdown4 = 'ALL';
                      _selectedDropdown5 = 'ALL';
                      _subAreas.clear();
                      _mcList.clear();
                      _statusTableData.clear();
                      _profileTableData.clear();
                      _manPowerTableData.clear();

                      int regionId = _regions.firstWhere(
                          (r) => r['name'] == _selectedDropdown2)['id'];
                      fetchStatusTable(regionId: regionId, token: token);
                      fetchProfileTable(regionId: regionId, token: token);
                    } else {
                      // Always reset dropdown 4 and 5 when area changes
                      _selectedDropdown4 = 'ALL';
                      _selectedDropdown5 = 'ALL';
                      _mcList.clear();
                      _statusTableData.clear();
                      _profileTableData.clear();
                      _manPowerTableData.clear();

                      int areaId = _subRegions
                          .firstWhere((sr) => sr['name'] == newValue)['id'];
                      int regionId = _regions.firstWhere(
                          (r) => r['name'] == _selectedDropdown2)['id'];

                      // Fetch new areas
                      fetchAreas(regionId, areaId);

                      fetchStatusTable(areaId: areaId, token: token);
                      fetchProfileTable(areaId: areaId, token: token);
                    }
                  });
                },
          items: _subRegions
              .map<DropdownMenuItem<String>>((Map<String, dynamic> subRegion) {
            return DropdownMenuItem<String>(
              value: subRegion['name'],
              alignment: AlignmentDirectional.centerEnd,
              child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  subRegion['name'],
                  style: TextStyle(
                    fontSize: 10,
                    color: _isDropdownLocked(3) ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
          alignment: Alignment.centerRight,
        );
      },
    );
  }

  // Dropdown 4
  Widget _buildDropdown4() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return DropdownButton<String>(
          value: _selectedDropdown4,
          isDense: true,
          onChanged: _isDropdownLocked(4)
              ? null
              : (String? newValue) {
                  setState(() {
                    _selectedDropdown4 = newValue;
                    final token =
                        Provider.of<AuthProvider>(context, listen: false).token;

                    if (newValue == 'ALL') {
                      _selectedDropdown5 = 'ALL';
                      _mcList.clear();
                      _statusTableData.clear();
                      _profileTableData.clear();
                      _manPowerTableData.clear();

                      int areaId = _subRegions.firstWhere(
                          (sr) => sr['name'] == _selectedDropdown3)['id'];
                      fetchStatusTable(areaId: areaId, token: token);
                      fetchProfileTable(areaId: areaId, token: token);
                    } else {
                      int branchId = _subAreas
                          .firstWhere((area) => area['name'] == newValue)['id'];
                      int regionId = _regions.firstWhere(
                          (r) => r['name'] == _selectedDropdown2)['id'];
                      int areaId = _subRegions.firstWhere(
                          (sr) => sr['name'] == _selectedDropdown3)['id'];

                      // Fetch MC list but maintain current selection if possible
                      fetchMC(1, regionId, areaId, branchId).then((_) {
                        if (_selectedDropdown5 != 'ALL') {
                          if (!_mcList
                              .any((mc) => mc['name'] == _selectedDropdown5)) {
                            _selectedDropdown5 = 'ALL';
                          }
                        }
                      });

                      fetchStatusTable(branchId: branchId, token: token);
                      fetchProfileTable(branchId: branchId, token: token);
                    }
                  });
                },
          items: _subAreas
              .map<DropdownMenuItem<String>>((Map<String, dynamic> area) {
            return DropdownMenuItem<String>(
              value: area['name'],
              alignment: AlignmentDirectional.centerEnd,
              child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  area['name'],
                  style: TextStyle(
                    fontSize: 10,
                    color: _isDropdownLocked(4) ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
          alignment: Alignment.centerRight,
        );
      },
    );
  }

  // Dropdown 5
  Widget _buildDropdown5() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return DropdownButton<String>(
          value: _selectedDropdown5,
          isDense: true,
          onChanged: _isDropdownLocked(5)
              ? null
              : (String? newValue) {
                  setState(() {
                    _selectedDropdown5 = newValue;
                    final token =
                        Provider.of<AuthProvider>(context, listen: false).token;
                    // Dalam onChanged dropdown 5:
                    if (newValue != 'ALL') {
                      int mcId = _mcList
                          .firstWhere((mc) => mc['name'] == newValue)['id'];
                      fetchStatusTable(
                          mcId: mcId,
                          token: token,
                          branchId: _subAreas.firstWhere((area) =>
                              area['name'] == _selectedDropdown4)['id'],
                          areaId: _subRegions.firstWhere(
                              (sr) => sr['name'] == _selectedDropdown3)['id'],
                          regionId: _regions.firstWhere(
                              (r) => r['name'] == _selectedDropdown2)['id']);
                      fetchProfileTable(
                          mcId: mcId,
                          token: token,
                          branchId: _subAreas.firstWhere((area) =>
                              area['name'] == _selectedDropdown4)['id'],
                          areaId: _subRegions.firstWhere(
                              (sr) => sr['name'] == _selectedDropdown3)['id'],
                          regionId: _regions.firstWhere(
                              (r) => r['name'] == _selectedDropdown2)['id']);
                    } else {
                      // Show branch status when ALL is selected for MC
                      if (_selectedDropdown4 != 'ALL') {
                        int branchId = _subAreas.firstWhere(
                            (area) => area['name'] == _selectedDropdown4)['id'];
                        fetchStatusTable(branchId: branchId, token: token);
                        fetchProfileTable(branchId: branchId, token: token);
                      }
                    }
                  });
                },
          items:
              _mcList.map<DropdownMenuItem<String>>((Map<String, dynamic> mc) {
            return DropdownMenuItem<String>(
              value: mc['name'],
              alignment: AlignmentDirectional.centerEnd,
              child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  mc['name'],
                  style: TextStyle(
                    fontSize: 10,
                    color: _isDropdownLocked(5) ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
          alignment: Alignment.centerRight,
        );
      },
    );
  }
}
