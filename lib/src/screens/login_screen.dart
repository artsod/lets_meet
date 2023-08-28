import 'package:flutter/material.dart';
import '../model/contact.dart';

class LoginScreen extends StatefulWidget {
  final Contact currentUser;
  final Map<String,String> labels;

  const LoginScreen({super.key, required this.currentUser, required this.labels});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _verificationCodeController = TextEditingController();

  late String _selectedLanguage = widget.currentUser.language.name;
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
            title: Text(widget.labels['verificationFailed']!),
            content: Text(widget.labels['enterValidCode']!),
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
          title: Text(widget.labels['verificationCode']!),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(widget.labels['enterVerificationCode']!),
              const SizedBox(height: 16.0),
              TextFormField(
                autofocus: true,
                controller: _verificationCodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: widget.labels['verificationCode'],
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
        title: Text(widget.labels['loginPageTitle']!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: widget.labels['phoneNumber'],
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return widget.labels['enterPhoneNumber'];
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: InputDecoration(
                  labelText: widget.labels['languageLabel'],
                ),
                items: <String>['English', 'Polski'].map<DropdownMenuItem<String>>((String value) {
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
                    return widget.labels['selectLanguage'];
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: <Widget>[
                  Checkbox(
                    value: _termsAccepted,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _termsAccepted = newValue!;
                      });
                    },
                  ),
                  Text(widget.labels['termsConditionsConfirmation']!),
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
                          title: Text(widget.labels['termsConditionsLabel']!),
                          content: Text(widget.labels['acceptTermsConditions']!),
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
                child: Text(widget.labels['verifyNumber']!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}