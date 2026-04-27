import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/main_screen.dart';
import 'pages/home_page.dart';
import 'pages/permission_page.dart';
import 'pages/request_assistance_page.dart';
import 'pages/searching_workshop_page.dart';
import 'pages/tracking_page.dart';
import 'pages/checkout_page.dart';
import 'pages/rating_page.dart';
import 'pages/mechanic_main_screen.dart';
import 'pages/mechanic_home_page.dart';
import 'pages/mechanic_job_details_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'theme.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Manejando mensaje en segundo plano: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'AsistCar',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/forgot_password': (context) => const ForgotPasswordPage(),
          '/main': (context) => const MainScreen(),
          '/home': (context) => const HomePage(),
          '/permissions': (context) => const PermissionPage(),
          '/request': (context) => const RequestAssistancePage(),
          '/searching': (context) => const SearchingWorkshopPage(),
          '/tracking': (context) => const TrackingPage(),
          '/checkout': (context) => const CheckoutPage(),
          '/rating': (context) => const RatingPage(),
          '/mechanic_home': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            final idTecnico = args?['id_tecnico'] ?? 1;
            return MechanicHomePage(idTecnico: idTecnico);
          },
          '/mechanic_main': (context) => const MechanicMainScreen(),
          '/mechanic_job_details': (context) => const MechanicJobDetailsPage(),
        },
      ),
    );
  }
}
