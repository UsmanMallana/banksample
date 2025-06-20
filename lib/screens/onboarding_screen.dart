import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:banksample/screens/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _focusNode = FocusNode();

  String? _selectedMethod;
  String? _selectedCurrency;
  String? _amountPerTime;
  String? _timesPerDay;
  String? _price;

  final List<String> _methods = ['Smoking', 'Edibles', 'Vaping', 'Other'];
  final List<String> _currencyTypes = ['USD', 'PKR', 'EUR', 'GBP'];

  Future<void> _saveOnboardingData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('consumption_method', _selectedMethod!);
      await prefs.setString('amount_per_time', _amountPerTime!);
      await prefs.setString('times_per_day', _timesPerDay!);
      await prefs.setString('price_per_session', _price!);
      await prefs.setString('currency_type', _selectedCurrency!);
      await prefs.setInt(
        'quit_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
      await prefs.setBool('onboarding_complete', true);

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  Widget _buildStyledDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
    String hint = 'Select',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade900,
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField2<T>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade600)),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            filled: true,
            fillColor: Colors.blue.shade50.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade300, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
            ),
          ),
          iconStyleData: IconStyleData(
            icon: Icon(Icons.keyboard_arrow_down_rounded, size: 24),
            iconEnabledColor: Colors.blue.shade700,
          ),
          buttonStyleData: ButtonStyleData(
            height: 54, // Consistent height for dropdown
            padding: EdgeInsets.only(left: 16, right: 8),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.blue.shade50,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items:
              items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  // Set consistent height for menu items using Container
                  child: Container(
                    height: 48, // Fixed height for menu items
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                );
              }).toList(),
          onChanged: onChanged,
          validator: (val) => val == null ? 'Please select one' : null,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required FormFieldSetter<String> onSaved,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
    bool isTimesPerDay = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade900,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 54, // Consistent height with dropdowns
          child: TextFormField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.blue.shade50.withOpacity(0.5),
              contentPadding: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade300, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
              ),
            ),
            style: TextStyle(color: Colors.blue.shade900),
            keyboardType: keyboardType,
            onSaved: onSaved,
            validator:
                validator ??
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field cannot be empty';
                  }
                  // Additional validation for times per day
                  if (isTimesPerDay) {
                    final numValue = int.tryParse(value);
                    if (numValue == null || numValue <= 0) {
                      return 'Enter a valid number (1 or more)';
                    }
                  }
                  return null;
                },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome to Quit Weed!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(_focusNode),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Let\'s get some quick info to personalize your journey.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue.shade900,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                // Consumption method dropdown
                _buildStyledDropdown<String>(
                  label: 'How do you usually consume?',
                  value: _selectedMethod,
                  items: _methods,
                  onChanged: (val) => setState(() => _selectedMethod = val),
                ),
                SizedBox(height: 20),
                // Amount per session text field
                _buildTextField(
                  label: 'How much do you consume per session? (eg. 10g)',
                  onSaved: (val) => _amountPerTime = val!,
                ),
                SizedBox(height: 20),
                // Times per day text field
                _buildTextField(
                  label: 'How many times per day?',
                  onSaved: (val) => _timesPerDay = val!,
                  keyboardType: TextInputType.number,
                  isTimesPerDay: true,
                ),
                SizedBox(height: 20),
                // Price text field
                _buildTextField(
                  label: 'Average cost per session',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onSaved: (val) => _price = val!,
                  validator: (val) {
                    if (val == null ||
                        val.isEmpty ||
                        double.tryParse(val) == null) {
                      return 'Enter a valid price';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // Currency dropdown
                _buildStyledDropdown<String>(
                  label: 'Currency',
                  value: _selectedCurrency,
                  items: _currencyTypes,
                  onChanged: (val) => setState(() => _selectedCurrency = val),
                ),
                SizedBox(height: 30),
                // Submit button
                ElevatedButton(
                  onPressed: _saveOnboardingData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'Start My Journey!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
