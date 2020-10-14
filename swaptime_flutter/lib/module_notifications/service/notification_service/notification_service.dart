import 'package:inject/inject.dart';
import 'package:swaptime_flutter/games_module/response/game_details/games_details.dart';
import 'package:swaptime_flutter/games_module/service/games_list_service/games_list_service.dart';
import 'package:swaptime_flutter/module_auth/service/auth_service/auth_service.dart';
import 'package:swaptime_flutter/module_notifications/model/notifcation_item/notification_item.dart';
import 'package:swaptime_flutter/module_profile/model/profile_model/profile_model.dart';
import 'package:swaptime_flutter/module_profile/service/general_profile/general_profile.dart';
import 'package:swaptime_flutter/module_swap/service/swap_service/swap_service.dart';

@provide
class NotificationService {
  final AuthService _authService;
  final SwapService _swapService;
  final GamesListService _gamesListService;
  final GeneralProfileService _generalProfileService;

  NotificationService(
    this._authService,
    this._generalProfileService,
    this._gamesListService,
    this._swapService,
  );

  Future<List<NotificationModel>> getNotifications() async {
    List<NotificationModel> notifications = [];
    var swaps = await _swapService.getSwapRequests();
    for (int i = 0; i < swaps.length; i++) {
      var element = swaps[i];
      ProfileModel otherDetails;
      GameDetails ownerGameDetails;
      GameDetails swapperGameDetails;

      if (element.ownerGame != null) {
        ownerGameDetails =
            await _gamesListService.getGameDetails(element.ownerGame);
      }
      if (element.swapperGame != null) {
        swapperGameDetails =
            await _gamesListService.getGameDetails(element.swapperId);
      }

      String uid = await _authService.userID;
      if (element.ownerId == uid) {
        otherDetails =
            await _generalProfileService.getUserDetails(element.swapperId);
      } else {
        otherDetails =
            await _generalProfileService.getUserDetails(element.ownerId);
      }

      notifications.add(NotificationModel(
        chatRoomId: element.roomID,
        swapId: element.id,
        ownerGameImageLink:
            ownerGameDetails != null ? ownerGameDetails.mainImage : null,
        ownerName: otherDetails.name,
        swapperGameImageLink: swapperGameDetails != null
            ? swapperGameDetails.mainImage
            : 'https://d1nhio0ox7pgb.cloudfront.net/_img/g_collection_png/standard/256x256/link_broken.png',
      ));
    }
    return notifications;
  }
}