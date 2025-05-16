import 'package:flutter/material.dart';
import 'package:farmwise_app/logic/schemas/Notification.dart' as App;
import 'package:farmwise_app/logic/schemas/Response.dart';
import 'package:farmwise_app/logic/api/notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _isLoading = true;
  bool _showUnreadOnly = false;
  List<App.Notification> _notifications = [];
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();

    // Add scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (_hasMoreData && !_isLoading) {
          _loadMoreNotifications();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
    });

    final NetworkResponse<List<App.Notification>> response =
        await getNotifications(page: _currentPage, unreadOnly: _showUnreadOnly);

    setState(() {
      _isLoading = false;
      if (response.response != null) {
        _notifications = response.response!;
        _hasMoreData = response.response!.isEmpty;
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.err ?? "Unknown error"}')),
        );
      }
    });
  }

  Future<void> _loadMoreNotifications() async {
    setState(() {
      _isLoading = true;
      _currentPage++;
    });

    final NetworkResponse<List<App.Notification>> response =
        await getNotifications(page: _currentPage, unreadOnly: _showUnreadOnly);

    setState(() {
      _isLoading = false;
      if (response.response != null) {
        if (response.response!.isEmpty) {
          _hasMoreData = false;
        } else {
          _notifications.addAll(response.response!);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error loading more: ${response.err ?? "Unknown error"}',
            ),
          ),
        );
      }
    });
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      _currentPage = 1;
      _hasMoreData = true;
    });
    await _fetchNotifications();
  }

  Future<void> _markAsRead(List<int> notificationIds) async {
    if (notificationIds.isEmpty) return;

    final NetworkResponse<List<App.Notification>> response =
        await readNotifications(nIDs: notificationIds);

    if (response.response != null) {
      setState(() {
        for (final nID in notificationIds) {
          final index = _notifications.indexWhere((n) => n.nID == nID);
          if (index != -1) {
            _notifications[index].lastRead = DateTime.now();
          }
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to mark as read: ${response.err ?? "Unknown error"}',
          ),
        ),
      );
    }
  }

  Future<void> _viewNotificationDetail(App.Notification notification) async {
    if (notification.lastRead == null) {
      await _markAsRead([notification.nID]);
    }

    // Navigate to detail page or show detail in dialog
    final NetworkResponse<App.Notification> response =
        await getNotificationsDetail(nID: notification.nID);

    if (response.response != null) {
      _showNotificationDetailDialog(response.response!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load details: ${response.err ?? "Unknown error"}',
          ),
        ),
      );
    }
  }

  void _showNotificationDetailDialog(App.Notification notification) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(notification.content.title),
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(notification.content.body),
                  const SizedBox(height: 16),
                  Text(
                    'Received: ${DateFormat('dd MMM yyyy, HH:mm').format(notification.time)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildNotificationTypeIcon(App.NotificationType type) {
    switch (type) {
      case App.NotificationType.alert:
        return const CircleAvatar(
          backgroundColor: Colors.red,
          radius: 20,
          child: Icon(Icons.warning_amber_rounded, color: Colors.white),
        );
      case App.NotificationType.general:
        return const CircleAvatar(
          backgroundColor: Colors.blue,
          radius: 20,
          child: Icon(Icons.notifications, color: Colors.white),
        );
    }
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
          'Notifications',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        actions: [
          // Filter button to show/hide read notifications
          IconButton(
            icon: Icon(
              _showUnreadOnly ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _showUnreadOnly = !_showUnreadOnly;
                _currentPage = 1;
                _hasMoreData = true;
              });
              _fetchNotifications();
            },
            tooltip: _showUnreadOnly ? 'Show all' : 'Show unread only',
          ),
          // Mark all as read button
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed:
                _notifications.isEmpty ||
                        _notifications.every((n) => n.lastRead != null)
                    ? null
                    : () {
                      final unreadNotifications =
                          _notifications
                              .where((n) => n.lastRead == null)
                              .map((n) => n.nID)
                              .toList();
                      _markAsRead(unreadNotifications);
                    },
            tooltip: 'Mark all as read',
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child:
            _isLoading && _notifications.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                ? Center(
                  child: Text(
                    _showUnreadOnly
                        ? 'No unread notifications'
                        : 'No notifications yet',
                  ),
                )
                : ListView.builder(
                  controller: _scrollController,
                  itemCount:
                      _notifications.length +
                      (_isLoading && _hasMoreData ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _notifications.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final notification = _notifications[index];
                    final bool isUnread = notification.lastRead == null;

                    return Dismissible(
                      key: Key('notification_${notification.nID}'),
                      background: Container(
                        color: Colors.blue,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.done, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          // Mark as read
                          if (isUnread) {
                            await _markAsRead([notification.nID]);
                          }
                          return false; // Don't dismiss the item
                        } else {
                          // For now, let's not implement delete functionality
                          // Just return false to keep the item in the list
                          return false;
                        }
                      },
                      child: Card(
                        elevation: isUnread ? 2 : 1,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: isUnread ? Colors.white : Colors.grey[50],
                        child: InkWell(
                          onTap: () => _viewNotificationDetail(notification),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: _buildNotificationTypeIcon(
                              notification.content.type,
                            ),
                            title: Text(
                              notification.content.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    isUnread
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  notification.content.body,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat(
                                    'dd MMM yyyy, HH:mm',
                                  ).format(notification.time),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            trailing:
                                isUnread
                                    ? Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                    : null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
