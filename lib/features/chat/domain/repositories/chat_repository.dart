import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/chat/domain/entities/chat_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, ChatSessionEntity>> startSession(String name, String phone);
  Future<Either<Failure, List<ChatMessageEntity>>> getMessages(String sessionId);
  Future<Either<Failure, ChatMessageEntity>> sendMessage(String sessionId, String text);
}
