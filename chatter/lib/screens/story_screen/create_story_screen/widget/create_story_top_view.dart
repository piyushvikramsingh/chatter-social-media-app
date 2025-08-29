import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/common/extensions/image_extension.dart';
import 'package:untitled/common/widgets/my_cached_image.dart';
import 'package:untitled/screens/camera_screen/create_reel_screen.dart';
import 'package:untitled/screens/camera_screen/create_reel_screen_controller.dart';
import 'package:untitled/utilities/const.dart';

import '../create_story_controller.dart';

class CreateStoryTopView extends StatelessWidget {
  const CreateStoryTopView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateStoryController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17.0, vertical: 5),
      child: Obx(
        () => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BuildBorderRoundIcon(
              image: MyImages.close,
              onTap: Get.back,
              size: 14,
            ),
            if (controller.isRecordingStarted)
              Container(
                height: 29,
                decoration: ShapeDecoration(
                  color: cWhite.withValues(alpha: .2),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(cornerRadius: 30),
                    side: BorderSide(color: cWhite.withValues(alpha: .5), width: .5),
                  ),
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  Duration(seconds: controller.recordingDuration.value.toInt()).toHHMMSS(),
                  style: MyTextStyle.gilroySemiBold(color: cWhite, size: 15),
                ),
              ),
            Column(
              children: [
                BuildBorderRoundIcon(
                  onTap: controller.toggleFlash,
                  image: controller.isTorchOn.value ? MyImages.flashOff : MyImages.flash,
                ),
                const SizedBox(height: 20),
                if (!controller.isRecordingStarted) ...[
                  BuildBorderRoundIcon(onTap: controller.toggleCamera, image: MyImages.cameraRotate),
                  // const SizedBox(height: 20),
                  // BuildBorderRoundIcon(
                  //   image: MyImages.filter,
                  //   onTap: () {
                  //     controller.isFilterShow.value = !controller.isFilterShow.value;
                  //   },
                  // ),
                ],
                const SizedBox(height: 20),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class SelectedMusicView extends StatelessWidget {
  final CreateReelScreenController controller;

  const SelectedMusicView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    var selectedMusic = controller.selectedMusic.value?.music;
    if (selectedMusic != null) {
      return Expanded(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: controller.removeMusic,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  MyCachedImage(
                    imageUrl: selectedMusic.image,
                    width: 38,
                    height: 38,
                    cornerRadius: 6,
                  ),
                  Positioned(
                    top: -8,
                    left: -8,
                    child: ClipOval(
                      child: Container(
                        color: cWhite.withValues(alpha: 0.2),
                        padding: EdgeInsets.all(5),
                        child: Image.asset(
                          MyImages.close,
                          width: 10,
                          height: 10,
                          color: cWhite,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: InkWell(
                onTap: () {
                  controller.tapOnMusicCard();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedMusic.title ?? '',
                      style: MyTextStyle.gilroyMedium(size: 15, color: cWhite),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      selectedMusic.artist ?? '',
                      style: MyTextStyle.gilroyLight(color: cWhite, size: 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      );
    } else {
      return SizedBox();
    }
  }
}
