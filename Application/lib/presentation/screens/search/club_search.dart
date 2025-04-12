import 'package:flutter/material.dart';
import '../../../data/repositories/club_repository.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../services/ClubService.dart';
import '../../UI/footer.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer.dart';
import '../../../routes.dart';
import '../club/club_detail_screen.dart';
import 'dart:math' as math;

/// IMPORT 2 FILE DƯỚI ĐÂY:
import 'club_card.dart';
import 'club_filter_bottom_sheet.dart';

class ClubSearch extends StatefulWidget {
  final List<Map<String, dynamic>> initialClubs;
  final String initialCategory;

  ClubSearch({
    Key? key,
    this.initialClubs = const [],
    this.initialCategory = 'Tất cả',
  }) : super(key: key);

  @override
  _ClubSearchState createState() => _ClubSearchState();
}

class _ClubSearchState extends State<ClubSearch> {
  final ClubRepository _clubRepository = ClubRepository();
  final CategoryRepository _categoryRepository = CategoryRepository();
  final ClubService _clubService = ClubService();

  late List<Map<String, dynamic>> _clubs;
  late String _selectedCategory;
  List<Map<String, dynamic>> _categories = [];

  // Loading indicator
  bool _isLoading = true;
  bool _isCategoriesLoading = true;

  // Biến tìm kiếm
  String _searchQuery = '';

  // Add more filter options
  String _sortBy = 'name'; // Default sort by name
  bool _onlyFeatured = false; // Filter for featured clubs
  int _minMembers = 0; // Minimum members filter

  // Biến và hàm để implement debounce cho tìm kiếm
  static const _searchDelayMillis = 500;
  DateTime? _lastSearchTime;

  @override
  void initState() {
    super.initState();
    _clubs = widget.initialClubs;
    _selectedCategory = widget.initialCategory;

    // Load categories from the API
    _loadCategories();

    if (_clubs.isEmpty) {
      _loadClubs();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadClubs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String? categoryId = _getCategoryId(_selectedCategory);

      print('Loading clubs');

      // Sử dụng searchClubs thay cho getClubs
      final clubs = await _clubService.searchClubs(
        name: _searchQuery.isNotEmpty ? _searchQuery : null,
        categoryId: categoryId != 'all' ? int.tryParse(categoryId!) : null,
        minMembers: _minMembers > 0 ? _minMembers : null,
        sortBy: _getSortField(),
        sortDirection: _getSortDirection(),
        paginate: false, // Không sử dụng phân trang
      );

      print('Received clubs: ${clubs.length} items');

      // Log chi tiết về dữ liệu club
      if (clubs.isNotEmpty) {
        print('First club data: ${clubs.first}');
        print(
            'First club background_images: ${clubs.first['background_images']}');
        print('First club imageUrl: ${clubs.first['imageUrl']}');
        print('First club logo: ${clubs.first['logo']}');
      }

      setState(() {
        _clubs = clubs.map((club) => Map<String, dynamic>.from(club)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading clubs: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải danh sách câu lạc bộ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onSearchQueryChanged(String value) {
    setState(() => _searchQuery = value);

    // Sử dụng debounce để tránh gọi API quá nhiều
    _debounceSearch();
  }

  void _debounceSearch() {
    final now = DateTime.now();
    _lastSearchTime = now;

    Future.delayed(Duration(milliseconds: _searchDelayMillis), () {
      if (_lastSearchTime == now) {
        _loadClubs();
      }
    });
  }

  // Helper method to convert UI sort option to API sort field
  String _getSortField() {
    switch (_sortBy) {
      case 'name':
        return 'name';
      case 'members':
        return 'member_count';
      case 'events':
        return 'id'; // Giả sử không có trường sắp xếp theo số lượng events
      default:
        return 'name';
    }
  }

  // Helper method to get sort direction
  String _getSortDirection() {
    if (_sortBy == 'name') return 'asc';
    return 'desc'; // For members and events, sort descending
  }

  // Helper method to get category ID from selected category name
  String? _getCategoryId(String categoryName) {
    if (categoryName == 'Tất cả') {
      return 'all';
    }

    final category = _categories.firstWhere(
      (category) => category['name'] == categoryName,
      orElse: () => {'id': 'all'},
    );

    return category['id'].toString();
  }

  // Enhanced filter method
  List<Map<String, dynamic>> _filterClubs() {
    if (_clubs.isEmpty) return [];

    var filteredList = List<Map<String, dynamic>>.from(_clubs);

    // Apply text search filter
    if (_searchQuery.isNotEmpty) {
      final lowercaseQuery = _searchQuery.toLowerCase();
      filteredList = filteredList.where((club) {
        final nameMatches =
            club['name'].toString().toLowerCase().contains(lowercaseQuery);
        final descriptionMatches = club['description'] != null &&
            club['description']
                .toString()
                .toLowerCase()
                .contains(lowercaseQuery);
        return nameMatches || descriptionMatches;
      }).toList();
    }

    // Apply featured filter
    if (_onlyFeatured) {
      filteredList =
          filteredList.where((club) => club['is_featured'] == true).toList();
    }

    // Apply minimum members filter
    if (_minMembers > 0) {
      filteredList = filteredList.where((club) {
        int memberCount = 0;
        if (club['members'] != null) {
          memberCount = int.tryParse(club['members'].toString()) ?? 0;
        } else if (club['members_count'] != null) {
          memberCount = int.tryParse(club['members_count'].toString()) ?? 0;
        } else if (club['member_count'] != null) {
          memberCount = int.tryParse(club['member_count'].toString()) ?? 0;
        }
        return memberCount >= _minMembers;
      }).toList();
    }

    // Sort the list
    filteredList.sort((a, b) {
      switch (_sortBy) {
        case 'name':
          return (a['name'] ?? '')
              .toString()
              .compareTo((b['name'] ?? '').toString());
        case 'members':
          int membersA =
              int.tryParse(a['members_count']?.toString() ?? '0') ?? 0;
          int membersB =
              int.tryParse(b['members_count']?.toString() ?? '0') ?? 0;
          return membersB.compareTo(membersA); // Descending
        case 'events':
          int eventsA = int.tryParse(a['events_count']?.toString() ?? '0') ?? 0;
          int eventsB = int.tryParse(b['events_count']?.toString() ?? '0') ?? 0;
          return eventsB.compareTo(eventsA); // Descending
        default:
          return (a['name'] ?? '')
              .toString()
              .compareTo((b['name'] ?? '').toString());
      }
    });

    return filteredList;
  }

  // Reset all filters
  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategory = 'Tất cả';
      _sortBy = 'name';
      _onlyFeatured = false;
      _minMembers = 0;
    });
    _loadClubs();
  }

  // Add method to load categories
  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryRepository.getCategories();

      // Add "All categories" option at the beginning
      final allCategoriesOption = {'id': 'all', 'name': 'Tất cả'};

      setState(() {
        _categories = [allCategoriesOption, ...categories];
        _isCategoriesLoading = false;
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() {
        _categories = [
          {'id': 'all', 'name': 'Tất cả'}
        ];
        _isCategoriesLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Lọc clubs dựa trên danh mục và từ khóa tìm kiếm
    final filteredClubs = _filterClubs();

    // Calculate how many clubs are being hidden by filters
    final int hiddenClubsCount = _clubs.length - filteredClubs.length;
    final bool hasActiveFilters = _selectedCategory != 'Tất cả' ||
        _searchQuery.isNotEmpty ||
        _onlyFeatured ||
        _minMembers > 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(),
      endDrawer: CustomDrawer(),
      body: Column(
        children: [
          _buildSearchBar(theme),
          _buildCategoryChips(theme),
          _buildFilterButton(theme),
          _buildFilterStatus(theme),

          // Loading indicator
          if (_isLoading)
            Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                ),
              ),
            )
          else if (filteredClubs.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      hasActiveFilters
                          ? Icons.filter_alt_off
                          : Icons.search_off,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      hasActiveFilters
                          ? 'Không tìm thấy câu lạc bộ phù hợp với bộ lọc'
                          : 'Không tìm thấy câu lạc bộ nào',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      hasActiveFilters
                          ? 'Hãy thử điều chỉnh lại các bộ lọc để xem thêm câu lạc bộ'
                          : 'Thử tìm kiếm với từ khóa khác',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    if (hasActiveFilters)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: ElevatedButton.icon(
                          onPressed: _resetFilters,
                          icon: Icon(Icons.filter_alt_off, size: 18),
                          label: Text('Xóa tất cả bộ lọc'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  // Show info about hidden clubs if any filtering is active
                  if (hiddenClubsCount > 0)
                    Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      color: Colors.amber.withOpacity(0.1),
                      child: Row(
                        children: [
                          Icon(Icons.visibility_off,
                              size: 16, color: Colors.amber[800]),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Đang tạm ẩn $hiddenClubsCount câu lạc bộ không phù hợp với bộ lọc',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.amber[900],
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _resetFilters,
                            child: Text(
                              'Hiện tất cả',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[800],
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filteredClubs.length,
                      itemBuilder: (context, index) {
                        final club = filteredClubs[index];
                        return ClubCard(
                          club: club,
                          onTap: () => _navigateToClubDetails(club['id']),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: buildFooter(context),
    );
  }

  // Add a filter button widget
  Widget _buildFilterButton(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: _showFilterBottomSheet,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor.withOpacity(0.1),
          foregroundColor: theme.primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        icon: Icon(Icons.filter_list, size: 20),
        label: Text(
          'Lọc và sắp xếp',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: _onSearchQueryChanged,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm câu lạc bộ...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: theme.primaryColor),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                  onPressed: () {
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(ThemeData theme) {
    if (_isCategoriesLoading) {
      return Center(
        child: Container(
          height: 50,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Container(
      height: 50,
      margin: EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) =>
            _buildCategoryChip(_categories[index]['name'], theme),
      ),
    );
  }

  Widget _buildCategoryChip(String category, ThemeData theme) {
    final isSelected = _selectedCategory == category;

    return Container(
      margin: EdgeInsets.only(right: 12),
      child: Material(
        color: isSelected ? theme.primaryColor : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
            width: 1,
          ),
        ),
        elevation: isSelected ? 2 : 0,
        child: InkWell(
          onTap: () {
            if (_selectedCategory != category) {
              setState(() => _selectedCategory = category);
              _loadClubs(); // Reload clubs when category changes
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              category,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[800],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToClubDetails(dynamic clubId) {
    if (clubId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClubDetailScreen(
            clubId: clubId.toString(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể mở chi tiết câu lạc bộ: ID không hợp lệ'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Mở bottom sheet lọc
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClubFilterBottomSheet(
        selectedCategory: _selectedCategory,
        categories: _categories,
        sortBy: _sortBy,
        onlyFeatured: _onlyFeatured,
        minMembers: _minMembers,
        onCategorySelected: (category) {
          setState(() {
            _selectedCategory = category;
          });
          _loadClubs(); // Reload clubs with the new filter
        },
        onFiltersChanged: (sortBy, onlyFeatured, minMembers) {
          setState(() {
            _sortBy = sortBy;
            _onlyFeatured = onlyFeatured;
            _minMembers = minMembers;
          });
          _loadClubs(); // Tải lại dữ liệu với bộ lọc mới
        },
      ),
    );
  }

  // Add a method to build the filter status indicator with improved UI
  Widget _buildFilterStatus(ThemeData theme) {
    // Check if any filters are applied
    bool hasFilters = _selectedCategory != 'Tất cả' ||
        _searchQuery.isNotEmpty ||
        _sortBy != 'name' ||
        _onlyFeatured ||
        _minMembers > 0;

    if (!hasFilters) {
      return SizedBox.shrink(); // No filters applied
    }

    // Calculate how many clubs are being hidden by filters
    final filteredClubs = _filterClubs();
    final int hiddenClubsCount = _clubs.length - filteredClubs.length;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                hiddenClubsCount > 0
                    ? 'Tạm ẩn ${hiddenClubsCount} CLB không phù hợp:'
                    : 'Bộ lọc đang hoạt động:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              if (hasFilters)
                TextButton.icon(
                  onPressed: _resetFilters,
                  icon: Icon(Icons.restore, size: 16),
                  label: Text(
                    'Hiện tất cả',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Category filter
              if (_selectedCategory != 'Tất cả')
                _buildFilterChip(
                  icon: Icons.category_outlined,
                  label: _selectedCategory,
                  color: theme.primaryColor,
                  onRemove: () {
                    setState(() => _selectedCategory = 'Tất cả');
                    _loadClubs();
                  },
                ),

              // Search query filter
              if (_searchQuery.isNotEmpty)
                _buildFilterChip(
                  icon: Icons.search,
                  label: '"$_searchQuery"',
                  color: Colors.blueGrey,
                  onRemove: () {
                    setState(() => _searchQuery = '');
                  },
                ),

              // Sort filter
              if (_sortBy != 'name')
                _buildFilterChip(
                  icon: _getSortIcon(_sortBy),
                  label: 'Sắp xếp: ${_getSortLabel(_sortBy)}',
                  color: Colors.amber[700]!,
                  onRemove: () {
                    setState(() => _sortBy = 'name');
                  },
                ),

              // Featured filter
              if (_onlyFeatured)
                _buildFilterChip(
                  icon: Icons.star,
                  label: 'Chỉ CLB nổi bật',
                  color: Colors.orange,
                  onRemove: () {
                    setState(() => _onlyFeatured = false);
                  },
                ),

              // Min members filter
              if (_minMembers > 0)
                _buildFilterChip(
                  icon: Icons.people,
                  label: 'Thành viên ≥ $_minMembers',
                  color: Colors.teal,
                  onRemove: () {
                    setState(() => _minMembers = 0);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to create a filter chip
  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(12),
            child: Tooltip(
              message: 'Bỏ bộ lọc này để hiện thêm câu lạc bộ',
              child: Icon(
                Icons.close,
                size: 16,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to get sort icon
  IconData _getSortIcon(String sortType) {
    switch (sortType) {
      case 'members':
        return Icons.people;
      case 'events':
        return Icons.event;
      default:
        return Icons.sort_by_alpha;
    }
  }

  // Helper to get sort label
  String _getSortLabel(String sortType) {
    switch (sortType) {
      case 'members':
        return 'Thành viên';
      case 'events':
        return 'Sự kiện';
      default:
        return 'Tên A-Z';
    }
  }
}
