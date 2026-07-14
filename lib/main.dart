//Phase 1&2:
//STATIC
//import flutter design element
import 'dart:ui' as ui;
// LOGIC: Helps create correct database file paths regardless of the operating system.
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'splash_screen.dart'; //connects home screen and splash screen

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
//LOGIC
//  Start the Flutter application and loads the root widget.
void main() {
  runApp(const StudyPlannerApp());
}

//STATIC
// we create then entire app as a stateless widget because the background never changes
class StudyPlannerApp extends StatelessWidget {
  const StudyPlannerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // LOGIC: Returns the Material application wrapper.
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner:
          false, // LOGIC: removes debug from top rigth corner
      title: 'Study Planner App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffE2B566),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xffC5B5D5),
      ),
      home:
          const SplashScreen(), //LOGIC: tells flutter to always start with splash screen
      routes: {'/home': (context) => const HomeScreen()},
    );
  }
} //phase 5:

//LOGIC
//handles permanent data storage using SQLite
// allows creating, saving, updating and deleting missions
class DatabaseHelper {
  static final DatabaseHelper instance =
      DatabaseHelper._init(); // LOGIC: ensures only one database instance
  static Database?
  _database; // Stores the database connection as it is not created immediately
  // Creates or opens the local SQLite database everytime the application starts.
  DatabaseHelper._init();
  Future<Database> get database async {
    //  If database already exists, it returns it.Otherwise, it creates a new one.
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!; // Returns the active database connection.
  } // LOGIC:

  // Creates the SQLite database file.
  Future<Database> _initDatabase() async {
    final databasePath =
        await getDatabasesPath(); //waits for the path check to be complete
    final path = join(
      databasePath,
      'study_planner.db',
    ); // Creates the complete path of the database file.

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase, // Function called when database is created.
      onOpen: (db) async {
        // Runs every time database opens.
        await _createDatabase(db, 1);
      },
    );
  }

  // LOGIC:
  // Create
  Future<void> _createDatabase(Database db, int version) async {
    // Executes SQL command to create the goals table.
    await db.execute('''
      CREATE TABLE IF NOT EXISTS goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT NOT NULL,
        hours INTEGER NOT NULL,
        done INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // LOGIC:
  // Insert
  Future<int> insertGoal({required String subject, required int hours}) async {
    final db = await instance.database; //get connection first
    // Inserts a new row into the goals table and Returns the ID of the inserted goal.
    return await db.insert('goals', {
      'subject': subject,
      'hours': hours,
      'done': 0,
    });
  }

  // LOGIC:
  // Retrieve (SELECT)
  Future<List<Map<String, dynamic>>> getGoals() async {
    final db = await instance.database; // get connection first
    // Reads all rows from goals table and Newest goals appear first.
    return await db.query('goals', orderBy: 'id DESC');
  }

  // LOGIC:
  // Update.
  Future<int> updateGoalDone({required int id, required bool done}) async {
    final db = await instance.database; // open connection

    return await db.update(
      // Updates the selected goal.
      'goals',
      {
        'done': done ? 1 : 0,
      }, // LOGIC:Converts Boolean value into SQLite integer.
      where: 'id = ?',
      whereArgs: [id], // Sends ID value safely into SQL query.
    );
  } //LOGIC

  //DELETE
  Future<int> deleteGoal(int id) async {
    final db = await instance.database;
    // Removes the selected goal using its ID.
    return await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }
}

// LOGIC:
// StatefulWidget is used because this screen changes
// when goals are added, completed, or deleted.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Temporary list holding goals currently displayed the Data comes from SQLite database.
  final List<Map<String, dynamic>> _missions = [];

  @override
  void initState() {
    // Runs automatically when screen is created.
    super.initState();
    _loadGoals();
  }

  //LOGIC: Reads goals from SQLite and converts them into objects used by the UI.
  Future<void> _loadGoals() async {
    final savedGoals = await DatabaseHelper.instance
        .getGoals(); // Gets saved goals from database.
    if (!mounted) return; // Prevents updating screen if it was removed.
    setState(() {
      // rebuilds screen everytime a change occurs
      _missions.clear();
      // Loops through every saved goal.
      for (final goal in savedGoals) {
        final isDone = goal['done'] == 1;
        final hours = goal['hours'] as int;
        // LOGIC: Adds database goal into the screen list.
        _missions.add({
          'id': goal['id'],
          'title': goal['subject'],
          'subtitle': isDone ? 'Completed!' : '$hours Hours',
          'icon': Icons.menu_book,
          'progress': isDone ? 1.0 : 0.0,
          'done': isDone, //stors comopletion logic (defined earlier)
          'hours': hours,
        });
      }
    });
  } //PHASE 2:

  //LOGIC
  //delete mission function deletes from the list and the database
  Future<void> _deleteMission(int index) async {
    final id = _missions[index]['id'] as int;
    await DatabaseHelper.instance.deleteGoal(
      id,
    ); //calls the delete function from the databse
    if (!mounted)
      return; // Checks if the widget is still active before updating UI.
    setState(() {
      _missions.removeWhere(
        (mission) => mission['id'] == id,
      ); // Removes the selected mission from displayed list.
    });
  }

  //STATIC
  //UI design and animation of the popup card
  void _showCompletedDialog(String title) {
    final dialogContext = appNavigatorKey.currentContext;
    if (dialogContext == null) return;
    showGeneralDialog(
      context: dialogContext,
      barrierDismissible: true, //closes tab when users click anywhere
      barrierLabel: 'Mission completed',
      barrierColor: Colors.black.withOpacity(.18),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (popupContext, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(26),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 340),
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.90),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withOpacity(.95),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff8D79A0).withOpacity(.18),
                          blurRadius: 26,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xffCDE7BE),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xff91B77A).withOpacity(.30),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Color(0xff527C45),
                            size: 52,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          "Mission Complete!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xff43324D),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          //LOGIC: string interpolation
                          "$title is done. Proud of you, keep this energy going!",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xff735F7D),
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffE2B566),
                              foregroundColor: const Color(0xff7A562E),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              // LOGIC: Removes popup from screen.
                              Navigator.pop(popupContext);
                            },
                            child: const Text(
                              "Nice!",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }, //STATIC: animation
      transitionBuilder: (popupContext, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(begin: .88, end: 1).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: scaleAnimation, child: child),
        );
      },
    );
  } //LOGIC

  // function for changing mission state
  Future<void> _toggleMissionDone(int index) async {
    final id =
        _missions[index]['id']
            as int; // Gets the unique database ID of the selected mission.
    final title = _missions[index]['title'].toString();
    final wasDone = _missions[index]['done'] == true;
    final newDoneValue = !wasDone; // Reverses the current state.
    setState(() {
      _missions[index]['done'] =
          newDoneValue; // Saves the new completion status.
      if (newDoneValue) {
        _missions[index]['progress'] = 1.0;
        _missions[index]['subtitle'] = 'Completed!';
      } else {
        _missions[index]['progress'] = 0.0;
        _missions[index]['subtitle'] = '${_missions[index]['hours']} Hours';
      }
    });

    if (newDoneValue) {
      _showCompletedDialog(title); // tells flutter to show the popup animation
    }
    //saves update in database
    await DatabaseHelper.instance.updateGoalDone(id: id, done: newDoneValue);
  }

  //PHASE 4:
  // LOGIC:
  //1.  using fold dunction to calculate total hours
  int get _totalHours {
    return _missions.fold(0, (sum, item) => sum + (item['hours'] as int));
  }

  //2. calculates total number of missions
  int get _completedCount {
    return _missions.where((item) => item['done'] == true).length;
  }

  //STATIC
  //builds entire UI of homescreen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffC5B5D5),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xffF3D99C), Color(0xffE2B566)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xffE2B566).withOpacity(.38),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: Colors.transparent,
          onPressed: () async {
            //PHASE 3:
            // LOGIC:Opens Add Goal screen.
            final newGoal = await Navigator.push(
              // Waits until AddGoalScreen returns data.
              context,
              MaterialPageRoute(builder: (context) => const AddGoalScreen()),
            );

            if (newGoal != null) {
              final newMission = Map<String, dynamic>.from(
                newGoal as Map,
              ); //LOGIC Converts returned object into a Map.;

              final id = await DatabaseHelper.instance.insertGoal(//LOGIC : CALLS  INSERT FUNCTION I DATABSE
                subject: newMission['title'].toString(),
                hours: newMission['hours'] as int,
              );

              newMission['id'] = id;

              if (!mounted) return;

              setState(() {// reload page
                _missions.insert(0, newMission);
              });
            }
          },
          child: const Icon(
            Icons.add_rounded,
            color: Color(0xff7A562E),
            size: 32,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/image.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(.05),
                    const Color(0xffC5B5D5).withOpacity(.12),
                    const Color(0xffBCA8CB).withOpacity(.22),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome Back",
                              style: TextStyle(
                                color: Color(0xff43324D),
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                height: 1.05,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Your study desk is ready.",
                              style: TextStyle(
                                color: Color(0xff6F5E79),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xffF4DEAA), Color(0xffE2B566)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xffE2B566).withOpacity(.28),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xffFFF8ED),
                          child: Icon(
                            Icons.person_rounded,
                            color: Color(0xff7F688E),
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: 320,
                    child: glassCard(
                      child: Column(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xffFFF0C9), Color(0xffE2B566)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xffE2B566,
                                  ).withOpacity(.30),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Color(0xff78552E),
                              size: 44,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            "Level 5",
                            style: TextStyle(
                              color: Color(0xff43324D),
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Study Warrior",
                            style: TextStyle(
                              color: Color(0xff735F7D),
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 22),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: .72),
                              duration: const Duration(seconds: 2),
                              builder: (context, value, child) {
                                return LinearProgressIndicator(
                                  value: value,
                                  minHeight: 14,
                                  borderRadius: BorderRadius.circular(16),
                                  backgroundColor: const Color(0xffEFE5F4),
                                  valueColor: const AlwaysStoppedAnimation(
                                    Color(0xffE2B566),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "720 / 1000 XP",
                                style: TextStyle(
                                  color: Color(0xff6D5A78),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "72%",
                                style: TextStyle(
                                  color: Color(0xffA87935),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffFFF8ED).withOpacity(.72),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(.80)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lightbulb_rounded, color: Color(0xffC99643)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Small progress today becomes big results later.",
                            style: TextStyle(
                              color: Color(0xff5F4D68),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: StatCardWidget(
                          icon: Icons.track_changes_rounded,
                          number: "${_missions.length}",//LOGIC: flutter reads from  list
                          title: "Goals",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCardWidget(
                          icon: Icons.hourglass_bottom_rounded,
                          number: "$_totalHours",,//LOGIC: flutter reads from  total hour function
                          title: "Hours",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCardWidget(
                          icon: Icons.check_circle_rounded,
                          number: "$_completedCount",,//LOGIC: flutter reads from completed  function
                          title: "Done",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Today's Missions",
                      style: TextStyle(
                        color: Color(0xff43324D),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _missions.isEmpty
                      ? glassCard(
                          child: const Text(
                            "No missions yet. Add your first study goal!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xff6D5A78),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : Column(
                          children: List.generate(_missions.length, (index) {
                            final mission = _missions[index];

                            return missionCard(
                              title: mission['title'],
                              subtitle: mission['subtitle'],
                              icon: mission['icon'],
                              progress: mission['progress'],
                              isDone: mission['done'],
                              onToggleDone: () => _toggleMissionDone(index),//LOGIC : flutters executes toggle function
                              onDelete: () => _deleteMission(index),//LOGIC: flutter executes delete function
                            );
                          }),
                        ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
//STATIC
//reusable widget with specific UI elements
Widget glassCard({required Widget child}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 9, sigmaY: 9),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withOpacity(.76),
          border: Border.all(color: Colors.white.withOpacity(.88), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff8D79A0).withOpacity(.13),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: child,
      ),
    ),
  );
}
//STATIC 
class StatCardWidget extends StatelessWidget {
  final IconData icon;
  final String number;
  final String title;

  const StatCardWidget({
    super.key,
    required this.icon,
    required this.number,
    required this.title,
  });
///STATIC
  @override
  Widget build(BuildContext context) {
    return glassCard(// type of reusable glass card widget
      child: Column(
        children: [
          Icon(icon, color: const Color(0xffA87935), size: 26),
          const SizedBox(height: 10),
          Text(
            number,
            style: const TextStyle(
              color: Color(0xff43324D),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xff735F7D),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
//STATIC 
Widget missionCard({
  required String title,
  required String subtitle,
  required IconData icon,
  required double progress,
  required bool isDone,
  required VoidCallback onToggleDone,
  required VoidCallback onDelete,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: glassCard(
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isDone
                    ? [const Color(0xffDDF0D0), const Color(0xffA9CF93)]
                    : [const Color(0xffEEE1F7), const Color(0xffD7C0E8)],
              ),
            ),
            child: Icon(
              icon,
              color: isDone ? const Color(0xff56804B) : const Color(0xff735A86),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xff43324D),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xff735F7D)),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xffEEE4F3),
                    valueColor: AlwaysStoppedAnimation(
                      isDone
                          ? const Color(0xffA9CF93)
                          : const Color(0xffE2B566),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              IconButton(
                icon: Icon(
                  isDone ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: isDone
                      ? const Color(0xff7CA966)
                      : const Color(0xff735F7D),
                ),
                onPressed: onToggleDone,
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xffC98A8A),
                  size: 21,
                ),
                onPressed: onDelete,// LOGIC 
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
//PHASE 3:
//LOGIC
//creates second add goal page
class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});
  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}
class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  String _subjectName = '';
  int _hours = 0;
//STATIC: style of add goal page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffC5B5D5),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/image.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: const Color(0xffC5B5D5).withOpacity(.14)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.68),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withOpacity(.80),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xff5E4A69),
                          ),
                          onPressed: () {// LOGIC: flutter returns to home screen
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Add New Mission",
                          style: TextStyle(
                            color: Color(0xff43324D),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  glassCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Container(
                            width: 82,
                            height: 82,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xffFFF0C9), Color(0xffE2B566)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xffE2B566,
                                  ).withOpacity(.26),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              size: 40,
                              color: Color(0xff7A562E),
                            ),
                          ),
                          const SizedBox(height: 25),
                          TextFormField(
                            style: const TextStyle(color: Color(0xff43324D)),
                            decoration: InputDecoration(
                              hintText: "Subject Name",
                              hintStyle: const TextStyle(
                                color: Color(0xff8C7A97),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(.80),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(.90),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xffE2B566),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            validator: (value) {//LOGIC: users cant leave field empty
                              if (value == null || value.trim().isEmpty) {
                                return "Enter subject name";
                              }

                              return null;
                            },
                            onSaved: (value) {// LOGIC : returns value when saved
                              _subjectName = value!;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            style: const TextStyle(color: Color(0xff43324D)),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "Planned Hours",
                              hintStyle: const TextStyle(
                                color: Color(0xff8C7A97),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(.80),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(.90),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xffE2B566),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            validator: (value) {//LOGIC: users cant leave hours field empty
                              if (value == null ||
                                  int.tryParse(value) == null ||
                                  int.parse(value) <= 0) {
                                return "Enter valid hours";
                              }

                              return null;
                            },
                            onSaved: (value) {//LOGIC: returns value when saved 
                              _hours = int.parse(value!);
                            },
                          ),
                          const SizedBox(height: 35),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffE2B566),
                                foregroundColor: const Color(0xff7A562E),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {//LOGIC: returns to home screen and updates list and database
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  Navigator.pop(context, {
                                    'title': _subjectName,
                                    'subtitle': '$_hours Hours',
                                    'icon': Icons.menu_book,
                                    'progress': 0.0,
                                    'done': false,
                                    'hours': _hours,
                                  });
                                }
                              },
                              child: const Text(
                                "Save Mission",
                                style: TextStyle(
                                  color: Color(0xff7A562E),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
