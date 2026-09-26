import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:polio_guard/core/services/firebase_service.dart';

class AddWorkerScreen extends StatefulWidget {
  const AddWorkerScreen({super.key});

  @override
  State<AddWorkerScreen> createState() => _AddWorkerScreenState();
}

class _AddWorkerScreenState extends State<AddWorkerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _sectorController = TextEditingController();
  final _passwordController = TextEditingController();

  var _isLoading = false.obs;
  var _showPassword = false.obs;

  // Common password for all workers
  static const String commonPassword = 'Worker@123';

  final List<String> _availableSectors = [
    'F-8_Markaz',
    'F-8_1',
    'F-8_2',
    'F-8_3',
    'F-8_4',
  ];

  String? _selectedSector;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Worker'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      // ✅ ADD resizeToAvoidBottomInset (default is true, but explicit here)
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        // ✅ Wrap in SingleChildScrollView to prevent overflow
        child: SingleChildScrollView(
          // ✅ Add padding that accounts for keyboard
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 16.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
          ),
          child: Obx(() => Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter worker name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'worker@example.com',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Sector dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Assign Sector',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                  value: _selectedSector,
                  items: _availableSectors.map((sector) {
                    return DropdownMenuItem(
                      value: sector,
                      child: Text(sector),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSector = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a sector';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Default password for all workers: $commonPassword',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                _isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: _createWorker,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: const Text(
                      'Create Worker Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next, // ✅ Better UX with next button
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }

  Future<void> _createWorker() async {
    if (!_formKey.currentState!.validate()) return;

    _isLoading.value = true;

    final success = await Get.find<FirebaseService>().createWorkerAccount(
      email: _emailController.text.trim(),
      name: _nameController.text.trim(),
      sector: _selectedSector!,
      password: commonPassword,
    );

    _isLoading.value = false;

    if (success) {
      Get.snackbar(
        'Success',
        'Worker account created successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Clear form
      _nameController.clear();
      _emailController.clear();
      setState(() {
        _selectedSector = null;
      });

      // Navigate back after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        Get.back();
      });
    } else {
      Get.snackbar(
        'Error',
        'Failed to create worker account',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _sectorController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}