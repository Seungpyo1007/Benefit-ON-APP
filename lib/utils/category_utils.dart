import '../models/store.dart';

class CategoryInfo {
  final String icon;
  final String color;

  CategoryInfo({required this.icon, required this.color});
}

class CategoryUtils {
  static final Map<Category, CategoryInfo> _categoryInfo = {
    Category.culture: CategoryInfo(icon: '🎭', color: 'text-purple-400'),
    Category.study: CategoryInfo(icon: '📚', color: 'text-blue-400'),
    Category.shopping: CategoryInfo(icon: '🛍️', color: 'text-pink-400'),
    Category.food: CategoryInfo(icon: '🍽️', color: 'text-orange-400'),
    Category.free: CategoryInfo(icon: '🎁', color: 'text-green-400'),
    Category.movie: CategoryInfo(icon: '🎬', color: 'text-red-400'),
    Category.other: CategoryInfo(icon: '📌', color: 'text-gray-400'),
  };

  static CategoryInfo getCategoryInfo(Category category) {
    return _categoryInfo[category] ?? _categoryInfo[Category.other]!;
  }

  static const List<Category> categoriesWithInfo = [
    Category.culture,
    Category.study,
    Category.shopping,
    Category.food,
    Category.free,
    Category.movie,
    Category.other,
  ];
} 