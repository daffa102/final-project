import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../../pos/providers/pos_provider.dart';
import 'map_picker_screen.dart';

class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _footerController = TextEditingController();
  
  String? _imagePath;
  XFile? _imageFile;
  String? _qrisPath;
  XFile? _qrisFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchStoreData();
  }

  Future<void> _fetchStoreData() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<PosProvider>().apiService;
      final response = await api.client.get('/store');
      
      if (response.statusCode == 200) {
        final data = response.data['data'];
        _nameController.text = data['store_name'] ?? '';
        _addressController.text = data['address'] ?? '';
        _phoneController.text = data['phone_number'] ?? '';
        _footerController.text = data['receipt_footer'] ?? '';
        _imagePath = data['logo_url'];
        _qrisPath = data['qris_url'];
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat data toko: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
        _imagePath = image.path;
      });
    }
  }

  Future<void> _pickQrisImage() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _qrisFile = image;
        _qrisPath = image.path;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final api = context.read<PosProvider>().apiService;
      
      final Map<String, dynamic> data = {
        'store_name': _nameController.text,
        'address': _addressController.text,
        'phone_number': _phoneController.text,
        'receipt_footer': _footerController.text,
      };

      if (_imageFile != null) {
        data['logo_bytes'] = await _imageFile!.readAsBytes();
        data['logo_name'] = _imageFile!.name;
      }

      if (_qrisFile != null) {
        data['qris_bytes'] = await _qrisFile!.readAsBytes();
        data['qris_name'] = _qrisFile!.name;
      }

      final response = await api.client.post('/store', data: data);

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengaturan toko berhasil disimpan!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan pengaturan: $e'), behavior: SnackBarBehavior.floating));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const MapPickerScreen()),
    );
    
    if (result != null && mounted) {
      setState(() {
        _addressController.text = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black87, size: 20),
                  ),
                  Text(
                    'Pengaturan Toko',
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18.sp, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                  ),
                  const Spacer(),
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2938) : Colors.white, 
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
                    ),
                    child: Icon(Icons.storefront, color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFBEF364)))
                  : SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 10.h),
                            
                            // Store Logo Picker
                            Center(
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 100.r,
                                  height: 100.r,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E2938) : Colors.black.withValues(alpha: 0.02),
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(color: isDark ? const Color(0xFF364152) : Colors.black.withValues(alpha: 0.05)),
                                  ),
                                  child: _imagePath != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(20.r),
                                          child: _buildLogoPreview(_imagePath!, isDark),
                                        )
                                      : Icon(Icons.add_a_photo_outlined, color: const Color(0xFFBEF364), size: 32.r),
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),

                            _buildSectionHeader('Informasi Identitas Toko'),
                            SizedBox(height: 16.h),
                            
                            _buildTextField(_nameController, 'Nama Toko', Icons.store_outlined, isDark, required: true),
                            SizedBox(height: 16.h),
                            
                            // Address with Map Pick
                            Stack(
                              children: [
                                _buildTextField(_addressController, 'Alamat Toko', Icons.location_on_outlined, isDark, maxLines: 2),
                                Positioned(
                                  right: 12.w,
                                  top: 12.h,
                                  child: GestureDetector(
                                    onTap: _pickLocation,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFBEF364),
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.map_outlined, size: 14.r, color: const Color(0xFF111727)),
                                          SizedBox(width: 4.w),
                                          Text('MAP', style: TextStyle(color: const Color(0xFF111727), fontSize: 10.sp, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            _buildTextField(_phoneController, 'Nomor WhatsApp', Icons.phone_outlined, isDark, keyboardType: TextInputType.phone),
                            
                            SizedBox(height: 32.h),
                            _buildSectionHeader('Pengaturan Struk'),
                            SizedBox(height: 16.h),
                            _buildTextField(_footerController, 'Catatan Kaki Struk', Icons.edit_note_outlined, isDark, hint: 'Terima Kasih, Selamat Datang Kembali'),
                            
                            SizedBox(height: 32.h),
                            _buildSectionHeader('QRIS Toko'),
                            SizedBox(height: 16.h),
                            GestureDetector(
                              onTap: _pickQrisImage,
                              child: Container(
                                height: 160.h,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E2938) : Colors.black.withValues(alpha: 0.02),
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(color: isDark ? const Color(0xFF364152) : Colors.black.withValues(alpha: 0.05)),
                                ),
                                child: _qrisPath != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(16.r),
                                        child: Center(
                                          child: _buildQrisPreview(_qrisPath!, isDark),
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.qr_code_scanner, color: const Color(0xFFBEF364), size: 40.r),
                                          SizedBox(height: 8.h),
                                          Text('Upload QRIS Toko Anda', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13.sp, fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                              ),
                            ),

                            SizedBox(height: 32.h),
                            _buildSectionHeader('Sistem & Sinkronisasi'),
                            SizedBox(height: 16.h),
                            _buildDropdownField(isDark),
                            
                            SizedBox(height: 48.h),
                            GestureDetector(
                              onTap: _isLoading ? null : _saveSettings,
                              child: Container(
                                height: 56.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBEF364),
                                  borderRadius: BorderRadius.circular(16.r),
                                  boxShadow: [
                                    BoxShadow(color: const Color(0xFFBEF364).withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 5))
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'SIMPAN PERUBAHAN',
                                    style: TextStyle(color: const Color(0xFF111727), fontSize: 16.sp, fontWeight: FontWeight.bold, letterSpacing: 1),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoPreview(String path, bool isDark) {
    if (kIsWeb && path.startsWith('blob:')) {
      return Image.network(path, fit: BoxFit.cover);
    }

    final pos = context.read<PosProvider>();
    final url = pos.apiService.resolveImageUrl(path);
    
    return Image.network(
      url, 
      fit: BoxFit.cover, 
      errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image, color: isDark ? Colors.white10 : Colors.black12)
    );
  }

  Widget _buildQrisPreview(String path, bool isDark) {
    if (kIsWeb && path.startsWith('blob:')) {
      return Image.network(path, fit: BoxFit.contain);
    }

    final pos = context.read<PosProvider>();
    final url = pos.apiService.resolveImageUrl(path);
    
    return Image.network(
      url, 
      fit: BoxFit.contain, 
      errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image, color: isDark ? Colors.white10 : Colors.black12)
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFBEF364).withValues(alpha: 0.7),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isDark, {bool required = false, TextInputType? keyboardType, String? hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13.sp, fontWeight: FontWeight.w500)),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: required ? (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null : null,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 14.sp),
            prefixIcon: Icon(icon, color: const Color(0xFFBEF364), size: 20.r),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E2938) : Colors.black.withValues(alpha: 0.02),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: isDark ? const Color(0xFF364152) : Colors.black.withValues(alpha: 0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFBEF364)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Frekuensi Refresh Data', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13.sp, fontWeight: FontWeight.w500)),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          initialValue: '1_hour',
          dropdownColor: isDark ? const Color(0xFF1E2938) : Colors.white,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.sync, color: Color(0xFFBEF364)),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E2938) : Colors.black.withValues(alpha: 0.02),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: isDark ? const Color(0xFF364152) : Colors.black.withValues(alpha: 0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFBEF364)),
            ),
          ),
          items: const [
            DropdownMenuItem(value: '1_hour', child: Text('Setiap 1 Jam')),
            DropdownMenuItem(value: '6_hours', child: Text('Setiap 6 Jam')),
            DropdownMenuItem(value: 'daily', child: Text('Setiap Hari')),
            DropdownMenuItem(value: 'manual', child: Text('Manual Saja')),
          ],
          onChanged: (val) {},
        ),
      ],
    );
  }
}
