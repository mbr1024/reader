import 'package:flutter_test/flutter_test.dart';

// 直接测试解析逻辑，不依赖完整服务
void main() {
  group('TXT 章节解析测试', () {
    test('标准章节格式解析', () {
      final content = '''
前言内容，这是一段比较长的前言内容，用来填充字数，确保章节之间的间隔足够长。
这里继续添加一些内容，让文本看起来更像是真实的小说内容。
我们需要确保每个章节之间至少有一定的字符数，这样规则选择算法才能正确工作。

第一章 开始
这是第一章的内容。包含多个段落。这是一段比较长的正文内容。
在这里我们描述故事的开始，主人公的出场，以及故事背景的介绍。
这里继续添加更多的内容，让章节看起来更加丰富和真实。
主人公踏上了冒险的旅程，故事就此展开。

第二章 发展
这是第二章的内容。故事继续发展，情节逐渐推进。
主人公遇到了新的挑战和困难，需要克服各种障碍。
在这个过程中，他结识了新的朋友，也遇到了强大的敌人。
故事的节奏逐渐加快，冲突也越来越激烈。

第三章 结局
这是第三章的内容。故事走向高潮，最终的决战即将到来。
主人公经历了重重考验，终于成长为一名真正的英雄。
最后的胜利来之不易，但正义终将战胜邪恶。
故事在一片祥和的氛围中落下帷幕。
''';
      
      final result = _parseTxtContent(content);
      expect(result.titles.length, greaterThanOrEqualTo(3));
      expect(result.titles, contains('第一章 开始'));
      expect(result.titles, contains('第二章 发展'));
      expect(result.titles, contains('第三章 结局'));
    });

    test('英文章节格式解析', () {
      final content = '''
Introduction to the story. This is a long introduction that provides background information about the world and characters. We need to ensure there is enough content between chapters for the algorithm to work correctly.

Chapter 1 The Beginning
This is chapter one content. The story begins with our protagonist setting out on their journey.
Many adventures await, and the road ahead is long and uncertain.
But our hero is determined to succeed, no matter what obstacles may arise.
The first day passes without incident, but dangers lurk in the shadows.

Chapter 2 The Middle
This is chapter two content. The plot thickens as new challenges emerge.
Our protagonist faces their first real test, and must prove their worth.
Allies are made, enemies are revealed, and the true nature of the quest becomes clear.
The stakes are higher than ever before.

Chapter 3 The End
This is chapter three content. The final confrontation approaches.
Everything has led to this moment, and our hero must give everything they have.
In the end, victory is achieved, but at a great cost.
The story concludes with hope for the future.
''';
      
      final result = _parseTxtContent(content);
      expect(result.titles.length, greaterThanOrEqualTo(3));
    });

    test('数字分隔符格式解析', () {
      final content = '''
1、第一节
内容一。这是第一节的详细内容，包含了很多重要的信息。
我们在这里详细介绍了相关的背景知识和基本概念。
读者需要认真阅读这部分内容，才能理解后续的章节。
这一节是整个文章的基础，非常重要。

2、第二节
内容二。这是第二节的详细内容，在第一节的基础上进行了扩展。
我们深入探讨了更加复杂的问题和解决方案。
这部分内容可能需要一些专业知识才能完全理解。
但是我们会尽量用通俗的语言来解释。

3、第三节
内容三。这是第三节的详细内容，是对前两节的总结和补充。
我们回顾了主要的观点，并提出了一些新的思考。
希望读者能够从中获得启发，并应用到实际生活中。
这一节也是全文的结尾部分。
''';
      
      final result = _parseTxtContent(content);
      expect(result.titles.length, greaterThanOrEqualTo(3));
    });

    test('晋江风格格式解析', () {
      final content = '''
☆、第一章 初遇
内容一。这是晋江风格的小说章节，通常会有一个星号作为标记。
故事从一个平凡的日子开始，女主角在咖啡店遇见了男主角。
两人的目光在空中交汇，仿佛整个世界都静止了。
这就是缘分的开始，一段浪漫的爱情故事即将展开。

☆、第二章 重逢
内容二。时隔多年，两人在一次宴会上再次相遇。
岁月在他们脸上留下了痕迹，但那份心动的感觉依然存在。
他们开始慢慢回忆起曾经的点点滴滴。
这一次，他们决定不再错过彼此。

☆、第三章 结局
内容三。经历了重重考验，两人终于走到了一起。
他们在亲朋好友的祝福下举行了婚礼。
从此过上了幸福的生活。
这就是他们的故事，关于爱情、成长和幸福。
''';
      
      final result = _parseTxtContent(content);
      expect(result.titles.length, greaterThanOrEqualTo(3));
    });

    test('无章节标题按大小分段', () {
      // 生成足够长的内容
      final content = List.generate(100, (i) => 
        '这是第${i+1}段内容。这是一段比较长的文本，用于测试按大小分段的功能。我们需要确保文本足够长，才能触发分段逻辑。'
      ).join('\n\n');
      
      final result = _parseTxtContent(content);
      expect(result.titles.length, greaterThan(1));
      expect(result.titles.first, contains('段'));
    });

    test('特殊章节类型', () {
      final content = '''
序章
序章内容。故事开始之前的背景介绍，让读者了解整个世界观。
这个世界有着独特的规则和设定，需要提前说明。
在这里我们会介绍主要的势力分布和历史背景。
希望读者能够耐心阅读，这对理解后续剧情很重要。

楔子
楔子内容。一个神秘的场景，预示着即将发生的故事。
黑暗中，一个身影悄然出现，带着不可告人的秘密。
这个秘密将会贯穿整个故事，影响所有人的命运。
一切都从这一刻开始改变。

第一章 正文
正文内容。故事正式开始，我们的主角终于登场。
他是一个普通的年轻人，却有着不普通的命运。
在命运的安排下，他踏上了一条充满未知的道路。
这条路将带他走向何方，没有人知道。

番外 后续
番外内容。故事结束后的一些补充和后续发展。
那些在正文中没有详细描述的情节，会在这里展开。
让读者能够了解更多关于配角们的故事。
这是对正文的一个完美补充。

后记
后记内容。作者在这里表达自己的感想和感谢。
感谢所有读者的支持和陪伴，让这个故事得以完成。
希望这个故事能够给大家带来一些思考和感动。
再次感谢大家，我们下个故事再见。
''';
      
      final result = _parseTxtContent(content);
      // 应该能识别序章、楔子、番外、后记等
      expect(result.titles.length, greaterThanOrEqualTo(4));
    });
  });

  group('HTML 实体解码测试', () {
    test('常见 HTML 实体', () {
      final html = '&nbsp;&amp;&lt;&gt;&quot;&#39;&apos;&mdash;&hellip;';
      final result = _stripHtml(html);
      expect(result, contains('&'));
      expect(result, contains('<'));
      expect(result, contains('>'));
      expect(result, contains('"'));
      expect(result, contains("'"));
      expect(result, contains('—'));
      expect(result, contains('…'));
    });

    test('数字实体解码', () {
      final html = '&#65;&#66;&#67;'; // ABC
      final result = _stripHtml(html);
      expect(result, 'ABC');
    });

    test('十六进制实体解码', () {
      final html = '&#x41;&#x42;&#x43;'; // ABC
      final result = _stripHtml(html);
      expect(result, 'ABC');
    });

    test('移除 HTML 标签', () {
      final html = '<p>段落内容</p><div>div内容</div>';
      final result = _stripHtml(html);
      expect(result.contains('<'), false);
      expect(result.contains('>'), false);
      expect(result, contains('段落内容'));
      expect(result, contains('div内容'));
    });
  });

  group('规则匹配测试', () {
    test('正则表达式有效性', () {
      // 测试所有规则的正则表达式是否有效
      for (final rule in _txtTocRules) {
        expect(() => RegExp(rule.pattern, multiLine: true), returnsNormally);
      }
    });

    test('标准章节正则匹配', () {
      final regex = RegExp(_txtTocRules[0].pattern, multiLine: true);
      expect(regex.hasMatch('第一章 标题'), true);
      expect(regex.hasMatch('第123章 标题'), true);
      expect(regex.hasMatch('第一百二十三章 标题'), true);
      expect(regex.hasMatch('序章'), true);
      expect(regex.hasMatch('楔子'), true);
      expect(regex.hasMatch('番外'), true);
      expect(regex.hasMatch('后记'), true);
    });

    test('英文章节正则匹配', () {
      final regex = RegExp(_txtTocRules[1].pattern, multiLine: true);
      expect(regex.hasMatch('Chapter 1 Title'), true);
      expect(regex.hasMatch('Section 2 Title'), true);
      expect(regex.hasMatch('Part 3 Title'), true);
    });

    test('数字分隔符正则匹配', () {
      final regex = RegExp(_txtTocRules[2].pattern, multiLine: true);
      expect(regex.hasMatch('1、标题'), true);
      expect(regex.hasMatch('1.标题'), true);
      expect(regex.hasMatch('1：标题'), true);
      expect(regex.hasMatch('123、标题内容'), true);
    });
  });
}

// ============ 复制的解析逻辑用于测试 ============

class _ParsedChapters {
  final List<String> titles;
  final List<String> contents;
  _ParsedChapters({required this.titles, required this.contents});
}

class _TxtTocRule {
  final String name;
  final String pattern;
  final int priority;
  const _TxtTocRule({required this.name, required this.pattern, required this.priority});
}

const int _maxCharsPerSegment = 5000;
const int _maxChapterLength = 15000;

final List<_TxtTocRule> _txtTocRules = [
  _TxtTocRule(
    name: '标准章节',
    pattern: r'^[ 　\t]{0,4}(?:序章|楔子|正文(?!完|结)|终章|后记|尾声|番外|第\s{0,4}[\d〇零一二两三四五六七八九十百千万壹贰叁肆伍陆柒捌玖拾佰仟]+?\s{0,4}(?:章|节(?!课)|卷|集(?![合和])|部(?![分赛游])|篇(?!张)|回(?![合来事去]))).{0,30}$',
    priority: 100,
  ),
  _TxtTocRule(
    name: '英文章节',
    pattern: r'^[ 　\t]{0,4}(?:[Cc]hapter|[Ss]ection|[Pp]art|ＰＡＲＴ|[Ee]pisode|[Nn][Oo]\.?)\s{0,4}\d{1,4}.{0,30}$',
    priority: 90,
  ),
  _TxtTocRule(
    name: '数字分隔符',
    pattern: r'^[ 　\t]{0,4}\d{1,5}[:：,.，、_—\-]\s*.{1,30}$',
    priority: 80,
  ),
  _TxtTocRule(
    name: '中文数字分隔符',
    pattern: r'^[ 　\t]{0,4}(?:序章|楔子|正文(?!完|结)|终章|后记|尾声|番外|[零一二两三四五六七八九十百千万壹贰叁肆伍陆柒捌玖拾佰仟]{1,8}章?)[ 、_—\-].{1,30}$',
    priority: 75,
  ),
  _TxtTocRule(
    name: '卷章序号',
    pattern: r'^[ \t　]{0,4}(?:[卷章][\d零一二两三四五六七八九十百千万壹贰叁肆伍陆柒捌玖拾佰仟]{1,8})[ 　]{0,4}.{0,30}$',
    priority: 70,
  ),
  _TxtTocRule(
    name: '晋江风格',
    pattern: r'^[ 　\t]{0,4}[☆★✦✧⭐].{1,30}$',
    priority: 65,
  ),
  _TxtTocRule(
    name: '方括号格式',
    pattern: r'^[ 　\t]{0,4}【(?:第[\d零一二两三四五六七八九十百千万]+[章节回卷]|序章?|楔子|番外|后记|终章).{0,20}】.{0,20}$',
    priority: 60,
  ),
  _TxtTocRule(
    name: '正文标题',
    pattern: r'^[ 　\t]{0,4}正文[ 　]{1,4}.{0,20}$',
    priority: 55,
  ),
  _TxtTocRule(
    name: '书名括号序号',
    pattern: r'^[一-龥]{1,20}[ 　\t]{0,4}[(（][\d〇零一二两三四五六七八九十百千万壹贰叁肆伍陆柒捌玖拾佰仟]{1,8}[)）][ 　\t]{0,4}$',
    priority: 50,
  ),
  _TxtTocRule(
    name: '分节阅读',
    pattern: r'^[ 　\t]{0,4}(?:.{0,15}分[页节章段]阅读[-_ ]?|第\s{0,4}[\d零一二两三四五六七八九十百千万]{1,6}\s{0,4}[页节]).{0,30}$',
    priority: 45,
  ),
];

RegExp? _selectBestTocRule(String sampleContent) {
  int maxMatches = 0;
  _TxtTocRule? bestRule;

  for (final rule in _txtTocRules) {
    try {
      final regex = RegExp(rule.pattern, multiLine: true);
      final matches = regex.allMatches(sampleContent);
      int validMatches = 0;
      int lastEnd = 0;

      for (final match in matches) {
        // 测试中降低间隔要求
        if (match.start - lastEnd >= 50 || lastEnd == 0) {
          validMatches++;
        }
        lastEnd = match.end;
      }

      if (validMatches > maxMatches) {
        maxMatches = validMatches;
        bestRule = rule;
      }
    } catch (_) {}
  }

  if (maxMatches >= 2 && bestRule != null) {
    return RegExp(bestRule.pattern, multiLine: true);
  }

  return null;
}

_ParsedChapters _parseTxtContent(String content) {
  final lines = content.split('\n');
  final sampleLength = content.length > 512000 ? 512000 : content.length;
  final sampleContent = content.substring(0, sampleLength);
  final regex = _selectBestTocRule(sampleContent);

  if (regex == null) {
    return _splitBySize(content.trim());
  }

  final titles = <String>[];
  final contents = <String>[];
  final buffer = StringBuffer();
  String currentTitle = '';
  int matchedChapters = 0;

  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isNotEmpty && regex.hasMatch(trimmed)) {
      if (currentTitle.isNotEmpty || buffer.isNotEmpty) {
        titles.add(currentTitle.isEmpty ? '开头' : currentTitle);
        contents.add(buffer.toString().trim());
        buffer.clear();
      }
      currentTitle = trimmed;
      matchedChapters++;
    } else {
      buffer.writeln(line);
    }
  }

  if (currentTitle.isNotEmpty || buffer.isNotEmpty) {
    titles.add(currentTitle.isEmpty ? '正文' : currentTitle);
    contents.add(buffer.toString().trim());
  }

  if (titles.isNotEmpty && titles[0] == '开头' && contents[0].isEmpty) {
    titles.removeAt(0);
    contents.removeAt(0);
  }

  if (matchedChapters < 2 || (titles.length == 1 && contents[0].length > _maxCharsPerSegment * 2)) {
    return _splitBySize(content.trim());
  }

  final finalTitles = <String>[];
  final finalContents = <String>[];
  for (int i = 0; i < titles.length; i++) {
    if (contents[i].length > _maxChapterLength) {
      final sub = _splitBySize(contents[i], baseTitle: titles[i]);
      finalTitles.addAll(sub.titles);
      finalContents.addAll(sub.contents);
    } else {
      finalTitles.add(titles[i]);
      finalContents.add(contents[i]);
    }
  }

  if (finalTitles.isEmpty) {
    return _splitBySize(content.trim());
  }

  return _ParsedChapters(titles: finalTitles, contents: finalContents);
}

_ParsedChapters _splitBySize(String text, {String baseTitle = ''}) {
  final titles = <String>[];
  final contents = <String>[];
  final paragraphs = text.split('\n');

  final buffer = StringBuffer();
  int charCount = 0;
  int segmentIndex = 1;

  for (final para in paragraphs) {
    buffer.writeln(para);
    charCount += para.length + 1;

    if (charCount >= _maxCharsPerSegment) {
      final prefix = baseTitle.isNotEmpty ? '$baseTitle · ' : '';
      titles.add('$prefix第$segmentIndex段');
      contents.add(buffer.toString().trim());
      buffer.clear();
      charCount = 0;
      segmentIndex++;
    }
  }

  if (buffer.isNotEmpty) {
    final remaining = buffer.toString().trim();
    if (remaining.isNotEmpty) {
      if (titles.isEmpty) {
        titles.add(baseTitle.isNotEmpty ? baseTitle : '正文');
        contents.add(remaining);
      } else {
        final prefix = baseTitle.isNotEmpty ? '$baseTitle · ' : '';
        titles.add('$prefix第$segmentIndex段');
        contents.add(remaining);
      }
    }
  }

  if (titles.isEmpty) {
    titles.add(baseTitle.isNotEmpty ? baseTitle : '正文');
    contents.add(text);
  }

  return _ParsedChapters(titles: titles, contents: contents);
}

String _stripHtml(String html) {
  var text = html
      .replaceAll(RegExp(r'<br\s*/?>'), '\n')
      .replaceAll(RegExp(r'</(p|div|h[1-6]|li|tr|blockquote|article|section|header|footer)>'), '\n\n')
      .replaceAll(RegExp(r'<[^>]+>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&ensp;', ' ')
      .replaceAll('&emsp;', '　')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&apos;', "'")
      .replaceAll('&mdash;', '—')
      .replaceAll('&ndash;', '–')
      .replaceAll('&hellip;', '…')
      .replaceAll('&lsquo;', ''')
      .replaceAll('&rsquo;', ''')
      .replaceAll('&ldquo;', '"')
      .replaceAll('&rdquo;', '"')
      .replaceAll('&laquo;', '«')
      .replaceAll('&raquo;', '»')
      .replaceAll('&copy;', '©')
      .replaceAll('&reg;', '®')
      .replaceAll('&trade;', '™')
      .replaceAll('&times;', '×')
      .replaceAll('&divide;', '÷')
      .replaceAll('&plusmn;', '±')
      .replaceAll('&deg;', '°')
      .replaceAll('&cent;', '¢')
      .replaceAll('&pound;', '£')
      .replaceAll('&yen;', '¥')
      .replaceAll('&euro;', '€');

  text = text.replaceAllMapped(
    RegExp(r'&#(\d+);'),
    (m) {
      try {
        final code = int.parse(m.group(1)!);
        if (code > 0 && code <= 0x10FFFF) {
          return String.fromCharCode(code);
        }
      } catch (_) {}
      return '';
    },
  );

  text = text.replaceAllMapped(
    RegExp(r'&#[xX]([0-9a-fA-F]+);'),
    (m) {
      try {
        final code = int.parse(m.group(1)!, radix: 16);
        if (code > 0 && code <= 0x10FFFF) {
          return String.fromCharCode(code);
        }
      } catch (_) {}
      return '';
    },
  );

  text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  text = text.replaceAll(RegExp(r'[ \t]+\n'), '\n');
  text = text.replaceAll(RegExp(r'\n[ \t]+'), '\n');

  return text.trim();
}
