import 'package:intl/intl.dart';

final _indianFormat = NumberFormat('#,##,###', 'en_IN');

String fmtNumber(num n) => _indianFormat.format(n);

String fmtRupee(num n) => '₹${_indianFormat.format(n)}';
