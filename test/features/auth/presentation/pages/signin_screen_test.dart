import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:project_eatup/features/auth/data/repositories/auth_repository.dart';

import 'package:project_eatup/features/auth/presentation/pages/signin_screen.dart';
import 'package:project_eatup/features/auth/presentation/state/auth_state.dart';
import 'package:project_eatup/features/auth/presentation/view_model/auth_view_model.dart';

import 'package:project_eatup/features/auth/domain/repositories/auth_repo.dart';
import 'package:project_eatup/features/auth/domain/entities/auth_entity.dart';
import 'package:project_eatup/core/error/failures.dart';

/// ------------------------------------------------------------
/// FAKE AUTH REPOSITORY
/// ------------------------------------------------------------
class FakeAuthRepository implements IAuthRepository {
  @override
  Future<Either<Failure, AuthEntity>> login(
    String email,
    String password,
  ) async {
    return Right(
      AuthEntity(
        token: 'fake_token',
        userId: '1',
        name: '',
        email: '',
        authId: '',
      ),
    );
  }

  @override
  Future<Either<Failure, bool>> signUp(AuthEntity user) async {
    return const Right(true);
  }
}


void main() {
  Widget createWidget() {
    return ProviderScope(
      overrides: [
        // ✅ override dependency only
        authRepositoryProvider.overrideWithValue(
          FakeAuthRepository(),
        ),
      ],
      child: const MaterialApp(
        home: SignInScreen(),
      ),
    );
  }

  
  testWidgets('shows login screen', (tester) async {
    await tester.pumpWidget(createWidget());

    expect(find.text('Log In'), findsOneWidget);
    expect(find.text('LOG IN'), findsOneWidget);
  });

  /// 2️⃣ Input fields exist
  testWidgets('shows email and password fields', (tester) async {
    await tester.pumpWidget(createWidget());

    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  /// 3️⃣ Empty submit shows validation
  testWidgets('shows validation errors on empty submit', (tester) async {
    await tester.pumpWidget(createWidget());

    await tester.tap(find.text('LOG IN'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  /// 4️⃣ Toggle password visibility
  testWidgets('toggles password visibility icon', (tester) async {
    await tester.pumpWidget(createWidget());

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  /// 5️⃣ Login button enabled initially
  testWidgets('login button is enabled initially', (tester) async {
    await tester.pumpWidget(createWidget());

    final button = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );

    expect(button.onPressed, isNotNull);
  });
}
