import 'package:inject/inject.dart';
import 'package:swaptime_flutter/consts/urls.dart';
import 'package:swaptime_flutter/module_network/http_client/http_client.dart';

@provide
class SwapRepository {
  final ApiClient _client;
  SwapRepository(this._client);

  Future<dynamic> getSwapInMarket() {
    return _client.get(Urls.API_GAMES);
  }
}