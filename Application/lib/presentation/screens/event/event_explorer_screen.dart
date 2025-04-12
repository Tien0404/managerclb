import 'package:flutter/material.dart';
import '../../UI/footer.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_drawer.dart';
import '../../../services/EventService.dart'; // Import service
import '../../../services/CategoryService.dart'; // Import Category service
import 'event_list.dart';
import 'package:intl/intl.dart';
import 'event_detail_screen.dart';
import 'event_card.dart'; // Import để sử dụng class Event, Category, Club, BackgroundImage
import 'event_filter_service.dart'; // Import filter service

class EventExplorerScreen extends StatefulWidget {
  @override
  _EventExplorerScreenState createState() => _EventExplorerScreenState();
}

class _EventExplorerScreenState extends State<EventExplorerScreen> {
  bool isLoading = true;
  bool hasError = false;
  bool isCategoryLoading = true;
  bool hasCategoryError = false;
  List<Event> events = [];
  String selectedCategory = "Tất cả";
  final TextEditingController searchController = TextEditingController();
  FilterOptions filterOptions = FilterOptions();
  bool isSearching = false;

  // Khởi tạo services
  final CategoryService _categoryService = CategoryService();
  final EventFilterService _filterService = EventFilterService();

  // Danh mục mặc định với "Tất cả"
  List<Category> categories = [
    Category(id: 0, name: "Tất cả", subtext: "Sự kiện", icon: Icons.explore),
  ];

  // Danh sách các địa điểm phổ biến để gợi ý
  final List<String> popularLocations = [
    "Hà Nội",
    "TP. Hồ Chí Minh",
    "Đà Nẵng",
    "Huế",
    "Nha Trang",
    "Cần Thơ"
  ];

  // Danh sách trạng thái sự kiện
  final List<Map<String, dynamic>> statusOptions = [
    {
      "value": "active",
      "label": "Đang diễn ra",
      "icon": Icons.event_available,
      "color": Colors.green
    },
    {
      "value": "upcoming",
      "label": "Sắp diễn ra",
      "icon": Icons.event,
      "color": Colors.blue
    },
    {
      "value": "completed",
      "label": "Đã kết thúc",
      "icon": Icons.event_busy,
      "color": Colors.grey
    },
    {
      "value": "cancelled",
      "label": "Đã hủy",
      "icon": Icons.cancel,
      "color": Colors.red
    },
  ];

  // Danh sách các tùy chọn sắp xếp
  final List<Map<String, dynamic>> sortOptions = [
    {
      "value": "start_date:asc",
      "label": "Ngày gần nhất",
      "icon": Icons.arrow_upward
    },
    {
      "value": "start_date:desc",
      "label": "Ngày xa nhất",
      "icon": Icons.arrow_downward
    },
    {"value": "name:asc", "label": "Tên A-Z", "icon": Icons.sort_by_alpha},
    {
      "value": "name:desc",
      "label": "Tên Z-A",
      "icon": Icons.sort_by_alpha_outlined
    },
    {
      "value": "registered_participants:desc",
      "label": "Người tham gia (nhiều nhất)",
      "icon": Icons.people
    },
    {
      "value": "registered_participants:asc",
      "label": "Người tham gia (ít nhất)",
      "icon": Icons.people_outline
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    fetchEvents();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchEvents() async {
    setState(() {
      isLoading = true;
      hasError = false;
      isSearching =
          filterOptions.hasActiveFilters || searchController.text.isNotEmpty;
    });

    try {
      List<dynamic> data;

      if (isSearching || selectedCategory != "Tất cả") {
        // Chuẩn bị các tham số tìm kiếm
        String? name =
            searchController.text.isNotEmpty ? searchController.text : null;
        int? categoryId;

        // Chuyển đổi từ tên danh mục sang ID thực tế
        if (selectedCategory != "Tất cả") {
          final selectedCat = categories.firstWhere(
              (cat) => cat.name == selectedCategory,
              orElse: () => categories[0] // Mặc định là "Tất cả"
              );

          categoryId = selectedCat.id != null && selectedCat.id! > 0
              ? selectedCat.id
              : null;
        }

        // Sử dụng service để tìm kiếm với forceRefresh=true
        filterOptions.name = name;
        filterOptions.categoryId = categoryId;
        data = await _filterService.searchEvents(
          searchQuery: name,
          categoryId: categoryId,
          filterOptions: filterOptions,
          forceRefresh: true,
        );
      } else {
        // Lấy tất cả sự kiện nếu không có bộ lọc, với forceRefresh=true
        data = await EventApiService.getEvents(forceRefresh: true);
      }

      setState(() {
        events = data.map((event) => Event.fromJson(event)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print('Error fetching events: $e');
    }
  }

  void refreshData() {
    fetchEvents();
  }

  void goToEventDetail(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(eventId: id.toString()),
      ),
    );
  }

  void _showFilterBottomSheet() {
    _filterService.showFilterBottomSheet(
      context: context,
      currentFilters: filterOptions,
      onApplyFilters: (newFilters) {
        setState(() {
          filterOptions = newFilters;
          fetchEvents();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      endDrawer: CustomDrawer(),
      bottomNavigationBar: buildFooter(context),
      body: RefreshIndicator(
        onRefresh: fetchEvents,
        color: Colors.lime[600],
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeroSection()),
            SliverToBoxAdapter(child: _buildSearchSection()),
            SliverToBoxAdapter(child: _buildCategorySection()),
            SliverToBoxAdapter(
              child: _filterService.buildActiveFiltersSection(
                filterOptions: filterOptions,
                onFilterChanged: (newFilters) {
                  setState(() {
                    filterOptions = newFilters;
                    fetchEvents();
                  });
                },
              ),
            ),
            EventList(
              isLoading: isLoading,
              hasError: hasError,
              filteredEvents: events,
              onRefresh: refreshData,
              onEventTap: goToEventDetail,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Khám phá sự kiện hấp dẫn",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900]),
          ),
          SizedBox(height: 8),
          Text(
            "${events.length} sự kiện đang chờ bạn khám phá",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Tìm kiếm sự kiện...",
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[400]),
                        onPressed: () {
                          searchController.clear();
                          fetchEvents();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => fetchEvents(),
            ),
          ),
          SizedBox(width: 8),
          InkWell(
            onTap: _showFilterBottomSheet,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: filterOptions.hasActiveFilters
                    ? Colors.lime[500]
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.filter_list,
                color: filterOptions.hasActiveFilters
                    ? Colors.white
                    : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Danh mục",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800]),
              ),
              if (isCategoryLoading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.lime[600]!),
                  ),
                ),
            ],
          ),
        ),
        if (hasCategoryError)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Không thể tải danh mục. Vui lòng thử lại sau.",
              style: TextStyle(color: Colors.red[400], fontSize: 14),
            ),
          ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length,
            itemBuilder: (context, index) =>
                _buildCategoryItem(categories[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(Category category) {
    final bool isSelected = selectedCategory == category.name;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category.name;
          fetchEvents();
        });
      },
      child: Container(
        width: 72,
        margin: EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected ? Colors.lime[500] : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? Colors.lime[600]! : Colors.lime[200]!,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                            color: Colors.lime[200]!,
                            blurRadius: 6,
                            offset: Offset(0, 2))
                      ]
                    : null,
              ),
              child: Icon(
                category.icon,
                color: isSelected ? Colors.white : Colors.lime[500],
                size: 22,
              ),
            ),
            SizedBox(height: 6),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.lime[700] : Colors.grey[800],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Lấy danh mục từ API
  Future<void> _fetchCategories() async {
    try {
      setState(() {
        isCategoryLoading = true;
        hasCategoryError = false;
      });

      // Fetch categories from API
      final data = await _categoryService.getCategories(forceRefresh: true);

      // Convert to Category objects and add to categories list
      List<Category> apiCategories = data
          .map((cat) => Category(
                id: cat['id'],
                name: cat['name'],
                subtext: cat['description'] ?? 'Sự kiện',
                icon: Icons.category,
              ))
          .toList();

      setState(() {
        // Combine default "All" category with API categories
        categories = [categories[0], ...apiCategories];
        isCategoryLoading = false;
      });
    } catch (e) {
      setState(() {
        isCategoryLoading = false;
        hasCategoryError = true;
      });
      print('Error fetching categories: $e');
    }
  }

  // Chọn biểu tượng phù hợp dựa vào tên danh mục
  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'workshop':
        return Icons.book;
      case 'âm nhạc':
        return Icons.music_note;
      case 'ẩm thực':
        return Icons.restaurant;
      case 'thể thao':
        return Icons.favorite;
      case 'sở thích':
        return Icons.games;
      case 'hoạt động':
        return Icons.people;
      case 'văn hóa':
        return Icons.calendar_today;
      case 'nghề nghiệp':
        return Icons.work;
      default:
        return Icons.event;
    }
  }
}
