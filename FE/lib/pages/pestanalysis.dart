// Simplified PestAnalysis class - Only shows plain response text
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:farmwise_app/logic/api/chats.dart';
import 'package:farmwise_app/logic/lib/myConvert.dart';
import 'package:farmwise_app/logic/logicGlobal.dart';
import 'package:farmwise_app/logic/schemas/Chat.dart';
import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

class PestAnalysis extends StatefulWidget {
  final String imagePath;
  final XFile? imageFile;
  final dynamic resultData;
  final bool isLoading;

  const PestAnalysis({
    Key? key,
    required this.imagePath,
    this.imageFile,
    this.resultData,
    this.isLoading = true,
  }) : super(key: key);

  @override
  State<PestAnalysis> createState() => _PestAnalysisState();
}

class _PestAnalysisState extends State<PestAnalysis> {
  bool _isLoading = true;
  dynamic _resultData;
  String? _errorMessage;
  String _analysisText = '';

  @override
  void initState() {
    super.initState();
    _resultData = widget.resultData;
    _isLoading = widget.isLoading;

    // If no result data and loading is true, perform analysis
    if (_isLoading && widget.imageFile != null) {
      _performAnalysis();
    } else if (_resultData != null) {
      _extractAnalysisText();
      _isLoading = false;
    } else {
      _isLoading = false;
    }
  }

  // Extract text from result data
  void _extractAnalysisText() {
    if (_resultData != null) {
      // If _resultData is a Chat object
      if (_resultData is Chat) {
        _analysisText = _resultData.answer;
      }
      // If _resultData is already a string
      else if (_resultData is String) {
        _analysisText = _resultData;
      }
      // If it's some other format, try to get a string representation
      else {
        _analysisText = _resultData.toString();
      }
    }
  }

  Future<void> _performAnalysis() async {
    try {
      // Convert image to base64
      String base64Image = await imageToBase64(widget.imageFile!);

      // Call API for plant analysis
      final resp = await scanAI(base64Image, ScanType.disease);

      // Log for debugging
      print("API Response Status: ${resp.statusCode}");
      if (resp.err != null) print("API Error: ${resp.err}");

      // Update state with results
      setState(() {
        if (resp.statusCode == 200 && resp.response != null) {
          _resultData = resp.response;
          _extractAnalysisText();
          _isLoading = false;
          chats = [resp.response!] + chats;
        } else {
          _errorMessage = resp.err ?? "Failed to analyze plant";
          _isLoading = false;
        }
      });
    } catch (e) {
      // Handle exception
      setState(() {
        _errorMessage = "Error: $e";
        _isLoading = false;
      });
      print("Exception during analysis: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Analysis'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body:
          _isLoading
              ? _buildLoadingView()
              : (_errorMessage != null
                  ? _buildErrorView()
                  : _buildResultView()),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: FileImage(File(widget.imagePath)),
                fit: BoxFit.cover,
                opacity: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(color: Colors.green),
          const SizedBox(height: 16),
          const Text('Analyzing plant...', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          const Text(
            'Mohon tunggu sebentar',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Terjadi kesalahan',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (widget.imageFile != null) {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _performAnalysis();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    // Display plant analysis result as simple text
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plant image
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              image: DecorationImage(
                image: FileImage(File(widget.imagePath)),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Single simple card with analysis text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.eco, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Analysis Result',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                MarkdownBlock(
                  data:
                      _analysisText.isNotEmpty
                          ? _analysisText
                          : 'No analysis results',
                  config: MarkdownConfig(
                    configs: [
                      PConfig(
                        textStyle: TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
