import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:banksample/screens/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  String _consumptionMethod = '';
  String _amountPerTime = '';
  String _timesPerDay = '';
  String _price = '';

  Future<void> _saveOnboardingData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('consumption_method', _consumptionMethod);
      await prefs.setString('amount_per_time', _amountPerTime);
      await prefs.setString('times_per_day', _timesPerDay);
      await prefs.setString('price_per_session', _price); // Store as string, parse to double later
      await prefs.setInt('quit_timestamp', DateTime.now().millisecondsSinceEpoch);
      await prefs.setBool('onboarding_complete', true);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Quit Weed!'),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Let\'s get some information to help you on your journey.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.green.shade900),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              _buildTextField(
                label: 'How do you usually consume?',
                hint: 'e.g., Smoking, Edibles, Vaping',
                onSaved: (value) => _consumptionMethod = value!,
              ),
              SizedBox(height: 20),
              _buildTextField(
                label: 'How much do you consume at one time?',
                hint: 'e.g., 0.5g, 1 joint, 1 brownie',
                onSaved: (value) => _amountPerTime = value!,
              ),
              SizedBox(height: 20),
              _buildTextField(
                label: 'How many times per day?',
                hint: 'e.g., 3 times, 5 times',
                keyboardType: TextInputType.number,
                onSaved: (value) => _timesPerDay = value!,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _buildTextField(
                label: 'What\'s the average cost per session/unit?',
                hint: 'e.g., 10.00 (USD)',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSaved: (value) => _price = value!,
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveOnboardingData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Start My Journey!',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required FormFieldSetter<String> onSaved,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green.shade600, width: 2),
        ),
        filled: true,
        fillColor: Colors.green.shade50.withOpacity(0.5),
        labelStyle: TextStyle(color: Colors.green.shade800),
        hintStyle: TextStyle(color: Colors.green.shade400),
      ),
      keyboardType: keyboardType,
      onSaved: onSaved,
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'This field cannot be empty';
        }
        return null;
      },
    );
  }
}
