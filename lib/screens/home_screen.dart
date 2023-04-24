// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:assessment/extentions.dart';
import 'package:assessment/models/user_model.dart';
import 'package:assessment/screens/login_screen.dart';
import 'package:assessment/services/local_db_service.dart';
import 'package:assessment/services/user_service.dart';
import 'package:assessment/widgets/app_button.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:assessment/utility/app_colors.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController _controller;
  final _userService = UserService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    syncUser();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Container(
            color: Colors.white,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.black),
            ),
          )
        : Scaffold(
            backgroundColor: AppColors.whiteColor,
            appBar: AppBar(
              backgroundColor: AppColors.whiteColor,
              centerTitle: true,
              title: Text(
                _userService.currentUser.name ?? "User",
                style: const TextStyle(color: Colors.black),
              ),
              actions: [
                IconButton(
                    onPressed: () async {
                      final result = await Connectivity().checkConnectivity();
                      if (result == ConnectivityResult.none) {
                        context.showConnectivityDialog();
                        return;
                      }
                      await LocalDBService().deleteUser();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()));
                    },
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.black,
                    ))
              ],
            ),
            body: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(_userService.currentUser.mobile ??
                      _userService.currentUser.id),
                  const SizedBox(
                    height: 10,
                  ),
                  AppButton(
                    text: 'Change Name',
                    onTap: onTapChangeName,
                  )
                ],
              ),
            ),
          );
  }

  void syncUser() async {
    setState(() {
      _isLoading = true;
    });

    await _userService.syncOrCreateUserAccount(user: widget.user);
    setState(() {
      _isLoading = false;
    });
  }

  void onTapChangeName() async {
    _controller.text = _userService.currentUser.name ?? 'User';
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    controller: _controller,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
              AppButton(
                text: 'Submit',
                onTap: _controller.text.isEmpty
                    ? null
                    : () async {
                        try {
                          final result =
                              await Connectivity().checkConnectivity();
                          if (result == ConnectivityResult.none) {
                            context.showConnectivityDialog();
                            return;
                          }
                          await _userService.updateName(name: _controller.text);
                          Navigator.pop(context);
                        } catch (e) {
                          log(e.toString());
                        }
                      },
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        );
      },
    );
    setState(() {});
  }
}
