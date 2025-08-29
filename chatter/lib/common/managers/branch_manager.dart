import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../extensions/image_extension.dart';

class BranchManager {
  static BranchManager shared = BranchManager();

  BranchManager() {
    FlutterBranchSdk.init();
  }

  void share({
    required String title,
    required String imageURL,
    required Map<String, String> data,
  }) async {
    BranchUniversalObject buo = BranchUniversalObject(canonicalIdentifier: 'flutter/branch', title: title, imageUrl: imageURL, publiclyIndex: true, locallyIndex: true);
    BranchLinkProperties lp = BranchLinkProperties();
    data.forEach((key, value) {
      lp.addControlParam(key, value);
    });
    if (GetPlatform.isIOS) {
      if (buo.imageUrl != '') {
        FlutterBranchSdk.showShareSheet(buo: buo, linkProperties: lp, messageText: '');
      } else {
        rootBundle.load(MyImages.appIcon).then((data) {
          FlutterBranchSdk.shareWithLPLinkMetadata(buo: buo, linkProperties: lp, icon: data.buffer.asUint8List(), title: title);
        });
      }
    } else {
      FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp).then((value) {
        SharePlus.instance.share(ShareParams(text: value.result ?? '', title: title, subject: title));
      });
    }
  }
}
