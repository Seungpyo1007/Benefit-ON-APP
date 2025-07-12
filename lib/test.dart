import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ai/firebase_ai.dart'; // firebase_ai 패키지를 임포트합니다.

// ... 다른 코드 ...

void initializeLiveModel() async {
  // Firebase가 초기화되었는지 확인합니다.
  await Firebase.initializeApp();

  // LiveModel 인스턴스를 초기화합니다.
  // gemini-2.0-flash-live-preview-04-09 모델을 지정합니다.
  final liveModel = LiveModel(model: 'gemini-2.0-flash-live-preview-04-09');

  // 이제 liveModel 인스턴스를 사용하여 Gemini Live API와 상호작용할 수 있습니다.
  // 이 인스턴스를 필요에 따라 다른 위젯이나 서비스에 전달하여 사용하세요.
}

// 앱 시작 부분에서 initializeLiveModel 함수를 호출합니다.
// 예시: main 함수
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeLiveModel(); // LiveModel 초기화
  runApp(MyApp());
}

// ... 다른 코드 ...
