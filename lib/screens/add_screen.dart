import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:keywarden/utils/extensions.dart';
import 'package:keywarden/utils/passwords.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({this.id = '', this.edit = false, super.key});

  final bool edit;
  final dynamic id;

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  TextEditingController websiteController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String icon = '';
  bool obscureText = true;

  @override
  void initState() {
    super.initState();
    if (widget.edit) {
      Map data = Hive.box('passwords').get(widget.id);
      websiteController.text = data['website']!;
      titleController.text = data['title']!;
      usernameController.text = data['username']!;
      passwordController.text = data['password']!;
      notesController.text = data['notes']!;
      icon = data['icon']!;
    }
  }

  @override
  Widget build(BuildContext context) {
    double strength = double.parse(
        PasswordManager.checkStrength(passwordController.text.trim())
            .toString());
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Scaffold(
        appBar: AppBar(
          leading: Navigator.canPop(context)
              ? IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(CupertinoIcons.chevron_down))
              : const SizedBox(),
          title: const Text("Add Password"),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            children: [
              const Text(
                'You can also use your fingerprint to login if you have enabled biometrics.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor:
                    context.isDarkMode ? Colors.black : Colors.white,
                child: icon == ''
                    ? Text(
                        titleController.text.isNotEmpty
                            ? titleController.text[0].toUpperCase()
                            : '',
                        style: const TextStyle(
                            fontSize: 50,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      )
                    : Image.network(
                        'https://www.google.com/s2/favicons?domain=${websiteController.text}&sz=64'),
              ),
              const SizedBox(height: 20),
              TextInput(
                controller: titleController,
                label: "Title",
                icon: Icon(
                  Icons.title,
                  color: context.isDarkMode ? Colors.white : Colors.black,
                ),
                onChanged: (value) {
                  setState(() {});
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextInput(
                controller: usernameController,
                label: "Username/Email",
                keyboardType: TextInputType.emailAddress,
                icon: Icon(
                  CupertinoIcons.person,
                  color: context.isDarkMode ? Colors.white : Colors.black,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextInput(
                controller: passwordController,
                keyboardType: TextInputType.text,
                label: "Password",
                onChanged: (value) => setState(() {}),
                icon: Icon(
                  CupertinoIcons.lock,
                  color: context.isDarkMode ? Colors.white : Colors.black,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                color: strength < 50
                    ? Colors.red
                    : strength < 75
                        ? Colors.orange
                        : Colors.green,
                borderRadius: BorderRadius.circular(5),
                value: strength / 100,
              ),
              const SizedBox(height: 16),
              TextInput(
                controller: websiteController,
                keyboardType: TextInputType.url,
                icon: Icon(
                  CupertinoIcons.globe,
                  color: context.isDarkMode ? Colors.white : Colors.black,
                ),
                label: "Website",
                onChanged: (e) async {
                  String url = websiteController.text.trim();
                  if (AnyLinkPreview.isValidLink(url)) {
                    setState(() {
                      icon = url;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              TextInput(
                controller: notesController,
                label: "Notes",
                minLines: 3,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    Map<String, String> data = {
                      "title": titleController.text.trim(),
                      "username": usernameController.text.trim(),
                      "password": passwordController.text.trim(),
                      "website": websiteController.text.trim(),
                      "notes": notesController.text.trim(),
                      "icon": icon
                    };
                    if (widget.edit) {
                      Hive.box('passwords').put(widget.id, data).then((value) {
                        Navigator.of(context).pop();
                      });
                    } else {
                      Hive.box('passwords').add(data).then((value) {
                        Navigator.of(context).pop();
                      });
                    }
                  }
                },
                child: const Text("Save"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TextInput extends StatelessWidget {
  const TextInput(
      {super.key,
      required this.controller,
      this.validator,
      this.label,
      this.icon,
      this.onChanged,
      this.keyboardType,
      this.maxLines,
      this.minLines});

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String? label;
  final void Function(String)? onChanged;
  final Widget? icon;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10)),
        fillColor: context.isDarkMode ? Colors.black : Colors.white,
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        prefixIcon: icon,
      ),
      onChanged: onChanged,
      validator: validator,
      maxLines: maxLines,
      minLines: minLines,
    );
  }
}
