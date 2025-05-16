import 'package:flutter/material.dart';
import 'package:farmwise_app/logic/api/news.dart';
import 'package:farmwise_app/logic/schemas/News.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<News> newsList = [];
  bool isLoading = true;
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    setState(() => isLoading = true);

    try {
      final response = await getNews(page: currentPage);
      if (response.response != null) {
        setState(() {
          newsList = response.response!;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat berita: ${e.toString()}')),
        );
      }
    } finally {}
  }

  void _loadMoreNews() {
    getNews(page: currentPage++).then((resp) {
      if (resp.response != null && mounted) {
        setState(() {
          newsList.addAll(resp.response!);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'Farm News',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: () async {
                  currentPage = 1;
                  await _fetchNews();
                },
                child:
                    newsList.isEmpty
                        ? const Center(child: Text('Tidak ada berita'))
                        : ListView.separated(
                          padding: const EdgeInsets.only(top: 8, bottom: 20),
                          itemCount: newsList.length + 1,
                          separatorBuilder: (context, index) {
                            if (index == newsList.length) {
                              return const SizedBox.shrink();
                            }
                            return const Divider(height: 1, thickness: 0.3);
                          },
                          itemBuilder: (context, index) {
                            if (index == newsList.length) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 12.0,
                                ),
                                child: ElevatedButton(
                                  onPressed: _loadMoreNews,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(40),
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Load more news'),
                                ),
                              );
                            }

                            final news = newsList[index];
                            return NewsItem(news: news);
                          },
                        ),
              ),
    );
  }
}

class NewsItem extends StatelessWidget {
  final News news;

  const NewsItem({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _launchURL(news.url, context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // News thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  news.urlToImage != null && news.urlToImage!.isNotEmpty
                      ? Image.network(
                        news.urlToImage!,
                        height: 90,
                        width: 90,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                _buildImagePlaceholder(),
                      )
                      : _buildImagePlaceholder(),
            ),
            const SizedBox(width: 12),

            // News content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _getSourceName(news.url),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        ' • ${_formatDate(news.publishedAt)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 90,
      width: 90,
      color: Colors.grey.shade200,
      child: Icon(Icons.image, color: Colors.grey.shade400, size: 40),
    );
  }

  String _getSourceName(String? url) {
    if (url == null || url.isEmpty) return "";

    try {
      final uri = Uri.parse(url);
      final host = uri.host;

      // Extract domain without www. and .com/.co.id/etc
      final parts = host.split('.');
      if (parts.length >= 2) {
        return parts[parts.length - 2] + "." + parts[parts.length - 1];
      }
      return host;
    } catch (e) {
      return "";
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      final formattedTime = DateFormat('HH:mm').format(date);
      return '$formattedTime WIB';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  Future<void> _launchURL(String? url, BuildContext context) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('URL tidak valid')));
      return;
    }

    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }
}
