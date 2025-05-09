import 'package:flutter/material.dart';
import 'db_helper.dart';

void main() {
  runApp(MyApp());
}

const Color primaryColor = Colors.yellow;
const Color accentColor = Colors.black;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leader Student App',
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(backgroundColor: primaryColor, foregroundColor: accentColor),
      ),
      home: AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLeader = true;
  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLeader ? 'Leader Login' : 'Student Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: userCtrl, decoration: InputDecoration(labelText: isLeader ? 'Username' : 'Reg No')),
          TextField(controller: passCtrl, obscureText: true, decoration: InputDecoration(labelText: 'Password')),
          ElevatedButton(
            onPressed: () async {
              final user = userCtrl.text.trim();
              final pass = passCtrl.text.trim();
              if (isLeader) {
                if (user == 'leader' && pass == 'leader123') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => LeaderPage()));
                } else {
                  _error('Invalid leader credentials');
                }
              } else {
                final student = await DBHelper.instance.getStudent(user, pass);
                if (student != null) {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => StudentPage(
                      school: student['school'],
                      dept: student['department'],
                      year: student['year'],
                    ),
                  ));
                } else {
                  _error('Invalid student credentials');
                }
              }
            },
            child: Text('Login'),
          ),
          TextButton(
            onPressed: () => setState(() => isLeader = !isLeader),
            child: Text(isLeader ? 'Login as Student' : 'Login as Leader'),
          ),
          if (!isLeader)
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentRegisterPage())),
              child: Text('Register as Student'),
            )
        ]),
      ),
    );
  }

  void _error(String msg) {
    showDialog(context: context, builder: (_) => AlertDialog(title: Text('Error'), content: Text(msg)));
  }
}

class StudentRegisterPage extends StatelessWidget {
  final reg = TextEditingController();
  final pass = TextEditingController();
  final school = TextEditingController();
  final dept = TextEditingController();
  final year = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register Student')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: reg, decoration: InputDecoration(labelText: 'Reg No')),
          TextField(controller: pass, obscureText: true, decoration: InputDecoration(labelText: 'Password')),
          TextField(controller: school, decoration: InputDecoration(labelText: 'School')),
          TextField(controller: dept, decoration: InputDecoration(labelText: 'Department')),
          TextField(controller: year, decoration: InputDecoration(labelText: 'Year')),
          ElevatedButton(
            onPressed: () async {
              await DBHelper.instance.registerStudent(
                reg.text.trim(), pass.text.trim(), school.text.trim(), dept.text.trim(), year.text.trim());
              Navigator.pop(context);
            },
            child: Text('Register'),
          )
        ]),
      ),
    );
  }
}

class LeaderPage extends StatefulWidget {
  @override
  _LeaderPageState createState() => _LeaderPageState();
}

class _LeaderPageState extends State<LeaderPage> {
  final title = TextEditingController();
  final msg = TextEditingController();
  final role = TextEditingController();
  final file = TextEditingController(); // Simulate filename
  final school = TextEditingController();
  final dept = TextEditingController();
  final year = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Send Message')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: title, decoration: InputDecoration(labelText: 'Title')),
          TextField(controller: msg, maxLines: 5, decoration: InputDecoration(labelText: 'Message')),
          TextField(controller: role, decoration: InputDecoration(labelText: 'Your Role')),
          TextField(controller: file, decoration: InputDecoration(labelText: 'Attach File (name only)')),
          TextField(controller: school, decoration: InputDecoration(labelText: 'School')),
          TextField(controller: dept, decoration: InputDecoration(labelText: 'Department')),
          TextField(controller: year, decoration: InputDecoration(labelText: 'Year')),
          ElevatedButton(
            onPressed: () async {
              await DBHelper.instance.sendMessage(
                title: title.text,
                msg: msg.text,
                file: file.text,
                school: school.text,
                dept: dept.text,
                year: year.text,
                role: role.text,
              );
              _clear();
            },
            child: Text('Send'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ManageMessagesPage())),
            child: Text('Manage Sent Messages'),
          ),
        ]),
      ),
    );
  }

  void _clear() {
    title.clear();
    msg.clear();
    role.clear();
    file.clear();
    school.clear();
    dept.clear();
    year.clear();
  }
}

class ManageMessagesPage extends StatefulWidget {
  @override
  _ManageMessagesPageState createState() => _ManageMessagesPageState();
}

class _ManageMessagesPageState extends State<ManageMessagesPage> {
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    messages = await DBHelper.instance.getAllMessages();
    setState(() {});
  }

  void _editMessage(Map<String, dynamic> msg) {
    final title = TextEditingController(text: msg['title']);
    final content = TextEditingController(text: msg['message']);
    final file = TextEditingController(text: msg['file']);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Message'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: title, decoration: InputDecoration(labelText: 'Title')),
          TextField(controller: content, decoration: InputDecoration(labelText: 'Message')),
          TextField(controller: file, decoration: InputDecoration(labelText: 'File')),
        ]),
        actions: [
          TextButton(
            onPressed: () async {
              await DBHelper.instance.updateMessage(msg['id'], title.text, content.text, file.text);
              Navigator.pop(context);
              _load();
            },
            child: Text('Save'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sent Messages')),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (_, i) {
          final m = messages[i];
          return ListTile(
            title: Text(m['title']),
            subtitle: Text(m['message']),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: Icon(Icons.edit), onPressed: () => _editMessage(m)),
              IconButton(icon: Icon(Icons.delete), onPressed: () async {
                await DBHelper.instance.deleteMessage(m['id']);
                _load();
              }),
            ]),
          );
        },
      ),
    );
  }
}

class StudentPage extends StatefulWidget {
  final String school, dept, year;

  StudentPage({required this.school, required this.dept, required this.year});

  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    messages = await DBHelper.instance.getMessagesForStudent(widget.school, widget.dept, widget.year);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Messages')),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (_, i) {
          final m = messages[i];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(m['title'], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m['message']),
                if (m['file'] != '') Text('File: ${m['file']}'),
                Text('From: ${m['senderRole']}'),
                Text('At: ${m['createdAt']}'),
              ]),
            ),
          );
        },
      ),
    );
  }
}
