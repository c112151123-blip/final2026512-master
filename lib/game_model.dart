class GamePrice {
  final String title;
  final String currentPrice;
  final String lowestPrice;
  final String region; // 增加區域，符合你跨區監控的需求
  final String source; // 來源：Steam 或 第三方站點

  GamePrice({
    required this.title,
    required this.currentPrice,
    required this.lowestPrice,
    required this.region,
    required this.source,
  });

  // 將 JSON 轉換為物件的 Factory 方法
  factory GamePrice.fromJson(Map<String, dynamic> json) {
    return GamePrice(
      title: json['title'] ?? '未知遊戲',
      currentPrice: json['current_price']?.toString() ?? 'N/A',
      lowestPrice: json['lowest_price']?.toString() ?? 'N/A',
      region: json['region'] ?? 'Global',
      source: json['source'] ?? 'Official',
    );
  }
}