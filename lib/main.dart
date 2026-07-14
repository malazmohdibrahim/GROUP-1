// phase 1&2:
// STATIC:
// Gives access to blur effects used in glassmorphism design.
import 'dart:ui' as ui;
//  Imports Flutter's Material Design widgets.
import 'package:flutter/material.dart';
import 'splash_screen.dart'; // to ba able to connect to the splash screen

//Runs the app for the first time.
void main() {
  runApp(const StudyPlannerApp());
}

//STATIC
// we build the entire app as a stateless widget because the background never changes
class StudyPlannerApp extends StatelessWidget {
  const StudyPlannerApp({super.key});
  @override
  // STATIC: Builds the MaterialApp and applies the app theme.
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // removes debug from top right corner
      title: 'Study Planner App', //The application's title
      theme: ThemeData(
        useMaterial3: true, //flutter's newest design system
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffE2B566),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xffC5B5D5),
      ),
      home:
          const SplashScreen(), // LOGIC: tells chrome to start with the splash screen everytime
      routes: {'/home': (context) => const HomeScreen()},
    );
  }
} //LOGIC

// home screen is stateful because some elements change
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState(); // Holds the state and data of the HomeScreen.
}

class _HomeScreenState extends State<HomeScreen> {
  //we use a list to store all missions because we don't have database yet
  // list is final because it has a strict structure that doent change
  final List<Map<String, dynamic>> _missions = [
    {
      'title': 'Flutter Course',
      'subtitle': '4 Hours',
      'icon': Icons.code,
      'progress': 0.40,
      'done': false,
      'hours': 4,
    },
    {
      'title': 'Database Assignment',
      'subtitle': '3 Hours',
      'icon': Icons.storage,
      'progress': 0.75,
      'done': false,
      'hours': 3,
    },
  ]; //LOGIC
  // delete function
  void _deleteMission(int index) {
    setState(() {
      //  Rebuilds the UI after deleting a mission.
      _missions.removeAt(index);
    });
  }

  //popup message animation after commpletting mission
  void _showCompletedDialog(String title) {
    showGeneralDialog(
      // STATIC: Creates the popup design and animations.
      context: context,
      barrierDismissible:
          true, //allows users to click anywhere to dismiss the pop up
      barrierLabel: 'Mission completed',
      barrierColor: Colors.black.withValues(alpha: .18),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
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
                      color: Colors.white.withValues(alpha: .90),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .95),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff8D79A0).withValues(alpha: .18),
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
                                color: const Color(
                                  0xff91B77A,
                                ).withValues(alpha: .30),
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
                              //LOGIC
                              Navigator.pop(
                                dialogContext,
                              ); //logic : return to homepage
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
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(begin: .88, end: 1).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: scaleAnimation, child: child),
        );
      },
    );
  }

  //LOGIC
  //change  mission state
  void _toggleMissionDone(int index) {
    final wasDone =
        _missions[index]['done'] ==
        true; //Stores the previous completion state.
    setState(() {
      _missions[index]['done'] = !wasDone;
      if (_missions[index]['done'] == true) {
        _missions[index]['progress'] = 1.0;
        _missions[index]['subtitle'] = 'Completed 🎉';
      } else {
        _missions[index]['progress'] = 0.5;
        _missions[index]['subtitle'] = '${_missions[index]['hours']} Hours';
      }
    });
    if (!wasDone) {
      // LOGIC: Shows the completion popup only when a mission is completed.
      _showCompletedDialog(_missions[index]['title'].toString());
    }
  }

  //phase 4:
  // LOGIC:
  //1.  Calculates the total number of planned study hours.
  int get _totalHours {
    return _missions.fold(0, (sum, item) => sum + (item['hours'] as int));
  }

  // 2. Count how many missions have been completed.
  int get _completedCount {
    return _missions.where((item) => item['done'] == true).length;
  }

  @override
  // STATIC:
  //Builds the entire user interface of the Home Screen.
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
              color: const Color(0xffE2B566).withValues(alpha: .38),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton(
          // STATIC: create container for + button
          elevation: 0,
          backgroundColor: Colors.transparent,
          onPressed: () async {
            // LOGIC: Opens the AddGoalScreen and waits for the returned mission.
            final newGoal = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddGoalScreen()),
            );
            if (newGoal != null) {
              setState(() {
                // LOGIC: Adds the new mission to the list and updates the UI.
                _missions.add(newGoal);
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
            child: Image.asset(
              'assets/images/image.jpg',
              fit: BoxFit.cover,
            ), // STATIC: Displays the background image.
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: .05),
                    const Color(0xffC5B5D5).withValues(alpha: .12),
                    const Color(0xffBCA8CB).withValues(alpha: .22),
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
                              color: const Color(
                                0xffE2B566,
                              ).withValues(alpha: .28),
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
                  glassCard(
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
                                ).withValues(alpha: .30),
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
                          "Study Warrior ⚔️",
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
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffFFF8ED).withValues(alpha: .72),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .80),
                      ),
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
                          emoji: "🎯",
                          number:
                              "${_missions.length}", // LOGIC: Reads the current number of missions.
                          title: "Goals",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCardWidget(
                          emoji: "⏳",
                          number:
                              "$_totalHours", // LOGIC: Reads the calculated total hours.
                          title: "Hours",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCardWidget(
                          emoji: "✅",
                          number:
                              "$_completedCount", // LOGIC: Reads the number of completed missions.
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
                  _missions
                          .isEmpty // LOGIC: Checks if there are any missions left.
                      ? glassCard(
                          child: const Text(
                            "No missions left! Great job! 🌟", // STATIC: Displays a message when no missions exist.
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
                            // LOGIC: Generates a mission card for every mission in the list.
                            final mission = _missions[index];
                            return missionCard(
                              title: mission['title'],
                              subtitle: mission['subtitle'],
                              icon: mission['icon'],
                              progress: mission['progress'],
                              isDone: mission['done'],
                              onToggleDone: () => _toggleMissionDone(index),
                              onDelete: () => _deleteMission(index),
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
} // STATIC:

//Reusable glassmorphism card widget used throughout the app.
Widget glassCard({required Widget child}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 9, sigmaY: 9),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withValues(alpha: .76),
          border: Border.all(
            color: Colors.white.withValues(alpha: .88),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff8D79A0).withValues(alpha: .13),
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
//state card function
class StatCardWidget extends StatelessWidget {
  final String emoji;
  final String number;
  final String title;

  const StatCardWidget({
    super.key,
    required this.emoji,
    required this.number,
    required this.title,
  });
  //STATIC
  @override
  Widget build(BuildContext context) {
    return glassCard(
      //a form of the glass card wqe created earlier
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 25)),
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
//reusable mission card widget
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
      //has same style as glass card widget
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
                onPressed:
                    onDelete, // LOGIC: Calls the function that changes the mission state.
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

//PHASE 3:
// LOGIC: Screen for adding a new study mission.
class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

// LOGIC:
// Stores and manages the form data
class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey =
      GlobalKey<FormState>(); //  Identifies and validates the form.
  String _subjectName = ''; // Stores the entered subject name.

  int _hours = 0; // Stores the entered study hours

  @override
  //STATIC : style of add goal page
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffC5B5D5),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/image.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              color: const Color(0xffC5B5D5).withValues(alpha: .14),
            ),
          ),
          SafeArea(
            //avoids camera holes
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .68),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .80),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xff5E4A69),
                          ),
                          onPressed: () {
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
                                  ).withValues(alpha: .26),
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
                              fillColor: Colors.white.withValues(alpha: .80),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: .90),
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
                            validator: (value) {
                              /// LOGIC: Validates that the subject name is not empty.
                              if (value == null || value.trim().isEmpty) {
                                return "Enter subject name";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              // LOGIC: Saves the entered subject name.
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
                              fillColor: Colors.white.withValues(alpha: .80),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: .90),
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
                            validator: (value) {
                              // LOGIC: Validates that the entered hours are valid
                              if (value == null ||
                                  int.tryParse(value) == null ||
                                  int.parse(value) <= 0) {
                                return "Enter valid hours";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              // LOGIC: Saves the entered hours.
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
                              ), //LOGIC
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  //  Checks that the form is valid before saving.
                                  _formKey.currentState!
                                      .save(); // LOGIC: Saves all form field values.
                                  Navigator.pop(context, {
                                    // Sends the new mission back to HomeScreen
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
