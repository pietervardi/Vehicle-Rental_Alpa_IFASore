import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vehicle_rental/database/database_helper.dart';
import 'package:vehicle_rental/models/user_model.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  group('Authentication Test', () {
    late DatabaseHelper dbHelper;

    setUp(() {
      dbHelper = DatabaseHelper();
    });

    test('Login with valid credentials should return true', () async {
      UserModel testUserRegister = UserModel(
        name: 'Test User',
        username: 'testuser',
        email: 'testuser@example.com',
        password: 'testpassword',
        about: '-',
      );

      await dbHelper.signup(testUserRegister);

      UserModel testUserLogin = UserModel(
        email: 'testuser@example.com',
        password: 'testpassword',
      );

      bool result = await dbHelper.login(testUserLogin);
      expect(result, true);
    });

    test('Login with invalid credentials should return false', () async {
      UserModel testUserLogin = UserModel(
        email: 'nonexistent@example.com',
        password: 'invalidpassword',
      );

      bool result = await dbHelper.login(testUserLogin);
      expect(result, false);
    });

    test('Register with a new user should return an integer (user id)', () async {
      UserModel testUserRegister = UserModel(
        name: 'New User',
        username: 'newuser',
        email: 'newuser@example.com',
        password: 'newpassword',
        about: '-',
      );

      await dbHelper.deleteUser(testUserRegister.email.toString());

      int result = await dbHelper.signup(testUserRegister);
      expect(result, equals(greaterThan(0)));
    });

    test('Register with an existing username should return -1', () async {
      UserModel existingUser = UserModel(
        username: 'existinguser',
        email: 'existinguser@example.com',
        password: 'existingpassword',
      );

      await dbHelper.signup(existingUser);

      int result = await dbHelper.signup(existingUser);
      expect(result, equals(-1));
    });
  });
}