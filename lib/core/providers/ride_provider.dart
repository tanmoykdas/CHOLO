import 'package:flutter/foundation.dart';
import '../models/ride_model.dart';
import '../services/ride_service.dart';

class RideProvider with ChangeNotifier {
  final _service = RideService();
  List<Ride> _results = [];
  bool _loading = false;

  List<Ride> get results => _results;
  bool get isLoading => _loading;

  Future<void> search(String route) async {
    _loading = true;
    notifyListeners();
    _service.ridesForRoute(route).listen((list) {
      _results = list;
      _loading = false;
      notifyListeners();
    });
  }
}
