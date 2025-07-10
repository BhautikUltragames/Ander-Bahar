import 'dart:html' as html;
import 'package:flutter/material.dart';

class ConnectivityListener extends StatefulWidget {
  final Widget child;
  const ConnectivityListener({required this.child, Key? key}) : super(key: key);

  @override
  _ConnectivityListenerState createState() => _ConnectivityListenerState();
}

class _ConnectivityListenerState extends State<ConnectivityListener> {
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    // Listen for offline events
    html.window.onOffline.listen((_) {
      if (!_dialogShowing) {
        _dialogShowing = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const AlertDialog(
            title: Text('Connection Error'),
            content: Text('No internet connection.'),
          ),
        );
      }
    });
    // Listen for online events
    html.window.onOnline.listen((_) {
      if (_dialogShowing) {
        Navigator.of(context, rootNavigator: true).pop();
        _dialogShowing = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
} 