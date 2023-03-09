import 'dart:math' as Math;

List inputStrToArr(text, [breakLine]) {
  List arr;
  if (text.indexOf('\n') != -1) {
    arr = text
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item != '')
        .toList();
  } else {
    arr = text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item != '')
        .toList();
  }
  if (breakLine == true) {
    if (arr[0].indexOf('|') != -1) {
      arr = arr
          .map((line) => line
              .split('|')
              .map((item) => item.trim())
              .where((item) => item != ''))
          .toList();
    } else {
      arr = arr
          .map((line) => line
              .split(',')
              .map((item) => item.trim())
              .where((item) => item != ''))
          .toList();
    }
  }
  return arr;
}

//x,a,b - returns a number based on the format
num getFormatedRandom(str) {
  num len = str.length;
  num range = Math.pow(10, len);
  num offset = Math.pow(10, len - 1);
  var random = new Math.Random();
  num no = (random.nextDouble() * (range - offset) + offset).floor();
  String nostr = '' + no.toString();

  for (int i = 0; i < nostr.length; i++) {
    if (str[i] != 'x') {
      if (str[i] == 'a') {
        num rand = (random.nextDouble() * 4).ceil();
        nostr =
            nostr.substring(0, i) + rand.toString() + nostr.substring(i + 1);
      } else if (str[i] == 'b') {
        num rand = (random.nextDouble() * 5).ceil() + 4;
        nostr =
            nostr.substring(0, i) + rand.toString() + nostr.substring(i + 1);
      } else {
        nostr = nostr.substring(0, i) + str[i] + nostr.substring(i + 1);
      }
    }
  }
  if (nostr.indexOf('.') != -1 && nostr[nostr.length - 1] == '0') {
    nostr = nostr.substring(0, nostr.length - 1) +
        (random.nextDouble() * 9).ceil().toString();
  }
  num ret = nostr.indexOf('.') != -1 ? double.parse(nostr) : int.parse(nostr);
  return ret;
}

/*
List generateDataFromPattern(Map data, {int count = 0} ) {
  List list = [];
  for (int i = 0; i < 10; i++) {
    List arr = [];
    String pattern = data['pattern'];
    pattern = getRepeated(pattern);
    List patternList = pattern.split(' ');
    List values = [];
    while (arr.length < 4) {
      List item = [...patternList];
      for (int k = 0; k < pattern.length; k += 2) {
        item[k] = getFormatedRandom(item[k]);
      }
      String itemStr = item.join(' ');
      let val = eval(item);
      if (val < 0 || values.indexOf(val) !== -1) {
        continue;
      }
      values.push(val);
      arr.push(item);
    }
    arr.sort((a, b) =>
      data.probType === 'biggest' || data.probType === 'descending'
        ? eval(b) - eval(a)
        : eval(a) - eval(b)
    );
    //Rethna: replaceAll not working on older browser
    arr = arr.map((item) => item.replace('*', '×'));
    arr = arr.map((item) => item.replace('-', '–'));
    //arr = arr.map((item) => item.replaceAll('/', '÷'));

    const randArr = [...Array(arr.length)].map((dummy, i) => i);
    randArr.sort(() => Math.random() - 0.5);
    if (data.probType === 'descending' || data.probType === 'ascending') {
      list.push({
        options: arr,
        randArr
      });
    } else {
      list.push({
        words: arr,
        randArr
      });
    }
  }
  return list;
}
*/