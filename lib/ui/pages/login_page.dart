import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:focus_friend/controllers/login_controller.dart';
import 'package:focus_friend/ui/pages/register_page.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../state/provider/controllers/login_provider.dart';

class LoginPage extends ConsumerWidget {
  LoginPage({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LoginController loginController =
    ref.read(loginControllerProvider.notifier);
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              const SizedBox(
              height: 30,
            ),
            SvgPicture.asset(
              "assets/focus_friend.svg",
              height: 100,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "H&H yourself",
              style: GoogleFonts.alegreyaSans(
                textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 27,
                    color: Theme
                        .of(context)
                        .colorScheme
                        .primary),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 30),
              child: Text(
                "Inicio de sesion",
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.start,
                ),
            ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 30),
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Correo electrónico"),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'La contrasena no debe estar vacia';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          obscureText: true,
                          controller: _passwordController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Contraseña"),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'El correo electronico no debe estar vacio';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 20))),
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ??
                                  false) {
                                await loginController.login(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    onError: (error) {
                                      ScaffoldMessenger.of(context)
                                          .showMaterialBanner(MaterialBanner(
                                          backgroundColor:
                                          Colors.red.shade400,
                                          content: Text(
                                            error,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  ScaffoldMessenger.of(
                                                      context)
                                                      .hideCurrentMaterialBanner();
                                                },
                                                child: const Text(
                                                  "OK",
                                                  style: TextStyle(
                                                      color:
                                                      Colors.white),
                                                ))
                                          ],
                                          overflowAlignment:
                                          OverflowBarAlignment.end));
                                    });
                              }
                            },
                            child: const Text(
                              "Iniciar sesion",
                              style: TextStyle(fontSize: 15),
                            )),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          width: double.infinity,
                          alignment: Alignment.centerRight,
                          child: TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_)=>RegisterPage()));
                              },
                              child: Text(
                                "Registrarme",
                                style: TextStyle(
                                    color: Theme
                                        .of(context)
                                        .colorScheme
                                        .secondary),
                              )),
                        )
                      ],
                    )),
              )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
