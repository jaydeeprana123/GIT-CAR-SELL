import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../controllers/car_report_controller.dart';
import '../models/car_report.dart';

class ReportFormPage extends StatefulWidget {
  final CarReport? report;
  const ReportFormPage({super.key, this.report});

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  bool get isEditMode => widget.report != null;

  // Controllers
  final _modelController = TextEditingController();
  final List<String> _ownerOptions = ['1st Owner', '2nd Owner', '3rd Owner', '4th Owner', '5th Owner'];
  String _selectedOwner = '1st Owner';
  final _ownerNameController = TextEditingController();
  final _ownerMobileController = TextEditingController();
  final _kmController = TextEditingController();
  final _vimoController = TextEditingController();
  final _touchupController = TextEditingController();
  final _engineLineController = TextEditingController();
  final _drivingController = TextEditingController();

  // Selected Option states (defaulting to 'ઓકે' or appropriate defaults)
  String _dent1 = 'ઓકે';
  String _dent2 = 'ઓકે';
  String _dent3 = 'ઓકે';
  String _dent4 = 'ઓકે';
  String _dickey = 'ઓકે';
  String _door1 = 'ઓકે';
  String _door2 = 'ઓકે';
  String _door3 = 'ઓકે';
  String _door4 = 'ઓકે';
  String _glass1 = 'ઓકે';
  String _glass2 = 'ઓકે';
  String _glass3 = 'ઓકે';
  String _glass4 = 'ઓકે';
  String _fenderDriver = 'ઓકે';
  String _fenderPassenger = 'ઓકે';
  String _bonnetInside = 'ઓકે';
  String _bonnetOutside = 'ઓકે';

  String _ac = 'ચાલુ';
  String _interior = 'સાફ';
  String _engineOil = 'બરાબર';
  String _engineSmoke = 'નથી';
  String _engineNoise = 'નથી';
  String _suspension = 'ઓકે';
  String _pickup = 'સારું';
  String _brake = 'સારું';
  String _gear = 'સ્મૂથ';
  String _starting = 'ઓકે';

  // Attached Images list
  final List<ReportImage> _attachedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.report != null) {
      final r = widget.report!;
      _modelController.text = r.model;
      
      if (_ownerOptions.contains(r.owner)) {
        _selectedOwner = r.owner;
      } else if (r.owner.isNotEmpty) {
        _ownerOptions.add(r.owner);
        _selectedOwner = r.owner;
      } else {
        _selectedOwner = '1st Owner';
      }

      _ownerNameController.text = r.ownerName;
      _ownerMobileController.text = r.ownerMobile;
      _kmController.text = r.kilometers;
      _vimoController.text = r.vimo;
      _touchupController.text = r.touchup;
      _engineLineController.text = r.engineLine;
      _drivingController.text = r.drivingCondition;

      _dent1 = r.bodyDent1;
      _dent2 = r.bodyDent2;
      _dent3 = r.bodyDent3;
      _dent4 = r.bodyDent4;
      _dickey = r.dickey;
      _door1 = r.door1;
      _door2 = r.door2;
      _door3 = r.door3;
      _door4 = r.door4;
      _glass1 = r.glass1;
      _glass2 = r.glass2;
      _glass3 = r.glass3;
      _glass4 = r.glass4;
      _fenderDriver = r.fenderDriver;
      _fenderPassenger = r.fenderPassenger;
      _bonnetInside = r.bonnetInside;
      _bonnetOutside = r.bonnetOutside;

      _ac = r.ac;
      _interior = r.interior;
      _engineOil = r.engineOilCheck;
      _engineSmoke = r.engineSmoke;
      _engineNoise = r.engineNoise;
      _suspension = r.suspension;
      _pickup = r.pickup;
      _brake = r.brake;
      _gear = r.gear;
      _starting = r.startingCondition;

      _attachedImages.addAll(r.images);
    }
  }

  @override
  void dispose() {
    _modelController.dispose();
    _ownerNameController.dispose();
    _ownerMobileController.dispose();
    _kmController.dispose();
    _vimoController.dispose();
    _touchupController.dispose();
    _engineLineController.dispose();
    _drivingController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Pick an image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      // Select Label for photo first
      final label = await _showLabelSelector();
      if (label == null) return;

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image == null) return;

      // Copy image to app folder to ensure persistence
      final directory = await getApplicationDocumentsDirectory();
      final String extension = p.extension(image.path);
      final String uniqueName = 'car_img_${DateTime.now().millisecondsSinceEpoch}$extension';
      final File savedImage = await File(image.path).copy('${directory.path}/$uniqueName');

      setState(() {
        _attachedImages.add(
          ReportImage(
            imagePath: savedImage.path,
            label: label,
          ),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ફોટો સિલેક્ટ કરવામાં ભૂલ થઈ: $e')),
      );
    }
  }

  Future<String?> _showLabelSelector() async {
    final List<String> labels = [
      'આગળ (Front)',
      'પાછળ (Rear)',
      'ડાબી સાઇડ (Left)',
      'જમણી સાઇડ (Right)',
      'બોનેટ ખોલીને (Bonnet Open)',
      'એન્જિન (Engine)',
      'ઇન્ટિરિયર (Interior)',
      'ડેકી (Dickey)',
      'પાછળની ડેકી (Rear Dickey)',
      'થાંભલી ૧ (Pillar 1)',
      'થાંભલી ૨ (Pillar 2)',
      'થાંભલી ૩ (Pillar 3)',
      'થાંભલી ૪ (Pillar 4)',
      'ટાયર ૧ (Tyre 1)',
      'ટાયર ૨ (Tyre 2)',
      'ટાયર ૩ (Tyre 3)',
      'ટાયર ૪ (Tyre 4)',
      'આગળની પેનલ (Front Panel)',
      'RC બુક ૧ (RC Book 1)',
      'RC બુક ૨ (RC Book 2)',
      'ડેન્ટ/સ્ક્રેચ (Dent)',
      'અન્ય (Other)'
    ];
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ફોટો માટે લેબલ પસંદ કરો'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: labels.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(labels[index]),
                  onTap: () => Navigator.pop(context, labels[index]),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Save inspection data to Database
  Future<void> _saveReport() async {
    if (!_formKey.currentState!.validate()) {
      // Go to first step if validation fails
      _goToStep(0);
      return;
    }

    final isEditMode = widget.report != null;

    // Build the CarReport object
    final report = CarReport(
      id: widget.report?.id,
      model: _modelController.text.trim(),
      owner: _selectedOwner,
      ownerName: _ownerNameController.text.trim(),
      ownerMobile: _ownerMobileController.text.trim(),
      kilometers: _kmController.text.trim(),
      vimo: _vimoController.text.trim(),
      bodyDent1: _dent1,
      bodyDent2: _dent2,
      bodyDent3: _dent3,
      bodyDent4: _dent4,
      dickey: _dickey,
      door1: _door1,
      door2: _door2,
      door3: _door3,
      door4: _door4,
      touchup: _touchupController.text.trim(),
      ac: _ac,
      interior: _interior,
      engineLine: _engineLineController.text.trim(),
      engineOilCheck: _engineOil,
      engineSmoke: _engineSmoke,
      engineNoise: _engineNoise,
      drivingCondition: _drivingController.text.trim(),
      suspension: _suspension,
      pickup: _pickup,
      brake: _brake,
      gear: _gear,
      startingCondition: _starting,
      glass1: _glass1,
      glass2: _glass2,
      glass3: _glass3,
      glass4: _glass4,
      fenderDriver: _fenderDriver,
      fenderPassenger: _fenderPassenger,
      bonnetInside: _bonnetInside,
      bonnetOutside: _bonnetOutside,
      createdAt: widget.report?.createdAt ?? DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()),
      images: _attachedImages,
    );

    try {
      final controller = Get.find<CarReportController>();
      bool success = false;
      if (isEditMode) {
        success = await controller.updateReportData(report);
      } else {
        success = await controller.addReport(report);
      }
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditMode
                ? 'રિપોર્ટ સફળતાપૂર્વક સુધારવામાં આવ્યો છે!'
                : 'રિપોર્ટ સફળતાપૂર્વક સાચવવામાં આવ્યો છે!'),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('સેવ કરવામાં ભૂલ થઈ: $e')),
      );
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'રિપોર્ટ સુધારો' : 'નવું ઇન્સ્પેક્શન'),
        actions: [
          if (_currentStep == _totalSteps - 1)
            TextButton(
              onPressed: _saveReport,
              child: Text(isEditMode ? 'સુધારો' : 'સાચવો', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Custom Stepper Indicator
            _buildStepperIndicator(),
            const Divider(height: 1),

            // Form pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentStep = page;
                  });
                },
                children: [
                  _buildStep1BasicInfo(),
                  _buildStep2ExteriorAndBody(),
                  _buildStep3EngineAndMech(),
                  _buildStep4DrivingAndPhotos(),
                ],
              ),
            ),

            // Bottom Navigation Actions
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  // Custom Progress Stepper
  Widget _buildStepperIndicator() {
    final theme = Theme.of(context);
    final List<String> stepTitles = ['માહિતી', 'બોડી / કાચ', 'એન્જિન', 'ડ્રાઇવિંગ / ફોટા'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      color: theme.colorScheme.surface,
      child: Row(
        children: List.generate(stepTitles.length, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _goToStep(index),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: isCurrent
                            ? theme.colorScheme.primary
                            : isCompleted
                                ? theme.colorScheme.secondary
                                : theme.disabledColor.withOpacity(0.1),
                        child: isCompleted
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isCurrent || isCompleted
                                      ? Colors.white
                                      : theme.textTheme.bodyMedium?.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stepTitles[index],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent
                              ? theme.colorScheme.primary
                              : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < stepTitles.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
                      color: isCompleted
                          ? theme.colorScheme.secondary
                          : theme.disabledColor.withOpacity(0.1),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Bottom action layout
  Widget _buildBottomActionBar() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          _currentStep > 0
              ? OutlinedButton(
                  onPressed: _prevStep,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('પાછળ'),
                )
              : const SizedBox.shrink(),

          // Next / Save Button
          ElevatedButton(
            onPressed: _currentStep == _totalSteps - 1 ? _saveReport : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentStep == _totalSteps - 1
                      ? (isEditMode ? 'સુધારો કરો' : 'સાચવો અને સેન્ડ')
                      : 'આગળ',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 6),
                Icon(
                  _currentStep == _totalSteps - 1 ? Icons.save : Icons.arrow_forward,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Custom Form fields with premium chip choices
  Widget _buildChipSelector({
    required String label,
    required String currentValue,
    required List<String> options,
    required Function(String) onSelected,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = currentValue == option;
              return ChoiceChip(
                label: Text(option),
                selected: isSelected,
                selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? theme.colorScheme.primary : theme.dividerColor.withOpacity(0.3),
                  ),
                ),
                onSelected: (selected) {
                  if (selected) onSelected(option);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Divider(color: theme.dividerColor.withOpacity(0.1)),
        ],
      ),
    );
  }

  // STEP 1: Basic details
  Widget _buildStep1BasicInfo() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'ગાડીની બેઝિક માહિતી ભરો',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _modelController,
          decoration: InputDecoration(
            labelText: 'Model (ગાડીનું મોડેલ)',
            prefixIcon: const Icon(Icons.directions_car),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) => value == null || value.trim().isEmpty ? 'કૃપા કરીને મોડેલ દાખલ કરો' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedOwner,
          decoration: InputDecoration(
            labelText: 'Owner (ઓનર)',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: _ownerOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                _selectedOwner = newValue;
              });
            }
          },
          validator: (value) => value == null || value.trim().isEmpty ? 'કૃપા કરીને ઓનર પસંદ કરો' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _ownerNameController,
          decoration: InputDecoration(
            labelText: 'ઓનરનું નામ (Owner Name)',
            prefixIcon: const Icon(Icons.badge),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'દા.ત. રમેશભાઈ પટેલ (માત્ર માહિતી માટે)',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _ownerMobileController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'મોબાઈલ નંબર (Mobile Number)',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'દા.ત. 9876543210 (માત્ર માહિતી માટે)',
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _kmController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Kilometers (કિલોમીટર)',
            prefixIcon: const Icon(Icons.speed),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) => value == null || value.trim().isEmpty ? 'કૃપા કરીને કિલોમીટર દાખલ કરો' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _vimoController,
          decoration: InputDecoration(
            labelText: 'Vimo / Insurance (વીમો)',
            prefixIcon: const Icon(Icons.security),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'દા.ત. ચાલુ છે, તારીખ અથવા પૂરું થયેલ છે',
          ),
          validator: (value) => value == null || value.trim().isEmpty ? 'કૃપા કરીને વીમાની વિગત ભરો' : null,
        ),
      ],
    );
  }

  // STEP 2: Exterior & Body Check
  Widget _buildStep2ExteriorAndBody() {
    final List<String> standardOptions = ['ઓકે', 'સ્ક્રેચ', 'ડેન્ટ', 'કલર કરેલ', 'ખરાબ'];
    final List<String> glassOptions = ['ઓકે', 'તિરાડ', 'બદલેલ'];

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'બોડી અને કાચનું ઇન્સ્પેક્શન',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        _buildChipSelector(
          label: '૧ થાંભલી (Pillar 1)',
          currentValue: _dent1,
          options: standardOptions,
          onSelected: (val) => setState(() => _dent1 = val),
        ),
        _buildChipSelector(
          label: '૨ થાંભલી (Pillar 2)',
          currentValue: _dent2,
          options: standardOptions,
          onSelected: (val) => setState(() => _dent2 = val),
        ),
        _buildChipSelector(
          label: '૩ થાંભલી (Pillar 3)',
          currentValue: _dent3,
          options: standardOptions,
          onSelected: (val) => setState(() => _dent3 = val),
        ),
        _buildChipSelector(
          label: '૪ થાંભલી (Pillar 4)',
          currentValue: _dent4,
          options: standardOptions,
          onSelected: (val) => setState(() => _dent4 = val),
        ),
        _buildChipSelector(
          label: 'Deki / Dickey (ડેકી)',
          currentValue: _dickey,
          options: standardOptions,
          onSelected: (val) => setState(() => _dickey = val),
        ),

        // Doors
        _buildChipSelector(
          label: '૧ દરવાજો (Door 1)',
          currentValue: _door1,
          options: standardOptions,
          onSelected: (val) => setState(() => _door1 = val),
        ),
        _buildChipSelector(
          label: '૨ દરવાજો (Door 2)',
          currentValue: _door2,
          options: standardOptions,
          onSelected: (val) => setState(() => _door2 = val),
        ),
        _buildChipSelector(
          label: '૩ દરવાજો (Door 3)',
          currentValue: _door3,
          options: standardOptions,
          onSelected: (val) => setState(() => _door3 = val),
        ),
        _buildChipSelector(
          label: '૪ દરવાજો (Door 4)',
          currentValue: _door4,
          options: standardOptions,
          onSelected: (val) => setState(() => _door4 = val),
        ),

        // Glasses
        _buildChipSelector(
          label: 'ગાડી ના કાચો ૧ (Glass 1)',
          currentValue: _glass1,
          options: glassOptions,
          onSelected: (val) => setState(() => _glass1 = val),
        ),
        _buildChipSelector(
          label: 'ગાડી ના કાચો ૨ (Glass 2)',
          currentValue: _glass2,
          options: glassOptions,
          onSelected: (val) => setState(() => _glass2 = val),
        ),
        _buildChipSelector(
          label: 'ગાડી ના કાચો ૩ (Glass 3)',
          currentValue: _glass3,
          options: glassOptions,
          onSelected: (val) => setState(() => _glass3 = val),
        ),
        _buildChipSelector(
          label: 'ગાડી ના કાચો ૪ (Glass 4)',
          currentValue: _glass4,
          options: glassOptions,
          onSelected: (val) => setState(() => _glass4 = val),
        ),

        // Fenders
        _buildChipSelector(
          label: 'ફેન્ડર ૧ ડ્રાઇવ સાઇડ (Fender Driver Side)',
          currentValue: _fenderDriver,
          options: standardOptions,
          onSelected: (val) => setState(() => _fenderDriver = val),
        ),
        _buildChipSelector(
          label: 'ફેન્ડર ૨ ખાલી સાઇડ (Fender Passenger Side)',
          currentValue: _fenderPassenger,
          options: standardOptions,
          onSelected: (val) => setState(() => _fenderPassenger = val),
        ),

        // Bonnet
        _buildChipSelector(
          label: 'બોનેટ ૧ અંદર થી (Bonnet Inside)',
          currentValue: _bonnetInside,
          options: standardOptions,
          onSelected: (val) => setState(() => _bonnetInside = val),
        ),
        _buildChipSelector(
          label: 'બોનેટ ૨ ઉપર થી (Bonnet Outside/Top)',
          currentValue: _bonnetOutside,
          options: standardOptions,
          onSelected: (val) => setState(() => _bonnetOutside = val),
        ),

        const SizedBox(height: 8),
        TextFormField(
          controller: _touchupController,
          decoration: InputDecoration(
            labelText: 'ગાડી મા કેટલો tachap (Touchup Details)',
            prefixIcon: const Icon(Icons.format_paint),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'દા.ત. ૨ દરવાજા ટચઅપ, બોનેટ રીપેઇન્ટ...',
          ),
        ),
      ],
    );
  }

  // STEP 3: Engine & Mechanical Check
  Widget _buildStep3EngineAndMech() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'મિકેનિકલ અને એન્જિન ચેક',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _engineLineController,
          decoration: InputDecoration(
            labelText: 'એન્જિન Lin (Engine Line Details)',
            prefixIcon: const Icon(Icons.construction),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),

        _buildChipSelector(
          label: 'એન્જિન oil chek (Engine Oil)',
          currentValue: _engineOil,
          options: ['બરાબર', 'ઓછું', 'બદલવાની જરૂર છે'],
          onSelected: (val) => setState(() => _engineOil = val),
        ),
        _buildChipSelector(
          label: 'એન્જિન ધુમાડો (Engine Smoke)',
          currentValue: _engineSmoke,
          options: ['નથી', 'સફેદ ધુમાડો', 'કાળો ધુમાડો'],
          onSelected: (val) => setState(() => _engineSmoke = val),
        ),
        _buildChipSelector(
          label: 'એન્જિન આવાજ (Engine Noise)',
          currentValue: _engineNoise,
          options: ['નથી', 'ખરાબ અવાજ', 'થોડો અવાજ'],
          onSelected: (val) => setState(() => _engineNoise = val),
        ),
        _buildChipSelector(
          label: 'ગાડી ચાલુ કરવા મા (Starting Condition)',
          currentValue: _starting,
          options: ['ઓકે (એક સેલ્ફ)', 'સેલ્ફ લોંગ લે છે', 'ચાલુ નથી થતી'],
          onSelected: (val) => setState(() => _starting = val),
        ),
      ],
    );
  }

  // STEP 4: Driving & Cabin + Photos
  Widget _buildStep4DrivingAndPhotos() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'ડ્રાઇવિંગ, કેબિન અને ફોટા',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        _buildChipSelector(
          label: 'AC (એસી)',
          currentValue: _ac,
          options: ['ચાલુ', 'બંધ', 'ગેસ નથી'],
          onSelected: (val) => setState(() => _ac = val),
        ),
        _buildChipSelector(
          label: 'Intriyal (ઇન્ટિરિયર)',
          currentValue: _interior,
          options: ['સાફ', 'ખરાબ', 'સીટ કવર તૂટેલા છે'],
          onSelected: (val) => setState(() => _interior = val),
        ),

        TextFormField(
          controller: _drivingController,
          decoration: InputDecoration(
            labelText: 'Gadi ચાલવામાં (Driving Performance)',
            prefixIcon: const Icon(Icons.alt_route),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),

        _buildChipSelector(
          label: 'સસ્પેન્સ (Suspension)',
          currentValue: _suspension,
          options: ['ઓકે', 'અવાજ આવે છે', 'નરમ/પોચું છે', 'ખરાબ'],
          onSelected: (val) => setState(() => _suspension = val),
        ),
        _buildChipSelector(
          label: 'પીકઅપ (Pickup)',
          currentValue: _pickup,
          options: ['સારું', 'ઓછું છે', 'લેગ થાય છે'],
          onSelected: (val) => setState(() => _pickup = val),
        ),
        _buildChipSelector(
          label: 'બ્રેક (Brake)',
          currentValue: _brake,
          options: ['સારું', 'ઢીલી છે', 'અવાજ આવે છે'],
          onSelected: (val) => setState(() => _brake = val),
        ),
        _buildChipSelector(
          label: 'ગેર (Gear)',
          currentValue: _gear,
          options: ['સ્મૂથ', 'હાર્ડ પડે છે', 'અવાજ કરે છે'],
          onSelected: (val) => setState(() => _gear = val),
        ),

        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 12),
        const Text(
          'ગાડીના ફોટા ઉમેરો (Camera / Media)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text('કેમેરા', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library, color: Colors.white),
                label: const Text('ગેલેરી', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        // Image display grid
        _attachedImages.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'કોઈ ફોટો ઉમેરેલ નથી',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.8,
                ),
                itemCount: _attachedImages.length,
                itemBuilder: (context, idx) {
                  final img = _attachedImages[idx];
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(7),
                                  topRight: Radius.circular(7),
                                ),
                                child: Image.file(
                                  File(img.imagePath),
                                  fit: MyersImageCacheFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                              color: Colors.black54,
                              child: Text(
                                img.label.contains('(') ? img.label.split('(').first.trim() : img.label,
                                style: const TextStyle(color: Colors.white, fontSize: 9),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _attachedImages.removeAt(idx);
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.close, color: Colors.white, size: 12),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ],
    );
  }
}

// Simple extension helper to fix image fit naming compilation if necessary.
class MyersImageCacheFit {
  static const BoxFit cover = BoxFit.cover;
}
