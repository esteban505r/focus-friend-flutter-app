import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:focus_friend/model/dto/activity_model.dart';
import 'package:focus_friend/model/dto/task_model.dart';
import 'package:focus_friend/model/repositories/activity_repository.dart';
import 'package:focus_friend/ui/widgets/custom_background.dart';
import 'package:focus_friend/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class NewTaskPage extends StatefulWidget {
  const NewTaskPage({Key? key, this.taskModel}) : super(key: key);

  final TaskModel? taskModel;

  @override
  NewTaskPageState createState() => NewTaskPageState();
}

class NewTaskPageState extends State<NewTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deadlineController = TextEditingController();
  String? _deadline;
  File? _image;

  @override
  void initState() {
    if (widget.taskModel != null) {
      _nameController.text = widget.taskModel?.name ?? '';
      _descriptionController.text = widget.taskModel?.description ?? '';
      _deadlineController.text = DateFormat.yMMMd().format(parseDateString(widget.taskModel?.deadline??""));
    }
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _deadlineController.dispose();
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
                  widget.taskModel != null ? "Editar Tarea" : "Nueva Tarea",
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
            const SizedBox(height: 16),
            _createTextField(_descriptionController, "Descripcion"),
            const SizedBox(height: 16),
            _createTextField(_deadlineController, "Limite de tiempo",
                enabled: false, onClick: () async {
              DateTime? dateTime = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                initialDate: widget.taskModel==null ? DateTime.now().add(const Duration(days: 1)) : parseDateString(widget.taskModel?.deadline??""),
                lastDate: DateTime(2199),
              );
              if (dateTime == null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        "La hora de finalizacion debe ser mayor a la de inicio")));
                return;
              }
              _deadline = dateTime!.toIso8601String();
              _deadlineController.text = DateFormat.yMMMd().format(dateTime!);
            })
          ],
        ),
      ),
    );
  }

  Future<void> _saveData() async {
    try {
      if (widget.taskModel != null) {
        TaskModel taskModel = TaskModel(
          id: widget.taskModel?.id,
          lastUpdate: widget.taskModel?.lastUpdate ?? '',
          image: widget.taskModel?.image ?? '',
          extraText: widget.taskModel?.extraText ?? '',
          status: widget.taskModel?.status ?? '',
          description: _descriptionController.text,
          name: _nameController.text,
          deadline: _deadline?? widget.taskModel?.deadline ??"",
        );
        await ActivityRepository().editTask(taskModel);
      } else {
        await ActivityRepository().addTask(TaskModel(
          description: _descriptionController.text,
          name: _nameController.text,
          deadline: _deadline,
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
