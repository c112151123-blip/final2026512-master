import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ================= 1. 資料模型 =================
class GamePrice {
  final String title;
  final String currentPrice;
  final String lowestPrice;
  final String region;
  final String source;

  GamePrice({
    required this.title,
    required this.currentPrice,
    required this.lowestPrice,
    required this.region,
    required this.source,
  });

  factory GamePrice.fromJson(Map<String, dynamic> json) {
    return GamePrice(
      title: json['title']?.toString() ?? '未知遊戲',
      currentPrice:
      (json['current_price'] ?? json['price'])?.toString() ?? 'N/A',
      lowestPrice: json['lowest_price']?.toString() ?? 'N/A',
      region: json['region']?.toString() ?? '—',
      source: json['source']?.toString() ?? 'Steam',
    );
  }
}

// ================= 2. 主程式入口 =================
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Steam 價格監控',
      theme: ThemeData(
        colorSchemeSeed: Colors.blueGrey,
        useMaterial3: true,
      ),
      home: const GamePriceListPage(),
    );
  }
}

class GamePriceListPage extends StatefulWidget {
  const GamePriceListPage({super.key});

  @override
  State<GamePriceListPage> createState() => _GamePriceListPageState();
}

class _GamePriceListPageState extends State<GamePriceListPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  Future<List<GamePrice>>? _resultsFuture;

  Future<List<GamePrice>> fetchGamePrices({
    required String nameKeyword,
    required String tagKeyword,
    required String minPrice,
    required String maxPrice,
  }) async {
    final Map<String, String> queryParameters = {};

    if (nameKeyword.trim().isNotEmpty) {
      queryParameters['name_keyword'] = nameKeyword.trim();
      queryParameters['keyword'] = nameKeyword.trim();
    }

    if (tagKeyword.trim().isNotEmpty) {
      queryParameters['tag_keyword'] = tagKeyword.trim();
    }

    if (minPrice.trim().isNotEmpty) {
      queryParameters['min_price'] = minPrice.trim();
    }

    if (maxPrice.trim().isNotEmpty) {
      queryParameters['max_price'] = maxPrice.trim();
    }

    final Uri uri = Uri.http(
      '10.0.2.2:5000',
      '/api/prices',
      queryParameters,
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is! List) {
          throw Exception('API 回傳格式不正確');
        }

        return decoded
            .map<GamePrice>((data) => GamePrice.fromJson(data))
            .toList();
      } else {
        final dynamic decodedBody = jsonDecode(response.body);
        if (decodedBody is Map<String, dynamic> &&
            decodedBody['error'] != null) {
          throw Exception(decodedBody['error'].toString());
        }

        throw Exception('伺服器回應錯誤: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('無法連線至 Flask 後端：$e');
    }
  }

  void _search() {
    setState(() {
      _resultsFuture = fetchGamePrices(
        nameKeyword: _nameController.text,
        tagKeyword: _tagController.text,
        minPrice: _minPriceController.text,
        maxPrice: _maxPriceController.text,
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tagController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Steam 跨區與序號比價'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Card(
              elevation: 0,
              color: Colors.blueGrey.withValues(alpha: 0.04),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 260,
                      child: TextField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: '遊戲名稱關鍵字',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                    SizedBox(
                      width: 260,
                      child: TextField(
                        controller: _tagController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Tag 關鍵字',
                          prefixIcon: Icon(Icons.sell_outlined),
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: TextField(
                        controller: _minPriceController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: '最低價',
                          prefixIcon: Icon(Icons.arrow_downward),
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: TextField(
                        controller: _maxPriceController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.search,
                        decoration: const InputDecoration(
                          hintText: '最高價',
                          prefixIcon: Icon(Icons.arrow_upward),
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                      ),
                      onPressed: _search,
                      icon: const Icon(Icons.manage_search),
                      label: const Text('搜尋'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _resultsFuture == null
                ? const Center(child: Text('請輸入條件後按搜尋'))
                : FutureBuilder<List<GamePrice>>(
              future: _resultsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        '${snapshot.error}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final List<GamePrice> games = snapshot.data ?? const [];
                if (games.isEmpty) {
                  return const Center(child: Text('找不到符合條件的遊戲'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: games.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final game = games[index];
                    final bool isFree = game.currentPrice == '免費';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.sports_esports,
                          color: Colors.blueGrey,
                        ),
                        title: Text(
                          game.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '區域: ${game.region} | 來源: ${game.source}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              game.currentPrice,
                              style: TextStyle(
                                color: isFree
                                    ? Colors.green
                                    : Colors.redAccent,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (game.lowestPrice != 'N/A' &&
                                game.lowestPrice != game.currentPrice)
                              Text(
                                '最低: ${game.lowestPrice}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
