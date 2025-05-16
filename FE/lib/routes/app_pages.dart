import 'package:farmwise_app/logic/schemas/WeatherResponse.dart';
import 'package:farmwise_app/pages/createfarm.dart';
import 'package:farmwise_app/pages/cropanalysis.dart';
import 'package:farmwise_app/pages/chatbot_preview.dart';
import 'package:farmwise_app/pages/editfarm.dart';
import 'package:farmwise_app/pages/landdetail.dart';
import 'package:farmwise_app/pages/locationpicker.dart';
import 'package:farmwise_app/pages/managefarm.dart';
import 'package:farmwise_app/pages/pestanalysis.dart';
import 'package:farmwise_app/pages/register.dart';
import 'package:farmwise_app/pages/scanai_preview.dart';
import 'package:farmwise_app/routes/app_routes.dart';
import 'package:go_router/go_router.dart';

import 'package:farmwise_app/pages/splash_screen.dart';
import 'package:farmwise_app/pages/home.dart';
import 'package:farmwise_app/pages/onboarding.dart';
import 'package:farmwise_app/pages/chatbot.dart';
import 'package:farmwise_app/pages/scan_ai.dart';
import 'package:farmwise_app/pages/news.dart';
import 'package:farmwise_app/pages/profile.dart';
import 'package:farmwise_app/widgets/bottom_navbar.dart';
import 'package:farmwise_app/pages/login.dart';
import 'package:farmwise_app/pages/notification.dart';

class AppPages {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splashscreen,
    routes: [
      GoRoute(
        path: AppRoutes.splashscreen,
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding_1,
        builder: (context, state) => Onboarding1(),
      ),
      GoRoute(
        path: AppRoutes.onboarding_2,
        builder: (context, state) => Onboarding2(),
      ),
      GoRoute(
        path: AppRoutes.onboarding_3,
        builder: (context, state) => Onboarding3(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => RegisterPage(),
      ),
      GoRoute(path: AppRoutes.login, builder: (context, state) => LoginPage()),
      GoRoute(
        path: AppRoutes.chatbot,
        builder: (context, state) => const ChatBot(),
      ),
      GoRoute(
        path: AppRoutes.scan,
        builder: (context, state) => const ScanAI(),
      ),
      GoRoute(
        path: AppRoutes.managefarm,
        builder: (context, state) => const ManageFarm(),
      ),
      GoRoute(
        path: AppRoutes.createfarm,
        builder: (context, state) => const CreateFarm(),
      ),
      GoRoute(
        path: AppRoutes.locationpicker,
        builder: (context, state) => const LocationPicker(),
      ),
      GoRoute(
        path: AppRoutes.notification,
        builder: (context, state) => const NotificationPage(),
      ),
      GoRoute(
        path: '/cropanalysis',
        name: 'cropAnalysis',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CropAnalysis(
            imagePath: extra?['imagePath'] ?? '',
            imageFile: extra?['imageFile'],
            resultData: extra?['resultData'],
            isLoading: extra?['isLoading'] ?? true,
          );
        },
      ),
      GoRoute(
        path: '/pestanalysis',
        name: 'pestAnalysis',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PestAnalysis(
            imagePath: extra?['imagePath'] ?? '',
            imageFile: extra?['imageFile'],
            resultData: extra?['resultData'],
            isLoading: extra?['isLoading'] ?? true,
          );
        },
      ),
      GoRoute(
        path: '/landDetail/:farmId',
        name: 'landDetail',
        builder: (context, state) {
          // Mengambil farmId dari parameter URL dan mengkonversinya ke int
          final String farmIdParam = state.pathParameters['farmId'] ?? '0';
          final int farmId = int.tryParse(farmIdParam) ?? 0;

          // Mengambil nama farm dari query parameters jika ada
          final String farmName =
              state.uri.queryParameters['name'] ?? 'Detail Lahan';

          // Memeriksa apakah ada data cuaca dalam extra
          final extra = state.extra;
          WeatherResponseForecast? weatherData;

          // Tangani berbagai tipe data extra
          if (extra is WeatherResponseForecast) {
            weatherData = extra;
          } else if (extra is Map<String, dynamic> &&
              extra.containsKey('weatherData')) {
            weatherData = extra['weatherData'] as WeatherResponseForecast?;
          }

          // Memanggil LandDetailPage dengan parameter yang sesuai
          return LandDetailPage(
            farmId: farmId,
            farmName: farmName,
            initialWeather: weatherData,
          );
        },
      ),
      GoRoute(
        path: '/editfarm/:farmId',
        builder: (context, state) {
          // Extract farmId (which is fID in your model) from the URL parameters
          final farmId = state.pathParameters['farmId']!;
          return EditFarmPage(farmId: farmId);
        },
      ),

      ShellRoute(
        builder: (context, state, child) => BottomNavbar(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => HomePage(),
          ),
          GoRoute(
            path: '/chatbotpreview',
            name: 'chatbotPreview',
            builder: (context, state) => const ChatBotPreview(),
          ),
          GoRoute(
            path: '/scanpreview',
            name: 'scanPreview',
            builder: (context, state) => const ScanAIPreview(),
          ),
          GoRoute(
            path: '/news',
            name: 'news',
            builder: (context, state) => NewsPage(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const Profile(),
          ),
        ],
      ),
    ],
    // Tambahkan error handler untuk menangani rute yang tidak valid
  );
}
