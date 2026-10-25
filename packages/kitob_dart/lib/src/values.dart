/// Dart `double` qiymati.
///
/// Webda (JavaScript) `int` va `double` bir xil tur bo'lgani uchun, Dart VM
/// xatti-harakatini barcha platformalarda bir xil saqlash maqsadida double
/// qiymatlar alohida o'raladi. `print(10 / 2)` hamma joyda `5.0` chiqaradi.
class KDouble implements Comparable<KDouble> {
  const KDouble(this.value);
  final double value;

  @override
  bool operator ==(Object other) =>
      (other is KDouble && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  int compareTo(KDouble other) => value.compareTo(other.value);

  @override
  String toString() => formatDouble(value);
}

String formatDouble(double v) {
  if (v.isNaN) return 'NaN';
  if (v.isInfinite) return v > 0 ? 'Infinity' : '-Infinity';
  var s = v.toString();
  if (!s.contains('.') && !s.contains('e')) s = '$s.0';
  // JS `1e+21` va Dart VM `1e+21` mos keladi.
  return s;
}

/// Dart `Record` qiymati, masalan `(1, nom: 'Ali')`.
class KRecord {
  KRecord(this.positional, this.named);
  final List<Object?> positional;
  final Map<String, Object?> named;

  @override
  bool operator ==(Object other) {
    if (other is! KRecord) return false;
    if (other.positional.length != positional.length) return false;
    if (other.named.length != named.length) return false;
    for (var i = 0; i < positional.length; i++) {
      if (positional[i] != other.positional[i]) return false;
    }
    for (final e in named.entries) {
      if (other.named[e.key] != e.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll([...positional, ...named.values]);
}
