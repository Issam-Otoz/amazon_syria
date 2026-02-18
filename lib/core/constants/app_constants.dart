class AppConstants {
  AppConstants._();

  static const String appName = 'أمازون سوريا';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String chatRoomsCollection = 'chat_rooms';
  static const String messagesCollection = 'messages';

  // Pagination
  static const int pageSize = 10;

  // User types
  static const String userTypeSupplier = 'supplier';
  static const String userTypeOrderUser = 'orderUser';
}
