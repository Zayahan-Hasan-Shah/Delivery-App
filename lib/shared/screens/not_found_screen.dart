import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:delivery_app/shared/widgets/empty_state_view.dart';
import 'package:delivery_app/shared/routing/route_names.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: EmptyStateView(
        icon: Icons.search_off,
        title: '404 - Page Not Found',
        message: 'The page or route you are looking for does not exist.',
        actionText: 'Go to Home',
        onActionPressed: () => context.goNamed(RouteNames.splash),
      ),
    );
  }
}
