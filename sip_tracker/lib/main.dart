import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DateTime _selectedDay = DateTime.now(); // 선택된 날짜
  DateTime _focusedDay = DateTime.now(); // 캘린더에서 집중된 날짜

  // 날짜별 이벤트를 저장하는 Map
  Map<DateTime, String> _events = {
    DateTime(2024, 11, 26): '기록',
  };

  // 텍스트 입력을 위한 컨트롤러
  TextEditingController _eventController = TextEditingController();

  // 날짜가 선택되었을 때 호출되는 함수
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay; // 선택된 날짜 업데이트
        _focusedDay = focusedDay; // 집중된 날짜 업데이트
      });
    }
  }

  // 이벤트 저장 함수
  void _saveEvent() {
    setState(() {
      // 선택된 날짜에 이벤트 저장
      _events[_selectedDay] = _eventController.text;
      _eventController.clear(); // 입력 필드 초기화
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('기록이 저장되었습니다!')));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: true, // 키보드 나타날 때 화면 조정
        appBar: AppBar(
          title: Text(
            "Calendar",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),

        body: SingleChildScrollView(
          // 스크롤 가능
          child: Column(
            children: [
              // 프로필과 사용자 이름 지정
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          AssetImage("assets/KakaoTalk_20241119_145249782.jpg"),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "김한잔",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // 선택된 날짜 표시
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "선택된 날짜: ${_selectedDay.toLocal()}",
                  style: TextStyle(fontSize: 13),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _events.containsKey(_selectedDay)
                      ? "기록: ${_events[_selectedDay]}"
                      : "잘하셨어요! 오늘은 기록이 없습니다!",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),

              // 캘린더
              Center(
                child: TableCalendar(
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) =>
                      isSameDay(_selectedDay, day), // 선택된 날짜 표시
                  firstDay: DateTime(2020, 3, 15),
                  lastDay: DateTime(2030, 3, 15),
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                  ),
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Color(0xFFD9D9D9),
                      shape: BoxShape.circle,
                    ),
                  ),
                  onDaySelected: _onDaySelected, // 날짜 선택 이벤트
                ),
              ),

              // 이벤트 입력 필드
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _eventController,
                      decoration: InputDecoration(
                        labelText: '술 잔을 입력하세요',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 13),
                    ElevatedButton(
                      onPressed: _saveEvent, // 이벤트 저장
                      child: Text(
                        '저장',
                        style: TextStyle(fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10), // 버튼 패딩
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
