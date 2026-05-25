import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class StaffManagementPage extends StatefulWidget {
  const StaffManagementPage({super.key});

  @override
  State<StaffManagementPage> createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends State<StaffManagementPage> {
  final AuthService _authService = AuthService();
  final _authController = Get.find<AuthController>();
  bool _isLoading = false;

  // Dialog controllers
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Stream of staff users for the current company
  Stream<List<UserModel>> _getStaffStream() {
    final companyId = _authController.localCompanyId.value;
    return FirebaseFirestore.instance
        .collection('users')
        .where('companyId', isEqualTo: companyId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .where((user) => user.role == 'staff' || user.role == 'Staff User')
          .toList();
    });
  }

  // Open add staff dialog
  void _showAddStaffDialog() {
    _nameController.clear();
    _mobileController.clear();
    _emailController.clear();
    _passwordController.clear();

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text('નવો સ્ટાફ ઉમેરો', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: _buildInputDecoration('સ્ટાફ નામ', Icons.person, theme),
                    validator: (v) => v!.trim().isEmpty ? 'સ્ટાફનું નામ દાખલ કરો' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: _buildInputDecoration('મોબાઇલ નંબર', Icons.phone, theme),
                    validator: (v) {
                      if (v!.trim().isEmpty) return 'મોબાઇલ નંબર દાખલ કરો';
                      if (v.trim().length < 10) return 'યોગ્ય નંબર દાખલ કરો';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _buildInputDecoration('ઇમેઇલ (યુઝરનેમ)', Icons.email, theme),
                    validator: (v) {
                      if (v!.trim().isEmpty) return 'ઇમેઇલ દાખલ કરો';
                      if (!v.contains('@')) return 'યોગ્ય ઇમેઇલ દાખલ કરો';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _buildInputDecoration('પાસવર્ડ', Icons.lock, theme),
                    validator: (v) => v!.trim().length < 6 ? 'પાસવર્ડ ઓછામાં ઓછો ૬ અક્ષરનો હોવો જોઈએ' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('રદ કરો', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(context);
                _registerStaffUser();
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary),
              child: const Text('ઉમેરો', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _registerStaffUser() async {
    setState(() => _isLoading = true);
    try {
      await _authService.registerStaff(
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        companyId: _authController.localCompanyId.value,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('સ્ટાફ યુઝર સફળતાપૂર્વક ઉમેરાયો છે.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('સ્ટાફ ઉમેરવામાં ભૂલ આવી: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Open edit staff details dialog
  void _showEditStaffDialog(UserModel staff) {
    _nameController.text = staff.staffName ?? '';
    _mobileController.text = staff.mobileNumber ?? '';

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text('વિગતો સુધારો', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration('સ્ટાફ નામ', Icons.person, theme),
                  validator: (v) => v!.trim().isEmpty ? 'સ્ટાફનું નામ દાખલ કરો' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: _buildInputDecoration('મોબાઇલ નંબર', Icons.phone, theme),
                  validator: (v) => v!.trim().isEmpty ? 'મોબાઇલ નંબર દાખલ કરો' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('રદ કરો', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(context);
                _updateStaffDetails(staff.uid);
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary),
              child: const Text('સાચવો', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateStaffDetails(String uid) async {
    setState(() => _isLoading = true);
    try {
      await _authService.updateStaffDetails(
        uid: uid,
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('સ્ટાફ વિગતો સફળતાપૂર્વક અપડેટ કરાઈ.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('અપડેટ કરવામાં ભૂલ આવી: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Open reset password dialog
  void _showResetPasswordDialog(UserModel staff) {
    _passwordController.clear();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text('પાસવર્ડ બદલો', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'યુઝર: ${staff.email}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _buildInputDecoration('નવો પાસવર્ડ', Icons.lock, theme),
                  validator: (v) => v!.trim().length < 6 ? 'પાસવર્ડ ઓછામાં ઓછો ૬ અક્ષરનો હોવો જોઈએ' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('રદ કરો', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(context);
                _resetStaffPassword(staff);
              },
              style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary),
              child: const Text('બદલો', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetStaffPassword(UserModel staff) async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch current stored password from Firestore staff document
      final doc = await FirebaseFirestore.instance.collection('users').doc(staff.uid).get();
      final oldPassword = doc.data()?['password'] as String? ?? '';

      if (oldPassword.isEmpty) {
        throw Exception('જુનો પાસવર્ડ ડેટાબેઝમાં મળ્યો નથી. પાસવર્ડ રીસેટ કરવા માટે કૃપા કરીને આ સ્ટાફને ડીલીટ કરી નવો બનાવો.');
      }

      await _authService.updateStaffPassword(
        uid: staff.uid,
        email: staff.email,
        oldPassword: oldPassword,
        newPassword: _passwordController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('સ્ટાફ પાસવર્ડ સફળતાપૂર્વક બદલાઈ ગયો છે.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('પાસવર્ડ બદલવામાં ભૂલ આવી: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Toggle staff active/inactive status
  Future<void> _toggleStaffActive(UserModel staff, bool isActive) async {
    setState(() => _isLoading = true);
    try {
      await _authService.toggleStaffActiveStatus(staff.uid, isActive);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isActive ? 'સ્ટાફ સફળતાપૂર્વક સક્રિય કરાયો.' : 'સ્ટાફ સફળતાપૂર્વક નિષ્ક્રિય કરાયો.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('સ્ટેટસ બદલવામાં ભૂલ આવી: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('સ્ટાફ મેનેજમેન્ટ'),
      ),
      body: Stack(
        children: [
          StreamBuilder<List<UserModel>>(
            stream: _getStaffStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('ભૂલ આવી: ${snapshot.error}'));
              }

              final staffList = snapshot.data ?? [];
              if (staffList.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: staffList.length,
                itemBuilder: (context, index) {
                  final staff = staffList[index];
                  return _buildStaffCard(staff, theme);
                },
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStaffDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('નવો સ્ટાફ ઉમેરો', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildStaffCard(UserModel staff, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: staff.isActive
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.redAccent.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Status Icon/Avatar
            CircleAvatar(
              backgroundColor: staff.isActive
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : Colors.redAccent.withOpacity(0.1),
              radius: 24,
              child: Icon(
                Icons.person,
                color: staff.isActive ? theme.colorScheme.primary : Colors.redAccent,
              ),
            ),
            const SizedBox(width: 14),
            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff.staffName ?? 'સ્ટાફ મેમ્બર',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    staff.email,
                    style: TextStyle(fontSize: 12, color: theme.hintColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'M: ${staff.mobileNumber ?? 'N/A'}',
                    style: TextStyle(fontSize: 12, color: theme.hintColor),
                  ),
                ],
              ),
            ),
            // Actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: 'સુધારો',
                      onPressed: () => _showEditStaffDialog(staff),
                    ),
                    IconButton(
                      icon: const Icon(Icons.vpn_key_outlined, size: 20),
                      tooltip: 'પાસવર્ડ બદલો',
                      onPressed: () => _showResetPasswordDialog(staff),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      staff.isActive ? 'એક્ટિવ' : 'ડીએક્ટિવ',
                      style: TextStyle(
                        fontSize: 11,
                        color: staff.isActive ? theme.colorScheme.primary : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Switch(
                      value: staff.isActive,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (val) => _toggleStaffActive(staff, val),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 70, color: Colors.grey.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text(
            'કોઈ સ્ટાફ મેમ્બર મળ્યો નથી',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          const Text(
            'નવો સ્ટાફ યુઝર ઉમેરવા માટે નીચેના બટન પર ક્લિક કરો.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, ThemeData theme) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
    );
  }
}
