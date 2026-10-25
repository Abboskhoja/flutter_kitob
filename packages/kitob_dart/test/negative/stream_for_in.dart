void main() {
  final s = Stream.value(1);
  for (final x in s) {
    print(x);
  }
}
