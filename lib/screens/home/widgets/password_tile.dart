import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keywarden/screens/home/widgets/tile_modal.dart';
import 'package:keywarden/utils/extensions.dart';
import 'package:keywarden/utils/snackbar.dart';

class PasswordTile extends StatefulWidget {
  const PasswordTile({required this.item, super.key});
  final Map item;

  @override
  State<PasswordTile> createState() => _PasswordTileState();
}

class _PasswordTileState extends State<PasswordTile> {
  bool _hiddenPass = true;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => showModalBottomSheet(
          context: context,
          builder: (context) => TileModal(
                item: widget.item,
              )),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      tileColor: context.isDarkMode ? Colors.black : Colors.white,
      leading: Container(
        height: 50,
        width: 50,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: widget.item['icon'] != null &&
                widget.item['icon'].toString().trim().isNotEmpty
            ? CachedNetworkImage(
                imageUrl:
                    'https://www.google.com/s2/favicons?domain=${widget.item['icon']}&sz=64',
                fit: BoxFit.cover,
              )
            : Text(widget.item['title'][0].toString().toUpperCase(),
                style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
      ),
      title: Text(widget.item['title']),
      subtitle: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.item['username'].trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  _hiddenPass ? '********' : widget.item['password'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: () => setState(() {
                  _hiddenPass = !_hiddenPass;
                }),
                child: Icon(
                  _hiddenPass
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: 16,
                ),
              ),
            ],
          )
        ],
      ),
      trailing: IconButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: widget.item['password']))
                .then((value) {
              ShowSnackbar.showSuccess(
                  context, 'Password copied to clipboard.');
            });
          },
          icon: const Icon(Icons.copy_rounded)),
    );
  }
}
