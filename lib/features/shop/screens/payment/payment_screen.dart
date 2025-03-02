import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/constants/sizes.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final List<String> fileNames;
  final String printType;
  final String colorMode;
  final int copies;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.fileNames,
    required this.printType,
    required this.colorMode,
    required this.copies,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'upi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        centerTitle: true,
        backgroundColor: TColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Order Summary",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    ...widget.fileNames.map((fileName) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(fileName),
                    )),
                    const Divider(),
                    _buildSummaryRow("Print Type", widget.printType == 'single' ? 'Single Side' : 'Double Side'),
                    _buildSummaryRow("Color Mode", widget.colorMode == 'bw' ? 'Black & White' : 'Colored'),
                    _buildSummaryRow("Copies", widget.copies.toString()),
                    const Divider(),
                    _buildSummaryRow("Total Amount", "₹${widget.amount.toStringAsFixed(2)}", isBold: true),
                  ],
                ),
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Payment Methods
            const Text(
              "Payment Method",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // UPI Option
            _buildPaymentOption(
              'upi',
              'UPI Payment',
              'Pay using any UPI app',
              Iconsax.mobile,
            ),

            // Cash Option
            _buildPaymentOption(
              'cash',
              'Cash Payment',
              'Pay at counter',
              Iconsax.money,
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Pay Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () => _processPayment(),
                child: Text(
                  "Pay ₹${widget.amount.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String value, String title, String subtitle, IconData icon) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _selectedPaymentMethod == value ? TColors.primary : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: RadioListTile(
        value: value,
        groupValue: _selectedPaymentMethod,
        onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
        title: Text(title),
        subtitle: Text(subtitle),
        secondary: Icon(icon, color: TColors.primary),
      ),
    );
  }

  void _processPayment() {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Remove loading indicator

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Payment Successful"),
          content: const Text("Your print job has been queued successfully."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Get.back(); // Return to home screen
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    });
  }
} 