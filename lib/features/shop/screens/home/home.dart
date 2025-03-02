import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

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
  List<PlatformFile> _selectedFiles = [];
  List<String> _fileUrls = [];
  final supabase = Supabase.instance.client;
  static const int _maxTotalFileSize = 4 * 1024 * 1024; // 4MB in bytes
  bool _isUploading = false;
  Map<String, double> _uploadProgress = {}; // Track upload progress for each file

  void _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'], // Allow only printable file types
        withData: true,
      );

      if (result != null) {
        // Calculate total size of selected files
        final totalSize = result.files.fold<int>(0, (sum, file) => sum + file.size);

        // Check if total size exceeds the 4MB limit
        if (totalSize > _maxTotalFileSize) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Total file size exceeds the 4MB limit")),
          );
          return;
        }

        // Filter out duplicate files
        final newFiles = result.files.where((file) => !_selectedFiles.any((f) => f.name == file.name)).toList();

        if (newFiles.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No new files to upload")),
          );
          return;
        }

        setState(() {
          _selectedFiles.addAll(newFiles);
        });

        // Upload all files concurrently
        await _uploadAllFiles(newFiles);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error selecting files. Please try again.")),
      );
      print("Error picking files: $e");
    }
  }

  Future<void> _uploadAllFiles(List<PlatformFile> files) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = {}; // Reset progress map
    });

    try {
      await Future.wait(files.map((file) async {
        if (file.path != null) {
          final uniqueFileName = _generateUniqueFileName(file.name);
          await _uploadFile(File(file.path!), uniqueFileName);
        }
      }));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  String _generateUniqueFileName(String originalName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(originalName);
    final nameWithoutExt = path.basenameWithoutExtension(originalName);
    final sanitizedName = nameWithoutExt.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    return '${sanitizedName}_${timestamp}$extension';
  }

  Future<void> _uploadFile(File file, String fileName) async {
    try {
      // Check if user is authenticated
      final user = supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please login to upload files")),
        );
        // Optionally navigate to login screen
        // Get.to(() => const LoginScreen());
        return;
      }

      // Upload to bucket
      await supabase.storage
          .from('Print Documents')
          .upload(
            'public/${user.id}/$fileName',  // Add user ID to path for better organization
            file,
            fileOptions: FileOptions(
              upsert: true,
              contentType: 'application/pdf',
            ),
          );

      String fileUrl = supabase.storage
          .from('Print Documents')
          .getPublicUrl('public/${user.id}/$fileName');

      setState(() {
        _fileUrls.add(fileUrl);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File uploaded successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
      print("Upload failed: $e");
    }
  }

  Future<void> _removeFile(int index) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Get the file URL that needs to be removed
      final fileUrl = _fileUrls[index];
      
      // Extract the file path from URL
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;
      final filePath = pathSegments.sublist(pathSegments.indexOf('public')).join('/');

      // Remove from Supabase storage
      await supabase.storage
          .from('Print Documents')
          .remove([filePath]);

      // Remove from local state
      setState(() {
        _selectedFiles.removeAt(index);
        _fileUrls.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File removed successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error removing file: $e")),
      );
    }
  }

  void _submitPrintRequest() {
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one file to print")),
      );
      return;
    }

    if (_printType.isEmpty || _colorMode.isEmpty || _copies <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please specify valid print preferences")),
      );
      return;
    }

    print("Print Type: $_printType");
    print("Color Mode: $_colorMode");
    print("Copies: $_copies");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Print request submitted!")),
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
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Iconsax.document_upload),
                        label: const Text("Choose Files"),
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
                              final progress = _uploadProgress[_generateUniqueFileName(file.name)] ?? 0.0;
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
                                      onPressed: _isUploading ? null : () => _removeFile(index),
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

            // Submit Button
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Iconsax.printer),
                label: const Text("Submit Print Request"),
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