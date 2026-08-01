import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reminder_app/controllers/chatbot_controller.dart';
import 'package:reminder_app/model/chatbot_model.dart';
import 'package:intl/intl.dart';

class ChatbotPage extends GetView<ChatbotController> {
  ChatbotPage({super.key});

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Assistant'),
        backgroundColor: Color(0xFF4FC3F7),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Toggle suggestions button
          Obx(() {
            if (controller.messages.isNotEmpty) {
              return IconButton(
                icon: Icon(
                  controller.showSuggestions.value
                      ? Icons.lightbulb
                      : Icons.lightbulb_outline,
                ),
                onPressed: controller.toggleSuggestions,
                tooltip: 'Quick Suggestions',
              );
            }
            return const SizedBox.shrink();
          }),
          // Clear chat button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Clear Chat?'),
                  content: const Text('This will delete all messages.'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        controller.clearChat();
                        Get.back();
                      },
                      child: const Text(
                        'Clear',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4FC3F7).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Messages list
            Expanded(
              child: Obx(() {
                if (controller.messages.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    return _buildMessageBubble(message);
                  },
                );
              }),
            ),

            // Quick Suggestions (above input field)
            Obx(() {
              if (controller.showSuggestions.value &&
                  controller.suggestions.isNotEmpty) {
                return _buildSuggestionsSection();
              }
              return const SizedBox.shrink();
            }),

            // Loading indicator
            Obx(() {
              if (controller.isLoading.value) {
                return _buildTypingIndicator();
              }
              return const SizedBox.shrink();
            }),

            // Input field
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  /// Build empty state with welcome message
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(0xFF4FC3F7).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                size: 64,
                color: Color(0xFF4FC3F7),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Hi! I\'m Your Medical Assistant',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4FC3F7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'Choose a suggestion below or type your question!',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF4FC3F7),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build suggestions section
  Widget _buildSuggestionsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '💡 Quick Suggestions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF42A5F5),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => controller.showSuggestions.value = false,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.suggestions.map((suggestion) {
              return _buildSuggestionChip(suggestion);
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Build individual suggestion chip
  Widget _buildSuggestionChip(QuickSuggestion suggestion) {
    return InkWell(
      onTap: () => controller.sendSuggestion(suggestion),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _getSuggestionColor(suggestion.category),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getSuggestionBorderColor(suggestion.category),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              suggestion.icon,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                suggestion.text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _getSuggestionTextColor(suggestion.category),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get suggestion colors based on category
  Color _getSuggestionColor(SuggestionCategory category) {
    switch (category) {
      case SuggestionCategory.medications:
        return const Color(0xFF42A5F5).withOpacity(0.1);
      case SuggestionCategory.adherence:
        return Colors.green.withOpacity(0.1);
      case SuggestionCategory.tips:
        return Colors.orange.withOpacity(0.1);
      case SuggestionCategory.general:
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }

  Color _getSuggestionBorderColor(SuggestionCategory category) {
    switch (category) {
      case SuggestionCategory.medications:
        return const Color(0xFF42A5F5).withOpacity(0.3);
      case SuggestionCategory.adherence:
        return Colors.green.withOpacity(0.3);
      case SuggestionCategory.tips:
        return Colors.orange.withOpacity(0.3);
      case SuggestionCategory.general:
      default:
        return Colors.grey.withOpacity(0.3);
    }
  }

  Color _getSuggestionTextColor(SuggestionCategory category) {
    switch (category) {
      case SuggestionCategory.medications:
        return const Color(0xFF42A5F5);
      case SuggestionCategory.adherence:
        return Colors.green.shade700;
      case SuggestionCategory.tips:
        return Colors.orange.shade700;
      case SuggestionCategory.general:
      default:
        return Colors.grey.shade700;
    }
  }

  /// Build message bubble
  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.fromUser;
    final time = DateFormat('HH:mm').format(message.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4FC3F7).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Color(0xFF4FC3F7),
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFF4FC3F7)
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUser ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4FC3F7).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFF4FC3F7),
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build typing indicator
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4FC3F7).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Color(0xFF4FC3F7),
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(delay: 0),
                const SizedBox(width: 4),
                _buildDot(delay: 200),
                const SizedBox(width: 4),
                _buildDot(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build animated dot for typing indicator
  Widget _buildDot({required int delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return FutureBuilder(
          future: Future.delayed(Duration(milliseconds: delay)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Transform.translate(
                offset: Offset(0, -4 * value),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4FC3F7).withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }
            return Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF4FC3F7).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      },
      onEnd: () {
        // Restart animation
      },
    );
  }

  /// Build input field
/// Build input field with voice button
Widget _buildInputField() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Voice recognition indicator
          Obx(() {
            if (controller.isListening.value) {
              return _buildVoiceRecognitionIndicator();
            }
            return const SizedBox.shrink();
          }),
          
          // Input row
          Row(
            children: [
              // Voice button
              Obx(() {
                return Material(
                  color: controller.isListening.value
                      ? Colors.red.shade400
                      : const Color(0xFF4FC3F7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: controller.startListening,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        controller.isListening.value
                            ? Icons.mic
                            : Icons.mic_none,
                        color: controller.isListening.value
                            ? Colors.white
                            : const Color(0xFF4FC3F7),
                        size: 24,
                      ),
                    ),
                  ),
                );
              }),
              
              const SizedBox(width: 8),
              
              // Text field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: 'Ask me anything...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        controller.sendMessage(value);
                        textController.clear();
                      }
                    },
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Send button
              Obx(() {
                return Material(
                  color: controller.isLoading.value
                      ? Colors.grey.shade300
                      : const Color(0xFF4FC3F7),
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: controller.isLoading.value
                        ? null
                        : () {
                            if (textController.text.trim().isNotEmpty) {
                              controller.sendMessage(textController.text);
                              textController.clear();
                            }
                          },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.send_rounded,
                        color: controller.isLoading.value
                            ? Colors.grey.shade500
                            : Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    ),
  );
}

/// Build voice recognition indicator
Widget _buildVoiceRecognitionIndicator() {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.red.shade200,
        width: 1,
      ),
    ),
    child: Row(
      children: [
        // Animated microphone icon
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: 1.3),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Icon(
                Icons.mic,
                color: Colors.red.shade400,
                size: 24,
              ),
            );
          },
          onEnd: () {
            // Loop animation
          },
        ),
        
        const SizedBox(width: 12),
        
        // Recognized text or "Listening..."
        Expanded(
          child: Obx(() {
            return Text(
              controller.recognizedText.value.isEmpty
                  ? 'Listening... Speak now'
                  : controller.recognizedText.value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            );
          }),
        ),
        
        const SizedBox(width: 8),
        
        // Stop button
        IconButton(
          icon: Icon(
            Icons.stop_circle,
            color: Colors.red.shade400,
          ),
          onPressed: controller.stopListening,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    ),
  );
}

}
