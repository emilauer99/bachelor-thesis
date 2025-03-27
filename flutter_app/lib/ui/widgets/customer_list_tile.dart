import 'package:flutter/material.dart';
import 'package:flutter_app/env_config.dart';
import 'package:flutter_app/models/customer_model.dart';

class CustomerListTile extends StatelessWidget {
  final CustomerModel customer;

  const CustomerListTile({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildCustomerAvatar(customer.imagePath),
      title: Text(customer.name),
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