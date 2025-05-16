import 'dart:convert';
import 'dart:io';
import 'package:farmwise_app/logic/api/chats.dart';
import 'package:farmwise_app/logic/lib/myConvert.dart';
import 'package:farmwise_app/logic/logicGlobal.dart';
import 'package:farmwise_app/logic/schemas/Chat.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:markdown_widget/markdown_widget.dart';

int chatPage = 1;
bool isFetching = false;

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  (String, int) _selectedFarm = ('General', -1); // Default option
  final List<(String, int)> _farmOptions =
      [('General', -1)] +
      farms.map((farm) {
        return (farm.name, farm.fID);
      }).toList();

  // Added to store the selected image
  XFile? _selectedImage;
  bool _isImageAttached = false;

  String fIDtoName(int fID) {
    for (var i = 0; i < farms.length; i++) {
      if (farms[i].fID == fID) {
        return farms[i].name;
      }
    }
    return 'Deleted';
  }

  // Sample messages for UI demonstration
  Future<void> testChatAPI() async {
    final p1 = await getChats(page: 1);
    if (p1.statusCode != 200) {
      print(p1.statusCode);
      print(p1.err);
      return;
    }
    final p2 = await getChats(page: 2);
    print(
      p2.response!.length > 0
          ? p1.response![0].cID != p2.response![0].cID
          : 'FAILED',
    );
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      print('No image selected');
      return;
    }

    // Update state with selected image
    setState(() {
      _selectedImage = image;
      _isImageAttached = true;
    });
    print('IMAGE SELECTED: ${image.path}');
  }

  // Remove attached image
  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _isImageAttached = false;
    });
  }

  // Fungsi untuk scroll ke pesan terbaru
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Fungsi untuk reset chat
  void _resetChat() {
    chatPage = 1;
    setState(() {
      chats.clear();
    });

    isFetching = true;
    getChats(page: chatPage++).then((value) {
      if (value.statusCode == 200) {
        isFetching = false;
        setState(() {
          chats = value.response!;
        });
      } else {
        print('Error: ${value.err}');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    print('Get chats history');

    isFetching = true;
    if (chats.isEmpty) {
      print('Get chats history');
      getChats(page: chatPage++).then((value) {
        if (value.statusCode == 200) {
          isFetching = false;
          setState(() {
            chats = value.response!;
          });
        } else {
          print('Error: ${value.err}');
        }
      });
    }
  }

  void scrollListener() {
    if (isFetching == false &&
        chatPage != -1 &&
        _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
      // Fetch more
      isFetching = true;
      getChats(page: chatPage++).then((value) {
        if (value.statusCode == 200) {
          isFetching = false;
          if (value.response!.isEmpty) {
            chatPage = -1;
            return;
          }
          setState(() {
            chats = chats + value.response!;
          });
        } else {
          print('Error: ${value.err}');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _scrollController.addListener(scrollListener);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'AI Chat',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          // Tambahkan tombol reset chat
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetChat,
            tooltip: 'Reset Chat',
          ),
          PopupMenuButton<(String, int)>(
            icon: Row(
              children: [
                Text(
                  _selectedFarm.$1,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
            onSelected: ((String, int) farm) {
              setState(() {
                _selectedFarm = farm;
              });
            },
            itemBuilder: (BuildContext context) {
              return _farmOptions.map(((String, int) farm) {
                return PopupMenuItem<(String, int)>(
                  value: farm,
                  child: Row(
                    children: [
                      Icon(
                        farm.$2 == -1 ? Icons.chat : Icons.eco,
                        color: Colors.green,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(farm.$1),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Farm context indicator
          if (_selectedFarm.$2 != -1)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.green.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'AI akan mempertimbangkan konteks ${_selectedFarm.$1}',
                    style: const TextStyle(color: Colors.green, fontSize: 13),
                  ),
                ],
              ),
            ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              reverse: true,
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: chats.length * 2, // Double for prompt and answer
              itemBuilder: (context, index) {
                final messageIndex =
                    index ~/ 2; // Integer division for message index
                final isUserMessage =
                    index % 2 == 1; // Even indices are user messages
                final message = chats[messageIndex];

                // Skip empty messages
                final messageText =
                    isUserMessage ? message.prompt.text : message.answer;
                if (messageText == null || messageText.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment:
                        isUserMessage
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AI Avatar (only shown for AI messages)
                      if (!isUserMessage)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: const CircleAvatar(
                            backgroundColor: Colors.green,
                            radius: 16,
                            child: Icon(
                              Icons.smart_toy,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),

                      Flexible(
                        child: Column(
                          crossAxisAlignment:
                              isUserMessage
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                          children: [
                            // Farm context badge (only for user messages)
                            if (isUserMessage && message.fID != null)
                              Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.eco,
                                      size: 12,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      message.fID!.toString(),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Message content
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.65,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isUserMessage ? Colors.green : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Display text message
                                  MarkdownBlock(
                                    data:
                                        isUserMessage
                                            ? (message.prompt.text ??
                                                'No Message')
                                            : message.answer,
                                    config: MarkdownConfig(
                                      configs: [
                                        PConfig(
                                          textStyle: TextStyle(
                                            color:
                                                isUserMessage == true
                                                    ? Colors.white
                                                    : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Display image if available
                                  if (isUserMessage &&
                                      message.prompt.image != null &&
                                      message.prompt.image!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          base64Decode(message.prompt.image!),
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              height: 100,
                                              color: Colors.grey[300],
                                              child: const Center(
                                                child: Icon(Icons.error),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Timestamp
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                (message.fID == null
                                        ? 'General'
                                        : fIDtoName(message.fID!)) +
                                    ' | ' +
                                    message.date.toString(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // User Avatar (only shown for user messages)
                      if (isUserMessage)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          child: CircleAvatar(
                            backgroundColor: Colors.green[700],
                            radius: 16,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Image preview (when image is selected)
          Container(
            padding:
                _selectedImage == null
                    ? null
                    : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Stack(
              children:
                  _selectedImage == null
                      ? [Text('')]
                      : [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_selectedImage!.path),
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: _removeImage,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
            ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.only(
              bottom: 40,
              left: 16,
              right: 16,
              top: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickImage, // Call our new _pickImage method
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          _isImageAttached
                              ? Colors.green.withOpacity(0.1)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      Icons.photo_library,
                      color: _isImageAttached ? Colors.green : Colors.grey,
                      size: 24,
                    ),
                  ),
                ),

                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    minLines: 1,
                    maxLines: 4,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    final text = _messageController.text.trim();
                    if (text.isEmpty && _selectedImage == null) return;

                    // Kosongkan input
                    _messageController.clear();

                    // Scroll ke bawah setelah pesan pengguna ditambahkan
                    _scrollToBottom();

                    try {
                      // Handle image upload first if there's an image
                      String? image;
                      if (_selectedImage != null) {
                        image = await imageToBase64(_selectedImage!);
                      } // Kirim ke API
                      final tempNow = chats;
                      setState(() {
                        _selectedImage = null;
                        chats =
                            [
                              Chat((
                                answer: '...',
                                cID: 999999999999,
                                uID: currentUser!.uID,
                                fID: _selectedFarm.$2,
                                date: DateTime.now(),
                                prompt: (image: image, text: text),
                              )),
                            ] +
                            chats;
                      });
                      final resp = await prompts(
                        text: text,
                        image: image,
                        fID: _selectedFarm.$2 == -1 ? null : (_selectedFarm.$2),
                      );

                      // Tambahkan respons AI ke UI
                      if (resp.statusCode == 200 && resp.response != null) {
                        setState(() {
                          chats = [resp.response!] + tempNow;
                          _selectedImage = null;
                        });

                        // Scroll ke bawah setelah respons AI ditambahkan
                        _scrollToBottom();
                      } else {
                        print('Error dari API: ${resp.err}');
                      }
                    } catch (e) {
                      print('Gagal kirim pesan: $e');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
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
}
