import 'package:eldcare/elduser/models/shoplisting.dart';
import 'package:eldcare/elduser/presentation/shop/shopwrapper.dart';
import 'package:eldcare/elduser/repository/shoplisting_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/elduser/blocs/VerifiedShopListing/verified_shop_listing_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          VerifiedShopListingBloc(repository: VerifiedShopListingRepository())
            ..add(LoadVerifiedShops()),
      child: const ShopScreenView(),
    );
  }
}

class ShopScreenView extends StatefulWidget {
  const ShopScreenView({super.key});

  @override
  ShopScreenViewState createState() => ShopScreenViewState();
}

class ShopScreenViewState extends State<ShopScreenView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingNearbyShops = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pharmacy Shops', style: AppFonts.headline3Light),
        backgroundColor: kPrimaryColor,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildNearbyShopsButton(),
          Expanded(
            child: _buildShopList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search shops...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onChanged: (query) {
          context
              .read<VerifiedShopListingBloc>()
              .add(SearchVerifiedShops(query));
        },
      ),
    );
  }

  Widget _buildNearbyShopsButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: _isLoadingNearbyShops ? null : _findNearbyShops,
        icon: _isLoadingNearbyShops
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(kWhiteColor),
                ),
              )
            : const Icon(
                Icons.location_on,
                color: kWhiteColor,
                size: 24,
              ),
        label: Text(
          _isLoadingNearbyShops ? 'Loading...' : 'Find Nearby Shops',
          style: AppFonts.button.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: kWhiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 3,
        ),
      ),
    );
  }

  Future<void> _findNearbyShops() async {
    setState(() {
      _isLoadingNearbyShops = true;
    });
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        setState(() {
          _isLoadingNearbyShops = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.'),
        ),
      );
      setState(() {
        _isLoadingNearbyShops = false;
      });
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      final geoPoint = GeoPoint(position.latitude, position.longitude);
      context
          .read<VerifiedShopListingBloc>()
          .add(LoadNearbyVerifiedShops(geoPoint, 10)); // 10 km radius
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    } finally {
      setState(() {
        _isLoadingNearbyShops = false;
      });
    }
  }

  Widget _buildShopList() {
    return BlocBuilder<VerifiedShopListingBloc, VerifiedShopListingState>(
      builder: (context, state) {
        if (state is VerifiedShopListingLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is VerifiedShopListingLoaded) {
          return ListView.builder(
            itemCount: state.shops.length,
            itemBuilder: (context, index) {
              return _buildShopCard(state.shops[index]);
            },
          );
        } else if (state is VerifiedShopListingError) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          return const Center(child: Text('No shops found'));
        }
      },
    );
  }

  Widget _buildShopCard(VerifiedShopListing shop) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_pharmacy,
                      color: kPrimaryColor, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shop.name, style: AppFonts.headline6),
                      const SizedBox(height: 4),
                      Text(shop.address,
                          style: AppFonts.bodyText2
                              .copyWith(color: kSecondaryTextColor)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Phone: ${shop.phoneNumber}', style: AppFonts.bodyText2),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ShopWrapper(
                          shopId: shop.id,
                          shopName: shop.name,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    'View',
                    style: AppFonts.button.copyWith(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
