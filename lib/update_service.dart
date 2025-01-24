import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateService {
  static const String VERSION_CHECK_URL =
      "https://raw.githubusercontent.com/AI-Elang/ElangDashboardUpdateApp/main/version.json";

  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  bool _isDownloading = false;
  bool _isDialogShowing = false;
  BuildContext? _currentContext;

  Future<void> checkForUpdate(BuildContext context) async {
    debugPrint('Checking for updates...');
    if (_isDownloading || _isDialogShowing) {
      debugPrint('Update check skipped: download or dialog in progress');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdateCheck = prefs.getInt('last_update_check') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Add a minimum interval between update checks (e.g., 2 days)
      if (now - lastUpdateCheck < const Duration(days: 2).inMilliseconds) {
        debugPrint('Skipping update check: checked recently');
        return;
      }

      final updateInfo = await _compareVersions();
      if (updateInfo != null && !_isDialogShowing) {
        _isDialogShowing = true;
        debugPrint('Showing update dialog...');
        await showUpdateDialog(context, updateInfo);
        _isDialogShowing = false;
      }

      // Save the timestamp of this update check
      await prefs.setInt('last_update_check', now);
    } catch (e) {
      debugPrint('Update check error: $e');
      _isDialogShowing = false;
    }
  }

  Future<Map<String, dynamic>?> _compareVersions() async {
    try {
      final response = await http.get(Uri.parse(VERSION_CHECK_URL));
      if (response.statusCode != 200) {
        debugPrint('Failed to get version info: ${response.statusCode}');
        return null;
      }

      final remoteConfig = json.decode(response.body);
      final packageInfo = await PackageInfo.fromPlatform();

      // Get the last successfully installed version from SharedPreferences
      final installedVersion = packageInfo.version;
      final installedBuild = int.parse(packageInfo.buildNumber);

      // Get the remote version info
      final remoteVersion = remoteConfig['version'].toString();
      final remoteBuild = remoteConfig['build_number'] as int;

      debugPrint('Version comparison:');
      debugPrint('Current: $installedVersion+$installedBuild');
      debugPrint('Remote: $remoteVersion+$remoteBuild');

      final List<int> currentParts =
          installedVersion.split('.').map(int.parse).toList();
      final List<int> remoteParts =
          remoteVersion.split('.').map(int.parse).toList();

      bool needsUpdate = false;

      // Compare version numbers (x.y.z)
      for (int i = 0; i < currentParts.length; i++) {
        if (remoteParts[i] > currentParts[i]) {
          needsUpdate = true;
          break;
        } else if (remoteParts[i] < currentParts[i]) {
          break;
        }
      }

      // If versions are same, compare build numbers
      if (!needsUpdate && remoteBuild > installedBuild) {
        needsUpdate = true;
      }

      if (needsUpdate) {
        debugPrint('Update available: $remoteVersion+$remoteBuild');
        return remoteConfig;
      }

      debugPrint('No update needed');
      return null;
    } catch (e) {
      debugPrint('Error checking version: $e');
      return null;
    }
  }

  Future<void> downloadAndInstallUpdate(
      String url, Function(double) onProgress) async {
    if (_isDownloading) return;

    _isDownloading = true;
    final dio = Dio();
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final status = await Permission.requestInstallPackages.request();
        if (!status.isGranted) {
          throw Exception('Installation permission not granted');
        }

        final tempDir = await getTemporaryDirectory();
        final savePath = '${tempDir.path}/app-update.apk';

        debugPrint('Starting download to: $savePath');
        await dio.download(
          url,
          savePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = received / total;
              onProgress(progress);
              debugPrint(
                  'Download progress: ${(progress * 100).toStringAsFixed(1)}%');
            }
          },
          options: Options(
            receiveTimeout: const Duration(minutes: 5),
            sendTimeout: const Duration(minutes: 5),
          ),
        );

        if (!await verifyDownloadedFile(savePath)) {
          throw Exception('Downloaded file verification failed');
        }

        debugPrint('Download completed, initiating installation...');

        // Close update dialog if it's showing
        if (_currentContext != null && _currentContext!.mounted) {
          Navigator.of(_currentContext!).pop();
          _isDialogShowing = false;
        }

        final result = await OpenFile.open(savePath);
        if (result.type != ResultType.done) {
          _isDownloading = false;
          throw Exception('Could not open APK file: ${result.message}');
        }

        // Reset all states
        _isDownloading = false;
        _isDialogShowing = false;
        _currentContext = null;

        // Force exit app for installation
        await FlutterExitApp.exitApp(iosForceExit: true);
        return;
      } catch (e) {
        retryCount++;
        debugPrint('Download attempt $retryCount failed: $e');

        if (_currentContext != null && _currentContext!.mounted) {
          ScaffoldMessenger.of(_currentContext!).showSnackBar(
            SnackBar(
              content: Text('Download failed: $e. Retrying...'),
              duration: const Duration(seconds: 3),
            ),
          );
        }

        if (retryCount >= maxRetries) {
          _isDownloading = false;
          if (_currentContext != null && _currentContext!.mounted) {
            showRetryDialog(_currentContext!, url);
          }
          return;
        }
      }
    }
  }

  Future<bool> verifyDownloadedFile(String filePath) async {
    try {
      final file = await File(filePath).readAsBytes();
      final size = file.lengthInBytes;
      debugPrint('Downloaded file size: ${size ~/ 1024} KB');
      return size > 0;
    } catch (e) {
      debugPrint('File verification failed: $e');
      return false;
    }
  }

  void showRetryDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Installation Failed'),
          content: const Text(
              'Would you like to try downloading and installing again?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                downloadAndInstallUpdate(url, (progress) {});
              },
              child: const Text('Retry'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showUpdateDialog(
      BuildContext context, Map<String, dynamic> updateInfo) {
    debugPrint('Attempting to show update dialog');
    _currentContext = context;
    return showDialog(
      context: context,
      barrierDismissible: !updateInfo['force_update'],
      builder: (BuildContext context) => WillPopScope(
        onWillPop: () async => !updateInfo['force_update'],
        child: UpdateDialog(updateInfo: updateInfo),
      ),
    ).then((_) {
      _isDialogShowing = false;
      debugPrint('Update dialog closed');
    });
  }
}

class UpdateDialog extends StatefulWidget {
  final Map<String, dynamic> updateInfo;

  const UpdateDialog({super.key, required this.updateInfo});

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _downloading = false;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          !widget.updateInfo['force_update'] && !_downloading,
      child: AlertDialog(
        title: const Text(
          'Pembaruan Tersedia',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versi ${widget.updateInfo['version']} telah tersedia!'),
            const SizedBox(height: 10),
            const Text('Pembaruan:'),
            const SizedBox(height: 5),
            ...List<Widget>.from(
              (widget.updateInfo['changelog'] as List).map(
                (item) => Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('• $item'),
                ),
              ),
            ),
            if (_downloading) ...[
              const SizedBox(height: 15),
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 5),
              Text('Mengunduh: ${(_progress * 100).toStringAsFixed(0)}%'),
            ],
          ],
        ),
        actions: [
          if (!_downloading) ...[
            if (widget.updateInfo['force_update'] != true)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Nanti'),
              ),
            ElevatedButton(
              onPressed: () async {
                setState(() => _downloading = true);
                try {
                  final updateService = UpdateService();
                  await updateService.downloadAndInstallUpdate(
                    widget.updateInfo['url'],
                    (progress) => setState(() => _progress = progress),
                  );
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal mengunduh pembaruan: $e')),
                    );
                  }
                }
              },
              child: const Text('Update Sekarang'),
            ),
          ],
        ],
      ),
    );
  }
}
