import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/dalali/dalali_navigation_drawer.dart';
import 'chat_page.dart';

class LeadManagementPage extends StatefulWidget {
  const LeadManagementPage({super.key});

  @override
  _LeadManagementPageState createState() => _LeadManagementPageState();
}

class _LeadManagementPageState extends State<LeadManagementPage> {
  bool isDarkMode = false; // Track the dark mode status

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lead Management & Client Communication'),
        backgroundColor: iconMainColorBlue,
      ),
      drawer: DalaliNavigationDrawer(
        onThemeChanged: (newIsDarkMode) {
          setState(() {
            isDarkMode = newIsDarkMode;
          });
        },
        isDarkMode: Theme.of(context).brightness == Brightness.dark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChatSection(context),
            const SizedBox(height: 20),
            _buildAutomatedRepliesSection(context),
            const SizedBox(height: 20),
            _buildDocumentManagementSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildChatSection(BuildContext context) {
    return _buildSectionCard(
      context: context,
      title: 'In-App Messaging/Chat',
      subtitle: 'Communicate with your clients in real-time.',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatPage(),
          ),
        );
      },
    );
  }

  Widget _buildAutomatedRepliesSection(BuildContext context) {
    return _buildSectionCard(
      context: context,
      title: 'Automated Replies',
      subtitle: 'Set up automated responses for common queries.',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AutomatedRepliesPage(),
          ),
        );
      },
    );
  }

  Widget _buildDocumentManagementSection(BuildContext context) {
    return _buildSectionCard(
      context: context,
      title: 'Document Management',
      subtitle: 'Store and share property documents securely.',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DocumentManagementPage(),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        onTap: onTap,
      ),
    );
  }
}

// Placeholder for Automated Replies Page
class AutomatedRepliesPage extends StatelessWidget {
  const AutomatedRepliesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Automated Replies')),
      body: const Center(child: Text('Automated replies management will be implemented here.')),
    );
  }
}

// Placeholder for Document Management Page
class DocumentManagementPage extends StatelessWidget {
  const DocumentManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Document Management')),
      body: const Center(child: Text('Document management interface will be implemented here.')),
    );
  }
}
