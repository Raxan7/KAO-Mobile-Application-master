import 'package:flutter/material.dart';

class AnalyticsInsightPage extends StatelessWidget {
  const AnalyticsInsightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Insight'),
        backgroundColor: const Color(0xFF3571C1), // Custom app bar color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Performance Insights'),
            const SizedBox(height: 10),
            _buildPropertyPerformanceSection(),
            const SizedBox(height: 20),
            _buildClientAnalyticsSection(),
            const SizedBox(height: 20),
            _buildSectionTitle('Market Insights'),
            const SizedBox(height: 10),
            _buildMarketInsightSection(),
            const SizedBox(height: 20),
            _buildBestPerformingListingsSection(),
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

  Widget _buildPropertyPerformanceSection() {
    return _buildAnalyticsCard(
      title: 'Property Performance Reports',
      subtitle: 'Track views, inquiries, conversion rates, and time on market.',
      onTap: () {
        // Navigate to property performance reports screen (to be implemented)
      },
    );
  }

  Widget _buildClientAnalyticsSection() {
    return _buildAnalyticsCard(
      title: 'Client Analytics',
      subtitle: 'Gain insights into client behavior and inquiry origins.',
      onTap: () {
        // Navigate to client analytics screen (to be implemented)
      },
    );
  }

  Widget _buildMarketInsightSection() {
    return _buildAnalyticsCard(
      title: 'Market Insight',
      subtitle: 'Stay updated on real estate trends, prices, and demographics.',
      onTap: () {
        // Navigate to market insight screen (to be implemented)
      },
    );
  }

  Widget _buildBestPerformingListingsSection() {
    return _buildAnalyticsCard(
      title: 'Best Performing Listings',
      subtitle: 'Identify top properties and optimize underperforming ones.',
      onTap: () {
        // Navigate to best performing listings screen (to be implemented)
      },
    );
  }

  Widget _buildAnalyticsCard({
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
