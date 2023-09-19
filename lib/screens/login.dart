import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:keywarden/providers/auth_provider.dart';
import 'package:keywarden/utils/encryption.dart';
import 'package:keywarden/utils/snackbar.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController controller = TextEditingController();
  bool hasBiometrics = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (hasBiometrics) {
        bioAuth();
      }
    });
    Preferences.getItem('hasBiometrics').then((value) {
      setState(() {
        hasBiometrics = value == null ? false : bool.parse(value);
      });
      if (hasBiometrics) {
        bioAuth();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            children: [
              const Text(
                'Login using your master key.',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              const Text(
                'You can also use your fingerprint to login if you have enabled biometrics.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: "Master Key",
                  border: OutlineInputBorder(),
                ),
                style:
                    TextStyle(fontFamily: GoogleFonts.robotoMono().fontFamily),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return "Master Key must be at least 6 characters long.";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await Preferences.getItem('masterKey').then((master) async {
                      if (master?.trim() != controller.text.trim()) {
                        ShowSnackbar.showWarning(
                            context, "Master Key is incorrect.");
                      } else {
                        await Hive.openBox('passwords',
                                encryptionCipher: HiveAesCipher(
                                    getEncryptKey(master!.trim())))
                            .then((value) {
                          context.read<AuthProvider>().setlogged(true);

                          context.go('/');
                        });
                      }
                    });
                  }
                },
                style: ButtonStyle(
                  textStyle: MaterialStateProperty.all(
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                child: const Text("Log In"),
              ),
              const SizedBox(height: 30),
              if (hasBiometrics)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () async {
                        bioAuth();
                      },
                      icon: const Icon(Icons.fingerprint),
                      iconSize: 50,
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  bioAuth() async {
    LocalAuthentication auth = LocalAuthentication();
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    if (canCheckBiometrics) {
      await auth
          .authenticate(
              localizedReason: 'Please authenticate to Log In',
              options: const AuthenticationOptions(stickyAuth: true))
          .then((value) async {
        if (value) {
          String key = (await Preferences.getItem('masterKey'))!;
          await Hive.openBox('passwords',
                  encryptionCipher: HiveAesCipher(getEncryptKey(key.trim())))
              .then((value) {
            context.read<AuthProvider>().setlogged(true);

            context.go('/');
          });
        } else {
          ShowSnackbar.showWarning(
              context, "Biometrics authentication failed.");
        }
      });
    }
  }
}
