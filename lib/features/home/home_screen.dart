import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/section_header.dart';
import '../../shared/models/vehicle.dart';
import 'providers/home_providers.dart';
import 'widgets/category_chip.dart';
import 'widgets/destination_search_bar.dart';
import 'widgets/home_bottom_nav.dart';
import 'widgets/home_header.dart';
import 'widgets/how_it_works_row.dart';
import 'widgets/nearby_map_preview.dart';
import 'widgets/safety_banner.dart';
import 'widgets/vehicle_card.dart';

/// GoLazy home page: search, nearby map preview, category filters, nearby
/// vehicles and the "How GoLazy Works" explainer.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(vehicleCategoriesProvider);
    final vehiclesAsync = ref.watch(nearbyVehiclesProvider);
    final stepsAsync = ref.watch(howItWorksStepsProvider);
    final selectedCategoryIndex = ref.watch(selectedCategoryIndexProvider);
    final selectedNavTab = ref.watch(selectedNavTabProvider);

    final vehicles = vehiclesAsync.value ?? const <Vehicle>[];

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverToBoxAdapter(child: const HomeHeader()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(child: const DestinationSearchBar()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: NearbyMapPreview(
                  featuredVehicle: vehicles.isNotEmpty ? vehicles.first : null,
                  onViewAllVehicles: () {},
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: categoriesAsync.when(
                  data: (categories) => SizedBox(
                    height: 96,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) => CategoryChip(
                        category: categories[index],
                        selected: index == selectedCategoryIndex,
                        onTap: () => ref
                            .read(selectedCategoryIndexProvider.notifier)
                            .state = index,
                      ),
                    ),
                  ),
                  loading: () => const SizedBox(
                    height: 96,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              sliver: SliverToBoxAdapter(
                child: SectionHeader(title: 'Vehicles Near You', onViewAll: () {}),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: vehicles.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) =>
                        VehicleCard(vehicle: vehicles[index]),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'How GoLazy Works',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: stepsAsync.when(
                  data: (steps) => HowItWorksRow(steps: steps),
                  loading: () => const SizedBox(
                    height: 90,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              sliver: SliverToBoxAdapter(
                child: SafetyBanner(onLearnMore: () {}),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNav(
        selectedIndex: selectedNavTab,
        onTabSelected: (index) =>
            ref.read(selectedNavTabProvider.notifier).state = index,
      ),
    );
  }
}
