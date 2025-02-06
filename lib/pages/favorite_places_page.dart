import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/store/global_store.dart';
import 'package:flutter_dashboard_app/theme/app_colors.dart';
import 'package:flutter_dashboard_app/widgets/app_drawer.dart';
import 'package:flutter_dashboard_app/widgets/fav_city_item.dart';
import 'package:provider/provider.dart';

/// A screen that displays the user's favorite cities.
///
/// This page allows users to view their favorite cities, dynamically updating the list
/// based on the stored preferences. It adapts to both desktop and mobile layouts,
/// displaying a list of saved cities or an empty state if no favorites exist.
class FavoritePlacesPage extends StatelessWidget {
  const FavoritePlacesPage({super.key});

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nie masz jeszcze ulubionych miast',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitiesList(GlobalStore store, bool isDesktop) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: isDesktop ? 24.0 : 16.0,
              top: isDesktop ? 0 : 16.0,
            ),
            child: Text(
              'Ulubione Miasta',
              style: TextStyle(
                color: Colors.white,
                fontSize: isDesktop ? 28 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final city = store.favoriteCities[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: isDesktop ? 16.0 : 12.0,
                ),
                child: FavoriteCityItem(city: city),
              );
            },
            childCount: store.favoriteCities.length,
          ),
        ),
        // Add bottom padding for mobile scrolling
        SliverToBoxAdapter(
          child: SizedBox(height: isDesktop ? 0 : 24.0),
        ),
      ],
    );
  }

  Widget _buildDesktopContent(BuildContext context, GlobalStore store) {
    return Row(
      children: [
        const ResponsiveDrawer(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: store.favoriteCities.isEmpty
                ? _buildEmptyState()
                : _buildCitiesList(store, true),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileContent(BuildContext context, GlobalStore store) {
    return Column(
      children: [
        AppBar(
          backgroundColor: AppColors.darkGray,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          elevation: 0,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: store.favoriteCities.isEmpty
                ? _buildEmptyState()
                : _buildCitiesList(store, false),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: AppColors.darkestGray,
      drawer: isDesktop ? null : const ResponsiveDrawer(),
      body: Consumer<GlobalStore>(
        builder: (context, store, child) {
          return isDesktop
              ? _buildDesktopContent(context, store)
              : _buildMobileContent(context, store);
        },
      ),
    );
  }
}
