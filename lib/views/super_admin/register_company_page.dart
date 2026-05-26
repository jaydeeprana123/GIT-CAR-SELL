import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';

class RegisterCompanyPage extends StatefulWidget {
  const RegisterCompanyPage({super.key});

  @override
  State<RegisterCompanyPage> createState() => _RegisterCompanyPageState();
}

class _RegisterCompanyPageState extends State<RegisterCompanyPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _companyIdController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  DateTime _expiryDate = DateTime.now().add(const Duration(days: 365)); // Default 1 year
  String _purchaseScheme = 'offline'; // 'online' or 'offline'
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _companyIdController.dispose();
    _companyNameController.dispose();
    _ownerNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Pick subscription expiration date
  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      helpText: 'સબ્સ્ક્રિપ્શન સમાપ્તિ તારીખ પસંદ કરો'.tr,
      confirmText: 'નક્કી કરો'.tr,
      cancelText: 'રદ કરો'.tr,
    );
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  // Trigger registration
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.registerCompany(
        companyId: _companyIdController.text.trim().toUpperCase(),
        companyName: _companyNameController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        expiryDate: _expiryDate,
        purchaseScheme: _purchaseScheme,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('કંપની સફળતાપૂર્વક રજીસ્ટર થઈ ગઈ છે.'.tr)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '').tr),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('નવી કંપની રજીસ્ટ્રેશન'.tr),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'કંપની અને એડમિન વિગતો'.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'બધી વિગતો સાચી ભરો જેથી એડમિન લોગીન આઈડી બની શકે.'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                
                const SizedBox(height: 24),

                // Company ID Field
                TextFormField(
                  controller: _companyIdController,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration('કંપની ID (દા.ત. COMP001)'.tr, Icons.badge_outlined, theme),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'કૃપા કરીને કંપની ID દાખલ કરો'.tr;
                    }
                    if (value.trim().length < 3) {
                      return 'કંપની ID ઓછામાં ઓછો 3 અક્ષરનો હોવો જોઈએ'.tr;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Company Name Field
                TextFormField(
                  controller: _companyNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration('કંપનીનું નામ'.tr, Icons.business_rounded, theme),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'કૃપા કરીને કંપનીનું નામ દાખલ કરો'.tr;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Owner Name Field
                TextFormField(
                  controller: _ownerNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration('ઓનરનું નામ'.tr, Icons.person_outline_rounded, theme),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'કૃપા કરીને ઓનરનું નામ દાખલ કરો'.tr;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration('એડમિન ઇમેલ એડ્રેસ'.tr, Icons.email_outlined, theme),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'કૃપા કરીને ઇમેલ દાખલ કરો'.tr;
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                      return 'કૃપા કરીને સાચો ઇમેલ દાખલ કરો'.tr;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'એડમિન પાસવર્ડ'.tr,
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    prefixIcon: Icon(Icons.lock_outlined, color: theme.colorScheme.primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.redAccent),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                    ),
                    filled: true,
                    fillColor: theme.cardColor,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'કૃપા કરીને પાસવર્ડ દાખલ કરો'.tr;
                    }
                    if (value.trim().length < 6) {
                      return 'પાસવર્ડ ઓછામાં ઓછો 6 અક્ષરનો હોવો જોઈએ'.tr;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Purchase Scheme Selector
                Text(
                  'પર્ચેઝ સ્કીમ (Purchase Scheme)'.tr,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _purchaseScheme,
                      dropdownColor: theme.cardColor,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _purchaseScheme = newValue;
                          });
                        }
                      },
                      items: [
                        DropdownMenuItem(
                          value: 'offline',
                          child: Text('ઓફલાઇન (Offline)'.tr),
                        ),
                        DropdownMenuItem(
                          value: 'online',
                          child: Text('ઓનલાઇન (Online)'.tr),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Subscription Expiry Selector
                Text(
                  'સબ્સ્ક્રિપ્શન સમાપ્તિ તારીખ'.tr,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _isLoading ? null : _selectExpiryDate,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, color: theme.colorScheme.primary),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            DateFormat('dd-MM-yyyy (dd MMM yyyy)').format(_expiryDate),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.white.withOpacity(0.6)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'કંપની રજીસ્ટર કરો'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
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

  InputDecoration _buildInputDecoration(String label, IconData icon, ThemeData theme) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
      prefixIcon: Icon(icon, color: theme.colorScheme.primary),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      filled: true,
      fillColor: theme.cardColor,
    );
  }
}
