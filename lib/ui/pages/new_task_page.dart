import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:focus_friend/model/dto/activity_model.dart';
import 'package:focus_friend/model/repositories/activity_repository.dart';
import 'package:focus_friend/ui/widgets/custom_background.dart';
import 'package:focus_friend/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class NewTaskPage extends StatefulWidget {
  const NewTaskPage({Key? key, this.activityModel}) : super(key: key);

  final ActivityModel? activityModel;

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
  void initState() {
    if (widget.activityModel != null) {
      _nameController.text = widget.activityModel?.name ?? '';
      _timeController.text = widget.activityModel?.time ?? '';
      _descriptionController.text = widget.activityModel?.description ?? '';
      _endingTimeController.text = widget.activityModel?.endingTime ?? '';
    }
    super.initState();
  }

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
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_formKey.currentState?.validate() ?? false) {
            await _saveData();
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.check),
      ),
      body: Stack(
        children: [CustomBackground(), _createBody()],
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
                  widget.activityModel != null ? "Editar Tarea" : "Nueva Tarea",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(fontSize: 30),
                )),
            if (_image == null)
              GestureDetector(
                onTap: _pickImage,
                child: Image.asset(
                  "assets/calendar.png",
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
            _createTextField(_timeController, "Hora", enabled: false,
                onClick: () async {
              TimeOfDay? time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now().replacing(minute: 0));
              if (time != null) {
                _timeController.text = formatTimeOfDay(time);
              }
            }),
            const SizedBox(height: 16),
            _createTextField(_descriptionController, "Descripcion"),
            const SizedBox(height: 16),
            _createTextField(_endingTimeController, "Hora de finalizacion",
                enabled: false, onClick: () async {
              if (_timeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text("Debes primero seleccionar una hora de inicio")));
                return;
              }

              TimeOfDay? time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now().replacing(minute: 0));

              if (time != null &&
                  time.compareTo(parseTimeOfDay(_timeController.text)) <=
                      0) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text("La hora de finalizacion debe ser mayor a la de inicio")));
                return;
              }

              _endingTimeController.text = formatTimeOfDay(time!);
            })
          ],
        ),
      ),
    );
  }

  Future<void> _saveData() async {
    try {
      if (widget.activityModel != null) {
        ActivityModel activityModel = ActivityModel(
          id: widget.activityModel?.id,
          lastUpdate: widget.activityModel?.lastUpdate ?? '',
          image: widget.activityModel?.image ?? '',
          extraText: widget.activityModel?.extraText ?? '',
          status: widget.activityModel?.status ?? '',
          description: _descriptionController.text,
          name: _nameController.text,
          time: _timeController.text,
          endingTime: _endingTimeController.text,
        );
        await ActivityRepository().editTask(activityModel);
      } else {
        await ActivityRepository().addTask(ActivityModel(
          description: _descriptionController.text,
          name: _nameController.text,
          time: _timeController.text,
          endingTime: _endingTimeController.text,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
      print(e);
    } finally {
      Navigator.pop(context);
    }
  }
}

Widget _createTextField(TextEditingController controller, String label,
        {bool enabled = true, void Function()? onClick}) =>
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: onClick,
        child: IgnorePointer(
          ignoring: !enabled,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
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
        ),
      ),
    );
