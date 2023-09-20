import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:keywarden/providers/auth_provider.dart';
import 'package:keywarden/utils/encryption.dart';
import 'package:keywarden/utils/extensions.dart';
import 'package:keywarden/utils/snackbar.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool hasBiometrics = false;

  @override
  void initState() {
    super.initState();
    Preferences.getItem('hasBiometrics').then((value) {
      log(value.toString());
      setState(() {
        hasBiometrics = value == null ? false : bool.parse(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            tileColor: context.isDarkMode ? Colors.black : Colors.white,
            title: const Row(
              children: [
                Icon(Icons.fingerprint_rounded),
                SizedBox(width: 16),
                Text("Enable Biometrics"),
              ],
            ),
            value: hasBiometrics,
            inactiveTrackColor: Colors.grey.shade400,
            onChanged: (value) async {
              LocalAuthentication auth = LocalAuthentication();
              bool canCheckBiometrics = await auth.canCheckBiometrics;
              if (canCheckBiometrics) {
                bool didAuthenticate = await auth.authenticate(
                    localizedReason: 'Please authenticate to enable biometrics',
                    options: const AuthenticationOptions(stickyAuth: true));
                if (didAuthenticate) {
                  setState(() {
                    hasBiometrics = value;
                  });
                }
              }
              await Preferences.addItem(
                  'hasBiometrics', hasBiometrics.toString());
            },
          ),
          const SizedBox(height: 8),
          ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            tileColor: context.isDarkMode ? Colors.black : Colors.white,
            leading: const Icon(Icons.backup),
            title: const Text("Backup"),
            onTap: exportData,
          ),
          const SizedBox(height: 8),
          ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            tileColor: context.isDarkMode ? Colors.black : Colors.white,
            leading: const Icon(Icons.restore),
            title: const Text("Import"),
            onTap: () {
              importData().then((value) {
                if (value) {
                  ShowSnackbar.showSuccess(context, 'Imported successfully.');
                } else {
                  ShowSnackbar.showWarning(context, 'Failed to import.');
                }
              });
            },
          ),
          const SizedBox(height: 8),
          ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            tileColor: context.isDarkMode ? Colors.black : Colors.white,
            leading: const Icon(Icons.logout_rounded),
            title: const Text("Logout"),
            onTap: () {
              context.read<AuthProvider>().setlogged(false);
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}

Future<void> exportData() async {
  final box = Hive.box('passwords');
  final data = {
    'name':'Key Warden',
    'type':'passwords',
    'data':box.values.toList()
  };


  String jsonData = jsonEncode(data);

  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/backup.json');

  await file.writeAsString(jsonData, mode: FileMode.writeOnly);

  await Share.shareXFiles([XFile(file.path, name: "Backup")]);
}

Future<bool> importData() async {
  Directory directory = await getTemporaryDirectory();
  // directory.delete(recursive: true);
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    dialogTitle: 'Select backup file',
    type: FileType.custom,
    withData: true,
    allowedExtensions: ['json'],
  );
  

  if (result != null) {
    File file = File(result.files.single.path!);
    file.delete(recursive: true);
    try{
      Map data = jsonDecode(utf8.decode(result.files.single.bytes!));
      if(data['type']=='passwords'){
        Hive.box('passwords').addAll(data['data']);
        return true;
      }
      return false;
    }catch(e){
      return false;
    } 
  } else {
    return false;
  }
}
