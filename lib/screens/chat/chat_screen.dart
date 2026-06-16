import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/colors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      sender: 'System',
      text: 'Mesh network chat active. Messages are broadcast to all peers.',
      isSystem: true,
      time: '12:00',
    ),
    _ChatMessage(
      sender: 'User A',
      text: 'Is anyone near the north bridge? Need help moving debris.',
      time: '12:03',
    ),
    _ChatMessage(
      sender: 'User B',
      text: 'I\'m about 500m away. Coming your way now.',
      time: '12:04',
    ),
    _ChatMessage(
      sender: 'You',
      text: 'Copy that. I have a first aid kit ready.',
      isMe: true,
      time: '12:05',
    ),
    _ChatMessage(
      sender: 'User C',
      text: 'Water distribution at City Park starts in 30 min. Pass it on!',
      time: '12:08',
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(
        sender: 'You',
        text: _messageController.text.trim(),
        isMe: true,
        time: TimeOfDay.now().format(context),
      ));
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Text(
                    'Mesh Chat',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.meshActive.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.meshActive,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Broadcast',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.meshActive,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const Divider(height: 1),

            // Messages
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];

                  if (msg.isSystem) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMedium,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            msg.text,
                            style: Theme.of(context).textTheme.labelSmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(
                          delay: Duration(milliseconds: index * 100),
                          duration: 300.ms,
                        );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: msg.isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!msg.isMe)
                          Container(
                            width: 32,
                            height: 32,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.meshActive.withAlpha(38),
                            ),
                            child: Center(
                              child: Text(
                                msg.sender[0],
                                style: const TextStyle(
                                  color: AppColors.meshActive,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: msg.isMe
                                  ? AppColors.accent.withAlpha(26)
                                  : AppColors.surfaceLight,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
                                bottomRight:
                                    Radius.circular(msg.isMe ? 4 : 16),
                              ),
                              border: Border.all(
                                color: msg.isMe
                                    ? AppColors.accent.withAlpha(51)
                                    : AppColors.glassBorder,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!msg.isMe)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      msg.sender,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.meshActive,
                                      ),
                                    ),
                                  ),
                                Text(
                                  msg.text,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      msg.time,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(fontSize: 9),
                                    ),
                                    if (msg.isMe) ...[
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.done_all,
                                        size: 12,
                                        color: AppColors.meshActive,
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(
                        delay: Duration(milliseconds: index * 100),
                        duration: 300.ms,
                      ).slideX(begin: msg.isMe ? 0.05 : -0.05);
                },
              ),
            ),

            // Message input
            Container(
              padding: EdgeInsets.fromLTRB(
                  20, 12, 20, MediaQuery.of(context).padding.bottom + 80),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                border: const Border(
                  top: BorderSide(color: AppColors.glassBorder, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMedium,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 14,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.meshGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
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
      ),
    );
  }
}

class _ChatMessage {
  final String sender;
  final String text;
  final bool isMe;
  final bool isSystem;
  final String time;

  const _ChatMessage({
    required this.sender,
    required this.text,
    this.isMe = false,
    this.isSystem = false,
    required this.time,
  });
}
