import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/features/authentication/screens/onboarding/onbording.dart';
import 'package:t_store/utils/theme/theme.dart';
import 'package:t_store/navigation_menu.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      home: _checkAuthAndNavigate(),
    );
  }

  Widget _checkAuthAndNavigate() {
    final user = Supabase.instance.client.auth.currentUser;
    return user != null ? const NavigationMenu() : const OnBoardingScreen();
  }
}