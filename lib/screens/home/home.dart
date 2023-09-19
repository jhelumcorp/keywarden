import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:keywarden/screens/home/widgets/password_tile.dart';
import 'package:keywarden/utils/extensions.dart';
import 'package:keywarden/utils/passwords.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  TextEditingController searchController = TextEditingController();
  List passwords = [];
  List searchList = [];
  List securePasswords = [];

  @override
  void initState() {
    super.initState();
    init();
    Hive.box('passwords').listenable().addListener(() {
      init();
      setState(() {});
    });
  }

  init() {
    passwords = [];
    List keys = Hive.box('passwords').keys.toList();
    for (var element in keys) {
      passwords.add({
        'key': element,
        ...Hive.box('passwords').get(element),
      });
    }

    passwords.sort((a, b) {
      return a['title'].toString().compareTo(b['title'].toString());
    });
    searchList = passwords;
    securePasswords = passwords
        .where((element) =>
            PasswordManager.checkStrength(element['password']) > 50)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(230, 101, 216, 152),
        title: const Text("Key Warden"),
        actions: [
          IconButton(
            onPressed: () {
              context.go('/settings');
            },
            icon: const Icon(CupertinoIcons.settings),
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 70),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color.fromARGB(230, 101, 216, 152),
                borderRadius: BorderRadiusDirectional.only(
                    bottomEnd: Radius.circular(25),
                    bottomStart: Radius.circular(25)),
              ),
              child: TextField(
                decoration: InputDecoration(
                    label: const Text("Search"),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    suffixIcon: const Icon(CupertinoIcons.search),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    fillColor: Colors.black.withOpacity(0.1),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(25)),
                    filled: true),
                onChanged: (value) {
                  setState(() {
                    searchList = passwords
                        .where((element) => element['title']
                            .toString()
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  InfoClip(
                    icon: CupertinoIcons.lock,
                    message: passwords.length.toString(),
                    title: "Total",
                    color: Colors.green,
                  ),
                  InfoClip(
                    icon: CupertinoIcons.lock_open,
                    message:
                        (passwords.length - securePasswords.length).toString(),
                    title: "Weak",
                    color: Colors.red,
                  ),
                ],
              ),
            ),
            if (searchList.isNotEmpty)
              const Padding(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
                child: Text(
                  'Your passwords',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ListView.separated(
              primary: false,
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              itemCount: searchList.length,
              itemBuilder: (context, index) {
                Map item = searchList[index];

                return PasswordTile(item: item);
              },
              separatorBuilder: (context, index) => const SizedBox(height: 16),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/addScreen');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class InfoClip extends StatelessWidget {
  const InfoClip(
      {super.key,
      required this.icon,
      required this.message,
      required this.title,
      required this.color});

  final IconData icon;
  final String message;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width / 2) - 24,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: context.isDarkMode ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(50),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: color,
              weight: 5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 131, 130, 130),
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
