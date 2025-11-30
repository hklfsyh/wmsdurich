import 'package:dio/dio.dart';
import 'package:dio/browser.dart';

// Web implementation
void configureWebAdapter(Dio dio) {
  dio.httpClientAdapter = BrowserHttpClientAdapter()..withCredentials = true;
}
