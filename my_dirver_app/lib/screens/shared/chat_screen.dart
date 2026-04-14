import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final String tripId; // نحتاج رقم الرحلة لربط الرسائل بها
  final String receiverName;

  const ChatScreen({super.key, required this.tripId, required this.receiverName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _supabase = Supabase.instance.client;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // دالة إرسال الرسالة إلى سوبابيز
  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    _messageController.clear();

    try {
      final userId = _supabase.auth.currentUser!.id;
      await _supabase.from('messages').insert({
        'trip_id': widget.tripId,
        'sender_id': userId,
        'content': messageText,
        'created_at': DateTime.now().toIso8601String(),
      });

      // التمرير لأسفل عند إرسال رسالة
      _scrollDown();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل إرسال الرسالة: $e")),
      );
    }
  }

  void _scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0, // لأننا سنستخدم reverse: true في الـ ListView
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final myId = _supabase.auth.currentUser!.id;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.receiverName,
                style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("متصل الآن",
                style: GoogleFonts.cairo(fontSize: 10, color: Colors.green)),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              // الاستماع للرسائل الخاصة بهذه الرحلة فقط في الوقت الفعلي
              stream: _supabase
                  .from('messages')
                  .stream(primaryKey: ['id'])
                  .eq('trip_id', widget.tripId)
                  .order('created_at', ascending: false), // ترتيب تنازلي للعرض من الأسفل
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // لتبدأ الرسائل من الأسفل
                  padding: const EdgeInsets.all(20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final bool isMe = msg['sender_id'] == myId;
                    return _buildChatBubble(msg['content'], isMe);
                  },
                );
              },
            ),
          ),
          _buildChatInput(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xff1C2541) : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
        ),
        child: Text(
          message,
          style: GoogleFonts.cairo(
            color: isMe ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 15, right: 15, top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        children: [
          IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send, color: Color(0xff1C2541))),
          Expanded(
            child: TextField(
              controller: _messageController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: "اكتب رسالتك هنا...",
                hintStyle: GoogleFonts.cairo(fontSize: 14),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
        ],
      ),
    );
  }
}