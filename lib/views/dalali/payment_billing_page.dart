import 'package:flutter/material.dart';

class PaymentBillingPage extends StatelessWidget {
  const PaymentBillingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment & Billing'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Manage Your Payments'),
            const SizedBox(height: 10),
            _buildPaymentHistorySection(),
            const SizedBox(height: 20),
            _buildSubscriptionManagementSection(),
            const SizedBox(height: 20),
            _buildPaymentForPremiumListingsSection(),
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
        color: Colors.black87,
      ),
    );
  }

  Widget _buildPaymentHistorySection() {
    return _buildCard(
      title: 'Payment History',
      subtitle: 'View invoices and transaction history for services used on the platform.',
      onTap: () {
        // Navigate to payment history screen (to be implemented)
      },
    );
  }

  Widget _buildSubscriptionManagementSection() {
    return _buildCard(
      title: 'Subscription Management',
      subtitle: 'Upgrade or downgrade your subscription plans.',
      onTap: () {
        // Navigate to subscription management screen (to be implemented)
      },
    );
  }

  Widget _buildPaymentForPremiumListingsSection() {
    return _buildCard(
      title: 'Payment for Premium Listings',
      subtitle: 'Manage payment for featured or promoted listings.',
      onTap: () {
        // Navigate to premium listings payment screen (to be implemented)
      },
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
        onTap: onTap,
      ),
    );
  }
}
