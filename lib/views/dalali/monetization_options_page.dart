import 'package:flutter/material.dart';

class MonetizationOptionsPage extends StatelessWidget {
  const MonetizationOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monetization Options'),
        backgroundColor: const Color(0xFF3571C1), // Custom app bar color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Subscription Plans'),
            const SizedBox(height: 10),
            _buildSubscriptionPlanCard(),
            const SizedBox(height: 20),
            _buildSectionTitle('Pay for Featured Listings'),
            const SizedBox(height: 10),
            _buildFeaturedListingsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF3571C1), // Custom section title color
        ),
      ),
    );
  }

  Widget _buildSubscriptionPlanCard() {
    return _buildMonetizationCard(
      title: 'Subscription Plans',
      subtitle:
          'Offer premium subscription tiers that unlock advanced features like enhanced analytics, lead management tools, and more property listings.',
      onTap: () {
        // Navigate to subscription plans screen (to be implemented)
      },
    );
  }

  Widget _buildFeaturedListingsCard() {
    return _buildMonetizationCard(
      title: 'Pay for Featured Listings',
      subtitle:
          'Charge the brokers and sellers a fee to have their properties featured in top-listings or as part of special promotions.',
      onTap: () {
        // Navigate to featured listings screen (to be implemented)
      },
    );
  }

  Widget _buildMonetizationCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
