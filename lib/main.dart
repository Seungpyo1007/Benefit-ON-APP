// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';

// Import after file is generated through flutterfire_cli.
// import 'package:firebase_ai_example/firebase_options.dart';

import 'pages/bidi_page.dart';   // 나중을 위해 남겨둠
import 'Page/LoginPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Enable this line instead once have the firebase_options.dart generated and
  // imported through flutterfire_cli.
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web App',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color.fromARGB(255, 171, 222, 244),
        ),
        useMaterial3: true,
      ),
      // 앱 시작점은 LoginPage 입니다.
      home: const LoginPage(),
    );
  }
}

// ===============================================================
// 아래 코드는 나중에 bidi_page를 사용하기 위해 남겨둔 코드입니다.
// 현재 앱 실행 흐름에서는 사용되지 않습니다.
// ===============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    final vertexInstance = FirebaseAI.vertexAI(auth: FirebaseAuth.instance);
    _model = vertexInstance.generativeModel(model: 'gemini-2.5-flash');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini Live Stream (Vertex AI)'),
      ),
      body: Center(
        child: BidiPage(title: 'Live Stream', model: _model),
      ),
    );
  }
}