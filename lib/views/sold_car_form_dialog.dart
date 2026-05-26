import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/car_report.dart';
import '../controllers/car_report_controller.dart';

class SoldCarFormDialog extends StatefulWidget {
  final CarReport? car; // If null, manual entry

  const SoldCarFormDialog({super.key, this.car});

  @override
  State<SoldCarFormDialog> createState() => _SoldCarFormDialogState();
}

class _SoldCarFormDialogState extends State<SoldCarFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<CarReportController>();

  // Car Details (only for manual entry)
  final _modelController = TextEditingController();
  final _ownerController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerMobileController = TextEditingController();
  final _kilometersController = TextEditingController();

  // Customer Details
  final _customerNameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _soldPriceController = TextEditingController();
  final _remarksController = TextEditingController();
  
  DateTime _soldDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.car != null) {
      _modelController.text = widget.car!.model;
      _ownerController.text = widget.car!.owner;
      _kilometersController.text = widget.car!.kilometers;
    }
  }

  @override
  void dispose() {
    _modelController.dispose();
    _ownerController.dispose();
    _ownerNameController.dispose();
    _ownerMobileController.dispose();
    _kilometersController.dispose();
    _customerNameController.dispose();
    _mobileNumberController.dispose();
    _addressController.dispose();
    _soldPriceController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _selectSoldDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _soldDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      helpText: 'વેચાણ તારીખ પસંદ કરો'.tr,
      confirmText: 'પસંદ કરો'.tr,
      cancelText: 'રદ કરો'.tr,
    );
    if (picked != null) {
      setState(() {
        _soldDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    bool success = false;
    final soldDateStr = DateFormat('yyyy-MM-dd').format(_soldDate);

    if (widget.car != null) {
      // Mark existing car as sold
      success = await _controller.markCarAsSold(
        widget.car!.id!,
        customerName: _customerNameController.text.trim(),
        customerMobile: _mobileNumberController.text.trim(),
        customerAddress: _addressController.text.trim(),
        soldPrice: _soldPriceController.text.trim(),
        soldDate: soldDateStr,
        remarks: _remarksController.text.trim(),
      );
    } else {
      // Add sold car manually
      success = await _controller.addManualSoldCar(
        model: _modelController.text.trim(),
        owner: _ownerController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        ownerMobile: _ownerMobileController.text.trim(),
        kilometers: _kilometersController.text.trim(),
        customerName: _customerNameController.text.trim(),
        customerMobile: _mobileNumberController.text.trim(),
        customerAddress: _addressController.text.trim(),
        soldPrice: _soldPriceController.text.trim(),
        soldDate: soldDateStr,
        remarks: _remarksController.text.trim(),
      );
    }

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('વેચેલી કારની વિગતો સફળતાપૂર્વક સાચવી લેવામાં આવી છે.'.tr)),
      );
      Navigator.pop(context, true);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('વેચેલી કાર સાચવતી વખતે કોઈ ભૂલ આવી.'.tr),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isManual = widget.car == null;
    final isLight = theme.brightness == Brightness.light;

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isManual ? 'નવી વેચેલી કાર ઉમેરો'.tr : 'વેચેલ માર્ક કરો'.tr,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isLight ? Colors.black87 : Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: isLight ? Colors.black54 : Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(color: isLight ? theme.dividerColor : const Color(0xFF334155), height: 16),
              
              if (isManual) ...[
                Text(
                  'ગાડીની વિગતો (Car Details)'.tr,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _modelController,
                  style: TextStyle(color: isLight ? Colors.black87 : Colors.white),
                  decoration: _buildInputDecoration('મોડેલ નામ', Icons.directions_car, theme, isLight),
                  validator: (value) => value!.trim().isEmpty ? 'ગાડીનું મોડેલ દાખલ કરો'.tr : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ownerController,
                        style: TextStyle(color: isLight ? Colors.black87 : Colors.white),
                        decoration: _buildInputDecoration('ઓનર (દા.ત. 1, 2)', Icons.numbers, theme, isLight),
                        validator: (value) => value!.trim().isEmpty ? 'ઓનર દાખલ કરો'.tr : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _kilometersController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: isLight ? Colors.black87 : Colors.white),
                        decoration: _buildInputDecoration('કિલોમીટર', Icons.speed, theme, isLight),
                        validator: (value) => value!.trim().isEmpty ? 'કિલોમીટર દાખલ કરો'.tr : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ownerNameController,
                        style: TextStyle(color: isLight ? Colors.black87 : Colors.white),
                        decoration: _buildInputDecoration('ઓનરનું નામ (વૈકલ્પિક)', Icons.person_outline, theme, isLight),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _ownerMobileController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: isLight ? Colors.black87 : Colors.white),
                        decoration: _buildInputDecoration('મોબાઇલ (વૈકલ્પિક)', Icons.phone, theme, isLight),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ] else ...[
                // Expose short info of selected car
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.grey.withOpacity(0.08) : Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isLight ? Colors.black.withOpacity(0.04) : Colors.white.withOpacity(0.04)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.directions_car, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.car!.model,
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 15,
                                color: isLight ? Colors.black87 : Colors.white,
                              ),
                            ),
                            Text(
                              "${'ઓનર:'.tr} ${widget.car!.owner} | ${'કિલોમીટર:'.tr} ${widget.car!.kilometers} km",
                              style: TextStyle(
                                fontSize: 12, 
                                color: isLight ? Colors.black54 : Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              Text(
                'ગ્રાહક અને વેચાણ વિગતો (Customer & Sales)'.tr,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 12),

              // Customer Name
              TextFormField(
                controller: _customerNameController,
                style: TextStyle(color: isLight ? Colors.black87 : Colors.white),
                decoration: _buildInputDecoration('ગ્રાહકનું નામ', Icons.person, theme, isLight),
                validator: (value) => value!.trim().isEmpty ? 'ગ્રાહકનું નામ દાખલ કરો'.tr : null,
              ),
              const SizedBox(height: 12),

              // Mobile Number & Sold Price
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _mobileNumberController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: isLight ? Colors.black87 : Colors.white),
                      decoration: _buildInputDecoration('મોબાઇલ નંબર', Icons.phone_iphone, theme, isLight),
                      validator: (value) {
                        if (value!.trim().isEmpty) return 'નંબર દાખલ કરો'.tr;
                        if (value.trim().length < 10) return 'યોગ્ય નંબર દાખલ કરો'.tr;
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _soldPriceController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: isLight ? Colors.black87 : Colors.white),
                      decoration: _buildInputDecoration('વેચાણ કિંમત (રૂ.)', Icons.currency_rupee, theme, isLight),
                      validator: (value) => value!.trim().isEmpty ? 'કિંમત દાખલ કરો'.tr : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Customer Address
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                style: TextStyle(color: isLight ? Colors.black87 : Colors.white),
                decoration: _buildInputDecoration('સરનામું', Icons.location_on_outlined, theme, isLight),
                validator: (value) => value!.trim().isEmpty ? 'ગ્રાહકનું સરનામું દાખલ કરો'.tr : null,
              ),
              const SizedBox(height: 12),

              // Sold Date Picker
              Text(
                'વેચાણ તારીખ'.tr,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _isLoading ? null : _selectSoldDate,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.grey.withOpacity(0.08) : Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isLight ? Colors.black.withOpacity(0.04) : Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: theme.colorScheme.primary, size: 18),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          DateFormat('dd-MM-yyyy').format(_soldDate),
                          style: TextStyle(
                            color: isLight ? Colors.black87 : Colors.white, 
                            fontSize: 14, 
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Remarks
              TextFormField(
                controller: _remarksController,
                maxLines: 2,
                style: TextStyle(color: isLight ? Colors.black87 : Colors.white),
                decoration: _buildInputDecoration('રિમાર્ક્સ / નોંધ (વૈકલ્પિક)', Icons.note_alt_outlined, theme, isLight),
              ),
              
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'વિગતો સાચવો'.tr,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, ThemeData theme, bool isLight) {
    return InputDecoration(
      labelText: label.tr,
      labelStyle: TextStyle(
        color: isLight ? Colors.black54 : Colors.white.withOpacity(0.6), 
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: theme.colorScheme.primary, size: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isLight ? Colors.black.withOpacity(0.08) : Colors.white.withOpacity(0.08),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      filled: true,
      fillColor: isLight ? Colors.black.withOpacity(0.03) : Colors.black.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
    );
  }
}
