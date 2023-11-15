class User {
  String userid;
  String email;
  String password;
  String accessType;
  List<String> tasks;

  User({
    required this.accessType,
    required this.password,
    required this.email,
    required this.userid,
    required this.tasks,
  });

  Map<String, dynamic> getdata() => {
        'userid': userid,
        'email': email,
        'password': password,
        'accessType': accessType,
        'tasks': tasks,
      };
}
