import 'package:flutter/material.dart';
import '../../../data/repositories/category_repository.dart';

class ClubFilterBottomSheet extends StatefulWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final List<Map<String, dynamic>>? categories;

  // Add new filter properties
  final String sortBy;
  final bool onlyFeatured;
  final int minMembers;
  final Function(String, bool, int) onFiltersChanged;

  const ClubFilterBottomSheet({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.categories,
    this.sortBy = 'name',
    this.onlyFeatured = false,
    this.minMembers = 0,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<ClubFilterBottomSheet> createState() => _ClubFilterBottomSheetState();
}

class _ClubFilterBottomSheetState extends State<ClubFilterBottomSheet> {
  late String _currentCategory;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  final CategoryRepository _categoryRepository = CategoryRepository();

  // State for new filters
  late String _sortBy;
  late bool _onlyFeatured;
  late int _minMembers;

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.selectedCategory;
    _sortBy = widget.sortBy;
    _onlyFeatured = widget.onlyFeatured;
    _minMembers = widget.minMembers;

    if (widget.categories != null && widget.categories!.isNotEmpty) {
      _categories = widget.categories!;
      _isLoading = false;
    } else {
      _loadCategories();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryRepository.getCategories();

      // Ensure we have "All" option
      final allExists = categories
          .any((cat) => cat['name'] == 'Tất cả' || cat['id'] == 'all');
      if (!allExists) {
        categories.insert(0, {'id': 'all', 'name': 'Tất cả'});
      }

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading categories: $e');
      // Fallback to default categories if API fails
      setState(() {
        _categories = [
          {'id': 'all', 'name': 'Tất cả'},
          {'id': '1', 'name': 'Âm nhạc'},
          {'id': '2', 'name': 'Nghệ thuật'},
          {'id': '3', 'name': 'Học thuật'},
          {'id': '4', 'name': 'Thể thao'},
          {'id': '5', 'name': 'Công nghệ'},
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(theme),
            Divider(),
            _isLoading
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _buildCategorySection(theme),
            Divider(),
            _buildSortingSection(theme),
            Divider(),
            _buildAdditionalFiltersSection(theme),
            Divider(),
            _buildApplyButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Lọc câu lạc bộ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _currentCategory = 'Tất cả';
                _sortBy = 'name';
                _onlyFeatured = false;
                _minMembers = 0;
              });
            },
            child: Text(
              'Hiện tất cả',
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Text(
            'Danh mục',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _categories
                .map((category) => _buildFilterChip(category, theme))
                .toList(),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  // Add a new section for sorting options
  Widget _buildSortingSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Text(
            'Sắp xếp theo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildSortOptionChip('name', 'Tên A-Z', theme),
              _buildSortOptionChip('members', 'Thành viên', theme),
              _buildSortOptionChip('events', 'Sự kiện', theme),
            ],
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  // Add a new section for additional filters
  Widget _buildAdditionalFiltersSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Text(
            'Lọc thêm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Switch for featured clubs
              SwitchListTile(
                title: Text(
                  'Chỉ hiển thị CLB nổi bật',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
                value: _onlyFeatured,
                activeColor: theme.primaryColor,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  setState(() {
                    _onlyFeatured = value;
                  });
                },
              ),

              // Slider for minimum members
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Số thành viên tối thiểu: $_minMembers',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  Slider(
                    value: _minMembers.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: _minMembers.toString(),
                    activeColor: theme.primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _minMembers = value.round();
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSortOptionChip(String value, String label, ThemeData theme) {
    final isSelected = _sortBy == value;

    return InkWell(
      onTap: () {
        setState(() {
          _sortBy = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getSortIcon(value),
              size: 16,
              color: isSelected ? theme.primaryColor : Colors.grey[700],
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? theme.primaryColor : Colors.grey[800],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSortIcon(String sortType) {
    switch (sortType) {
      case 'name':
        return Icons.sort_by_alpha;
      case 'members':
        return Icons.people;
      case 'events':
        return Icons.event;
      default:
        return Icons.sort;
    }
  }

  Widget _buildApplyButton(ThemeData theme) {
    // Count how many filters are active
    int activeFilterCount = 0;
    if (_currentCategory != 'Tất cả') activeFilterCount++;
    if (_sortBy != 'name') activeFilterCount++;
    if (_onlyFeatured) activeFilterCount++;
    if (_minMembers > 0) activeFilterCount++;

    String buttonText = activeFilterCount > 0
        ? 'Áp dụng bộ lọc (${activeFilterCount > 1 ? "$activeFilterCount bộ lọc" : "1 bộ lọc"})'
        : 'Áp dụng';

    return Container(
      padding: EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          widget.onCategorySelected(_currentCategory);
          widget.onFiltersChanged(_sortBy, _onlyFeatured, _minMembers);
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(Map<String, dynamic> category, ThemeData theme) {
    final isSelected = _currentCategory == category['name'];
    final bool isAllCategory = category['id'] == 'all';
    final String clubCount = isAllCategory ? '' : category['club_count'] ?? '0';

    return Material(
      color:
          isSelected ? theme.primaryColor.withOpacity(0.1) : Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          setState(() => _currentCategory = category['name']);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? theme.primaryColor : Colors.transparent,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                category['name'],
                style: TextStyle(
                  color: isSelected ? theme.primaryColor : Colors.grey[800],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (clubCount.isNotEmpty) ...[
                SizedBox(width: 6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.primaryColor : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    clubCount,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
