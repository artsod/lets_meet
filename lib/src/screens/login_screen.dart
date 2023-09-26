import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _verificationCodeController = TextEditingController();
  CountryCode selectedCountry = CountryCode.fromCountryCode('PL');


  String _selectedLanguage = 'English';
  bool _termsAccepted = false;

  void _verifyPhoneNumber(BuildContext context) {
    // Perform phone number verification logic here
    // You can use a service like Firebase Authentication for this

    // Simulating successful verification for demonstration
    String verificationCode = "111111";

    if (_verificationCodeController.text == verificationCode) {
      Navigator.pushNamedAndRemoveUntil(
          context,
          '/map',
          ModalRoute.withName("/Home")
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Verification Failed'),
            content: const Text('Please enter a valid verification code.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _showVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verification Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Please enter the 6-digit verification code:'),
              const SizedBox(height: 16.0),
              TextFormField(
                autofocus: true,
                controller: _verificationCodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Verification Code',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _verifyPhoneNumber(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CountryCodePicker(
                    onChanged: (countryCode) {
                      setState(() {
                        selectedCountry = countryCode;
                      });
                    },
                    initialSelection: 'PL',
                    showCountryOnly:
                        false, // Set to true to show only country names
                    showOnlyCountryWhenClosed:
                        false, // Set to true to show only country names when closed
                    alignLeft: false, // Set to true for left alignment
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: SizedBox(
                      width: 200,
                      child: TextFormField(
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Implement phone number authentication logic here
                  // You can access the selected country and phone number using selectedCountry and phoneNumberController.text
                },
                child: Text('Login with Phone Number'),
              ),
              SizedBox(height: 16.0),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 400,
                    child: DropdownButtonFormField<String>(
                      value: _selectedLanguage,
                      decoration: const InputDecoration(
                        labelText: 'Language',
                      ),
                      items: <String>['English', 'Polish']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedLanguage = newValue!;
                        });
                      },
                      validator: (String? value) {
                        if (value == null) {
                          return 'Please select a language';
                        }
                        return null;
                      },
                    ),
                  ), 
                ],
              ),
              Row(
                children: <Widget>[
                  const SizedBox(height: 16.0),
                  Checkbox(
                    value: _termsAccepted,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _termsAccepted = newValue!;
                      });
                    },
                  ),
                  const Text('I accept the terms and conditions'),
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (!_termsAccepted) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Terms and Conditions'),
                          content: const Text(
                              'Please accept the terms and conditions.'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else if (_formKey.currentState!.validate()) {
                    _showVerificationDialog(context);
                  }
                },
                child: const Text('Verify Phone Number'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
