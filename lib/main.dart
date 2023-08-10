import 'package:flutter/material.dart';
import 'src/screens/map_screen.dart';
import 'src/screens/login_screen.dart';
import 'src/api/api_client.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final AuthService authService = AuthService();
  final Color mainColor = Colors.orange.shade700;
  final Color secondaryColor = Colors.orange.shade100;

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MeetMeThere',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: mainColor, primary: mainColor, secondary: secondaryColor),
        appBarTheme: AppBarTheme(
            backgroundColor: mainColor
        ),
        primaryColor: mainColor,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: mainColor,
          ),
        ),
        radioTheme: RadioThemeData(
          fillColor: MaterialStateProperty.all(mainColor),
        ),
        bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: secondaryColor
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.all(mainColor),
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: secondaryColor,
        ),
        chipTheme: ChipThemeData(
            backgroundColor: mainColor,
            deleteIconColor: Colors.white
        ),
        timePickerTheme: TimePickerThemeData(
            dialHandColor: mainColor,
            dialBackgroundColor: Colors.white,
            hourMinuteTextColor: mainColor,
            entryModeIconColor: mainColor,
            inputDecorationTheme: const InputDecorationTheme(
              enabledBorder: InputBorder.none,
              filled: true,
            )
        ),
      ),
      home: FutureBuilder(
        future: authService.isLoggedIn(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingScreen();
          } else if (snapshot.hasData) {
            final bool? isLoggedIn = snapshot.data;
            if (isLoggedIn != null && isLoggedIn) {
              return const MapScreen();
            } else {
              return const LoginScreen();
            }
          } else {
            return const Scaffold(
              body: Center(
                child: Text('There is something fishy going on... Please try again later and if the error persists, please let us know'),
              ),
            );
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/map': (context) => const MapScreen(),
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
