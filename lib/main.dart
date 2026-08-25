import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app.dart';
import 'core/db/app_database.dart';
import 'core/db/db_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Locale Indonesia untuk format uang & tanggal.
  Intl.defaultLocale = 'id_ID';
  await initializeDateFormatting('id_ID');

  // Buka database sekali di awal; sediakan ke seluruh app via provider.
  final database = AppDatabase();
  await database.open();

  runApp(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
      child: const PosWaroengApp(),
    ),
  );
}
