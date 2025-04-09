import 'package:flutter/material.dart';
import '../models/retailer.dart';
import '../services/retailer_manager.dart';
import '../constants/color_constants.dart';

class RetailerSettingsScreen extends StatefulWidget {
  const RetailerSettingsScreen({Key? key}) : super(key: key);

  @override
  _RetailerSettingsScreenState createState() => _RetailerSettingsScreenState();
}

class _RetailerSettingsScreenState extends State<RetailerSettingsScreen> {
  final RetailerManager _retailerManager = RetailerManager();
  bool _isLoading = true;
  List<Retailer> _retailers = [];
  Map<String, bool> _isConfigured = {};
  Map<String, bool> _isExpanded = {};

  @override
  void initState() {
    super.initState();
    _loadRetailers();
  }

  Future<void> _loadRetailers() async {
    setState(() {
      _isLoading = true;
    });

    await _retailerManager.initialize();
    
    final retailers = _retailerManager.getAllRetailers();
    final configuredMap = <String, bool>{};
    final expandedMap = <String, bool>{};
    
    for (final retailer in retailers) {
      configuredMap[retailer.id] = _retailerManager.isRetailerConfigured(retailer);
      expandedMap[retailer.id] = false;
    }

    setState(() {
      _retailers = retailers;
      _isConfigured = configuredMap;
      _isExpanded = expandedMap;
      _isLoading = false;
    });
  }

  Future<void> _toggleRetailerActive(String retailerId, bool isActive) async {
    await _retailerManager.toggleRetailerActive(retailerId, isActive);
    
    // Refresh the list
    setState(() {
      // No state update needed here since we're just toggling the active state
      // and that's managed by the retailer manager
    });
  }

  Future<void> _setApiKey(String retailerId, String apiKey) async {
    await _retailerManager.setApiKey(retailerId, apiKey);
    
    setState(() {
      _isConfigured[retailerId] = _retailerManager.isRetailerConfigured(
        _retailers.firstWhere((r) => r.id == retailerId),
      );
    });
  }

  void _toggleExpanded(String retailerId) {
    setState(() {
      _isExpanded[retailerId] = !(_isExpanded[retailerId] ?? false);
    });
  }

  Future<void> _showApiKeyDialog(Retailer retailer) async {
    final controller = TextEditingController();
    
    // Pre-fill with existing API key if any
    final existingKey = await _retailerManager.getApiKey(retailer.id);
    if (existingKey != null) {
      controller.text = existingKey;
    }
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('API Key for ${retailer.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your API key for ${retailer.name}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'API Key',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _setApiKey(retailer.id, controller.text);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retailer Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _retailers.isEmpty
              ? const Center(
                  child: Text('No retailers configured yet'),
                )
              : RefreshIndicator(
                  onRefresh: _loadRetailers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _retailers.length,
                    itemBuilder: (context, index) {
                      final retailer = _retailers[index];
                      final isActive = _retailerManager
                          .getActiveRetailers()
                          .any((r) => r.id == retailer.id);
                      final isConfigured = _isConfigured[retailer.id] ?? false;
                      final isExpanded = _isExpanded[retailer.id] ?? false;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          children: [
                            // Retailer header
                            ListTile(
                              title: Text(
                                retailer.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                retailer.retailerCategory.displayName,
                              ),
                              leading: CircleAvatar(
                                // Use a placeholder or retailer logo
                                child: Text(
                                  retailer.name.substring(0, 1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: ColorConstants.primaryColor,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Status indicator
                                  Icon(
                                    isConfigured
                                        ? Icons.check_circle
                                        : Icons.warning,
                                    color: isConfigured
                                        ? ColorConstants.success
                                        : ColorConstants.warning,
                                  ),
                                  const SizedBox(width: 8),
                                  // Active toggle
                                  Switch(
                                    value: isActive,
                                    onChanged: (value) {
                                      _toggleRetailerActive(retailer.id, value);
                                    },
                                    activeColor: ColorConstants.primaryColor,
                                  ),
                                  // Expand/collapse button
                                  IconButton(
                                    icon: Icon(
                                      isExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                    ),
                                    onPressed: () =>
                                        _toggleExpanded(retailer.id),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Expanded details
                            if (isExpanded)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Status message
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isConfigured
                                            ? ColorConstants.success.withOpacity(0.1)
                                            : ColorConstants.warning.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isConfigured
                                                ? Icons.check_circle
                                                : Icons.warning,
                                            color: isConfigured
                                                ? ColorConstants.success
                                                : ColorConstants.warning,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              isConfigured
                                                  ? 'Retailer is properly configured'
                                                  : 'API key required for this retailer',
                                              style: TextStyle(
                                                color: isConfigured
                                                    ? ColorConstants.success
                                                    : ColorConstants.warning,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Retailer details
                                    Text(
                                      'API Configuration',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              _showApiKeyDialog(retailer);
                                            },
                                            icon: const Icon(Icons.key),
                                            label: Text(isConfigured
                                                ? 'Update API Key'
                                                : 'Set API Key'),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Additional info
                                    Text(
                                      'Retailer Information',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Category: ${retailer.retailerCategory.displayName}'),
                                    Text('Website: ${retailer.baseUrl}'),
                                    if (retailer.apiConfig['requiresApiKey'] == true)
                                      const Text(
                                        'Requires API Key: Yes',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add new retailer screen
          // Not implementing this in the initial version
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Adding custom retailers will be available in a future update'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}