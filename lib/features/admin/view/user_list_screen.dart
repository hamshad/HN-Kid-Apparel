import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../provider/admin_provider.dart';
import '../models/admin_models.dart';
import 'seller_registration_screen.dart';
import 'edit_user_screen.dart';

/// Wrapper screen that manages both user list and registration
class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  bool _showRegistrationForm = false;

  void _toggleView() {
    setState(() {
      _showRegistrationForm = !_showRegistrationForm;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showRegistrationForm) {
      return WillPopScope(
        onWillPop: () async {
          _toggleView();
          return false;
        },
        child: SellerRegistrationForm(
          onBack: _toggleView,
          onSuccess: () {
            _toggleView();
            // Refresh the user list
            ref.invalidate(usersProvider(1));
          },
        ),
      );
    }

    return UserListScreen(onAddUser: _toggleView);
  }
}

/// User list display component
class UserListScreen extends ConsumerStatefulWidget {
  final VoidCallback onAddUser;
  
  const UserListScreen({super.key, required this.onAddUser});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<User> _users = [];
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  Object? _paginationError;

  @override
  void initState() {
    super.initState();
    _fetchPage(_currentPage);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int page, {bool refresh = false}) async {
    if (_isLoadingMore || (!_hasMore && !refresh)) return;
    bool isError = false;
    List<User> newUsers = [];
    if (mounted) {
      setState(() {
        _isLoadingMore = true;
        if (refresh) _paginationError = null;
      });
    }
    try {
      newUsers = await ref.read(usersProvider(page).future);
      // Deduplicate by userId
      final ids = _users.map((u) => u.userId).toSet();
      final uniqueNew = newUsers.where((u) => !ids.contains(u.userId)).toList();
      if (mounted) {
        setState(() {
          if (refresh) {
            _users.clear();
            _currentPage = 1;
            _hasMore = true;
          }
          if (uniqueNew.isEmpty) {
            _hasMore = false;
          } else {
            _users.addAll(uniqueNew);
            _currentPage = page;
          }
          _paginationError = null;
        });
      }
    } catch (e) {
      isError = true;
      if (mounted) {
        setState(() {
          _paginationError = e;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
         // Check if we should load more after layout
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _hasMore && !_isLoadingMore && _scrollController.hasClients) {
            if (_scrollController.position.maxScrollExtent <= 0) {
              _fetchPage(_currentPage + 1);
            }
          }
        });
      }
      if (isError && mounted && _users.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Failed to load more users: ${_paginationError ?? ""}')),
        );
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoadingMore && _hasMore) {
      _fetchPage(_currentPage + 1);
    }
  }

  Future<void> _onRefresh() async {
    await _fetchPage(1, refresh: true);
  }

  Future<void> _editUser(User user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserScreen(user: user),
      ),
    );

    // If edit was successful, refresh the list
    if (result == true && mounted) {
      _onRefresh();
    }
  }

  Future<void> _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete ${user.fullName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(adminServiceProvider).deleteUser(user.userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the list
        _onRefresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _users.isEmpty && _isLoadingMore
            ? const Center(child: CircularProgressIndicator())
            : _paginationError != null && _users.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: $_paginationError',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _onRefresh,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _users.isEmpty && !_hasMore 
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No users found',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _users.length + (_isLoadingMore || _hasMore ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index < _users.length) {
                             final user = _users[index];
                             return Card(
                              elevation: 2,
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  child: Text(
                                    user.fullName.isNotEmpty
                                        ? user.fullName[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        user.fullName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    if (!user.isActive)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Inactive',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red.shade900,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.email, size: 16, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            user.email,
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.phone, size: 16, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Text(
                                          user.mobile,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    if (user.shopName.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.store, size: 16, color: Colors.grey),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              user.shopName,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Joined: ${DateFormat('MMM dd, yyyy').format(user.createdAt)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  icon: const Icon(Icons.more_vert),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 20),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, size: 20, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Delete', style: TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _editUser(user);
                                    } else if (value == 'delete') {
                                      _deleteUser(user);
                                    }
                                  },
                                ),
                              ),
                            );
                          } else {
                             if (_paginationError != null) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('Failed to load more'),
                                      TextButton(
                                        onPressed: () => _fetchPage(_currentPage + 1),
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                );
                             }
                             return const Center(
                               child: Padding(
                                 padding: EdgeInsets.all(16.0),
                                 child: CircularProgressIndicator(),
                               ),
                             );
                          }
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onAddUser,
        icon: const Icon(Icons.person_add),
        label: const Text('Register New User'),
      ),
    );
  }
}

