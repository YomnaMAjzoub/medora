import 'package:flutter_test/flutter_test.dart';
import 'package:medora_git/features/auth/data/models/login_response_model.dart';

void main() {
  test('login response with int is_verified parses and keeps role/id', () {
    const json = {
      'message': 'Login successful',
      'access_token': '1|0QIghigb2SuVOPsF2RohPXob62WbMPIYvDhN5Qcu3f0468f1',
      'token_type': 'Bearer',
      'user': {
        'id': 1,
        'first_name': 'manal',
        'last_name': 'alali',
        'birth': '1975-06-01',
        'phone': '0932457855',
        'gender': 'female',
        'email': 'yomnamajzoub@gmail.com',
        'role': 'patient',
        'is_verified': 1,
        'email_verified_at': null,
        'fcm_token': null,
        'created_at': '2026-08-01T22:50:44.000000Z',
        'updated_at': '2026-08-01T22:53:37.000000Z',
      },
    };

    final result = LoginResponseModel.fromJson(json);

    expect(result.accessToken, '1|0QIghigb2SuVOPsF2RohPXob62WbMPIYvDhN5Qcu3f0468f1');
    expect(result.user, isNotNull);
    expect(result.user!.id, 1);
    expect(result.user!.role, 'patient');
    expect(result.user!.isVerified, isTrue);
    expect(result.user!.firstName, 'manal');
  });

  test('login response without user still parses', () {
    const json = {
      'message': 'Login successful',
      'access_token': '2|abc',
      'token_type': 'Bearer',
    };

    final result = LoginResponseModel.fromJson(json);

    expect(result.accessToken, '2|abc');
    expect(result.user, isNull);
  });
}
