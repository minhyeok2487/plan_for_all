import 'dart:math';

String generateRandomAvatarUrl() {
  final randomSeed = _generateRandomString(8);
  return 'https://api.dicebear.com/7.x/bottts/png?seed=$randomSeed';
}

String _generateRandomString(int length) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final rand = Random();
  return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
}