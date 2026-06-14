import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  ConnectivityResult _collapseResults(List<ConnectivityResult> results) {
    if (results.isEmpty) return ConnectivityResult.none;
    if (results.contains(ConnectivityResult.wifi)) return ConnectivityResult.wifi;
    if (results.contains(ConnectivityResult.mobile)) return ConnectivityResult.mobile;
    if (results.contains(ConnectivityResult.ethernet)) return ConnectivityResult.ethernet;
    if (results.contains(ConnectivityResult.bluetooth)) return ConnectivityResult.bluetooth;
    if (results.contains(ConnectivityResult.vpn)) return ConnectivityResult.vpn;
    if (results.contains(ConnectivityResult.other)) return ConnectivityResult.other;
    return ConnectivityResult.none;
  }

  Stream<ConnectivityResult> get connectivityStream => _connectivity.onConnectivityChanged.map(_collapseResults);

  Future<ConnectivityResult> get currentConnectivity async {
    final results = await _connectivity.checkConnectivity();
    return _collapseResults(results);
  }

  Future<bool> get isOnline async {
    final result = await currentConnectivity;
    return result != ConnectivityResult.none;
  }

  Future<bool> get hasInternet async {
    final result = await currentConnectivity;
    return result == ConnectivityResult.wifi || result == ConnectivityResult.mobile;
  }
}