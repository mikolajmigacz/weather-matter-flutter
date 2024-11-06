import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/store/global_store.dart';
import 'package:flutter_dashboard_app/theme/app_colors.dart';
import 'package:flutter_dashboard_app/widgets/app_drawer.dart';
import 'package:flutter_dashboard_app/widgets/fav_city_item.dart';
import 'package:provider/provider.dart';

class FavoritePlacesPage extends StatelessWidget {
  const FavoritePlacesPage({super.key});

  Widget _buildContent(BuildContext context, GlobalStore store) {
    if (store.favoriteCities.isEmpty) {
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

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(bottom: 24.0),
            child: Text(
              'Ulubione Miasta',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final city = store.favoriteCities[index];
              return FavoriteCityItem(city: city);
            },
            childCount: store.favoriteCities.length,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkestGray,
      body: Row(
        children: [
          const AppDrawer(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Consumer<GlobalStore>(
                builder: (context, store, child) =>
                    _buildContent(context, store),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
