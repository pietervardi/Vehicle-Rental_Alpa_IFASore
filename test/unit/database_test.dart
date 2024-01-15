import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vehicle_rental/database/database_helper.dart';
import 'package:vehicle_rental/models/user_model.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Database Test', () {
    late DatabaseHelper dbHelper;

    setUp(() {
      dbHelper = DatabaseHelper();
    });

    test('Get Login User should return UserModel for existing user', () async {
      UserModel testUser = UserModel(
        id: 999,
        name: 'Test Database User',
        username: 'testdatabaseuser',
        email: 'testdatabaseuser@example.com',
        password: 'testdatabasepassword',
        about: '-',
      );

      await dbHelper.signup(testUser);

      UserModel? result = await dbHelper.getLoginUser(testUser.email.toString());

      expect(result, isA<UserModel>());
    });

    test('Get Login User should return null for non-existing user', () async {
      UserModel? result = await dbHelper.getLoginUser('nonexistent@example.com');

      expect(result, null);
    });

    test('Update User should return the number of updated rows', () async {
      UserModel testUserUpdate = UserModel(
        id: 999,
        name: 'Test Database User Updated',
        username: 'testdatabaseuser',
        email: 'testdatabaseuser@example.com',
        password: 'testdatabasepassword',
        about: 'Description Updated',
      );

      int result = await dbHelper.updateUser(testUserUpdate);

      expect(result, equals(greaterThan(0)));
    });

    test('Update Non Existing User should return -1', () async {
      UserModel testUserUpdate = UserModel(
        id: 998,
        name: 'Test Database User Updated',
        username: 'testdatabaseuser',
        email: 'testdatabaseuser@example.com',
        password: 'testdatabasepassword',
        about: 'Description Updated',
      );

      int result = await dbHelper.updateUser(testUserUpdate);

      expect(result, equals(-1));
    });

    test('Update Password with no existing user should return -1', () async {
      UserModel testUser = UserModel(
        id: 997,
        name: 'Test Database User Updated',
        username: 'testdatabaseusers',
        email: 'testdatabaseusers@example.com',
        password: BCrypt.hashpw('testdatabasepassword', BCrypt.gensalt()),
        about: 'Description Updated',
      );

      int result = await dbHelper.updatePassword(
        testUser,
        'testdatabasepassword',
        'newdatabasepassword',
      );

      expect(result, equals(-1));
    });

    test('Update Password with incorrect current password should return -2', () async {
      UserModel testUser = UserModel(
        id: 999,
        name: 'Test Database User Updated',
        username: 'testdatabaseuser',
        email: 'testdatabaseuser@example.com',
        password: BCrypt.hashpw('testdatabasepassword', BCrypt.gensalt()),
        about: 'Description Updated',
      );

      int result = await dbHelper.updatePassword(
        testUser,
        'incorrectpassword',
        'newdatabasepassword',
      );

      expect(result, equals(-2));
    });

    test('Update Password should return the number of updated rows', () async {
      UserModel testUser = UserModel(
        id: 999,
        name: 'Test Database User Updated',
        username: 'testdatabaseuser',
        email: 'testdatabaseuser@example.com',
        password: BCrypt.hashpw('testdatabasepassword', BCrypt.gensalt()),
        about: 'Description Updated',
      );

      int result = await dbHelper.updatePassword(
        testUser,
        'testdatabasepassword',
        'newdatabasepassword',
      );

      expect(result, equals(greaterThan(0)));
    });

    test('Delete User should return the number of updated rows', () async {
      UserModel testUser = UserModel(
        id: 999,
        name: 'Test Database User Updated',
        username: 'testdatabaseuser',
        email: 'testdatabaseuser@example.com',
        password: BCrypt.hashpw('testdatabasepassword', BCrypt.gensalt()),
        about: 'Description Updated',
      );

      int result = await dbHelper.deleteUser(testUser.email.toString());

      expect(result, equals(greaterThan(0)));
    });
  });
}
