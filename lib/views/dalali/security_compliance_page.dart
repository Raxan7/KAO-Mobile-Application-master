import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class SecurityCompliancePage extends StatelessWidget {
  const SecurityCompliancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security & Compliance'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDataSecuritySection(context),
            // const SizedBox(height: 20),
            // _buildLegalAgreementSection(),
            // const SizedBox(height: 20),
            // _buildPrivacyComplianceSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSecuritySection(BuildContext context) {
    return _buildCard(
      title: 'Data Security',
      subtitle: 'Implement encryption and secure storage for all client information and sensitive data.',
      icon: Icons.lock,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MyPdfViewer(
              pdfPath: 'assets/pdfs/KAO-Compliance-Checklist-for-Real-Estate-Brokers.pdf', 
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegalAgreementSection() {
    return _buildCard(
      title: 'Legal Agreement',
      subtitle: 'Upload and manage contracts with e-signatures capabilities.',
      icon: Icons.article,
      onTap: () {
        // Navigate to legal agreements management screen (to be implemented)
      },
    );
  }

  Widget _buildPrivacyComplianceSection() {
    return _buildCard(
      title: 'GDPR / Privacy Compliance',
      subtitle: 'Manage user data and opt-out options for compliance with data regulations.',
      icon: Icons.privacy_tip,
      onTap: () {
        // Navigate to privacy compliance management screen (to be implemented)
      },
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent.shade100,
          child: Icon(icon, color: Colors.white),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
        onTap: onTap,
      ),
    );
  }
}

class MyPdfViewer extends StatefulWidget {
  final String pdfPath;
  const MyPdfViewer({super.key, required this.pdfPath});  @override
  _MyPdfViewerState createState() => _MyPdfViewerState();
}class _MyPdfViewerState extends State<MyPdfViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfPdfViewer.asset(widget.pdfPath)
    );
  }
}
