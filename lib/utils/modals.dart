import 'package:flutter/material.dart';

class Modals {
  static show(
    BuildContext context, {
    Widget? title,
    Widget? body,
    List<Widget>? actions,
  }) =>
      showModalBottomSheet(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        context: context,
        builder: (context) => SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: Column(
              children: [
                if (title != null) title,
                if (body != null) body,
                if (actions != null) ...actions
              ],
            ),
          ),
        ),
      );
  static showSimple(BuildContext context,
          {Widget? title,
          Widget? icon,
          List<Widget>? topActions,
          Widget? body}) =>
      show(context,
          title: title != null
              ? AppBar(
                  leading: icon,
                  title: title,
                  actions: topActions != null && topActions.isNotEmpty
                      ? topActions
                      : null,
                )
              : null,
          body: body);
}
