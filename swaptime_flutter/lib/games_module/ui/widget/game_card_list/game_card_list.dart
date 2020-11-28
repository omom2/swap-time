import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inject/inject.dart';
import 'package:swaptime_flutter/games_module/games_routes.dart';
import 'package:swaptime_flutter/games_module/model/game_model.dart';
import 'package:swaptime_flutter/games_module/response/games_response/games_response.dart';
import 'package:swaptime_flutter/games_module/state_manager/games_list_state_manager/games_list_state_manager.dart';
import 'package:swaptime_flutter/games_module/states/games_list_state/game_list_states.dart';
import 'package:swaptime_flutter/games_module/ui/widget/game_card_large/game_card_large.dart';
import 'package:swaptime_flutter/games_module/ui/widget/game_card_list_header/game_card_list_header.dart';
import 'package:swaptime_flutter/games_module/ui/widget/game_card_medium/game_card_medium.dart';
import 'package:swaptime_flutter/games_module/ui/widget/game_card_small/game_card_small.dart';
import 'package:swaptime_flutter/generated/l10n.dart';
import 'package:swaptime_flutter/module_auth/auth_routes.dart';
import 'package:swaptime_flutter/module_auth/service/auth_service/auth_service.dart';

@provide
class GameCardList extends StatefulWidget {
  final GamesListStateManager _stateManager;
  final AuthService _authService;

  GameCardList(this._stateManager, this._authService);

  @override
  State<StatefulWidget> createState() => _GameCardListState();
}

class _GameCardListState extends State<GameCardList> {
  GameCardType currentType = GameCardType.GAME_CARD_MEDIUM;
  GamesListState currentState = GamesListStateInit();
  List<Games> gamesList = [];
  List<Games> visibleGames = [];

  SortByType activeSort;

  bool loggedIn = false;

  @override
  void initState() {
    super.initState();
    widget._stateManager.stateStream.listen((event) {
      currentState = event;
      if (currentState is GamesListStateLoadSuccess) {
        GamesListStateLoadSuccess state = currentState;
        gamesList = _processList(state.games);
        visibleGames = gamesList;
      }
      if (mounted) setState(() {});
    });

    widget._authService.isLoggedIn.then((value) {
      loggedIn = value;
    });
    widget._stateManager.getAvailableGames();
  }

  @override
  Widget build(BuildContext context) {
    return calibrateScreen();
  }

  Widget calibrateScreen() {
    switch (currentState.runtimeType) {
      case GamesListStateLoadSuccess:
        return getSuccessUI();
        break;
      case GamesListStateLoadError:
        return getErrorUI();
        break;
      case GamesListStateLoading:
        return getLoadingUI();
        break;
      default:
        return Container();
    }
  }

  Widget getLoadingUI() {
    return Flex(
      direction: Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            CircularProgressIndicator(),
          ],
        )
      ],
    );
  }

  Widget getErrorUI() {
    return Flex(
      direction: Axis.vertical,
      children: [
        Text(S.of(context).errorLoadingItems),
        OutlineButton(
          onPressed: () {
            widget._stateManager.getAvailableGames();
          },
          child: Text(S.of(context).retry),
        )
      ],
    );
  }

  Widget getSuccessUI() {
    Widget gamesGrid;
    switch (currentType) {
      case GameCardType.GAME_CARD_SMALL:
        gamesGrid = GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: ScrollPhysics(),
          children: getSmallCards(),
        );
        break;
      case GameCardType.GAME_CARD_MEDIUM:
        gamesGrid = GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: ScrollPhysics(),
          children: getMediumCards(),
        );
        break;
      case GameCardType.GAME_CARD_LARGE:
        gamesGrid = GridView.count(
          crossAxisCount: 1,
          shrinkWrap: true,
          physics: ScrollPhysics(),
          children: getLargeCards(),
        );
        break;
      default:
        return Container();
    }

    return Flex(
      direction: Axis.vertical,
      children: [
        GameCardListHeader(
          selectedCardType: currentType,
          onTypeChanged: (newType) {
            currentType = newType;
            if (mounted) setState(() {});
          },
          onSortChanged: (newSort) {
            activeSort = newSort;
            visibleGames = _processList(gamesList);
            setState(() {});
          },
        ),
        Container(
          height: 16,
        ),
        gamesGrid
      ],
    );
  }

  List<Widget> getSmallCards() {
    List<Widget> cards = [];

    for (int i = 0; i < visibleGames.length; i++) {
      cards.add(GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(GamesRoutes.ROUTE_GAME_DETAILS,
              arguments: visibleGames[i].id);
        },
        child: GameCardSmall(
          gameModel: GameModel(
            gameTitle: visibleGames[i].name,
            imageUrl: visibleGames[i].mainImage.substring(29),
            gameOwnerFirstName: visibleGames[i].name,
            lovable: loggedIn,
            loved: visibleGames[i].interaction.checkLoved && loggedIn,
            itemId: visibleGames[i].id.toString(),
          ),
          onChatRequested: (itemId) {},
          onLoved: (loved) {
            if (loved) {
              widget._stateManager.unLove(visibleGames[i].id.toString());
            } else {
              widget._stateManager
                  .love(visibleGames[i].id.toString(), null)
                  .then((value) {
                if (value == null) {
                  Navigator.of(context).pushNamed(AuthRoutes.ROUTE_AUTHORIZE);
                }
              });
            }
          },
          onReport: (itemId) {
            Fluttertoast.showToast(msg: S.of(context).reportIsSent);
          },
        ),
      ));
    }

    return cards;
  }

  List<Widget> getMediumCards() {
    List<Widget> cards = [];
    for (int i = 0; i < visibleGames.length; i++) {
      cards.add(GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(GamesRoutes.ROUTE_GAME_DETAILS,
              arguments: visibleGames[i].id);
        },
        child: GameCardMedium(
          gameModel: GameModel(
            gameTitle: visibleGames[i].name,
            imageUrl: visibleGames[i].mainImage.substring(29),
            lovable: loggedIn,
            gameOwnerFirstName: visibleGames[i].name,
            loved: visibleGames[i].interaction.checkLoved && loggedIn,
            itemId: visibleGames[i].id.toString(),
          ),
          onChatRequested: (itemId) {},
          onLoved: (loved) {
            if (loved) {
              widget._stateManager.unLove(visibleGames[i].id.toString());
            } else {
              widget._stateManager
                  .love(visibleGames[i].id.toString(), null)
                  .then((value) {
                if (value == null) {
                  Navigator.of(context).pushNamed(AuthRoutes.ROUTE_AUTHORIZE);
                }
              });
            }
          },
          onReport: (itemId) {
            Fluttertoast.showToast(msg: S.of(context).reportIsSent);
          },
        ),
      ));
    }
    return cards;
  }

  List<Widget> getLargeCards() {
    List<Widget> cards = [];

    for (int i = 0; i < visibleGames.length; i++) {
      cards.add(GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(GamesRoutes.ROUTE_GAME_DETAILS,
              arguments: visibleGames[i].id);
        },
        child: GameCardLarge(
          gameModel: GameModel(
            gameTitle: visibleGames[i].name,
            imageUrl: visibleGames[i].mainImage.substring(29),
            gameOwnerFirstName: visibleGames[i].name,
            lovable: loggedIn,
            loved: visibleGames[i].interaction.checkLoved && loggedIn,
            itemId: visibleGames[i].id.toString(),
          ),
          comments: int.tryParse(visibleGames[i].commentNumber) ?? 0,
          onChatRequested: (itemId) {
            Navigator.of(context)
                .pushNamed(GamesRoutes.ROUTE_GAME_DETAILS, arguments: itemId);
          },
          onLoved: (loved) {
            if (loved) {
              widget._stateManager.unLove(visibleGames[i].id.toString());
            } else {
              widget._stateManager
                  .love(visibleGames[i].id.toString(), null)
                  .then((value) {
                if (value == null) {
                  Navigator.of(context).pushNamed(AuthRoutes.ROUTE_AUTHORIZE);
                }
              });
            }
          },
          onReport: (itemId) {},
        ),
      ));
    }

    return cards;
  }

  List<Games> _processList(List<Games> gamesList) {
    Map<int, dynamic> games = {};
    gamesList.forEach((element) {
      games[element.id] = element;
    });
    return _sortList(List.from(games.values));
  }

  List<Games> _sortList(List<Games> games) {
    if (activeSort == SortByType.SORT_BY_NAME) {
      games.sort((a, b) => a.name.compareTo(b.name));
      return games;
    } else if (activeSort == SortByType.SORT_BY_COMMENTS) {
      games.sort((a, b) => a.commentNumber.compareTo(b.commentNumber));
      return games.reversed;
    } else {
      return games;
    }
  }
}
