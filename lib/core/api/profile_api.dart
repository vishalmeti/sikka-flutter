import 'api_client.dart';
import 'auth_api.dart';

class PhoneOtpSent {
  PhoneOtpSent({
    required this.ttlSec,
    required this.resendInSec,
    required this.devMode,
  });

  final int ttlSec;
  final int resendInSec;
  final bool devMode;

  factory PhoneOtpSent.fromJson(Map<String, dynamic> j) => PhoneOtpSent(
        ttlSec: (j['ttlSec'] as num).toInt(),
        resendInSec: (j['resendInSec'] as num).toInt(),
        devMode: j['devMode'] == true,
      );
}

class ProfileApi {
  ProfileApi(this._client);
  final ApiClient _client;

  Future<UserProfile> getMe() async {
    final data = await _client.get('/profile') as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }

  Future<PhoneOtpSent> sendPhoneOtp(String phone) async {
    final data = await _client.post('/profile/phone/send-otp', {
      'phone': phone,
    }) as Map<String, dynamic>;
    return PhoneOtpSent.fromJson(data);
  }

  Future<UserProfile> verifyPhoneOtp({
    required String phone,
    required String code,
  }) async {
    final data = await _client.post('/profile/phone/verify', {
      'phone': phone,
      'code': code,
    }) as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }
}
