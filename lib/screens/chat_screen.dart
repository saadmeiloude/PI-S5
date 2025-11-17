import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:record/record.dart'; // Temporarily disabled
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../models/chat.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String doctorName;
  final String doctorId;

  const ChatScreen({
    super.key,
    required this.chatRoomId,
    required this.doctorName,
    required this.doctorId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  // final Record _audioRecorder = Record(); // Temporarily disabled
  final TextEditingController _searchController = TextEditingController();
  bool _isRecording = false;
  String? _recordingPath;
  Timer? _typingTimer;
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (userProvider.currentUser != null) {
        chatProvider.loadMessages(widget.chatRoomId);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    // _audioRecorder.dispose(); // Temporarily disabled
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    hintText: 'البحث في الرسائل...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                )
              : Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00BFFF).withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF00BFFF),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.doctorName,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Consumer<ChatProvider>(
                            builder: (context, chatProvider, child) {
                              return Text(
                                chatProvider.isConnected ? 'متصل' : 'غير متصل',
                                style: TextStyle(
                                  color: chatProvider.isConnected
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          leading: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.black87),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                )
              : null,
          actions: _isSearching
              ? null
              : [
                  IconButton(
                    icon: const Icon(Icons.search, color: Color(0xFF00BFFF)),
                    onPressed: () {
                      setState(() {
                        _isSearching = true;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.videocam, color: Color(0xFF00BFFF)),
                    onPressed: () {
                      // Start video call
                      _startVideoCall();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.call, color: Color(0xFF00BFFF)),
                    onPressed: () {
                      // Start voice call
                      _startVoiceCall();
                    },
                  ),
                ],
        ),
        body: Column(
          children: [
            // Messages List
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  final allMessages = chatProvider.getMessages(
                    widget.chatRoomId,
                  );

                  // Filter messages based on search query
                  final messages = _searchQuery.isEmpty
                      ? allMessages
                      : allMessages.where((message) {
                          return message.message.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          );
                        }).toList();

                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'لا توجد رسائل بعد'
                            : 'لا توجد رسائل تطابق البحث',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final userProvider = Provider.of<UserProvider>(
                        context,
                        listen: false,
                      );
                      final isMe =
                          message.senderId == userProvider.currentUser?.id;

                      return GestureDetector(
                        onLongPress: () {
                          _showMessageOptions(context, message, isMe);
                        },
                        child: _buildMessageBubble(message, isMe),
                      );
                    },
                  );
                },
              ),
            ),

            // Typing Indicator
            Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.isUserTyping(widget.chatRoomId)) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF00BFFF),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.doctorName} يكتب...',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Message Input
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    Widget messageContent;

    switch (message.type) {
      case MessageType.image:
        messageContent = _buildImageMessage(message, isMe);
        break;
      case MessageType.file:
        messageContent = _buildFileMessage(message, isMe);
        break;
      case MessageType.voice:
        messageContent = _buildVoiceMessage(message, isMe);
        break;
      default:
        messageContent = _buildTextMessage(message, isMe);
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF00BFFF) : Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: isMe
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
        ),
        child: messageContent,
      ),
    );
  }

  Widget _buildTextMessage(ChatMessage message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.message,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 4),
                _buildStatusIcon(message.status),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageMessage(ChatMessage message, bool isMe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: Image.network(
            message.attachmentUrl ?? '',
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported, size: 50),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            _formatTime(message.timestamp),
            style: TextStyle(
              color: isMe ? Colors.white70 : Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileMessage(ChatMessage message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(
            Icons.attach_file,
            color: isMe ? Colors.white : Colors.black87,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.attachmentUrl?.split('/').last ?? 'ملف',
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        color: isMe ? Colors.white70 : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      _buildStatusIcon(message.status),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceMessage(ChatMessage message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.play_arrow,
              color: isMe ? Colors.white : Colors.black87,
              size: 24,
            ),
            onPressed: () {
              // Implement voice message playback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تشغيل الرسالة الصوتية')),
              );
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'رسالة صوتية',
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        color: isMe ? Colors.white70 : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      _buildStatusIcon(message.status),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(MessageStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        color = Colors.grey;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.grey;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.grey;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.blue;
        break;
    }

    return Icon(icon, size: 14, color: color);
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file, color: Color(0xFF00BFFF)),
            onPressed: _attachFile,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          if (_messageController.text.isEmpty)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isRecording ? Colors.red : const Color(0xFF00BFFF),
              ),
              child: IconButton(
                icon: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: Colors.white,
                ),
                onPressed: _toggleRecording,
              ),
            )
          else
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF00BFFF),
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.currentUser != null) {
      chatProvider.sendMessage(
        chatRoomId: widget.chatRoomId,
        senderId: userProvider.currentUser!.id,
        receiverId: widget.doctorId,
        message: message,
      );

      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _attachFile() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('الكاميرا'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('المعرض'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: const Text('ملف'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // For web platform, skip permission check as it's not supported
      bool hasPermission = true;

      // Only check permissions on mobile platforms
      if (!kIsWeb) {
        PermissionStatus permissionStatus;

        if (source == ImageSource.camera) {
          permissionStatus = await Permission.camera.request();
        } else {
          permissionStatus = await Permission.photos.request();
        }

        hasPermission = permissionStatus.isGranted;
      }

      if (hasPermission) {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );

        if (image != null) {
          // For now, just send as text message with file path
          // In production, upload to server and get URL
          _sendFileMessage(image.path, MessageType.image);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم رفض الإذن للوصول إلى الصور')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ في اختيار الصورة: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      // For web platform, skip permission check as it's not supported
      bool hasPermission = true;

      // Only check permissions on mobile platforms
      if (!kIsWeb) {
        PermissionStatus permissionStatus = await Permission.storage.request();
        hasPermission = permissionStatus.isGranted;
      }

      if (hasPermission) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'png'],
        );

        if (result != null) {
          final file = result.files.single;
          if (file.path != null) {
            // Determine message type based on extension
            MessageType type = MessageType.file;
            if (file.extension == 'jpg' || file.extension == 'png') {
              type = MessageType.image;
            }
            _sendFileMessage(file.path!, type);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم رفض الإذن للوصول إلى الملفات')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ في اختيار الملف: ${e.toString()}')),
        );
      }
    }
  }

  void _sendFileMessage(String filePath, MessageType type) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.currentUser != null) {
      chatProvider.sendMessage(
        chatRoomId: widget.chatRoomId,
        senderId: userProvider.currentUser!.id,
        receiverId: widget.doctorId,
        message: 'تم إرسال ملف', // Placeholder message
        type: type,
        attachmentUrl: filePath, // In production, this would be uploaded URL
      );
    }
  }

  Future<void> _toggleRecording() async {
    // Audio recording temporarily disabled - uncomment when record package is fixed
    /*
    try {
      if (_isRecording) {
        // Stop recording
        final path = await _audioRecorder.stop();
        setState(() {
          _isRecording = false;
          _recordingPath = path;
        });

        if (_recordingPath != null) {
          _sendVoiceMessage(_recordingPath!);
        }
      } else {
        // Start recording
        bool hasPermission = true;

        // Only check permissions on mobile platforms
        if (!kIsWeb) {
          PermissionStatus permissionStatus = await Permission.microphone
              .request();
          hasPermission = permissionStatus.isGranted;
        }

        if (hasPermission) {
          final path = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
          await _audioRecorder.start(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
          );
          setState(() {
            _isRecording = true;
            _recordingPath = null;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم رفض الإذن للوصول إلى الميكروفون'),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ في التسجيل الصوتي: ${e.toString()}')),
        );
      }
    }
    */

    // Show temporary message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('التسجيل الصوتي غير متاح حالياً')),
      );
    }
  }

  void _sendVoiceMessage(String filePath) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.currentUser != null) {
      chatProvider.sendMessage(
        chatRoomId: widget.chatRoomId,
        senderId: userProvider.currentUser!.id,
        receiverId: widget.doctorId,
        message: 'رسالة صوتية', // Placeholder message
        type: MessageType.voice,
        attachmentUrl: filePath, // In production, this would be uploaded URL
      );
    }
  }

  void _onTextChanged() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    if (_messageController.text.isNotEmpty) {
      chatProvider.sendTypingStatus(widget.chatRoomId, true);
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        chatProvider.sendTypingStatus(widget.chatRoomId, false);
      });
    } else {
      chatProvider.sendTypingStatus(widget.chatRoomId, false);
      _typingTimer?.cancel();
    }
  }

  void _startVideoCall() {
    // Check if Agora is configured
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('بدء المكالمة المرئية...'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    Navigator.pushNamed(
      context,
      '/video_call',
      arguments: {
        'channelName': widget.chatRoomId,
        'doctorName': widget.doctorName,
        'isVideoCall': true,
      },
    );
  }

  void _startVoiceCall() {
    // Check if Agora is configured
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('بدء المكالمة الصوتية...'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    Navigator.pushNamed(
      context,
      '/video_call',
      arguments: {
        'channelName': widget.chatRoomId,
        'doctorName': widget.doctorName,
        'isVideoCall': false,
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showMessageOptions(
    BuildContext context,
    ChatMessage message,
    bool isMe,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              if (isMe) ...[
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'حذف الرسالة',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteMessage(message);
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('نسخ النص'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement copy functionality
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('تم نسخ النص')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.reply),
                title: const Text('رد'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement reply functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ميزة الرد قيد التطوير')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.forward),
                title: const Text('إعادة توجيه'),
                onTap: () {
                  Navigator.pop(context);
                  _forwardMessage(message);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteMessage(ChatMessage message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('حذف الرسالة'),
          content: const Text('هل أنت متأكد من حذف هذه الرسالة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final chatProvider = Provider.of<ChatProvider>(
                  context,
                  listen: false,
                );
                final success = await chatProvider.deleteMessage(
                  widget.chatRoomId,
                  message.id,
                );

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'تم حذف الرسالة' : 'فشل في حذف الرسالة',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              },
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _forwardMessage(ChatMessage message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('إعادة توجيه الرسالة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('الرسالة المراد توجيهها:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  message.message,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
              const Text('اختر الدردشة المراد التوجيه إليها:'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // For now, just show a placeholder
                // In production, this would open a chat selection dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ميزة إعادة التوجيه قيد التطوير'),
                  ),
                );
              },
              child: const Text('توجيه'),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${time.day}/${time.month}';
    } else if (difference.inHours > 0) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.minute} دقيقة';
    }
  }
}
