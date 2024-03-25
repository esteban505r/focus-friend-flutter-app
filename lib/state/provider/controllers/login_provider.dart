import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_friend/controllers/login_controller.dart';

StateNotifierProvider<LoginController,void> loginControllerProvider =
    StateNotifierProvider<LoginController,void>((ref) => LoginController());
