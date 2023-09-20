import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:keywarden/utils/encryption.dart';
import 'package:keywarden/utils/snackbar.dart';
import 'package:local_auth/local_auth.dart';

class CreateMasterKey extends StatefulWidget {
  const CreateMasterKey({super.key});

  @override
  State<CreateMasterKey> createState() => _CreateMasterKeyState();
}

class _CreateMasterKeyState extends State<CreateMasterKey> {
  final TextEditingController _controller = TextEditingController();

  final TextEditingController _confirmController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            children: [
              const Text(
                "Create Master Key",
                style: TextStyle(fontSize: 30),
              ),
              const SizedBox(height: 20),
              const Text(
                "Your master key is used to encrypt and decrypt your passwords. It will be used to encrypt your passwords before they are stored on your device.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: "Master Key",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return "Master Key must be at least 6 characters long.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmController,
                decoration: const InputDecoration(
                  labelText: "Confirm Master Key",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return "Master Key must be at least 6 characters long.";
                  }
                  if (_confirmController.text != _controller.text) {
                    return "Master Keys do not match.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await Preferences.addItem(
                      'masterKey',
                      _controller.text.trim(),
                    ).then((value) => Hive.openBox('passwords',
                            encryptionCipher: HiveAesCipher(
                                getEncryptKey(_controller.text.trim())))
                        .then((value) => ShowSnackbar.showSuccess(
                            context, "Master Key Created"))).then((value) =>  context.go('/'));
                    
                   
                  }
                },
                style: ButtonStyle(
                  textStyle: MaterialStateProperty.all(
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                child: const Text("Create Master Key"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
