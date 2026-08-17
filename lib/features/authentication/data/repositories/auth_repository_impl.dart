import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:milliy_metr/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:milliy_metr/features/authentication/domain/entities/token_entity.dart';
import 'package:milliy_metr/features/authentication/domain/entities/user_entity.dart';
import 'package:milliy_metr/features/authentication/data/models/token_model.dart'
    as milliy_metr_token_model;
import 'package:milliy_metr/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, TokenEntity>> login(
    String phone,
    String password,
  ) async {
    try {
      final tokenModel = await remoteDataSource.login(phone, password);
      await localDataSource.saveToken(tokenModel);
      return Right(tokenModel.toEntity());
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> register(
    String fullName,
    String phone,
    String password,
  ) async {
    try {
      await remoteDataSource.register(fullName, phone, password);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> requestOtp(String phone) async {
    try {
      await remoteDataSource.requestOtp(phone);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkPhone(String phone) async {
    try {
      final exists = await remoteDataSource.checkPhone(phone);
      return Right(exists);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TokenEntity>> verifyOtp(
    String phone,
    String otp, {
    String? fullName,
    String? surname,
  }) async {
    try {
      final tokenModel = await remoteDataSource.verifyOtp(
        phone,
        otp,
        fullName: fullName,
        surname: surname,
      );
      await localDataSource.saveToken(tokenModel);
      return Right(tokenModel.toEntity());
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TokenEntity>> socialLogin(
    String provider,
    String token,
  ) async {
    try {
      final tokenModel = await remoteDataSource.socialLogin(provider, token);
      await localDataSource.saveToken(tokenModel);
      return Right(tokenModel.toEntity());
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return Right(userModel.toEntity());
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearSession();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear session'));
    }
  }

  @override
  Future<void> saveDemoSession(UserEntity user) async {
    final token = milliy_metr_token_model.TokenModel(
      accessToken: 'demo_token_${user.id}',
      refreshToken: null,
    );
    await localDataSource.saveToken(token);
  }
}
