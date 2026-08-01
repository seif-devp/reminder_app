import 'package:dio/dio.dart';
import 'package:reminder_app/data/entity/medications.dart';
import 'package:reminder_app/data/entity/intake_records.dart';
import 'package:reminder_app/data/entity/users.dart';

class ChatbotService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  static const String _apiKey = 'AIzaSyA1MvCetq004SSeZDYp9WiEd3gUK6R6VcE';

  /// Send message with medical context and enhanced error handling
  Future<String> send(
    List<Map<String, dynamic>> history, {
    List<Medication>? userMedications,
    List<IntakeRecord>? recentRecords,
    User? userProfile,
  }) async {
    try {
      // Build medical context
      String medicalContext = _buildMedicalContext(
        userMedications,
        recentRecords,
        userProfile,
      );

      // تحويل history لصيغة Gemini
      final contents = history
          .map((m) => {
                'role': m['role'] == 'assistant' ? 'model' : 'user',
                'parts': [
                  {
                    'text': m['content'] ?? '',
                  },
                ],
              })
          .toList();

      // Enhanced system prompt مع medical context
      contents.insert(0, {
        'role': 'user',
        'parts': [
          {
            'text': _buildSystemPrompt(medicalContext),
          },
        ],
      });

      final res = await _dio.post(
        '/models/gemini-2.5-flash:generateContent?key=$_apiKey',
        data: {
          'contents': contents,
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 500,
            'topP': 0.9,
          },
        },
      );

      // Validate response
      return _parseGeminiResponse(res);
      
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ChatbotException(
        message: 'An unexpected error occurred',
        type: ChatbotErrorType.unknown,
        originalError: e.toString(),
      );
    }
  }

  /// Parse Gemini API response with detailed error handling
  String _parseGeminiResponse(Response res) {
    if (res.statusCode != 200) {
      throw ChatbotException(
        message: 'Server returned an error',
        type: ChatbotErrorType.serverError,
        originalError: 'Status code: ${res.statusCode}',
      );
    }

    final data = res.data as Map?;
    if (data == null) {
      throw ChatbotException(
        message: 'Received empty response from server',
        type: ChatbotErrorType.invalidResponse,
      );
    }

    // Check for API errors
    if (data['error'] != null) {
      final error = data['error'] as Map?;
      final errorMessage = error?['message'] ?? 'Unknown API error';
      throw ChatbotException(
        message: errorMessage,
        type: ChatbotErrorType.apiError,
        originalError: error.toString(),
      );
    }

    // Validate candidates
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw ChatbotException(
        message: 'No response generated. Try rephrasing your question.',
        type: ChatbotErrorType.noResponse,
      );
    }

    final first = candidates[0] as Map?;
    
    // Check for content filtering
    final finishReason = first?['finishReason'] as String?;
    if (finishReason == 'SAFETY') {
      throw ChatbotException(
        message: 'Your message was blocked by safety filters. Please rephrase.',
        type: ChatbotErrorType.contentFiltered,
      );
    }

    final content = first?['content'] as Map?;
    final parts = content?['parts'] as List?;
    if (parts == null || parts.isEmpty) {
      throw ChatbotException(
        message: 'Response format is invalid',
        type: ChatbotErrorType.invalidResponse,
      );
    }

    final firstPart = parts[0] as Map?;
    final text = firstPart?['text'] as String?;
    
    if (text == null || text.trim().isEmpty) {
      throw ChatbotException(
        message: 'Received empty response. Please try again.',
        type: ChatbotErrorType.emptyResponse,
      );
    }

    return text.trim();
  }

  /// Handle Dio exceptions with specific error types
  ChatbotException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ChatbotException(
          message: 'Connection timeout. Please check your internet connection.',
          type: ChatbotErrorType.timeout,
          originalError: e.message,
        );

      case DioExceptionType.sendTimeout:
        return ChatbotException(
          message: 'Request timeout. Please try again.',
          type: ChatbotErrorType.timeout,
          originalError: e.message,
        );

      case DioExceptionType.receiveTimeout:
        return ChatbotException(
          message: 'Server took too long to respond. Please try again.',
          type: ChatbotErrorType.timeout,
          originalError: e.message,
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 429) {
          return ChatbotException(
            message: 'Too many requests. Please wait a moment and try again.',
            type: ChatbotErrorType.rateLimited,
            originalError: 'Status: $statusCode',
          );
        } else if (statusCode == 401 || statusCode == 403) {
          return ChatbotException(
            message: 'Authentication failed. Please contact support.',
            type: ChatbotErrorType.authentication,
            originalError: 'Status: $statusCode',
          );
        } else if (statusCode == 500 || statusCode == 502 || statusCode == 503) {
          return ChatbotException(
            message: 'Server is temporarily unavailable. Please try again later.',
            type: ChatbotErrorType.serverError,
            originalError: 'Status: $statusCode',
          );
        } else {
          return ChatbotException(
            message: 'Server error occurred. Please try again.',
            type: ChatbotErrorType.serverError,
            originalError: 'Status: $statusCode',
          );
        }

      case DioExceptionType.connectionError:
        return ChatbotException(
          message: 'No internet connection. Please check your network.',
          type: ChatbotErrorType.noInternet,
          originalError: e.message,
        );

      case DioExceptionType.cancel:
        return ChatbotException(
          message: 'Request was cancelled',
          type: ChatbotErrorType.cancelled,
          originalError: e.message,
        );

      default:
        return ChatbotException(
          message: 'Network error. Please try again.',
          type: ChatbotErrorType.networkError,
          originalError: e.message,
        );
    }
  }

  /// Build comprehensive medical context
  String _buildMedicalContext(
    List<Medication>? medications,
    List<IntakeRecord>? records,
    User? profile,
  ) {
    StringBuffer context = StringBuffer();

    // User profile
    if (profile != null) {
      context.writeln('\n📋 Patient Information:');
      context.writeln('Name: ${profile.name}');
      if (profile.age != null && profile.age!.isNotEmpty) {
        context.writeln('Age: ${profile.age}');
      }
      if (profile.gender != null && profile.gender!.isNotEmpty) {
        context.writeln('Gender: ${profile.gender}');
      }
      if (profile.bloodType != null && profile.bloodType!.isNotEmpty) {
        context.writeln('Blood Type: ${profile.bloodType}');
      }
    }

    // Current medications
    if (medications != null && medications.isNotEmpty) {
      context.writeln('\n💊 Current Medications:');
      for (var med in medications) {
        context.writeln('- ${med.name}');
        context.writeln('  • Dosage: ${med.dosage}');
        context.writeln('  • Frequency: ${med.frequency}');
        context.writeln('  • Duration: ${med.durationOfUse}');
        if (med.notes != null && med.notes!.isNotEmpty) {
          context.writeln('  • Notes: ${med.notes}');
        }
      }
    }

    // Adherence statistics
    if (records != null && records.isNotEmpty) {
      final taken = records.where((r) => r.status == 'taken').length;
      final missed = records.where((r) => r.status == 'missed').length;
      final pending = records.where((r) => r.status == 'pending').length;
      final total = records.length;
      final adherenceRate = total > 0 ? (taken / total * 100) : 0.0;

      context.writeln('\n📊 Recent Adherence (Last 7 Days):');
      context.writeln('Total Doses: $total');
      context.writeln('Taken: $taken ✅');
      context.writeln('Missed: $missed ❌');
      context.writeln('Pending: $pending ⏳');
      context.writeln('Adherence Rate: ${adherenceRate.toStringAsFixed(1)}%');
    }

    return context.toString();
  }

  /// Build enhanced system prompt
  String _buildSystemPrompt(String medicalContext) {
    return '''
You are **MediTrack AI Assistant** 🏥, a helpful and empathetic medical companion for a medication reminder app.

$medicalContext

🎯 Your Role:
- Answer questions about the patient's medications, schedules, and adherence
- Provide general medical information in simple, clear language
- Offer encouragement and support for medication adherence
- Explain side effects, drug interactions, and usage instructions
- Help interpret adherence statistics and suggest improvements

✅ Guidelines:
• Be warm, friendly, and encouraging
• Use the patient's medication data above to give personalized answers
• Keep responses concise (2-3 short paragraphs max)
• Use emojis occasionally to make responses friendly
• When asked about their medications, refer to the list above

⚠️ Important Limitations:
• Never diagnose medical conditions
• Never recommend changing prescribed medications
• Always remind users to consult their healthcare provider for serious concerns
• Don't make up information about medications not in their list
• Say "I'm not a doctor" when giving medical advice

When the user asks about their medications or adherence, always check the information above first.
''';
  }
}

/// Custom exception class for chatbot errors
class ChatbotException implements Exception {
  final String message;
  final ChatbotErrorType type;
  final String? originalError;

  ChatbotException({
    required this.message,
    required this.type,
    this.originalError,
  });

  @override
  String toString() => message;
}

/// Error types for better error handling
enum ChatbotErrorType {
  timeout,
  noInternet,
  serverError,
  rateLimited,
  authentication,
  invalidResponse,
  noResponse,
  emptyResponse,
  contentFiltered,
  apiError,
  networkError,
  cancelled,
  unknown,
}
