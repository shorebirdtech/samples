/// Contract for persisting and retrieving high scores.
/// Follows Dependency Inversion Principle (DIP) allowing easy mock injection in tests.
abstract class IHighScoreRepository {
  Future<int> loadHighScore();
  Future<void> saveHighScore(int score);
}
