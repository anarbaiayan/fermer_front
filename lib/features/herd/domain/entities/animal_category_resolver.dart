import 'animal_category.dart';
import 'cattle_gender.dart';

class AnimalCategoryResolver {
  static ({AnimalCategory? category, int ageInMonths}) resolve({
    required CattleGender gender,
    required DateTime dateOfBirth,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();

    int months =
        (today.year - dateOfBirth.year) * 12 + (today.month - dateOfBirth.month);

    if (months < 0) months = 0;

    AnimalCategory? category;

    if (months < 12) {
      category = AnimalCategory.calf;
    } else if (gender == CattleGender.male && months >= 12) {
      category = AnimalCategory.bull;
    } else if (gender == CattleGender.female && months >= 12 && months < 24) {
      category = AnimalCategory.heifer;
    } else if (gender == CattleGender.female && months >= 24) {
      category = AnimalCategory.cow;
    }

    return (category: category, ageInMonths: months);
  }
}
