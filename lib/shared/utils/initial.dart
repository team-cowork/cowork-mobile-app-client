import 'package:characters/characters.dart';

/// 아바타·단축 바에 보일 [name] 의 첫 글자. 이름이 비면 `?`.
///
/// `substring(0, 1)` 은 UTF-16 코드 유닛으로 잘라 이모지(`🚀`)나 결합 문자가 반쪽만
/// 남는다. 사람이 보는 한 글자(grapheme) 단위로 자른다.
String initialOf(String name) => name.isEmpty ? '?' : name.characters.first;
