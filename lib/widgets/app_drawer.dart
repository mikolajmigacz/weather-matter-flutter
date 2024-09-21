import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/constants/routes.dart';
import 'package:flutter_dashboard_app/store/global_store.dart';
import 'package:flutter_dashboard_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final globalStore = Provider.of<GlobalStore>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      child: Container(
        color: AppColors.darkestGray,
        child: Column(
          children: <Widget>[
            Container(
              width: screenWidth,
              height: screenHeight * 0.4,
              padding: const EdgeInsets.all(4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'weather.png',
                    width: 200,
                    height: 200,
                  ),
                  Text(
                    'Cześć ${globalStore.name} 👋',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  _NavItem(
                      title: 'Home',
                      route: AppRoutes.home,
                      currentRoute: currentRoute),
                  _NavItem(
                      title: 'Ulubione miasta',
                      route: AppRoutes.favoriteCities,
                      currentRoute: currentRoute),
                  _NavItem(
                      title: 'Miasta',
                      route: AppRoutes.cities,
                      currentRoute: currentRoute),
                  _NavItem(
                      title: 'Mapa',
                      route: AppRoutes.map,
                      currentRoute: currentRoute),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final String title;
  final String route;
  final String? currentRoute;

  const _NavItem(
      {required this.title, required this.route, required this.currentRoute});

  @override
  __NavItemState createState() => __NavItemState();
}

class __NavItemState extends State<_NavItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.currentRoute == widget.route;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: InkWell(
        onTap: () {
          Navigator.pushReplacementNamed(context, widget.route);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white
                    .withAlpha((0.2 * 255).toInt()) // Zamiana withOpacity(0.2)
                : (isHovered
                    ? Colors.white.withAlpha((0.1 * 255).toInt())
                    : null), // Zamiana withOpacity(0.1)
          ),
          child: Text(
            widget.title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
