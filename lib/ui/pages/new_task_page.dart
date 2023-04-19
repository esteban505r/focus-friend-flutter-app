import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:focus_friend/ui/widgets/custom_background.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class NewTaskPage extends StatefulWidget {
  const NewTaskPage({Key? key}) : super(key: key);

  @override
  NewTaskPageState createState() => NewTaskPageState();
}

class NewTaskPageState extends State<NewTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _timeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _endingTimeController = TextEditingController();
  File? _image;

  @override
  void dispose() {
    _nameController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    _endingTimeController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.check),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Stack(
        children: [
          CustomBackground(),
          _createBody()
        ],
      ),
    );
  }

  Widget _createBody() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "Nueva Tarea",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(fontSize: 30),
                )),
            if (_image == null)
              GestureDetector(
                onTap: _pickImage,
                child: Image.asset(
                  "assets/gallery.png",
                  height: 150,
                ),
              )
            else
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Image.file(
                    _image!,
                    height: 150,
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _image = null;
                      });
                    },
                    icon: const Icon(Icons.delete),
                    color: Colors.white,
                  ),
                ],
              ),
            const SizedBox(height: 40),
            _createTextField(_nameController, "Nombre"),
            const SizedBox(height: 16),
            _createTextField(_timeController, "Hora"),
            const SizedBox(height: 16),
            _createTextField(_descriptionController, "Descripcion"),
            const SizedBox(height: 16),
            _createTextField(_endingTimeController, "Hora de finalizacion")
          ],
        ),
      ),
    );
  }
}

Widget _createTextField(TextEditingController controller, String label) =>
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Este campo no fue ingresado';
          }
          return null;
        },
      ),
    );
