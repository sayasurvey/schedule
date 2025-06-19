import 'package:flutter/material.dart';

class CustomerHeader extends StatelessWidget {
  final List<String> customers;

  const CustomerHeader({
    super.key,
    required this.customers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
          ...customers.map((customer) {
            return Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Center(
                  child: Text(
                    customer,
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}