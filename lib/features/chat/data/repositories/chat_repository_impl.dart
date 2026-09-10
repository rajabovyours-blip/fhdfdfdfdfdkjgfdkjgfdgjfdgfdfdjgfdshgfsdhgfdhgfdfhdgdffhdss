import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:milliy_metr/features/chat/domain/entities/chat_entity.dart';
import 'package:milliy_metr/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ChatSessionEntity>> startSession(String name, String phone) async {
    try {
      final result = await remoteDataSource.startSession(name, phone);
      return Right(ChatSessionEntity.fromJson(result));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> getMessages(String sessionId) async {
    try {
      final result = await remoteDataSource.getMessages(sessionId);
      return Right(result.map((e) => ChatMessageEntity.fromJson(e)).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatMessageEntity>> sendMessage(String sessionId, String text) async {
    try {
      final result = await remoteDataSource.sendMessage(sessionId, text);
      return Right(ChatMessageEntity.fromJson(result));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
