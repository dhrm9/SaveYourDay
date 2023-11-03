
import 'package:hive_flutter/hive_flutter.dart';

class ToDoDataBase {
  
  List toDoList = [];


  //refrence our box 
  final _mybox = Hive.box('mybox');
  
   //run this method if app is opening very first time
   void createInitialData() {
    toDoList = [
      ["make tutorial",false],
      ["do excercise",false],
    ];
   }
   

   //load the data from database

   void loadData(){
     toDoList = _mybox.get("TODOLIST");
   }

   //update the database
   
   void updateDataBase(){
      _mybox.put("TODOLIST", toDoList);
   }


}