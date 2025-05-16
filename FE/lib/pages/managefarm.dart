import 'package:farmwise_app/logic/logicGlobal.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:farmwise_app/logic/api/farms.dart';
import 'package:farmwise_app/logic/schemas/Farm.dart';
import 'package:go_router/go_router.dart';

class ManageFarm extends StatefulWidget {
  const ManageFarm({Key? key}) : super(key: key);

  @override
  State<ManageFarm> createState() => _ManageFarmState();
}

class _ManageFarmState extends State<ManageFarm> {
  bool _isLoading = true;
  List<Farm> _farms = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFarms();
  }

  // Load all farms belonging to the user
  Future<void> _loadFarms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    setState(() {
      _isLoading = false;
      _farms = farms;
    });
  }

  // View details of a specific farm
  Future<void> _viewFarmDetails(int farmId) async {
    final response = await getFarmDetails(fID: farmId);

    if (response.statusCode == 200) {
      _showFarmDetailsDialog(response.response!);
    } else {
      _showErrorSnackBar(response.err ?? 'Failed to load farm details');
    }
  }

  // Delete a farm
  Future<void> _deleteFarm(int farmId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Farm'),
            content: const Text(
              'Are you sure you want to delete this farm? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    final response = await deleteFarm(fID: farmId);

    setState(() {
      _isLoading = false;
      if (response.statusCode == 200) {
        // Remove the deleted farm from the list
        _farms.removeWhere((farm) => farm.fID == farmId);
        _showSuccessSnackBar('Farm deleted successfully');
      } else {
        _showErrorSnackBar('Failed to delete farm');
      }
    });
  }

  // Show farm details in a dialog
  void _showFarmDetailsDialog(Farm farm) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              farm.name,
              style: TextStyle(
                fontSize: 20,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ID: ${farm.fID}'),
                  const SizedBox(height: 8),
                  Text('Type: ${farm.type}'),
                  const SizedBox(height: 8),
                  Text('Location: [${farm.location.$1}, ${farm.location.$2}]'),
                  const SizedBox(height: 8),
                  Text('Owner ID: ${farm.uID}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'Manage Farm',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadFarms),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadFarms,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _farms.isEmpty
              ? const Center(child: Text('No farms found'))
              : ListView.builder(
                itemCount: _farms.length,
                itemBuilder: (context, index) {
                  final farm = _farms[index];
                  return Card(
                    color: Colors.green,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(
                        farm.name,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: Text(
                        'Type: ${farm.type}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed:
                                () => context.go('/editfarm/${farm.fID}'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteFarm(farm.fID),
                          ),
                        ],
                      ),
                      onTap: () => _viewFarmDetails(farm.fID),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          // Navigation to create farm screen
          context.go('/createfarm');
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
