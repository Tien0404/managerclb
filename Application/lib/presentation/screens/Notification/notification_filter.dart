import 'package:flutter/material.dart';

class NotificationFilter extends StatelessWidget {
  final String currentFilter;
  final Function(String) onFilterChanged;
  final List<FilterOption> filterOptions;

  const NotificationFilter({
    Key? key,
    required this.currentFilter,
    required this.onFilterChanged,
    this.filterOptions = const [
      FilterOption('all', 'Tất cả', Icons.notifications),
      FilterOption('event', 'Sự kiện', Icons.event),
      FilterOption('blog', 'Bài viết', Icons.article),
      FilterOption('club', 'CLB', Icons.people),
      FilterOption('promotion', 'Ưu đãi', Icons.local_offer),
      FilterOption('system', 'Hệ thống', Icons.settings),
    ],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lọc thông báo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filterOptions
                .map((option) => _buildFilterOption(context, option))
                .toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFilterOption(BuildContext context, FilterOption option) {
    final isSelected = currentFilter == option.value;

    return InkWell(
      onTap: () => onFilterChanged(option.value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              option.icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(width: 8),
            Text(
              option.label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[800],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterOption {
  final String value;
  final String label;
  final IconData icon;

  const FilterOption(this.value, this.label, this.icon);
}
