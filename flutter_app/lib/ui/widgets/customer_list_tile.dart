import 'package:flutter/material.dart';
import 'package:flutter_app/env_config.dart';
import 'package:flutter_app/models/customer_model.dart';
import 'package:flutter_app/theme.dart';

class CustomerListTile extends StatelessWidget {
  final CustomerModel customer;
  final bool isDismissible;
  final Function(int)? onDelete;

  const CustomerListTile({
    super.key,
    required this.customer,
    this.isDismissible = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final content = ListTile(
      leading: _buildCustomerAvatar(customer.imagePath),
      title: Text(customer.name, style: theme.textTheme.bodyMedium),
    );

    if (!isDismissible) {
      return content;
    }

    return Dismissible(
      key: Key(customer.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Customer'),
            content: Text('Are you sure you want to delete ${customer.name}? All projects of this customer will be deleted too.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        if (onDelete != null) {
          onDelete!(customer.id);
        }
      },
      child: content,
    );
  }

  Widget _buildCustomerAvatar(String imagePath) {
    final imageUrl = '${EnvironmentConfig.apiFileURL}$imagePath';
    return SizedBox(
      width: 48,
      height: 48,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[200],
            child: const Icon(
              Icons.person,
              size: 24,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}