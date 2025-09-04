import 'package:asman_toga/pages/create_user_page.dart';
import 'package:flutter/material.dart';
import '../service/api_service.dart';

class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  bool isLoading = true;
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];

  // Pagination
  int currentPage = 1;
  int itemsPerPage = 10;
  bool hasMoreData = true;
  bool isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();

  // Search
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  // Color palette
  static const Color primaryGreen = Color(0xFF57A32E);
  static const Color lightGreen = Color(0xFF7BC142);
  static const Color darkGreen = Color(0xFF3D7A1E);
  static const Color backgroundColor = Color(0xFFF8FAF6);
  static const Color cardColor = Colors.white;
  static const Color errorRed = Color(0xFFE53E3E);
  static const Color warningOrange = Color(0xFFFF8C42);
  static const Color successGreen = Color(0xFF38A169);
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);

  @override
  void initState() {
    super.initState();
    fetchUsers();
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore && hasMoreData) {
        _loadMoreUsers();
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text.toLowerCase();
      _filterUsers();
    });
  }

  void _filterUsers() {
    if (searchQuery.isEmpty) {
      filteredUsers = users;
    } else {
      filteredUsers =
          users.where((user) {
            final name = user['name'].toString().toLowerCase();
            final email = user['email'].toString().toLowerCase();
            return name.contains(searchQuery) || email.contains(searchQuery);
          }).toList();
    }
  }

  Future<void> fetchUsers({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        currentPage = 1;
        hasMoreData = true;
        users.clear();
        filteredUsers.clear();
        isLoading = true;
      });
    }

    try {
      final result = await ApiService.getAllUsers();
      final newUsers = List<Map<String, dynamic>>.from(result);

      // Simulate pagination
      final startIndex = (currentPage - 1) * itemsPerPage;
      final endIndex = startIndex + itemsPerPage;
      final paginatedUsers =
          newUsers.skip(startIndex).take(itemsPerPage).toList();

      setState(() {
        if (refresh || currentPage == 1) {
          users = paginatedUsers;
        } else {
          users.addAll(paginatedUsers);
        }
        hasMoreData = paginatedUsers.length == itemsPerPage;
        _filterUsers();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasMoreData = false;
      });
      _showErrorSnackBar('Gagal memuat data users: $e');
    }
  }

  Future<void> _loadMoreUsers() async {
    if (isLoadingMore || !hasMoreData) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      currentPage++;
      final result = await ApiService.getAllUsers();
      final allUsers = List<Map<String, dynamic>>.from(result);

      final startIndex = (currentPage - 1) * itemsPerPage;
      final paginatedUsers =
          allUsers.skip(startIndex).take(itemsPerPage).toList();

      setState(() {
        users.addAll(paginatedUsers);
        hasMoreData = paginatedUsers.length == itemsPerPage;
        _filterUsers();
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        currentPage--;
        isLoadingMore = false;
        hasMoreData = false;
      });
      _showErrorSnackBar('Gagal memuat data tambahan: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(fontSize: 16, color: textPrimary),
        decoration: InputDecoration(
          hintText: "Cari berdasarkan nama atau email...",
          hintStyle: TextStyle(color: textSecondary.withOpacity(0.7)),
          prefixIcon: Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.search_rounded, color: primaryGreen, size: 20),
          ),
          suffixIcon:
              searchQuery.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear_rounded, color: textSecondary),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: cardColor,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryGreen, lightGreen],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.people_rounded, color: Colors.white, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total Users",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "${filteredUsers.length}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (searchQuery.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Filtered",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryGreen, lightGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              user['name'].toString()[0].toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          user['name'].toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.email_outlined, size: 14, color: textSecondary),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    user['email'].toString(),
                    style: TextStyle(fontSize: 13, color: textSecondary),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone, size: 14, color: textSecondary),
                SizedBox(width: 4),
                Text(
                  "No Hp: ${user['phone']}",
                  style: TextStyle(
                    fontSize: 12,
                    color: textSecondary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
        // trailing: PopupMenuButton<String>(
        //   icon: Container(
        //     padding: EdgeInsets.all(8),
        //     decoration: BoxDecoration(
        //       color: primaryGreen.withOpacity(0.1),
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //     child: Icon(Icons.more_vert_rounded, color: primaryGreen, size: 16),
        //   ),
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //   onSelected: (value) {
        //     if (value == 'edit') {
        //       _editUser(user);
        //     } else if (value == 'delete') {
        //       _deleteUser(user);
        //     }
        //   },
        //   itemBuilder:
        //       (context) => [
        //         PopupMenuItem(
        //           value: 'edit',
        //           child: Row(
        //             children: [
        //               Icon(Icons.edit_outlined, size: 18, color: primaryGreen),
        //               SizedBox(width: 8),
        //               Text('Edit User'),
        //             ],
        //           ),
        //         ),
        //         PopupMenuItem(
        //           value: 'delete',
        //           child: Row(
        //             children: [
        //               Icon(Icons.delete_outline, size: 18, color: errorRed),
        //               SizedBox(width: 8),
        //               Text('Hapus User'),
        //             ],
        //           ),
        //         ),
        //       ],
        // ),
      ),
    );
  }

  Widget _buildLoadingMore() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
            ),
          ),
          SizedBox(width: 12),
          Text(
            "Memuat data lainnya...",
            style: TextStyle(color: textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _editUser(Map<String, dynamic> user) {
    _showErrorSnackBar('Fitur edit user belum tersedia');
  }

  void _deleteUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              "Hapus User",
              style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
            ),
            content: Text(
              "Apakah Anda yakin ingin menghapus user \"${user['name']}\"?",
              style: TextStyle(color: textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Batal", style: TextStyle(color: textSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showErrorSnackBar('Fitur hapus user belum tersedia');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: errorRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Hapus", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        title: Text(
          "Kelola Users",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.refresh_rounded, color: primaryGreen, size: 20),
            ),
            onPressed: () => fetchUsers(refresh: true),
          ),
        ],
      ),
      body:
          isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Memuat data users...",
                      style: TextStyle(color: textSecondary, fontSize: 14),
                    ),
                  ],
                ),
              )
              : filteredUsers.isEmpty && searchQuery.isNotEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 80,
                      color: textSecondary.withOpacity(0.5),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Tidak ada hasil",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Tidak ditemukan user dengan kata kunci\n\"$searchQuery\"",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textSecondary.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
              : users.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 80,
                      color: textSecondary.withOpacity(0.5),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Belum ada users",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Tambahkan user pertama dengan\nmenekan tombol + di bawah",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textSecondary.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: () => fetchUsers(refresh: true),
                color: primaryGreen,
                child: Column(
                  children: [
                    _buildSearchBar(),
                    _buildStatsCard(),
                    SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount:
                            filteredUsers.length + (isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == filteredUsers.length) {
                            return _buildLoadingMore();
                          }
                          return _buildUserCard(filteredUsers[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryGreen,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateUserPage()),
          );

          if (result == true) {
            fetchUsers(refresh: true);
          }
        },
        icon: Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text(
          "Tambah User",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
