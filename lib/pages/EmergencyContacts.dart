import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'dart:math';

class EmergencyContacts extends StatefulWidget {
  const EmergencyContacts({super.key});

  @override
  State<EmergencyContacts> createState() => _EmergencyContactsState();
}

class _EmergencyContactsState extends State<EmergencyContacts>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showAddContact = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showAddContact) {
      return _AddEmergencyContact(
        onBack: () => setState(() => _showAddContact = false),
        onSave: (contact) {
          final appState = Provider.of<AppState>(context, listen: false);
          appState.addContact(contact);
          setState(() => _showAddContact = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Emergency contact added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: const Color(0xFF87CEEB),
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Contacts'),
                Tab(text: 'SOS History'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildContactsTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsTab() {
    final appState = Provider.of<AppState>(context);
    final contacts = appState.contacts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Info Alert
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF87CEEB).withOpacity(0.2),
              border: Border.all(
                color: const Color(0xFF87CEEB),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: const Color(0xFF5ba3c7),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'These contacts get notified when you press SOS. They can see your location.',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Contact Cards
          if (contacts.isEmpty)
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_add,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No emergency contacts yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first contact below',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...contacts.map((contact) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Contact Info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: contact.color,
                            child: Text(
                              contact.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  contact.name,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  contact.relationship,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  contact.phone,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Contact?'),
                                  content: Text(
                                    'Are you sure you want to delete ${contact.name}?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        appState.deleteContact(contact.id);
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Contact deleted'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Action Buttons
                      Column(
                        children: [
                          // Call Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Calling ${contact.name}...'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.phone, size: 24),
                              label: const Text(
                                'Call',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB4F8C8),
                                foregroundColor: Colors.grey[800],
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // WhatsApp Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Opening WhatsApp for ${contact.name}...'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.chat, size: 24),
                              label: const Text(
                                'WhatsApp',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black87,
                                side: const BorderSide(
                                  color: Color(0xFF87CEEB),
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )),

          // Add Contact Button
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _showAddContact = true),
                  icon: const Icon(Icons.person_add, size: 24),
                  label: const Text(
                    'Add Contact',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: const BorderSide(
                      color: Color(0xFF87CEEB),
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    final appState = Provider.of<AppState>(context);
    final sosEvents = appState.sosHistory;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: const Color(0xFFd4b84a),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'SOS Alert History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Events List or Empty State
                  if (sosEvents.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No SOS alerts',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your emergency history will appear here',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...sosEvents.map((event) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: event.trigger == 'automatic'
                                  ? const Color(0xFFF4E87C).withOpacity(0.4)
                                  : const Color(0xFFFAA09A).withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.warning,
                              color: event.trigger == 'automatic'
                                  ? const Color(0xFFd4b84a)
                                  : const Color(0xFFd97066),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Event Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date/Time and Status
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${event.date} at ${event.time}',
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: event.trigger == 'automatic'
                                                  ? const Color(0xFFF4E87C)
                                                  : const Color(0xFFFAA09A),
                                              borderRadius:
                                              BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              event.trigger == 'automatic'
                                                  ? 'AUTO'
                                                  : 'MANUAL',
                                              style: TextStyle(
                                                color: Colors.grey[800],
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: event.status == 'resolved'
                                              ? const Color(0xFFB4F8C8)
                                              : const Color(0xFFFAA09A),
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        event.status,
                                        style: TextStyle(
                                          color: event.status == 'resolved'
                                              ? const Color(0xFF6fbb8a)
                                              : const Color(0xFFd97066),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Reason
                                Text(
                                  event.reason,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Details
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.phone,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${event.contactsNotified} contacts notified',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            event.location,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Add Emergency Contact Widget
class _AddEmergencyContact extends StatefulWidget {
  final VoidCallback onBack;
  final Function(EmergencyContactModel) onSave;

  const _AddEmergencyContact({
    required this.onBack,
    required this.onSave,
  });

  @override
  State<_AddEmergencyContact> createState() => _AddEmergencyContactState();
}

class _AddEmergencyContactState extends State<_AddEmergencyContact> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final initials = _nameController.text
          .split(' ')
          .map((n) => n.isNotEmpty ? n[0] : '')
          .join('')
          .toUpperCase();

      final colors = [
        Colors.pink,
        Colors.blue,
        Colors.green,
        Colors.purple,
        Colors.orange,
        Colors.teal,
      ];

      final contact = EmergencyContactModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        relationship: _relationshipController.text,
        phone: _phoneController.text,
        initials: initials,
        color: colors[Random().nextInt(colors.length)],
      );

      widget.onSave(contact);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: const Text('Add Emergency Contact'),
        backgroundColor: const Color(0xFF87CEEB),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  hintText: 'Enter contact name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _relationshipController,
                decoration: const InputDecoration(
                  labelText: 'Relationship *',
                  hintText: 'e.g., Daughter, Son, Doctor',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a relationship';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  hintText: '(555) 123-4567',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _handleSubmit,
                  icon: const Icon(Icons.person_add, size: 24),
                  label: const Text(
                    'Save Contact',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB4F8C8),
                    foregroundColor: Colors.grey[800],
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}