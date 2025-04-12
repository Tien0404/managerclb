import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../services/EventService.dart';

// Lớp chứa các tùy chọn lọc
class FilterOptions {
  String? name;
  int? categoryId;
  String? location;
  String? status;
  DateTime? startDateFrom;
  DateTime? startDateTo;
  String? sortBy;
  String? sortDirection;

  FilterOptions({
    this.name,
    this.categoryId,
    this.location,
    this.status,
    this.startDateFrom,
    this.startDateTo,
    this.sortBy,
    this.sortDirection,
  });

  // Kiểm tra xem có bất kỳ bộ lọc nào được áp dụng không
  bool get hasActiveFilters {
    return location != null ||
        status != null ||
        startDateFrom != null ||
        startDateTo != null ||
        sortBy != null;
  }

  // Reset tất cả các bộ lọc
  void reset() {
    location = null;
    status = null;
    startDateFrom = null;
    startDateTo = null;
    sortBy = null;
    sortDirection = null;
  }

  // Clone để tạo bản sao
  FilterOptions clone() {
    return FilterOptions(
      name: name,
      categoryId: categoryId,
      location: location,
      status: status,
      startDateFrom: startDateFrom,
      startDateTo: startDateTo,
      sortBy: sortBy,
      sortDirection: sortDirection,
    );
  }
}

class EventFilterService {
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

  // Phương thức tìm kiếm sự kiện với các bộ lọc
  Future<List<dynamic>> searchEvents({
    String? searchQuery,
    int? categoryId,
    FilterOptions? filterOptions,
    bool forceRefresh = false,
  }) async {
    try {
      // Chuẩn bị các tham số tìm kiếm
      String? name =
          searchQuery != null && searchQuery.isNotEmpty ? searchQuery : null;

      // Tách sortBy và sortDirection
      String? sortBy;
      String? sortDirection;
      if (filterOptions != null &&
          filterOptions.sortBy != null &&
          filterOptions.sortBy!.contains(':')) {
        List<String> sortParts = filterOptions.sortBy!.split(':');
        sortBy = sortParts[0];
        sortDirection = sortParts[1];
      }

      // Gọi API tìm kiếm với các tham số lọc
      return await EventApiService.searchEvents(
        name: name,
        categoryId: categoryId,
        location: filterOptions?.location,
        status: filterOptions?.status,
        startDateFrom: filterOptions?.startDateFrom?.toIso8601String(),
        startDateTo: filterOptions?.startDateTo?.toIso8601String(),
        sortBy: sortBy,
        sortDirection: sortDirection,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      print('Error in searchEvents: $e');
      rethrow;
    }
  }

  // Hiển thị chip filter cho địa điểm
  Widget buildLocationFilterChip(
      String location, bool isSelected, Function(bool) onSelected) {
    return ChoiceChip(
      label: Text(location),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: Colors.lime[200],
      labelStyle: TextStyle(
        color: isSelected ? Colors.lime[800] : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  // Hiển thị chip filter cho trạng thái
  Widget buildStatusFilterChip(
      Map<String, dynamic> status, bool isSelected, Function(bool) onSelected) {
    return ChoiceChip(
      avatar: Icon(
        status['icon'] as IconData,
        color: isSelected ? status['color'] : Colors.grey,
        size: 18,
      ),
      label: Text(status['label']),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: Colors.lime[200],
      labelStyle: TextStyle(
        color: isSelected ? Colors.lime[800] : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  // Hiển thị radio button cho sắp xếp
  Widget buildSortOptionRadio({
    required Map<String, dynamic> sort,
    required String? groupValue,
    required Function(String?) onChanged,
  }) {
    final bool isSelected = groupValue == sort['value'];
    return RadioListTile<String>(
      title: Row(
        children: [
          Icon(
            sort['icon'] as IconData,
            color: isSelected ? Colors.lime[700] : Colors.grey[600],
            size: 18,
          ),
          SizedBox(width: 8),
          Text(
            sort['label'],
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.lime[700] : Colors.grey[800],
            ),
          ),
        ],
      ),
      value: sort['value'],
      groupValue: groupValue,
      activeColor: Colors.lime[600],
      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      dense: true,
      onChanged: onChanged,
    );
  }

  // Widget hiển thị danh sách các bộ lọc đang áp dụng
  Widget buildActiveFiltersSection({
    required FilterOptions filterOptions,
    required Function(FilterOptions) onFilterChanged,
  }) {
    if (!filterOptions.hasActiveFilters) return SizedBox.shrink();

    List<Widget> chips = [];

    // Địa điểm
    if (filterOptions.location != null) {
      chips.add(
        Chip(
          label: Text(filterOptions.location!),
          backgroundColor: Colors.lime[100],
          labelStyle: TextStyle(color: Colors.lime[800], fontSize: 12),
          deleteIconColor: Colors.lime[800],
          onDeleted: () {
            FilterOptions newFilters = filterOptions.clone();
            newFilters.location = null;
            onFilterChanged(newFilters);
          },
        ),
      );
    }

    // Trạng thái
    if (filterOptions.status != null) {
      final statusInfo = statusOptions.firstWhere(
        (s) => s['value'] == filterOptions.status,
        orElse: () => {"label": filterOptions.status!, "color": Colors.grey},
      );

      chips.add(
        Chip(
          label: Text(statusInfo['label']),
          backgroundColor: Colors.lime[100],
          labelStyle: TextStyle(color: Colors.lime[800], fontSize: 12),
          deleteIconColor: Colors.lime[800],
          onDeleted: () {
            FilterOptions newFilters = filterOptions.clone();
            newFilters.status = null;
            onFilterChanged(newFilters);
          },
        ),
      );
    }

    // Thời gian
    if (filterOptions.startDateFrom != null ||
        filterOptions.startDateTo != null) {
      String dateRangeText = '';

      if (filterOptions.startDateFrom != null &&
          filterOptions.startDateTo != null) {
        dateRangeText =
            '${DateFormat('dd/MM').format(filterOptions.startDateFrom!)} - ${DateFormat('dd/MM').format(filterOptions.startDateTo!)}';
      } else if (filterOptions.startDateFrom != null) {
        dateRangeText =
            'Từ ${DateFormat('dd/MM').format(filterOptions.startDateFrom!)}';
      } else if (filterOptions.startDateTo != null) {
        dateRangeText =
            'Đến ${DateFormat('dd/MM').format(filterOptions.startDateTo!)}';
      }

      chips.add(
        Chip(
          label: Text(dateRangeText),
          backgroundColor: Colors.lime[100],
          labelStyle: TextStyle(color: Colors.lime[800], fontSize: 12),
          deleteIconColor: Colors.lime[800],
          onDeleted: () {
            FilterOptions newFilters = filterOptions.clone();
            newFilters.startDateFrom = null;
            newFilters.startDateTo = null;
            onFilterChanged(newFilters);
          },
        ),
      );
    }

    // Sắp xếp
    if (filterOptions.sortBy != null) {
      final sortInfo = sortOptions.firstWhere(
        (s) => s['value'] == filterOptions.sortBy,
        orElse: () => {"label": "Sắp xếp tùy chỉnh"},
      );

      chips.add(
        Chip(
          label: Text(sortInfo['label']),
          backgroundColor: Colors.lime[100],
          labelStyle: TextStyle(color: Colors.lime[800], fontSize: 12),
          deleteIconColor: Colors.lime[800],
          onDeleted: () {
            FilterOptions newFilters = filterOptions.clone();
            newFilters.sortBy = null;
            onFilterChanged(newFilters);
          },
        ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Bộ lọc đang áp dụng",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              TextButton(
                onPressed: () {
                  FilterOptions newFilters = FilterOptions();
                  onFilterChanged(newFilters);
                },
                child: Text(
                  "Xóa tất cả",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.lime[700],
                  ),
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips,
          ),
        ],
      ),
    );
  }

  // Hiển thị bottom sheet cho các bộ lọc
  void showFilterBottomSheet({
    required BuildContext context,
    required FilterOptions currentFilters,
    required Function(FilterOptions) onApplyFilters,
  }) {
    // Tạo một bản sao của filterOptions hiện tại để có thể hủy thay đổi
    FilterOptions tempFilterOptions = currentFilters.clone();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bộ lọc sự kiện',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                tempFilterOptions.reset();
                              });
                            },
                            child: Text(
                              'Đặt lại',
                              style: TextStyle(
                                color: Colors.lime[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Hủy',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Filter options
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(16),
                    children: [
                      // Địa điểm
                      Text(
                        'Địa điểm',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: popularLocations.map((location) {
                          final bool isSelected =
                              tempFilterOptions.location == location;
                          return buildLocationFilterChip(
                            location,
                            isSelected,
                            (selected) {
                              setModalState(() {
                                tempFilterOptions.location =
                                    selected ? location : null;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 20),

                      // Trạng thái
                      Text(
                        'Trạng thái',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: statusOptions.map((status) {
                          final bool isSelected =
                              tempFilterOptions.status == status['value'];
                          return buildStatusFilterChip(
                            status,
                            isSelected,
                            (selected) {
                              setModalState(() {
                                tempFilterOptions.status =
                                    selected ? status['value'] : null;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 20),

                      // Thời gian
                      Text(
                        'Thời gian',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      tempFilterOptions.startDateFrom ??
                                          DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: Colors.lime[600]!,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setModalState(() {
                                    tempFilterOptions.startDateFrom = picked;
                                  });
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      tempFilterOptions.startDateFrom != null
                                          ? DateFormat('dd/MM/yyyy').format(
                                              tempFilterOptions.startDateFrom!)
                                          : 'Từ ngày',
                                      style: TextStyle(
                                        color:
                                            tempFilterOptions.startDateFrom !=
                                                    null
                                                ? Colors.black
                                                : Colors.grey[600],
                                      ),
                                    ),
                                    Icon(Icons.calendar_today,
                                        size: 18, color: Colors.grey[600]),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: tempFilterOptions.startDateTo ??
                                      DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: Colors.lime[600]!,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setModalState(() {
                                    tempFilterOptions.startDateTo = picked;
                                  });
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      tempFilterOptions.startDateTo != null
                                          ? DateFormat('dd/MM/yyyy').format(
                                              tempFilterOptions.startDateTo!)
                                          : 'Đến ngày',
                                      style: TextStyle(
                                        color: tempFilterOptions.startDateTo !=
                                                null
                                            ? Colors.black
                                            : Colors.grey[600],
                                      ),
                                    ),
                                    Icon(Icons.calendar_today,
                                        size: 18, color: Colors.grey[600]),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Sắp xếp
                      Text(
                        'Sắp xếp',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Column(
                        children: sortOptions.map((sort) {
                          return buildSortOptionRadio(
                            sort: sort,
                            groupValue: tempFilterOptions.sortBy,
                            onChanged: (value) {
                              setModalState(() {
                                tempFilterOptions.sortBy = value;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // Apply button
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      onApplyFilters(tempFilterOptions.clone());
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lime[600],
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Áp dụng bộ lọc',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
