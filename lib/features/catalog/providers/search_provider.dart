import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The live search query string typed by the user.
final searchQueryProvider = StateProvider<String>((ref) => '');
