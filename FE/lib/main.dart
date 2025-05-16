import 'package:camera/camera.dart';
import 'package:farmwise_app/firebase_options.dart';
import 'package:farmwise_app/logic/api/accounts.dart';
import 'package:farmwise_app/logic/api/notifications.dart';
import 'package:farmwise_app/logic/lib/networkClient.dart';
import 'package:farmwise_app/logic/logicGlobal.dart';
import 'package:farmwise_app/logic/schemas/Response.dart';
import 'package:farmwise_app/logic/schemas/User.dart';
import 'package:farmwise_app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  print('TEST DOTENVVV');
  print(dotenv.env['GOOGLE_MAP_API_KEY']);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user == null) {
      print('User is currently signed out!');
      networkClient.token = '';
      currentUser = null;
    } else {
      print('User is signed in!');
      print(user.uid);
      networkClient.token = (await user.getIdToken())!;
      NetworkResponse<MyUser> hasil = await getUser();
      print(hasil.err);
      if (hasil.statusCode == 403 && hasil.err == 'Account Not Registered') {
        print('Bikin');
        hasil = await createUser(
          email: user.email!,
          username: user.displayName,
          profilePicture: user.photoURL,
        );
        print(user.email);
        print(user.displayName);
        print(user.photoURL);
      }
      currentUser = hasil.response!;
    }
  });

  cameras = await availableCameras();
  final prefs = await SharedPreferences.getInstance();

  notificationsEnabled = prefs.getBool('notificationsEnabled');
  if (notificationsEnabled == null && await requestNotificationPermission()) {
    final _token = await FirebaseMessaging.instance.getToken();
    if (_token != null) {
      await registerNotification(token: _token!);
      notificationsEnabled = true;
      prefs.setBool('notificationsEnabled', true);
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.green,
          selectionColor: Colors.green.withOpacity(0.3),
          selectionHandleColor: Colors.green,
        ),
      ),
      routerConfig: AppPages.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
