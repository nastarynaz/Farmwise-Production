import 'package:farmwise_app/logic/logicGlobal.dart';

enum ScanType { disease, info }

typedef PromptRecord = ({String? text, String? image});

class Prompt {
  static PromptRecord recordDummy = (
    text: 'Kenapa rico kakinya 2?',
    image: base64Dummy,
  );
  static Prompt dummy = Prompt(recordDummy);

  String? text;
  String? image;
  Prompt(PromptRecord prompt) : text = prompt.text, image = prompt.image;
}

typedef ChatRecord =
    ({
      int cID,
      String uID,
      int? fID,
      PromptRecord prompt,
      String answer,
      DateTime date,
    });

class Chat {
  static ChatRecord recordDummy = (
    cID: 1,
    uID: '1',
    fID: 1,
    prompt: Prompt.recordDummy,
    answer: 'Jawaban Gemini',
    date: dateTimeDummy,
  );
  static Chat dummy = Chat(recordDummy);

  int cID;
  String uID;
  int? fID;
  Prompt prompt;
  String answer;
  DateTime date;

  Chat(ChatRecord chat)
    : cID = chat.cID,
      uID = chat.uID,
      fID = chat.fID,
      prompt = Prompt(chat.prompt),
      answer = chat.answer,
      date = chat.date;

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat((
      cID: json['cID'] as int,
      uID: json['uID'] as String,
      fID: json['fID'] as int?,
      prompt: (
        text: json['prompt']['text'] as String?,
        image: json['prompt']['image'] as String?,
      ),
      answer: json['answer'] as String,
      date: DateTime.parse(json['date'] as String),
    ));
  }
}
