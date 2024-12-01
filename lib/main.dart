import 'dart:async'; // Timer 클래스를 사용하기 위한 패키지
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class Helper {
  static void goToStartScreen(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TimerScreen(
                  startTimer: true,
                )));
  }
}

int failedGames = 0;

// 구구단 게임
class MultiplicationGame extends StatefulWidget {
  const MultiplicationGame({super.key});

  @override
  State<MultiplicationGame> createState() => _MultiplicationGameState();
}

class _MultiplicationGameState extends State<MultiplicationGame> {
  late int number1;
  late int number2;
  String answer = "";

  bool correct = false;
  bool wrong = false;
  bool timeUp = false;

  late Timer timer;
  int timeLeft = 0;

  // 초기화 함수
  @override
  void initState() {
    super.initState();
    correct = false;
    wrong = false;
    timeUp = false;

    generateQuestion();
    startTimer();
  }

  // 문제 생성
  void generateQuestion() {
    setState(() {
      number1 = Random().nextInt(9) + 1;
      number2 = Random().nextInt(9) + 1;
    });
  }

  // 타이머 작동
  void startTimer() {
    timeLeft = 5;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          timer.cancel();
          timeUp = true;
          failedGames++;
          Future.delayed(Duration(seconds: 1), () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DifferentWordGame()),
            );
          });
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel(); // 화면이 닫힐 때 타이머 중지
    super.dispose();
  }

  // 정답 확인
  void checkAnswer() {
    int correctAnswer = number1 * number2; // 정답
    if (int.tryParse(answer) == correctAnswer) {
      setState(() {
        correct = true;
      });
    } else {
      setState(() {
        wrong = true;
        failedGames++;
      });
    }
    // 다음 문제로
    timer.cancel();
    Future.delayed(Duration(seconds: 1), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DifferentWordGame()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 상단
        title: Text("구구단 게임"),
        centerTitle: true,

        leading: IconButton(
            onPressed: () {
              timer.cancel();
              Helper.goToStartScreen(context);
            },
            icon: Icon(Icons.close)),

        actions: const [
          Text(
            "1/3",
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
      body: Column(
        // 중단
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
          ),
          Row(
            // 남은 시간
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer, size: 30),
              SizedBox(
                width: 20,
              ),
              Text(
                "$timeLeft 초",
                style: TextStyle(fontSize: 24),
              )
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Align(
            // 문제 / 정답
            alignment: Alignment.topCenter,
            child: Container(
                height: 100,
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$number1 x $number2 = ",
                      style: TextStyle(fontSize: 40),
                    ),
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          answer = value;
                        },
                        style: TextStyle(fontSize: 40),
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                        ),
                      ),
                    )
                  ],
                )),
          ),
          SizedBox(
            height: 30,
          ),
          ElevatedButton(
              onPressed: checkAnswer,
              child: Text(
                "정답 제출",
                style: TextStyle(fontSize: 25),
              )),
          SizedBox(
            height: 30,
          ),
          if (correct)
            Text(
              "정답!",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.green),
            ),
          if (wrong)
            Text(
              "오답...",
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w600, color: Colors.red),
            ),
          if (timeUp)
            Text(
              "시간 초과..",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.yellow),
            )
        ],
      ),
    );
  }
}

// 틀린 단어 찾기
class DifferentWordGame extends StatefulWidget {
  const DifferentWordGame({super.key});

  @override
  State<DifferentWordGame> createState() => _DifferentWordGameState();
}

class _DifferentWordGameState extends State<DifferentWordGame> {
  List<String> correctWordsList = ["소주", "디사", "맥주", "한잔"]; // 정답 단어 목록
  List<String> differentWordsList = ["수조", "다시", "백수", "한산"]; // 틀린 단어 목록
  late String correctWord;
  late String differentWord;
  List<String> questionWords = List.filled(16, "");
  late int differentWordIndex;

  bool correct = false;
  bool wrong = false;
  bool timeUp = false;

  late Timer timer;
  int timeLeft = 0;

  // 초기화 함수
  @override
  void initState() {
    super.initState();
    correct = false;
    wrong = false;
    timeUp = false;
    generateQuestion();
    startTimer();
  }

  // 문제 생성
  void generateQuestion() {
    // 문제 선택
    int wordsListIndex = Random().nextInt(3);
    correctWord = correctWordsList[wordsListIndex];
    differentWord = differentWordsList[wordsListIndex];

    // 문제 배치
    differentWordIndex = Random().nextInt(16);
    setState(() {
      questionWords.fillRange(0, 16, correctWord);
      questionWords[differentWordIndex] = differentWord;
    });
  }

  // 타이머 작동
  void startTimer() {
    timeLeft = 10;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          timer.cancel();
          failedGames++;
          Future.delayed(Duration(seconds: 1), () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TypingGame()),
            );
          });
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel(); // 화면이 닫힐 때 타이머 중지
    super.dispose();
  }

  void checkAnswer(int answer) {
    if (answer == differentWordIndex) {
      setState(() {
        correct = true;
      });
    } else {
      setState(() {
        wrong = true;
        failedGames++;
      });
    }
    timer.cancel();
    Future.delayed(Duration(seconds: 1), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TypingGame()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 상단
        title: Text("다른 단어 찾기"),
        centerTitle: true,

        leading: IconButton(
            onPressed: () {
              timer.cancel();
              Helper.goToStartScreen(context);
            },
            icon: Icon(Icons.close)),

        actions: const [
          Text(
            "2/3",
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Row(
              // 남은 시간
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer, size: 30),
                SizedBox(
                  width: 20,
                ),
                Text(
                  "$timeLeft 초",
                  style: TextStyle(fontSize: 24),
                )
              ],
            ),
            SizedBox(height: 50),

            // 문제
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 4x4 그리드
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                ),
                itemCount: 16,

                // 버튼 작동
                itemBuilder: (context, index) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.symmetric(vertical: 20.0), // 버튼 높이
                    ),
                    onPressed: () {
                      checkAnswer(index);
                    },
                    child: Text(
                      questionWords[index],
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                  );
                },
              ),
            ),

            if (correct)
              Text(
                "정답!",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.green),
              ),
            if (wrong)
              Text(
                "오답...",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.red),
              ),
            if (timeUp)
              Text(
                "시간 초과..",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.yellow),
              )
          ],
        ),
      ),
    );
  }
}

// 타자 게임
class TypingGame extends StatefulWidget {
  const TypingGame({super.key});

  @override
  State<TypingGame> createState() => _TypingGameState();
}

class _TypingGameState extends State<TypingGame> {
  List<String> questionList = [
    "동해 물과 백두산이 마르고 닳도록",
    "하느님이 보우하사 우리나라 만세",
    "남산 위에 저 소나무 철갑을 두른 듯",
    "바람 서리 불변함은 우리 기상일세",
    "가을 하늘 공활한데 높고 구름 없이",
    "밝은 달은 우리 가슴 일편단심일세",
    "이 기상과 이 맘으로 충성을 다하여",
    "괴로우나 즐거우나 나라 사랑하세",
    "무궁화 삼천리 화려 강산",
    "대한 사람 대한으로 길이 보전하세"
  ];
  late String question;
  String answer = "";

  bool correct = false;
  bool wrong = false;
  bool timeUp = false;

  late Timer timer;
  int timeLeft = 0;

  // 초기화 함수
  @override
  void initState() {
    super.initState();
    correct = false;
    wrong = false;
    timeUp = false;
    generateQuestion();
    startTimer();
  }

  // 문제 생성
  void generateQuestion() {
    // 문제 선택
    int wordsListIndex = Random().nextInt(9);
    question = questionList[wordsListIndex];
  }

  // 타이머 작동
  void startTimer() {
    timeLeft = 15;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          timer.cancel();
          failedGames++;
          Future.delayed(Duration(seconds: 1), () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GameEndScreen()),
            );
          });
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel(); // 화면이 닫힐 때 타이머 중지
    super.dispose();
  }

  void checkAnswer() {
    if (answer == question) {
      setState(() {
        correct = true;
      });
    } else {
      setState(() {
        wrong = true;
        failedGames++;
      });
    }
    timer.cancel();
    Future.delayed(Duration(seconds: 1), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GameEndScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 상단
        title: Text("타자 게임"),
        centerTitle: true,

        leading: IconButton(
            onPressed: () {
              timer.cancel();
              Helper.goToStartScreen(context);
            },
            icon: Icon(Icons.close)),

        actions: const [
          Text(
            "3/3",
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
          ),
          Row(
            // 남은 시간
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer, size: 30),
              SizedBox(
                width: 20,
              ),
              Text(
                "$timeLeft 초",
                style: TextStyle(fontSize: 24),
              )
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            width: 375,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  question,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24),
                ),
                TextField(
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, color: Colors.black54),
                  cursorColor: Colors.black54,
                  decoration: InputDecoration(),
                  onChanged: (value) {
                    answer = value;
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: checkAnswer,
              child: Text(
                "정답 제출",
                style: TextStyle(fontSize: 25),
              )),
          SizedBox(
            height: 30,
          ),
          if (correct)
            Text(
              "정답!",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.green),
            ),
          if (wrong)
            Text(
              "오답...",
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w600, color: Colors.red),
            ),
          if (timeUp)
            Text(
              "시간 초과..",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.yellow),
            )
        ],
      ),
    );
  }
}

// 종료 화면
class GameEndScreen extends StatefulWidget {
  const GameEndScreen({super.key});

  @override
  State<GameEndScreen> createState() => _GameEndScreenState();
}

class _GameEndScreenState extends State<GameEndScreen> {
  List<List<String>> warningList = [
    ["앗!", "조금 실수했네요.."],
    ["조심하세요!", "취한 것 같아요"],
    ["오늘은 여기까지!", "이제 집에 돌아가세요!"]
  ];
  String message1 = "!";
  String message2 = "!";

  @override
  void initState() {
    super.initState();
    printMessage();
  }

  void printMessage() {
    if (failedGames < 4) {
      message1 = warningList[failedGames - 1][0];
      message2 = warningList[failedGames - 1][1];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("게임 종료"),
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                Helper.goToStartScreen(context);
              },
              icon: Icon(Icons.close)),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
            ),
            SizedBox(
              height: 80,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 50,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "틀린 개수: $failedGames개",
                  style: TextStyle(fontSize: 30),
                ),
              ],
            ),
            SizedBox(
              height: 100,
            ),
            Container(
              width: 300,
              height: 120,
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$message1",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "$message2",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 70,
            ),
            ElevatedButton(
                onPressed: () {
                  Helper.goToStartScreen(context);
                },
                child: Text(
                  "홈 화면으로",
                  style: TextStyle(fontSize: 28, color: Colors.black),
                ))
          ],
        ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      home: SplashScreen(), // 앱 시작 시 SplashScreen 화면을 먼저 띄움
    );
  }
}

// SplashScreen 화면: 로고를 잠깐 보여주는 화면
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 3초 후에 HomeScreen으로 이동
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색 설정 (원하는 색으로 바꿀 수 있음)
      body: Center(
        child: Image.asset("assets/로고.png"), // 로고 이미지 표시
      ),
    );
  }
}

// 홈 화면
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {},
          ),
        ],
        title: Text("딱 한 잔"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, // 세로로 정렬
        children: [
          SizedBox(height: 300),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: Size(150, 70)),
              onPressed: () {
                // 타이머 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TimerScreen(startTimer: true)),
                );
              },
              child: Text(
                "기록 시작",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 350),
          Column(
            children: [
              Container(
                alignment: Alignment.bottomCenter,
                child: Text(
                  "과도한 음주는 간질환, 관상동맥, 심장질환 및 뇌졸중 위험을 높입니다", // 원하는 텍스트
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// 두 번째 화면 (타이머 작동 중 화면)
class TimerScreen extends StatefulWidget {
  final bool startTimer;
  TimerScreen({required this.startTimer});
  @override
  _TimerScreenState createState() => _TimerScreenState();
}

int time = 0;
int number = 0;

class _TimerScreenState extends State<TimerScreen> {
  // 마셨어요 버튼 클릭 시 증가하는 변수
  // 타이머에 의해 증가하는 시간 변수
  Timer? _timer; // 타이머 객체
  bool _isTimerRunning = false; // 타이머 상태 관리 변수

  // 타이머 시작
  void _startTimer() {
    _isTimerRunning = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        time++; // 1초마다 time을 1씩 증가
      });
    });
  }

  // 타이머 멈추기
  void _stopTimer() {
    _isTimerRunning = false;
    _timer?.cancel(); // 타이머 멈추기
  }

  // 타이머 리셋
  void _resetTimer() {
    setState(() {
      time = 0; // 타이머 리셋
    });
    _stopTimer(); // 타이머 멈추기
  }

  // @override
  // void dispose() {
  //   _timer?.cancel(); // 화면 종료 시 타이머를 멈추기
  //   super.dispose();
  // }

  // 시간, 분, 초로 변환하는 함수
  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600; // 시간을 계산
    int minutes = (seconds % 3600) ~/ 60; // 분을 계산
    int remainingSeconds = seconds % 60; // 나머지 초 계산

    // 형식: 00:00:00 (시간:분:초)
    return '${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(remainingSeconds)}';
  }

  // 두 자릿수로 반환하는 함수 (예: 1 => 01)
  String _twoDigits(int number) {
    if (number < 10) {
      return '0$number';
    } else {
      return '$number';
    }
  }

  @override
  void initState() {
    super.initState();
    // 타이머 시작 매개변수가 true일 경우 타이머 시작
    if (_isTimerRunning == false) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center, // 아이콘 중앙에 배치
                  margin: EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.timer,
                    size: 50,
                  ),
                ),
                Container(
                  color: Colors.white,
                  margin: EdgeInsets.only(right: 20),
                  child: Text(
                    _formatTime(time), // time을 형식화하여 표시
                    style: TextStyle(fontSize: 30),
                  ),
                ),
                Container(
                  alignment: Alignment.center, // 이미지를 중앙에 배치
                  margin: EdgeInsets.only(right: 20),
                  child: Image.asset("assets/한잔이미지.png"), // 이미지를 표시
                ),
                Container(
                  color: Colors.white,
                  margin: EdgeInsets.only(right: 20),
                  child: Text(
                    "$number", // number 값을 텍스트로 표시
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ElevatedButton(
                //   onPressed: _isTimerRunning
                //       ? null
                //       : () {
                //           _startTimer(); // 타이머 시작
                //         },
                //   child: Text("타이머 시작"),
                // ),

                //SizedBox(height: 20),
                Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size(100, 70)),
                        onPressed: !_isTimerRunning
                            ? null
                            : () {
                                _stopTimer(); // 타이머 멈추기
                              },
                        child: Text("기록 끝내기"),
                      ),
                    ),
                  ],
                )

                //SizedBox(width: 20),
                // ElevatedButton(
                //   onPressed: () {
                //     _resetTimer(); // 타이머 리셋
                //   },
                //   child: Text("타이머 리셋"),
                // ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 400, right: 10),
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        number += 1; // number를 1만큼 증가
                      });
                    },
                    child: Text(
                      '마셨어요',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 400, left: 10),
                  child: OutlinedButton(
                    onPressed: () {
                      failedGames = 0;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MultiplicationGame()));
                    },
                    child: Text(
                      '게임하기',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
