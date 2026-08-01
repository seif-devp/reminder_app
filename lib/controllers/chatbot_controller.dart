import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reminder_app/core/init_local_db.dart';
import 'package:reminder_app/data/entity/medications.dart';
import 'package:reminder_app/data/entity/intake_records.dart';
import 'package:reminder_app/data/entity/users.dart';
import 'package:reminder_app/model/chatbot_model.dart';
import 'package:reminder_app/services/chatbot_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatbotController extends GetxController {
  final ChatbotService _chatbotService = ChatbotService();

  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  
  // Quick suggestions
  final suggestions = <QuickSuggestion>[].obs;
  final showSuggestions = true.obs;

  // Voice input
  late stt.SpeechToText _speech;
  final isListening = false.obs;
  final recognizedText = ''.obs;
  final isSpeechAvailable = false.obs;

  // User medical data for context
  List<Medication> userMedications = [];
  List<IntakeRecord> recentRecords = [];
  User? userProfile;

  // Chat history for Gemini
  final List<Map<String, dynamic>> chatHistory = [];

  @override
  void onInit() {
    super.onInit();
    _initSpeech();
    _loadUserMedicalData();
  }

  /// Initialize speech recognition
  Future<void> _initSpeech() async {
    _speech = stt.SpeechToText();
    try {
      isSpeechAvailable.value = await _speech.initialize(
        onError: (error) {
          print('Speech error: ${error.errorMsg}');
          isListening.value = false;
          Get.snackbar(
            'Voice Input Error',
            'Failed to initialize speech recognition',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade400,
            colorText: Colors.white,
            icon: const Icon(Icons.mic_off, color: Colors.white),
          );
        },
        onStatus: (status) {
          print('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            isListening.value = false;
          }
        },
      );

      if (isSpeechAvailable.value) {
        print('✅ Speech recognition initialized successfully');
      } else {
        print('❌ Speech recognition not available');
      }
    } catch (e) {
      print('❌ Error initializing speech: $e');
      isSpeechAvailable.value = false;
    }
  }

  /// Start listening to user's voice
  Future<void> startListening() async {
    if (!isSpeechAvailable.value) {
      Get.snackbar(
        'Voice Input Unavailable',
        'Speech recognition is not available on this device',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.mic_off, color: Colors.white),
      );
      return;
    }

    if (isListening.value) {
      await stopListening();
      return;
    }

    try {
      recognizedText.value = '';
      isListening.value = true;

      await _speech.listen(
        onResult: (result) {
          recognizedText.value = result.recognizedWords;
          print('Recognized: ${result.recognizedWords}');
          
          // If user stops speaking and result is final, send message
          if (result.finalResult) {
            stopListening();
            if (recognizedText.value.trim().isNotEmpty) {
              sendMessage(recognizedText.value);
            }
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );
    } catch (e) {
      print('❌ Error starting speech recognition: $e');
      isListening.value = false;
      Get.snackbar(
        'Voice Input Error',
        'Could not start listening. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        icon: const Icon(Icons.mic_off, color: Colors.white),
      );
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    isListening.value = false;
  }

  /// Load user's medical data for context
  Future<void> _loadUserMedicalData() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) return;

    try {
      // Load medications
      userMedications = await database.medicationsDao.getMedicationsByUser(userId);

      // Load recent records (last 7 days)
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final startDay = DateTime(weekAgo.year, weekAgo.month, weekAgo.day);
      final endDay = DateTime(now.year, now.month, now.day)
          .add(const Duration(days: 1))
          .subtract(const Duration(milliseconds: 1));

      recentRecords = await database.intakeRecordDao.getRecordsBetweenDates(
        startDay.toIso8601String(),
        endDay.toIso8601String(),
      );

      // Load user profile
      userProfile = await database.userDao.getUserById(userId);

      // Generate dynamic suggestions
      _generateSuggestions();

      print('✅ Loaded ${userMedications.length} medications and ${recentRecords.length} records');
    } catch (e) {
      print('❌ Error loading medical data: $e');
      _generateDefaultSuggestions();
    }
  }

  /// Generate dynamic suggestions based on user data
  void _generateSuggestions() {
    suggestions.clear();

    // Always show general suggestions
    suggestions.add(QuickSuggestion(
      icon: '❓',
      text: 'How can you help me?',
      prompt: 'What can you help me with?',
      category: SuggestionCategory.general,
    ));

    // Medication-specific suggestions
    if (userMedications.isNotEmpty) {
      suggestions.add(QuickSuggestion(
        icon: '💊',
        text: 'My current medications',
        prompt: 'What medications am I currently taking?',
        category: SuggestionCategory.medications,
      ));

      if (userMedications.length == 1) {
        suggestions.add(QuickSuggestion(
          icon: '📋',
          text: 'About ${userMedications.first.name}',
          prompt: 'Tell me about ${userMedications.first.name}. What are its uses and side effects?',
          category: SuggestionCategory.medications,
        ));
      } else {
        suggestions.add(QuickSuggestion(
          icon: '⚠️',
          text: 'Drug interactions',
          prompt: 'Are there any interactions between my current medications?',
          category: SuggestionCategory.medications,
        ));
      }
    }

    // Adherence suggestions
    if (recentRecords.isNotEmpty) {
      final adherenceRate = _calculateAdherenceRate();
      
      suggestions.add(QuickSuggestion(
        icon: '📊',
        text: 'My adherence stats',
        prompt: 'How is my medication adherence this week?',
        category: SuggestionCategory.adherence,
      ));

      if (adherenceRate < 80) {
        suggestions.add(QuickSuggestion(
          icon: '💡',
          text: 'Improve adherence',
          prompt: 'How can I improve my medication adherence?',
          category: SuggestionCategory.adherence,
        ));
      }

      final missedToday = recentRecords.where((r) => 
        r.status == 'missed' && 
        DateTime.parse(r.scheduledAt).day == DateTime.now().day
      ).length;

      if (missedToday > 0) {
        suggestions.add(QuickSuggestion(
          icon: '❌',
          text: 'Missed doses today',
          prompt: 'I missed $missedToday dose${missedToday > 1 ? 's' : ''} today. What should I do?',
          category: SuggestionCategory.adherence,
        ));
      }

      final pendingToday = recentRecords.where((r) =>
        r.status == 'pending' &&
        DateTime.parse(r.scheduledAt).day == DateTime.now().day &&
        DateTime.parse(r.scheduledAt).isBefore(DateTime.now())
      ).length;

      if (pendingToday > 0) {
        suggestions.add(QuickSuggestion(
          icon: '⏰',
          text: 'Pending doses',
          prompt: 'I have $pendingToday pending dose${pendingToday > 1 ? 's' : ''}. When should I take them?',
          category: SuggestionCategory.adherence,
        ));
      }
    }

    suggestions.add(QuickSuggestion(
      icon: '🍎',
      text: 'Health tips',
      prompt: 'Give me some general health tips for managing my medications',
      category: SuggestionCategory.tips,
    ));

    if (suggestions.length > 6) {
      suggestions.removeRange(6, suggestions.length);
    }
  }

  /// Generate default suggestions
  void _generateDefaultSuggestions() {
    suggestions.clear();
    
    suggestions.addAll([
      QuickSuggestion(
        icon: '❓',
        text: 'How can you help?',
        prompt: 'What can you help me with?',
        category: SuggestionCategory.general,
      ),
      QuickSuggestion(
        icon: '💊',
        text: 'About medications',
        prompt: 'How do I properly take my medications?',
        category: SuggestionCategory.medications,
      ),
      QuickSuggestion(
        icon: '⏰',
        text: 'Best time to take meds',
        prompt: 'What\'s the best time to take medications?',
        category: SuggestionCategory.medications,
      ),
      QuickSuggestion(
        icon: '🍎',
        text: 'Health tips',
        prompt: 'Give me general health tips',
        category: SuggestionCategory.tips,
      ),
    ]);
  }

  /// Calculate adherence rate
  double _calculateAdherenceRate() {
    if (recentRecords.isEmpty) return 0.0;
    final taken = recentRecords.where((r) => r.status == 'taken').length;
    return (taken / recentRecords.length) * 100;
  }

  /// Send message from suggestion
  Future<void> sendSuggestion(QuickSuggestion suggestion) async {
    showSuggestions.value = false;
    await sendMessage(suggestion.prompt);
  }

  /// Send message with enhanced error handling
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = text.trim();

    // Hide suggestions after sending message
    showSuggestions.value = false;

    // Add user message to UI
    messages.insert(
      0,
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: userMessage,
        fromUser: true,
        createdAt: DateTime.now(),
      ),
    );

    // Add to chat history
    chatHistory.add({
      'role': 'user',
      'content': userMessage,
    });

    isLoading.value = true;

    try {
      final response = await _chatbotService.send(
        chatHistory,
        userMedications: userMedications,
        recentRecords: recentRecords,
        userProfile: userProfile,
      );

      messages.insert(
        0,
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: response,
          fromUser: false,
          createdAt: DateTime.now(),
        ),
      );

      chatHistory.add({
        'role': 'assistant',
        'content': response,
      });
      
    } on ChatbotException catch (e) {
      _handleChatbotError(e);
    } catch (e) {
      _handleUnexpectedError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void _handleChatbotError(ChatbotException e) {
    String errorIcon = _getErrorIcon(e.type);
    String errorMessage = _getErrorMessage(e);
    String actionHint = _getActionHint(e.type);

    messages.insert(
      0,
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: '$errorIcon $errorMessage\n\n💡 $actionHint',
        fromUser: false,
        createdAt: DateTime.now(),
      ),
    );

    if (_isCriticalError(e.type)) {
      Get.snackbar(
        'Connection Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _getErrorColor(e.type),
        colorText: Colors.white,
        icon: Icon(_getErrorIconData(e.type), color: Colors.white),
        duration: const Duration(seconds: 4),
      );
    }

    if (chatHistory.isNotEmpty && chatHistory.last['role'] == 'user') {
      chatHistory.removeLast();
    }
  }

  void _handleUnexpectedError(dynamic e) {
    messages.insert(
      0,
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: '❌ An unexpected error occurred.\n\n💡 Please try again or restart the app.',
        fromUser: false,
        createdAt: DateTime.now(),
      ),
    );

    Get.snackbar(
      'Error',
      'Something went wrong. Please try again.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );

    if (chatHistory.isNotEmpty && chatHistory.last['role'] == 'user') {
      chatHistory.removeLast();
    }
  }

  String _getErrorIcon(ChatbotErrorType type) {
    switch (type) {
      case ChatbotErrorType.noInternet:
      case ChatbotErrorType.networkError:
        return '📡';
      case ChatbotErrorType.timeout:
        return '⏱️';
      case ChatbotErrorType.rateLimited:
        return '🚦';
      case ChatbotErrorType.authentication:
        return '🔑';
      case ChatbotErrorType.serverError:
        return '🔧';
      case ChatbotErrorType.contentFiltered:
        return '⚠️';
      default:
        return '❌';
    }
  }

  String _getErrorMessage(ChatbotException e) => e.message;

  String _getActionHint(ChatbotErrorType type) {
    switch (type) {
      case ChatbotErrorType.noInternet:
        return 'Check your internet connection and try again.';
      case ChatbotErrorType.timeout:
        return 'The server is slow. Please wait a moment and retry.';
      case ChatbotErrorType.rateLimited:
        return 'You\'ve sent too many messages. Wait 30 seconds and try again.';
      case ChatbotErrorType.authentication:
        return 'There\'s a configuration issue. Please contact support.';
      case ChatbotErrorType.serverError:
        return 'The server is having issues. Try again in a few minutes.';
      case ChatbotErrorType.contentFiltered:
        return 'Try asking your question in a different way.';
      case ChatbotErrorType.emptyResponse:
      case ChatbotErrorType.noResponse:
        return 'Rephrase your question or try asking something else.';
      default:
        return 'Please try again or restart the app.';
    }
  }

  bool _isCriticalError(ChatbotErrorType type) {
    return type == ChatbotErrorType.noInternet ||
        type == ChatbotErrorType.authentication ||
        type == ChatbotErrorType.rateLimited;
  }

  Color _getErrorColor(ChatbotErrorType type) {
    switch (type) {
      case ChatbotErrorType.noInternet:
        return Colors.orange;
      case ChatbotErrorType.authentication:
        return Colors.red;
      case ChatbotErrorType.rateLimited:
        return Colors.amber;
      default:
        return Colors.red.shade400;
    }
  }

  IconData _getErrorIconData(ChatbotErrorType type) {
    switch (type) {
      case ChatbotErrorType.noInternet:
        return Icons.wifi_off;
      case ChatbotErrorType.authentication:
        return Icons.lock_outline;
      case ChatbotErrorType.rateLimited:
        return Icons.timer_outlined;
      default:
        return Icons.error_outline;
    }
  }

  Future<void> refreshMedicalData() async {
    await _loadUserMedicalData();
  }

  void clearChat() {
    messages.clear();
    chatHistory.clear();
    showSuggestions.value = true;
  }

  void toggleSuggestions() {
    showSuggestions.value = !showSuggestions.value;
  }

  @override
  void onClose() {
    stopListening();
    super.onClose();
  }
}

class QuickSuggestion {
  final String icon;
  final String text;
  final String prompt;
  final SuggestionCategory category;

  QuickSuggestion({
    required this.icon,
    required this.text,
    required this.prompt,
    required this.category,
  });
}

enum SuggestionCategory {
  general,
  medications,
  adherence,
  tips,
}
