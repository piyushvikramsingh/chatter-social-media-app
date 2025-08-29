import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:untitled/common/extensions/date_time_extension.dart';
import 'package:untitled/common/extensions/font_extension.dart';
import 'package:untitled/common/managers/session_manager.dart';
import 'package:untitled/common/widgets/my_cached_image.dart';
import 'package:untitled/models/reel_comments_model.dart';
import 'package:untitled/screens/extra_views/back_button.dart';
import 'package:untitled/screens/profile_screen/profile_screen.dart';
import 'package:untitled/utilities/const.dart';

class ReelCommentCard extends StatelessWidget {
  final ReelComment comment;
  final Function() onDeleteTap;
  final Function() onDeleteModeratorTap;

  const ReelCommentCard({Key? key, required this.comment, required this.onDeleteTap, required this.onDeleteModeratorTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var shouldShowOptionOfModerator = (SessionManager.shared.getUserID() != comment.userId && SessionManager.shared.getUser()?.isModerator == 1);
    return (SessionManager.shared.getUserID() == comment.userId || shouldShowOptionOfModerator)
        ? Slidable(
            key: Key(comment.id.toString()),
            endActionPane: ActionPane(
              motion: DrawerMotion(),
              children: [
                SlidableAction(
                  flex: 1,
                  onPressed: (context) {
                    if (SessionManager.shared.getUserID() == comment.userId) {
                      onDeleteTap();
                    } else {
                      onDeleteModeratorTap();
                    }
                  },
                  backgroundColor: cRed,
                  foregroundColor: Colors.white,
                  icon: CupertinoIcons.trash,
                  autoClose: true,
                ),
              ],
            ),
            child: view())
        : view();
  }

  Widget view() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: goToProfile,
                  child: MyCachedImage(
                    imageUrl: comment.user?.profile,
                    height: 45,
                    width: 45,
                    cornerRadius: 40,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: goToProfile,
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          '@${comment.user?.username ?? ''}',
                                          style: MyTextStyle.gilroySemiBold(color: cPrimary, size: 16),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      VerifyIcon(user: comment.user)
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  comment.createdAt?.timeAgo() ?? '',
                                  style: MyTextStyle.gilroyLight(color: cLightText, size: 14),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 20),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comment.description ?? '',
                        style: MyTextStyle.outfitLight(color: cWhite, size: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void goToProfile() {
    Get.back();
    Get.to(() => ProfileScreen(userId: comment.userId ?? 0));
  }
}
