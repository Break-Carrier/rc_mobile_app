import 'package:flutter/material.dart';

class EventPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function() onPrevious;
  final Function() onNext;

  const EventPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNavigationButton(
            icon: Icons.chevron_left,
            onPressed: currentPage > 0 ? onPrevious : null,
          ),
          _buildPageIndicator(context),
          _buildNavigationButton(
            icon: Icons.chevron_right,
            onPressed: currentPage < totalPages - 1 ? onNext : null,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      icon: Icon(icon),
      iconSize: 20,
      splashRadius: 20,
      constraints: const BoxConstraints(
        minWidth: 32,
        minHeight: 32,
      ),
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        foregroundColor: Colors.grey[700],
        disabledForegroundColor: Colors.grey[400],
      ),
    );
  }

  Widget _buildPageIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${currentPage + 1} / $totalPages',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }
}
