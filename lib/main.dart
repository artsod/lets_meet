import 'package:flutter/material.dart';
import 'src/model/contact.dart';
import 'src/screens/map_screen.dart';
import 'src/screens/login_screen.dart';
import 'src/api/api_client.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final apiClient = ApiClient();
  final Color mainColor = Colors.orange.shade700;
  final Color secondaryColor = Colors.orange.shade100;
  late final Contact currentUser;
  late final Map<String,String> labels;

  MyApp({super.key}) {
    _initializeData();
  }

  Future<void> _initializeData() async {
    WidgetsFlutterBinding.ensureInitialized();
    //##Zrobić dynamicznie
    currentUser = await apiClient.getCurrentUser('606994342');
    labels = await apiClient.getLabels(currentUser.language.name);
  }

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
        future: apiClient.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingScreen();
          } else if (snapshot.hasData) {
            final bool? isLoggedIn = snapshot.data;
            if (isLoggedIn != null && isLoggedIn) {
              return MapScreen(currentUser: currentUser, labels: labels);
            } else {
              return LoginScreen(currentUser: currentUser, labels: labels);
            }
          } else {
            return Scaffold(
              body: Center(
                child: Text(labels['mainPageError']!),
              ),
            );
          }
        },
      ),
      routes: {
        '/login': (context) => LoginScreen(currentUser: currentUser, labels: labels),
        '/map': (context) => MapScreen(currentUser: currentUser, labels: labels),
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
