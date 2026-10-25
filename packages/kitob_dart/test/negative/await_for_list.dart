Future<void> main() async {
  await for (final x in [1, 2]) {
    print(x);
  }
}
