import 'package:farmwise_app/logic/api/farms.dart';
import 'package:farmwise_app/logic/logicGlobal.dart';
import 'package:farmwise_app/logic/schemas/Farm.dart';
import 'package:farmwise_app/logic/schemas/WeatherResponse.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:farmwise_app/logic/api/news.dart';
import 'package:farmwise_app/logic/schemas/News.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Farm? selectedFarm;
  WeatherResponseCurrent? currentWeather;
  bool isLoading = true;
  String? errorMessage;
  List<News> newsList = [];
  bool isLoadingNews = true;

  @override
  void initState() {
    super.initState();
    _fetchNewsForHome();
    _loadInitialData();
    getWeatherLocationCurrent(lat: -7.7765367, long: 110.3438727).then((res) {
      print(res.statusCode);
      print(res.err);
    });
  }

  Future<void> _fetchNewsForHome() async {
    setState(() => isLoadingNews = true);

    try {
      final response = await getNews(page: 1);
      if (response.response != null && mounted) {
        setState(() => newsList = response.response!.take(4).toList());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat berita: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoadingNews = false);
      }
    }
  }

  String _getSourceName(String? url) {
    if (url == null || url.isEmpty) return "";
    try {
      final uri = Uri.parse(url);
      final parts = uri.host.split('.');
      if (parts.length >= 2) {
        return parts[parts.length - 2] + "." + parts[parts.length - 1];
      }
      return uri.host;
    } catch (e) {
      return "";
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date) + ' WIB';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }

  Future<void> _loadInitialData() async {
    try {
      final farmsResponse = await getFarms();

      if (!mounted) return;

      setState(() {
        if (farmsResponse.response != null) {
          farms = farmsResponse.response!;
          if (farms.isNotEmpty) {
            selectedFarm = farms.first;
            _loadWeatherData();
          } else {
            isLoading = false;
          }
        } else {
          errorMessage = farmsResponse.err ?? 'Gagal memuat data farm';
          isLoading = false;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _loadWeatherData() async {
    try {
      if (selectedFarm == null) return;

      final weatherResponse = await getWeatherCurrent(fID: selectedFarm!.fID);

      if (!mounted) return;

      setState(() {
        if (weatherResponse.response != null) {
          currentWeather = weatherResponse.response!;
          errorMessage = null;
        } else {
          errorMessage = weatherResponse.err ?? 'Gagal memuat data cuaca';
        }
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error cuaca: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void _handleFarmChange(Farm farm) {
    setState(() {
      selectedFarm = farm;
      isLoading = true;
      currentWeather = null;
    });
    _loadWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(child: Text(errorMessage!))
                : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAppBar(),
                      _buildUserProfile(),
                      _buildWeatherWidget(),
                      _buildFarmMetricsGrid(),
                      _buildChatAISection(),
                      _buildNewsSection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.eco, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              const Text(
                'FarmWise',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: Colors.grey[700],
            onPressed: () => context.go('/notification'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green,
                radius: 24,
                child: ClipOval(
                  child:
                      currentUser?.getImageWidget() ??
                      const Icon(Icons.person, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                // Tambahkan Expanded di sini
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${currentUser?.username ?? 'Pengguna'}!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const Text(
                      'Ready to optimize your farm with FarmWise?',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Farm',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 42,
                child:
                    farms.isEmpty
                        ? GestureDetector(
                          onTap: () => context.push('/createfarm'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 1,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  size: 18,
                                  color: Colors.black,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Add your first farm",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: farms.length,
                          itemBuilder: (context, index) {
                            final farm = farms[index];
                            final isSelected = farm == selectedFarm;
                            return GestureDetector(
                              onTap: () => _handleFarmChange(farm),
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected ? Colors.green : Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? Colors.green
                                            : Colors.grey[300]!,
                                  ),
                                  boxShadow:
                                      isSelected
                                          ? [
                                            BoxShadow(
                                              color: Colors.green.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                          : null,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.eco,
                                      size: 18,
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.green,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      farm.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Colors.grey[800],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherWidget() {
    if (currentWeather == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[700]!, Colors.blue[500]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                currentWeather!.location.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat(
                  'dd MMM yyyy HH:mm',
                ).format(currentWeather!.current.last_updated_epoch),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.network(
                        'https:${currentWeather!.current.condition.icon}',
                        width: 48,
                        height: 48,
                        errorBuilder:
                            (_, __, ___) => const Icon(
                              Icons.cloud,
                              color: Colors.white,
                              size: 48,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${currentWeather!.current.temp_c.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentWeather!.current.condition.text,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildWeatherDetail(
                    '${currentWeather!.current.wind_kph.toStringAsFixed(1)} km/jam',
                    Icons.air,
                  ),
                  const SizedBox(height: 8),
                  _buildWeatherDetail(
                    '${currentWeather!.current.humidity}%',
                    Icons.water_drop,
                  ),
                  const SizedBox(height: 8),
                  _buildWeatherDetail(
                    currentWeather!.current.uv.toStringAsFixed(1),
                    Icons.wb_sunny,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFarmMetricsGrid() {
    // Jika tidak ada data cuaca, tampilkan widget kosong
    if (currentWeather == null) return const SizedBox.shrink();

    // Ambil data cuaca terkini
    final current = currentWeather!.current;

    // Daftar metrik berdasarkan data cuaca aktual
    final weatherMetrics = [
      {
        'title': 'Suhu',
        'value': '${current.temp_c.toStringAsFixed(1)}°C',
        'icon': Icons.thermostat,
        'color': Colors.orange,
        'status': 'Suhu Saat Ini',
      },
      {
        'title': 'Curah Hujan',
        'value': '${current.precip_mm} mm',
        'icon': Icons.water_drop,
        'color': Colors.blue[700]!,
        'status': 'Presipitasi',
      },
      {
        'title': 'Kelembaban',
        'value': '${current.humidity}%',
        'icon': Icons.opacity,
        'color': Colors.cyan,
        'status': 'Tingkat Kelembaban',
      },
      {
        'title': 'Indeks UV',
        'value': current.uv.toStringAsFixed(1),
        'icon': Icons.wb_sunny,
        'color': Colors.amber[700]!,
        'status': 'Radiasi UV',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kondisi Cuaca',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              TextButton(
                onPressed: () {
                  if (selectedFarm != null) {
                    context.pushNamed(
                      'landDetail',
                      pathParameters: {'farmId': selectedFarm!.fID.toString()},
                      queryParameters: {'name': selectedFarm!.name},
                    );
                  }
                },
                child: Text(
                  'Lihat Detail',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: weatherMetrics.length,
            itemBuilder: (context, index) {
              final metric = weatherMetrics[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: (metric['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            metric['icon'] as IconData,
                            color: metric['color'] as Color,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            metric['title'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      metric['value'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 0,
                      ),
                      decoration: BoxDecoration(
                        color: (metric['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        metric['status'] as String,
                        style: TextStyle(
                          fontSize: 9,
                          color: metric['color'] as Color,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatAISection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.green,
                radius: 16,
                child: Icon(Icons.smart_toy, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                'Chat with FarmWise AI',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              context.go('/chatbot');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[500], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ask anything about your farm...',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildNewsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Farm News',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child:
                isLoadingNews
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                      children: [
                        if (newsList.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text('Tidak ada berita terkini'),
                          )
                        else
                          ...newsList.map((news) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  child: InkWell(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child:
                                              news.urlToImage != null &&
                                                      news
                                                          .urlToImage!
                                                          .isNotEmpty
                                                  ? Image.network(
                                                    news.urlToImage!,
                                                    height: 60,
                                                    width: 60,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) =>
                                                            _buildImagePlaceholder(),
                                                  )
                                                  : _buildImagePlaceholder(),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                news.title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[900],
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                '${_getSourceName(news.url)} • ${_formatDate(news.publishedAt)}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (newsList.indexOf(news) <
                                    newsList.length - 1)
                                  const Divider(
                                    thickness: 1,
                                    color: Colors.black12,
                                  ),
                              ],
                            );
                          }).toList(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.go('/news'),
                            child: const Text(
                              'Lihat selengkapnya',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 60,
      width: 60,
      color: Colors.grey.shade200,
      child: Icon(Icons.image, color: Colors.grey.shade400, size: 30),
    );
  }
}
