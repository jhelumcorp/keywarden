import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:keywarden/screens/add_screen.dart';
import 'package:keywarden/utils/extensions.dart';
import 'package:keywarden/utils/passwords.dart';
import 'package:keywarden/utils/snackbar.dart';

class TileModal extends StatelessWidget {
  final Map item;
  const TileModal({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Scaffold(
        appBar: AppBar(
          leading: Container(
            height: 50,
            width: 50,
            padding: const EdgeInsets.all(16),
            child: item['icon'] != null &&
                    item['icon'].toString().trim().isNotEmpty
                ? CachedNetworkImage(
                    imageUrl:
                        'https://www.google.com/s2/favicons?domain=${item['icon']}&sz=64',
                    fit: BoxFit.cover,
                  )
                : Text(item['title'][0].toString().toUpperCase(),
                    style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
          ),
          title: Text(item['title']),
        ),
        body: SafeArea(
          child: Center(
            child: ListView(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              children: [
                ItemCard(
                  title: "Username / Email",
                  message: item['username'],
                ),
                const SizedBox(height: 8),
                ItemCard(
                  title: "Password",
                  message: item['password'],
                  isPassword: true,
                ),
                const SizedBox(height: 8),
                ItemCard(
                  title: "Website",
                  message: item['website'],
                ),
                const SizedBox(height: 8),
                ItemCard(
                  title: "Notes",
                  message: item['notes'],
                ),
                if (PasswordManager.checkStrength(item['password']) < 50)
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      tileColor: Colors.orangeAccent.withAlpha(50),
                      leading: const Icon(
                        Icons.warning,
                        color: Colors.orange,
                      ),
                      title: const Text(
                        "Vulnerability Alert",
                        style: TextStyle(color: Colors.orange, fontSize: 18),
                      ),
                      subtitle: Text("The Password is weak.",
                          style:
                              TextStyle(color: Colors.orange.withAlpha(150))),
                    ),
                  )
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.green.withAlpha(70),
                  elevation: 0,
                  enableFeedback: false,
                  focusElevation: 0,
                  hoverElevation: 0,
                  disabledElevation: 0,
                  highlightElevation: 0,
                  onPressed: () {
                    Navigator.pop(context);
                    // context.go('/addScreen', extra: {
                    //   'edit': true,
                    //   'id': item['key'],
                    // });
                    showCupertinoModalPopup(
                      context: context,
                      builder: (context) {
                        return AddScreen(
                          edit: true,
                          id: item['key'],
                        );
                      },
                    );
                  },
                  child: const Text(
                    "Edit",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.red.withAlpha(50),
                  elevation: 0,
                  enableFeedback: false,
                  focusElevation: 0,
                  hoverElevation: 0,
                  disabledElevation: 0,
                  highlightElevation: 0,
                  onPressed: () async {
                    bool confirm = await showConfirm(
                        context: context,
                        title: const Text("Delete"),
                        content:
                            const Text("Are you sure you want to delete it?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("No"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              "Yes",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ]);
                    if (confirm) {
                      Hive.box('passwords').delete(item['key']).then(
                            (value) => Navigator.pop(context),
                          );
                    }
                  },
                  child: const Icon(
                    CupertinoIcons.delete,
                    color: Colors.red,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemCard extends StatefulWidget {
  const ItemCard({
    super.key,
    required this.title,
    required this.message,
    this.isPassword = false,
  });

  final String title;
  final String message;
  final bool isPassword;

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  bool obscure = false;

  @override
  void initState() {
    super.initState();
    obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title,
                    maxLines: 1, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Text(obscure ? "******" : widget.message)),
                    if (widget.isPassword)
                      InkWell(
                        onTap: () => setState(() {
                          obscure = !obscure;
                        }),
                        child: Icon(
                          obscure
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.message))
                  .then((value) {
                ShowSnackbar.showSuccess(context, 'Copied to clipboard.');
              });
            },
            icon: const Icon(Icons.copy),
          )
        ],
      ),
    );
  }
}

showConfirm(
    {required BuildContext context,
    Widget? title,
    Widget? content,
    List<Widget>? actions}) async {
  bool confirm = await showDialog(
    context: context,
    builder: (context) =>
        AlertDialog(title: title, content: content, actions: actions),
  );
  if (confirm == true) {
    return true;
  }
  return false;
}
