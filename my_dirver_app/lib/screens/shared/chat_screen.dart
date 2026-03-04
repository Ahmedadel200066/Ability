import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text("أحمد السائق",
                style: GoogleFonts.cairo(
                    fontSize: 16, fontWeight: FontWeight.bold)),
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
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildChatBubble("السلام عليكم، أنا في الطريق إليك", true),
                _buildChatBubble(
                    "وعليكم السلام، أنا بانتظارك أمام الصيدلية", false),
                _buildChatBubble("تمام، سأصل خلال دقيقتين", true),
              ],
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
          color: isMe ? const Color(0xff007AFF) : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
        ),
        child: Text(
          message,
          style: GoogleFonts.cairo(color: isMe ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(15),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.send, color: Color(0xff007AFF))),
          Expanded(
            child: TextField(
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: "اكتب رسالتك هنا...",
                hintStyle: GoogleFonts.cairo(fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
