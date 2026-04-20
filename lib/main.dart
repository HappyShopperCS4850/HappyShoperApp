import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nremtqmtivxsceekxjbn.supabase.co',
    anonKey: 'sb_publishable_0gT0Whos_ndZNQw6lLGiEA__XFMIy25',
  );

  runApp(const HappyShopperApp());
}