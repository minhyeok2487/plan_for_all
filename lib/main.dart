import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plan_for_all/services/task_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'package:logging/logging.dart';

Future<void> main() async {
  // runApp을 수행하기전에 비동기 작업을 할 경우 추가해주는 코드
  WidgetsFlutterBinding.ensureInitialized();

  // dotenv를 가져오는 부분
  await dotenv.load();

  // dotenv 패키지를 사용해서 supabase 설정값 호출
  await Supabase.initialize(
    url: dotenv.get("SUPABASE_URL"),
    anonKey: dotenv.get("SUPABASE_API_KEY"),
  );

  Logger.root.level = Level.WARNING;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskService(Supabase.instance.client),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
