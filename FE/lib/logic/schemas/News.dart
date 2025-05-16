typedef NewsRecord =
    ({
      ({String? id, String name}) source,
      String? author,
      String title,
      String? description,
      String url,
      String? urlToImage,
      DateTime publishedAt,
      String content,
    });

class News {
  static NewsRecord recordDummy = (
    source: (id: 'abc-news', name: 'ABC News'),
    author: 'John Smith',
    title: 'Breaking News: Dart 3.0 Released',
    description:
        'Major update brings new features to Dart programming language',
    url:
        'https://www.liputan6.com/hot/read/5484231/5-potret-jaka-tirta-dan-kardin-anak-attila-syach-kini-putri-kedua-diculik',
    urlToImage: 'https://picsum.photos/200/150',
    publishedAt: DateTime(2023, 5, 10, 14, 30),
    content: 'Dart 3.0 introduces significant improvements...',
  );
  static News dummy = News(recordDummy);

  ({String? id, String name}) source;
  String? author;
  String title;
  String? description;
  String url;
  String? urlToImage;
  DateTime publishedAt;
  String content;

  News(NewsRecord news)
    : source = news.source,
      author = news.author,
      title = news.title,
      description = news.description,
      url = news.url,
      urlToImage = news.urlToImage,
      publishedAt = news.publishedAt,
      content = news.content;

  factory News.fromJson(Map<String, dynamic> json) {
    return News((
      source: (
        id: json['source']['id'] as String?,
        name: json['source']['name'] as String,
      ),
      author: json['author'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      url: json['url'] as String,
      urlToImage: json['urlToImage'] as String?,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      content: json['content'] as String,
    ));
  }
}
