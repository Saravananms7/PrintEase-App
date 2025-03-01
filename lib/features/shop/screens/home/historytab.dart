import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/constants/sizes.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Print History"),
        centerTitle: true,
        backgroundColor: TColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: historyList.isEmpty
            ? const Center(
                child: Text(
                  "No print history available.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : ListView(
                children: [
                  const Text(
                    "Your Past Print Requests",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  // Display history cards
                  ...historyList.map((history) => _buildHistoryCard(
                        docName: history.docName,
                        date: history.date,
                        copies: history.copies,
                        printType: history.printType,
                        colorMode: history.colorMode,
                        status: history.status,
                      )),
                ],
              ),
      ),
    );
  }

  // Function to create a styled history card
  Widget _buildHistoryCard({
    required String docName,
    required String date,
    required int copies,
    required String printType,
    required String colorMode,
    required String status,
  }) {
    Color statusColor = _getStatusColor(status);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
      child: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Document Name & Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  docName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),

            const Divider(),

            // Print Details
            Wrap(
              spacing: TSizes.spaceBtwItems,
              children: [
                _buildInfoRow(Iconsax.copy, "$copies Copies"),
                _buildInfoRow(Iconsax.paperclip, printType),
                _buildInfoRow(Iconsax.paintbucket, colorMode),
              ],
            ),

            const Divider(),

            // Print Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Status:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(
                    status,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: statusColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for icon + text rows
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade700),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: Colors.grey.shade800)),
      ],
    );
  }

  // Function to determine status color
  Color _getStatusColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green;
      case "Pending":
        return Colors.orange;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// PrintHistory model
class PrintHistory {
  final String docName;
  final String date;
  final int copies;
  final String printType;
  final String colorMode;
  final String status;

  PrintHistory({
    required this.docName,
    required this.date,
    required this.copies,
    required this.printType,
    required this.colorMode,
    required this.status,
  });
}

// Sample data
final List<PrintHistory> historyList = [
  PrintHistory(
    docName: "Report.pdf",
    date: "Feb 16, 2025",
    copies: 3,
    printType: "Double-Sided",
    colorMode: "Color",
    status: "Completed",
  ),
  PrintHistory(
    docName: "Assignment.docx",
    date: "Feb 14, 2025",
    copies: 1,
    printType: "Single-Sided",
    colorMode: "B & W",
    status: "Cancelled",
  ),
  PrintHistory(
    docName: "Presentation.ppt",
    date: "Feb 10, 2025",
    copies: 2,
    printType: "Double-Sided",
    colorMode: "Color",
    status: "Pending",
  ),
];