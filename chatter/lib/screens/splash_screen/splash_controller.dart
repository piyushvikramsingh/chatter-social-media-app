import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/managers/session_manager.dart';
import 'package:untitled/common/api_service/common_service.dart';
import 'package:untitled/common/api_service/user_service.dart';
import 'package:untitled/common/controller/base_controller.dart';
import 'package:untitled/screens/block_by_admin_screen/block_by_admin_screen.dart';
import 'package:untitled/screens/interests_screen/interests_screen.dart';
import 'package:untitled/screens/on_boarding_screen/on_boarding_screen.dart';
import 'package:untitled/screens/profile_picture_screen/profile_picture_screen.dart';
import 'package:untitled/screens/tabbar/tabbar_screen.dart';
import 'package:untitled/screens/username_screen/username_screen.dart';

class SplashController extends BaseController {
  @override
  void onInit() {
    print("SplashController: onInit");
    fetchSettings();
    super.onInit();
  }

  void fetchUser(Function() completion) {
    print("SplashController: fetchUser started");
    if (SessionManager.shared.getUser()?.id != null) {
      print("SplashController: User ID found, fetching profile");
      UserService.shared.fetchMyProfile(
        userID: SessionManager.shared.getUser()?.id ?? 0,
        completion: (user) {
          print("SplashController: fetchMyProfile completed");
          SessionManager.shared.setUser(user);
          completion();
        },
      );
    } else {
      print("SplashController: No user ID found, skipping profile fetch");
      completion();
    }
  }

  void fetchSettings() {
    print("SplashController: fetchSettings started");
    fetchUser(() {
      print("SplashController: fetchUser completed, now fetching global settings");
      
      // Add timeout to prevent infinite hanging
      Timer? timeoutTimer = Timer(const Duration(seconds: 10), () {
        print("SplashController: fetchGlobalSettings timeout reached");
        // Navigate to view even if settings fetch fails
        Get.offAll(() => gotoView());
      });
      
      try {
        CommonService.shared.fetchGlobalSettings((p0) {
          print("SplashController: fetchGlobalSettings completed with result: $p0");
          timeoutTimer?.cancel(); // Cancel timeout timer
          Get.offAll(() => gotoView());
        });
      } catch (e) {
        print("SplashController: Error fetching settings: $e");
        timeoutTimer?.cancel();
        Get.offAll(() => gotoView());
      }
    });
  }

  Widget gotoView() {
    if (SessionManager.shared.isLogin()) {
      var user = SessionManager.shared.getUser();
      if (user?.isBlock == 1) {
        return const BlockedByAdminScreen();
      } else if (user?.interestIds == null) {
        return InterestScreen();
      } else if (user?.username == null) {
        return const UserNameScreen();
      } else if (user?.profile == null) {
        return const ProfilePictureScreen();
      } else {
        return TabBarScreen();
      }
    }
    return const OnBoardingScreen();
  }
}
