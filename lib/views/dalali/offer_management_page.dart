import 'package:flutter/material.dart';

class OfferManagementPage extends StatelessWidget {
  const OfferManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offer Management'),
        backgroundColor: const Color(0xFF3571C1), // Custom app bar color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Manage Offers'),
            const SizedBox(height: 10),
            _buildReceiveOffersSection(),
            const SizedBox(height: 20),
            _buildCompareOffersSection(),
            const SizedBox(height: 20),
            _buildCounterofferSection(),
            const SizedBox(height: 20),
            _buildAcceptRejectOffersSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF3571C1), // Custom section title color
      ),
    );
  }

  Widget _buildReceiveOffersSection() {
    return _buildOfferCard(
      title: 'Receive Offers',
      subtitle: 'View incoming offers for properties (buy/rent) and respond directly.',
      onTap: () {
        // Navigate to receive offers screen (to be implemented)
      },
    );
  }

  Widget _buildCompareOffersSection() {
    return _buildOfferCard(
      title: 'Compare Offers',
      subtitle: 'Easily compare different offers based on price and qualifications.',
      onTap: () {
        // Navigate to compare offers screen (to be implemented)
      },
    );
  }

  Widget _buildCounterofferSection() {
    return _buildOfferCard(
      title: 'Counteroffer',
      subtitle: 'Make counteroffers with a record of negotiating steps.',
      onTap: () {
        // Navigate to counteroffer screen (to be implemented)
      },
    );
  }

  Widget _buildAcceptRejectOffersSection() {
    return _buildOfferCard(
      title: 'Accept/Reject Offers',
      subtitle: 'Track accepted offers and follow up with necessary documents.',
      onTap: () {
        // Navigate to accept/reject offers screen (to be implemented)
      },
    );
  }

  Widget _buildOfferCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4.0,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}
