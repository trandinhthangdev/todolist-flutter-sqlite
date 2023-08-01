import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todolist_flutter_sqlite/model_todo.dart';
import 'package:intl/intl.dart';

import 'constants.dart';
import 'db_todo.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ToDoApp(),
    );
  }
}

class ToDoApp extends StatefulWidget {
  const ToDoApp({Key? key}) : super(key: key);

  @override
  _ToDoAppState createState() => _ToDoAppState();
}

class _ToDoAppState extends State<ToDoApp> {
  FocusNode nodeToDoInput = FocusNode();
  final TextEditingController _toDoTextController = TextEditingController(text: "");
  List<ToDo> _toDoList = [];
  @override
  void initState() {
    super.initState();
    refreshToDoList();
  }

  @override
  void dispose() {
    _toDoTextController.dispose();
    DBToDo.instance.close();
    super.dispose();
  }

  Future refreshToDoList() async {
    DBToDo.instance.getToDoList().then((value) {
      setState(() {
        _toDoList = value;
      });
    });
  }

  addToDo() async {
    String label = _toDoTextController.text;
    if (label != "") {
      DateTime now = DateTime.now();
      ToDo toDo = ToDo(
        status: toDoProcessing,
        label: label,
        createdAt: now
      );
      _toDoTextController.clear();
      await DBToDo.instance.save(toDo);
      refreshToDoList();
      FocusScope.of(context).requestFocus(nodeToDoInput);
    }
  }

  _toggleToDoStatus(ToDo toDo) async {
    ToDo toDoUpdate = toDo.copy(
      status: toDo.status == toDoDone ? toDoProcessing : toDoDone
    );
    await DBToDo.instance.update(toDoUpdate);
    refreshToDoList();
  }

  _deleteToDo(ToDo toDo) async {
    await DBToDo.instance.delete(toDo.id);
    refreshToDoList();
  }


  List<Container> _listToDoContainer() {
    List<Container> listContainer = [];
    _toDoList.asMap().forEach((index, ToDo toDoItem) {
      listContainer.add(
        Container(
            padding: const EdgeInsets.symmetric(
              vertical: 5,
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                onPrimary: const Color(0xFFdddddd),
                primary: toDoItem.status == toDoDone ? const Color(0xFF7f7c82) : index%2 == 0 ? const Color(0xFFf9f9f9) : const Color(0xFFeeeeee),
                padding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 0
                )
              ),
              onPressed: () {
                _toggleToDoStatus(toDoItem);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                ),
                child: Row(
                  children: [
                   Container(
                     width: 40,
                     child: toDoItem.status == toDoDone ? const Icon(
                       Icons.check,
                       size: 16,
                     ) : null,
                   ),
                    Expanded(
                      child: Text(
                        toDoItem.label,
                        style: googleFontHandlee(
                            TextStyle(
                            color: toDoItem.status == toDoDone ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
                              decoration: toDoItem.status == toDoDone ? TextDecoration.lineThrough : null
                          )
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _deleteToDo(toDoItem);
                      },
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: toDoItem.status == toDoDone ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
      );
    });
    return listContainer;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: size.height,
        width: size.width,
        decoration: const BoxDecoration(
            color: Color(0xFFf3f1f5)
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 40,
          horizontal: 10
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 180,
              width: size.width,
              decoration: const BoxDecoration(
                color: Color(0xFF22577a)
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "To Do List - Flutter & SQLite",
                    style: googleFontHandlee(
                      const TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontWeight: FontWeight.w500,
                          fontSize: 20
                      )
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: const BoxDecoration(
                              color: Color(0xFFFFFFFF)
                          ),
                          child: TextField(
                            autofocus: true,
                            focusNode: nodeToDoInput,
                            controller: _toDoTextController,
                            style: googleFontHandlee(
                              const TextStyle(
								  
                              )
                            ),
                            decoration: const InputDecoration(
                                hintText: "Title ...",
                                border: InputBorder.none,
                                fillColor: Color(0xFFFFFFFF),
                                filled: true
                            ),
                            onSubmitted: (value) {
                              addToDo();
                            },
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          addToDo();
                        },
                        child: Container(
                          width: 60,
                          height: 40,
                          alignment: Alignment.center,
                          color: const Color(0xFF9d9d9d),
                          child: Text(
                            "Add",
                            style: googleFontHandlee(
                              const TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.w600
                              )
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            // body
            Container(
              height: size.height - 80 - 180,
              child: ListView(
                  shrinkWrap: true,
                  children: _listToDoContainer()
              ),
            )
          ],
        ),
      )
    );
  }
}

TextStyle googleFontHandlee(TextStyle textStyle) {
  return GoogleFonts.handlee(
    textStyle: textStyle,
  );
}