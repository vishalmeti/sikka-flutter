import 'package:flutter/material.dart';

import '../../../shared/widgets/sk_loading_view.dart';

/// Full-screen scaffold around [SkLoadingView]. Use as a route or push as a
/// modal page while async work runs.
///
/// Push via the named route:
/// ```dart
/// Navigator.of(context).pushNamed(
///   '/loading',
///   arguments: {'message': 'Signing you in'},
/// );
/// ```
/// or directly:
/// ```dart
/// Navigator.of(context).push(MaterialPageRoute(
///   builder: (_) => const LoadingScreen(message: 'Connecting'),
/// ));
/// ```
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050508),
      body: SkLoadingView(message: message),
    );
  }
}
