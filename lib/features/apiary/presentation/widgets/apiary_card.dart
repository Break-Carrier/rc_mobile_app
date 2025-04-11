import 'package:flutter/material.dart';
import '../../../../models/apiary.dart';

/// Widget pour afficher un rucher sous forme de carte
class ApiaryCard extends StatelessWidget {
  final Apiary apiary;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ApiaryCard({
    super.key,
    required this.apiary,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            _buildHeader(context),
            _buildBody(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Get image URL from metadata if available
    final String? imageUrl = apiary.metadata?['imageUrl'] as String?;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        image: imageUrl != null
            ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
              )
            : null,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.centerLeft,
              child: Text(
                apiary.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (onEdit != null || onDelete != null)
            Positioned(
              top: 4,
              right: 4,
              child: Row(
                children: [
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: onEdit,
                      tooltip: 'Modifier',
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: onDelete,
                      tooltip: 'Supprimer',
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (apiary.location != null) ...[
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    apiary.location,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (apiary.description != null) ...[
            Text(
              apiary.description!,
              style: const TextStyle(
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Icon(
                Icons.hive,
                size: 16,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                '${apiary.hiveIds.length} ruches',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
        ],
      ),
    );
  }
}
