import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:amazon_syria/core/theme/app_theme.dart';
import 'package:amazon_syria/features/auth/presentation/providers/auth_provider.dart';
import 'package:amazon_syria/features/products/domain/entities/product_entity.dart';
import 'package:amazon_syria/features/products/presentation/providers/product_provider.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _isSubmitting = false;
  bool _isValidImageUrl = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _onImageUrlChanged(String url) {
    final isValid = url.startsWith('http://') || url.startsWith('https://');
    if (isValid != _isValidImageUrl) {
      setState(() => _isValidImageUrl = isValid);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = context.read<AuthProvider>().currentUser!;
      final productProvider = context.read<ProductProvider>();

      final product = ProductEntity(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: _priceController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        supplierId: user.id,
        supplierName: user.name,
        createdAt: DateTime.now(),
      );

      await productProvider.addProduct(product);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تمت إضافة المنتج بنجاح',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/');
      }
    } catch (e, stackTrace) {
      debugPrint('Add product error: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطأ: $e',
              style: const TextStyle(fontFamily: 'Tajawal'),
            ),
            duration: const Duration(seconds: 10),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إضافة منتج'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImageUrlSection(),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _titleController,
                  label: 'اسم المنتج',
                  hint: 'أدخل اسم المنتج',
                  icon: Icons.shopping_bag_outlined,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'اسم المنتج مطلوب' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'وصف المنتج',
                  hint: 'أدخل وصف المنتج',
                  icon: Icons.description_outlined,
                  maxLines: 4,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'وصف المنتج مطلوب' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _priceController,
                  label: 'السعر (ل.س)',
                  hint: 'أدخل سعر المنتج',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.text,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'السعر مطلوب' : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'إضافة منتج',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageUrlSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _imageUrlController,
          textDirection: TextDirection.ltr,
          onChanged: _onImageUrlChanged,
          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 14),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'رابط الصورة مطلوب';
            if (!v.startsWith('http://') && !v.startsWith('https://')) {
              return 'الرجاء إدخال رابط صحيح يبدأ بـ http';
            }
            return null;
          },
          decoration: const InputDecoration(
            labelText: 'رابط صورة المنتج',
            hintText: 'https://example.com/image.jpg',
            hintTextDirection: TextDirection.ltr,
            prefixIcon: Icon(Icons.link),
          ),
        ),
        const SizedBox(height: 12),
        if (_isValidImageUrl)
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            clipBehavior: Clip.antiAlias,
            child: CachedNetworkImage(
              imageUrl: _imageUrlController.text.trim(),
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (_, _) => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              errorWidget: (_, _, _) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image_outlined,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    'لا يمكن تحميل الصورة',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 56,
                  color: AppTheme.primaryColor.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 12),
                Text(
                  'أدخل رابط الصورة أعلاه لمعاينتها',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 15,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textDirection: TextDirection.rtl,
      style: const TextStyle(fontFamily: 'Tajawal'),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}
