import 'package:asman_toga/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:asman_toga/models/banjar.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailOrPhoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FocusNode nameFocus = FocusNode();
  final FocusNode emailOrPhoneFocus = FocusNode();
  final FocusNode banjarFocus = FocusNode();

  List<Banjar> _banjars = [];
  Banjar? _selectedBanjar;
  bool _isLoading = false;
  bool _isBanjarLoading = true;
  late AnimationController _animationController;

  // Color palette
  static const Color primaryGreen = Color(0xFF57A32E);
  static const Color lightGreen = Color(0xFF7BC142);
  static const Color darkGreen = Color(0xFF3D7A1E);
  static const Color backgroundColor = Color(0xFFF8FAF6);
  static const Color cardColor = Colors.white;
  static const Color errorRed = Color(0xFFE53E3E);
  static const Color successGreen = Color(0xFF38A169);
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color inputBorder = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _loadBanjars();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailOrPhoneController.dispose();
    passwordController.dispose();
    nameFocus.dispose();
    emailOrPhoneFocus.dispose();
    banjarFocus.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadBanjars() async {
    try {
      final list = await ApiService.getAllBanjarModel();
      setState(() {
        _banjars = List<Banjar>.from(list);
        _isBanjarLoading = false;
      });
    } catch (e) {
      setState(() {
        _isBanjarLoading = false;
      });
      if (mounted) {
        _showErrorSnackBar('Gagal memuat data banjar: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: TextStyle(fontSize: 16, color: textPrimary),
          decoration: InputDecoration(
            hintText: hintText ?? label,
            hintStyle: TextStyle(
              color: textSecondary.withOpacity(0.6),
              fontSize: 14,
            ),
            prefixIcon: Container(
              margin: EdgeInsets.all(12),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: primaryGreen, size: 20),
            ),
            filled: true,
            fillColor: cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: inputBorder, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: inputBorder, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: primaryGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: errorRed, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: errorRed, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Banjar",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<Banjar>(
          focusNode: banjarFocus,
          decoration: InputDecoration(
            hintText: "Pilih Banjar",
            hintStyle: TextStyle(
              color: textSecondary.withOpacity(0.6),
              fontSize: 14,
            ),
            prefixIcon: Container(
              margin: EdgeInsets.all(12),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.location_city_rounded,
                color: primaryGreen,
                size: 20,
              ),
            ),
            filled: true,
            fillColor: cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: inputBorder, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: inputBorder, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: primaryGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: errorRed, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: errorRed, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          value: _selectedBanjar,
          items:
              _isBanjarLoading
                  ? []
                  : _banjars.map((banjar) {
                    return DropdownMenuItem(
                      value: banjar,
                      child: Text(
                        banjar.name,
                        style: TextStyle(fontSize: 16, color: textPrimary),
                      ),
                    );
                  }).toList(),
          onChanged:
              _isBanjarLoading
                  ? null
                  : (value) {
                    setState(() {
                      _selectedBanjar = value;
                    });
                  },
          validator: (value) {
            if (value == null) {
              return "Banjar harus dipilih";
            }
            return null;
          },
          icon:
              _isBanjarLoading
                  ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                    ),
                  )
                  : Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: primaryGreen,
                  ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient:
            _isLoading
                ? null
                : LinearGradient(
                  colors: [primaryGreen, lightGreen],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
        color: _isLoading ? textSecondary.withOpacity(0.3) : null,
        boxShadow:
            _isLoading
                ? []
                : [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: _isLoading ? null : _handleSubmit,
        child:
            _isLoading
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Menyimpan...",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Simpan User",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBanjar == null) {
      _showErrorSnackBar("Banjar harus dipilih");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.createUser(
        name: nameController.text.trim(),
        emailOrPhone: emailOrPhoneController.text.trim(),
        banjarId: _selectedBanjar!.id,
        role: "user",
      );

      if (result["success"] == true) {
        _showSuccessSnackBar("User berhasil dibuat");
        await Future.delayed(Duration(milliseconds: 1000));
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        _showErrorSnackBar("Gagal membuat user: ${result["message"]}");
      }
    } catch (e) {
      _showErrorSnackBar("Gagal membuat user: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        title: Text(
          "Tambah User Baru",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back_ios_rounded,
              color: primaryGreen,
              size: 16,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _animationController,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryGreen, lightGreen],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.person_add_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Buat Akun User",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Isi form di bawah untuk menambahkan user baru",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),

                  // Form Fields
                  _buildTextField(
                    controller: nameController,
                    focusNode: nameFocus,
                    label: "Nama Lengkap",
                    icon: Icons.person_outline_rounded,
                    hintText: "Masukkan nama lengkap",
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? "Nama wajib diisi"
                                : null,
                  ),
                  SizedBox(height: 24),

                  _buildTextField(
                    controller: emailOrPhoneController,
                    focusNode: emailOrPhoneFocus,
                    label: "Email atau Nomor HP",
                    icon: Icons.alternate_email_rounded,
                    hintText: "Masukkan email atau nomor HP",
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email atau nomor HP wajib diisi";
                      }

                      // regex email
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      // regex nomor hp (Indonesia 08 / +62 / 62)
                      final phoneRegex = RegExp(r'^(?:\+62|62|0)[0-9]{9,13}$');

                      if (!emailRegex.hasMatch(value) &&
                          !phoneRegex.hasMatch(value)) {
                        return "Harus berupa email valid atau nomor HP valid";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),

                  _buildDropdownField(),
                  SizedBox(height: 32),

                  // Submit Button
                  _buildSubmitButton(),
                  SizedBox(height: 16),

                  // Helper Text
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryGreen.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryGreen.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: primaryGreen,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "User akan mendapatkan akses untuk mengelola tanaman toga di banjar yang dipilih.",
                            style: TextStyle(
                              fontSize: 13,
                              color: textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
