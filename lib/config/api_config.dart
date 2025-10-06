/// API configuration constants for the ReDine app
class ApiConfig {
  /// Base URL for the ReDine API server
  static const String baseUrl = 'http://redineai.sit.kmutt.ac.th:5000/api';
  
  /// Alternative method to get base URL (for future flexibility)
  static String getBaseUrl() => baseUrl;
  
  // API Endpoints
  static const String aiClassifyEndpoint = '/ai/classify';
  static const String metaIngredientsEndpoint = '/meta/ingredients';
  static const String metaCategoriesEndpoint = '/meta/categories';
  static const String metaAllergensEndpoint = '/meta/allergens';
  static const String metaAreasEndpoint = '/meta/areas';
  static const String menuIngredientsEndpoint = '/menu/ingredients';
  static const String proxyImageEndpoint = '/proxy-image';
  
  // Full URL builders
  static String get aiClassifyUrl => '$baseUrl$aiClassifyEndpoint';
  static String get metaIngredientsUrl => '$baseUrl$metaIngredientsEndpoint';
  static String get metaCategoriesUrl => '$baseUrl$metaCategoriesEndpoint';
  static String get metaAllergensUrl => '$baseUrl$metaAllergensEndpoint';
  static String get metaAreasUrl => '$baseUrl$metaAreasEndpoint';
  static String get menuIngredientsUrl => '$baseUrl$menuIngredientsEndpoint';
  
  static String proxyImageUrl(String imageUrl) => 
      '$baseUrl$proxyImageEndpoint?url=${Uri.encodeComponent(imageUrl)}';
}