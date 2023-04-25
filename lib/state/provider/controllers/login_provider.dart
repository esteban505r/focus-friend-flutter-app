import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/controllers/history_controller.dart';
import 'package:focus_friend/controllers/login_controller.dart';
import 'package:focus_friend/state/state/history_state.dart';

StateNotifierProvider<LoginController,void> loginControllerProvider =
    StateNotifierProvider<LoginController,void>((ref) => LoginController());
