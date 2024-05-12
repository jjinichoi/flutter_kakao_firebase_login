import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_kakao_login/firebase_auth_remote_data_source.dart';
import 'package:flutter_kakao_login/social_login.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

class MainViewModel {
  final _firebaseAuthDataSource = FirebaseAuthRemoteDataSource();
  final SocialLogin _socialLogin;
  bool isLogined = false;
  kakao.User? user;

  MainViewModel(this._socialLogin);

  Future login() async {
    isLogined = await _socialLogin.login();
    if (isLogined) {
      user = await kakao.UserApi.instance.me();

      final token = await _firebaseAuthDataSource.createCustomToken({
        'uid': user!.id.toString(), //카카오에서는 숫자로 주는데 파베는 문자를 취급하기때문에 String으로 변형
        'displayName': user!.kakaoAccount!.profile!.nickname,
        'email': user?.kakaoAccount?.email,
        'photoUrl': user!.kakaoAccount!.profile!.profileImageUrl!,
      });

      await FirebaseAuth.instance.signInWithCustomToken(token);
    }
  }

  Future logout() async {
    await _socialLogin.logout();
    await FirebaseAuth.instance.signOut();
    isLogined = false;
    user = null;
  }
}
