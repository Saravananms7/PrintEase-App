import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:t_store/features/shop/screens/payment/payment_screen.dart';
import 'package:pdf_render/pdf_render.dart';
// Remove these imports as they don't exist in the project dependencies
// import 'package:syncfusion_flutter_pdf/syncfusion_flutter_pdf.dart';
// import 'package:syncfusion_flutter_docx/syncfusion_flutter_docx.dart'; 
// import 'package:docx_to_text/docx_to_text.dart';
import 'dart:math' show max;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _printType = "single";
  String _colorMode = "bw";
  int _copies = 1;
  int _queueNumber = 5;
  List<LocalFile> _selectedFiles = [];
  final supabase = Supabase.instance.client;
  static const int _maxTotalFileSize = 4 * 1024 * 1024; // 4MB in bytes
  bool _isUploading = false;
  Map<String, double> _uploadProgress = {};
  static const double PRICE_PER_PAGE_BW = 2.0;
  static const double PRICE_PER_PAGE_COLOR = 5.0;
  static const double DOUBLE_SIDED_DISCOUNT = 0.8; // 20% discount for double-sided
  double _estimatedCost = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSavedFiles();
  }

  Future<void> _loadSavedFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filesDir = Directory('${directory.path}/selected_files');
      if (await filesDir.exists()) {
        final files = await filesDir.list().toList();
        setState(() {
          _selectedFiles = files
              .whereType<File>()
              .map((file) => LocalFile(
                    file: file,
                    name: path.basename(file.path),
                    size: file.lengthSync(),
                  ))
              .toList();
        });
      }
    } catch (e) {
      print('Error loading saved files: $e');
    }
  }

  Future<void> _saveFileLocally(PlatformFile platformFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filesDir = Directory('${directory.path}/selected_files');
      if (!await filesDir.exists()) {
        await filesDir.create(recursive: true);
      }

      final file = File(platformFile.path!);
      final savedFile = await file.copy('${filesDir.path}/${platformFile.name}');

      final localFile = LocalFile(
        file: savedFile,
        name: platformFile.name,
        size: platformFile.size,
      );

      setState(() {
        _selectedFiles.add(localFile);
      });

      // Calculate page count after adding file
      await _updateFilePageCount(localFile);
    } catch (e) {
      print('Error saving file locally: $e');
      rethrow;
    }
  }

  void _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null) {
        final totalSize = result.files.fold<int>(
            0, (sum, file) => sum + file.size + _getTotalSelectedFilesSize());

        if (totalSize > _maxTotalFileSize) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Total file size exceeds the 4MB limit")),
          );
          return;
        }

        for (var file in result.files) {
          if (!_selectedFiles.any((f) => f.name == file.name)) {
            await _saveFileLocally(file);
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error selecting files: $e")),
      );
    }
  }

  int _getTotalSelectedFilesSize() {
    return _selectedFiles.fold<int>(0, (sum, file) => sum + file.size);
  }

  Future<void> _removeFile(LocalFile file) async {
    try {
      // Delete from local storage
      await file.file.delete();
      
      // If file was uploaded to Supabase, delete it there too
      if (file.uploadedPath != null) {
        await supabase.storage
            .from('Print Documents')
            .remove([file.uploadedPath!]);
      }

      setState(() {
        _selectedFiles.remove(file);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error removing file: $e")),
      );
    }
  }

  Future<bool> _uploadAllFiles() async {
    if (_selectedFiles.isEmpty) return true;

    setState(() {
      _isUploading = true;
      _uploadProgress = {};
    });

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      for (var file in _selectedFiles) {
        if (file.uploadedPath != null) continue; // Skip already uploaded files

        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        final filePath = 'public/${user.id}/$fileName';

        await supabase.storage
            .from('Print Documents')
            .upload(
              filePath,
              file.file,
              fileOptions: FileOptions(
                contentType: _getContentType(file.name),
                upsert: true,
              ),
            );

        file.uploadedPath = filePath;
        setState(() {
          _uploadProgress[file.name] = 100;
        });
      }

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
      return false;
    } finally {
      setState(() => _isUploading = false);
    }
  }

  String _getContentType(String fileName) {
    return 'application/pdf';
  }

  Future<void> _submitPrintRequest() async {
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one file to print")),
      );
      return;
    }

    // Show upload progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildUploadProgressDialog(),
    );

    // Upload files
    final uploadSuccess = await _uploadAllFiles();
    Navigator.pop(context); // Close progress dialog

    if (!uploadSuccess) return;

    // Calculate total amount
    double basePrice = _colorMode == 'bw' ? 2.0 : 5.0;
    if (_printType == 'double') basePrice *= 1.5;
    double totalAmount = basePrice * _copies * _selectedFiles.length;

    // Navigate to payment screen
    Get.to(() => PaymentScreen(
          amount: totalAmount,
          fileNames: _selectedFiles.map((file) => file.name).toList(),
          printType: _printType,
          colorMode: _colorMode,
          copies: _copies,
        ));
  }

  Widget _buildUploadProgressDialog() {
    return AlertDialog(
      title: const Text("Uploading Files"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text("Uploading ${_selectedFiles.length} files..."),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Print Management"),
        centerTitle: true,
        backgroundColor: TColors.primary,
        automaticallyImplyLeading: true,
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload Document Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Upload Documents",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Supported format: PDF only",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Iconsax.document_upload, color: Colors.white),
                        label: const Text("Choose PDF Files"),
                        onPressed: _isUploading ? null : _pickFiles,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_selectedFiles.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Selected Files:",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          ...List.generate(
                            _selectedFiles.length,
                            (index) {
                              final file = _selectedFiles[index];
                              final progress = _uploadProgress[file.name] ?? 0.0;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${index + 1}. ${file.name}",
                                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                                          ),
                                          if (_isUploading)
                                            LinearProgressIndicator(
                                              value: progress / 100,
                                              backgroundColor: Colors.grey[300],
                                              valueColor: const AlwaysStoppedAnimation<Color>(TColors.primary),
                                            ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.red, size: 20),
                                      onPressed: _isUploading ? null : () => _removeFile(file),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Print Preferences Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Print Preferences",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    PreferenceDropdown<String>(
                      label: "Paper Sides:",
                      value: _printType,
                      items: const [
                        DropdownMenuItem(value: "single", child: Text("Single Side")),
                        DropdownMenuItem(value: "double", child: Text("Double Side")),
                      ],
                      onChanged: (value) => setState(() => _printType = value!),
                    ),

                    const Divider(),

                    PreferenceDropdown<String>(
                      label: "Print Mode:",
                      value: _colorMode,
                      items: const [
                        DropdownMenuItem(value: "bw", child: Text("Black & White")),
                        DropdownMenuItem(value: "color", child: Text("Colored")),
                      ],
                      onChanged: (value) => setState(() => _colorMode = value!),
                    ),

                    const Divider(),

                    PreferenceDropdown<int>(
                      label: "No. of Copies:",
                      value: _copies,
                      items: List.generate(5, (index) => index + 1)
                          .map((e) => DropdownMenuItem(value: e, child: Text("$e")))
                          .toList(),
                      onChanged: (value) => setState(() => _copies = value!),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Queue Number Display
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Current Queue Number: #$_queueNumber",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Cost Estimation Card
            if (_selectedFiles.isNotEmpty)
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Cost Estimation",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      _buildCostBreakdown(),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Estimated Total:",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "₹${_estimatedCost.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: TColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // Submit Button
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Iconsax.money, color: Colors.white),
                label: const Text("Proceed to Pay"),
                onPressed: _isUploading ? null : _submitPrintRequest,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: TColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Build the Side Drawer
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: TColors.primary,
            ),
            child: Text(
              "PrintEase",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Iconsax.code),
            title: const Text("Report Bugs"),
            onTap: () {
              // TODO: Navigate to report bugs screen
            },
          ),
          ListTile(
            leading: const Icon(Iconsax.info_circle),
            title: const Text("App Version"),
            subtitle: const Text("1.0.0"), // Replace with dynamic version if needed
            onTap: () {
              // TODO: Show app version dialog
            },
          ),
          ListTile(
            leading: const Icon(Iconsax.info_circle),
            title: const Text("About"),
            onTap: () {
              // TODO: Navigate to about screen
            },
          ),
        ],
      ),
    );
  }

  Future<int> _getPageCount(LocalFile file) async {
    try {
      if (!file.name.toLowerCase().endsWith('.pdf')) {
        throw UnsupportedError('Only PDF files are supported');
      }

      final document = await PdfDocument.openFile(file.file.path);
      final pageCount = await document.pageCount;
      document.dispose();
      return pageCount;
    } catch (e) {
      print('Error getting page count: $e');
      // Fallback to size-based estimation
      return _estimatePagesByFileSize(file.size);
    }
  }

  int _estimatePagesByFileSize(int fileSize) {
    // Average PDF page is about 100KB
    const averagePageSize = 100 * 1024; // 100KB in bytes
    return max(1, (fileSize / averagePageSize).ceil());
  }

  Future<void> _updateFilePageCount(LocalFile file) async {
    if (file.pageCount == null) {
      final pages = await _getPageCount(file);
      setState(() {
        file.pageCount = pages;
      });
      await _calculateEstimatedCost();
    }
  }

  Future<void> _calculateEstimatedCost() async {
    double totalCost = 0.0;
    final basePrice = _colorMode == 'bw' ? PRICE_PER_PAGE_BW : PRICE_PER_PAGE_COLOR;
    final doubleSidedMultiplier = _printType == 'double' ? DOUBLE_SIDED_DISCOUNT : 1.0;

    for (var file in _selectedFiles) {
      if (file.pageCount == null) {
        await _updateFilePageCount(file);
      }
      
      final effectivePages = (file.pageCount ?? 1).toDouble();
      totalCost += effectivePages * basePrice * doubleSidedMultiplier;
    }

    totalCost *= _copies;

    setState(() {
      _estimatedCost = totalCost;
    });
  }

  Widget _buildCostBreakdown() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Print Mode:"),
            Text(_colorMode == 'bw' ? "Black & White (₹$PRICE_PER_PAGE_BW/page)" : "Color (₹$PRICE_PER_PAGE_COLOR/page)"),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Print Type:"),
            Text(_printType == 'double' 
              ? "Double-sided (${(DOUBLE_SIDED_DISCOUNT * 100).toInt()}% discount)" 
              : "Single-sided"),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Number of Copies:"),
            Text("$_copies"),
          ],
        ),
        const SizedBox(height: 4),
        ..._selectedFiles.map((file) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  file.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(file.pageCount != null ? "${file.pageCount} pages" : "Calculating..."),
            ],
          ),
        )),
      ],
    );
  }
}

class PreferenceDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const PreferenceDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class LocalFile {
  final File file;
  final String name;
  final int size;
  String? uploadedPath;
  int? pageCount;

  LocalFile({
    required this.file,
    required this.name,
    required this.size,
    this.uploadedPath,
    this.pageCount,
  });
}