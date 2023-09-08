String? validateEmail(value) {
  if (value == null || value.isEmpty) {
    return 'Email cannot be empty.';
  }
  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
    return "Please enter a valid email address";
  }
  return null;
}

String? validatePassword(value) {
  if (value.toString().trim().length < 6) {
    return "Password should have atleast 6 characters.";
  }
  return null;
}

String? validateOTP(value) {
  if (value == null || value.isEmpty) {
    return 'Please enter the code';
  }
  if (value.toString().trim().length != 6) {
    return "Invalid code";
  }
  return null;
}

int getPaymentMap(Map data) {
  int lastSubDate = 0;
  if (data['list'] is List) {
    data['list'].forEach((item) => {
          if (lastSubDate < item['time']) {lastSubDate = item['time']}
        });
  } else {
    lastSubDate = data['date'] ?? 0;
  }
  return lastSubDate;
}

double parseNum(String str) {
  RegExp exp = RegExp(r'\d+\.?\d*');
  RegExpMatch? matches = exp.firstMatch(str);
  double no = double.parse(matches?.group(0) ?? '1');
  if (str.contains('rem')) {
    return no * 16;
  } else {
    return no;
  }
}

List _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
];

String getDate(tillDate) {
  var d = DateTime.fromMillisecondsSinceEpoch(tillDate);
  return '${d.day} ${_months[d.month - 1]}, ${d.year}';
}
