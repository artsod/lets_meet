/*import 'package:flutter/material.dart';

class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration Form'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String phoneNumber = _phoneNumberController.text;
                // Navigate to the phone verification screen
                initiateVerication(phoneNumber);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhoneVerificationScreen(phoneNumber: phoneNumber),
                  ),
                );
              },
              child: Text('Verify Phone Number'),
            ),
          ],
        ),
      ),
    );
  }
}

class PhoneVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  PhoneVerificationScreen({required this.phoneNumber});

  @override
  _PhoneVerificationScreenState createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final TextEditingController _verificationCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Verification'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Verification Code has been sent to ${widget.phoneNumber}.',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _verificationCodeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Verification Code',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String verificationCode = _verificationCodeController.text;
                // Call your API to verify the phone number
                verifyPhoneNumber(widget.phoneNumber, verificationCode);
              },
              child: Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }

  void verifyPhoneNumber(String phoneNumber, String verificationCode) {
    // Make an API call to verify the phone number
    // You can use a package like http or dio for HTTP requests
    // Example using http package:
    // final response = await http.post(
    //   'your-api-url.com/verify-phone-number',
    //   body: {
    //     'phoneNumber': phoneNumber,
    //     'verificationCode': verificationCode,
    //   },
    // );
    // Handle the response as per your API's requirements
  }
}
*/