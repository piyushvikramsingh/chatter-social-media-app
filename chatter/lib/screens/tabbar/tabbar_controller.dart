import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:get/get.dart';
import 'package:untitled/common/controller/base_controller.dart';
import 'package:untitled/common/managers/logger.dart';
import 'package:untitled/screens/profile_screen/profile_screen.dart';
import 'package:untitled/screens/rooms_screen/single_room/single_room_screen.dart';
import 'package:untitled/screens/single_post_screen/single_post_screen.dart';
import 'package:untitled/screens/single_reel_screen/single_reel_screen.dart';
import 'package:untitled/utilities/params.dart';

class TabBarController extends BaseController {
  int selectedTab = 0;

  @override
  void onInit() {
    super.onInit();
  }

  void selectIndex(int index) {
    selectedTab = index;
    update();
  }

  void handleBranch() async {
    await FlutterBranchSdk.init();
    FlutterBranchSdk.listSession().listen(
      (data) {
        if (data["+clicked_branch_link"] == true) {
          _navigateIfExists(data: data, key: Param.reelId, screenBuilder: (id) => SingleReelScreen(reelId: id));
          _navigateIfExists(data: data, key: Param.postId, screenBuilder: (id) => SinglePostScreen(postId: id));
          _navigateIfExists(data: data, key: Param.userId, screenBuilder: (id) => ProfileScreen(userId: id));
          _navigateIfExists(data: data, key: Param.roomId, screenBuilder: (id) => SingleRoomScreen(roomId: id));
        }
        FlutterBranchSdk.clearPartnerParameters();
      },
      onError: (error) => Loggers.error((error as PlatformException).message),
    );
  }

  void _navigateIfExists({required Map data, required String key, required Widget Function(int) screenBuilder}) {
    if (data.containsKey(key)) {
      final value = data[key];
      if (value is String || value is double) {
        Get.to(screenBuilder(int.parse(value.toString())));
      }
    }
  }
}
