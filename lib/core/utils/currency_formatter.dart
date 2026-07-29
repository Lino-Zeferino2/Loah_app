import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../currency/currency_controller.dart';

/// Data class holding currency formatting details.
class CurrencyInfo {
  final String code;
  final String name;
  final String nameEn;
  final String symbol;
  final String locale;
  final int decimalDigits;

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.nameEn,
    required this.symbol,
    required this.locale,
    required this.decimalDigits,
  });
}

/// Formats numbers as any world currency, e.g. `€ 1.234,50`,
/// `$ 1,234.50`, `R$ 1.234,50`, `Kz 1.234,50`.
///
/// Usage:
///   CurrencyFormatter.format(1234.5, currencyCode: 'EUR')
///   CurrencyFormatter.format(1234.5, currencyCode: 'USD')
///   CurrencyFormatter.format(1234.5, currencyCode: 'BRL')
///
/// If no [currencyCode] is provided, it reads the current currency from
/// the widget tree via [CurrencyController].
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats [value] with the given [currencyCode].
  /// If [currencyCode] is null, reads from context.
  static String format(
    double value, {
    String? currencyCode,
    BuildContext? context,
  }) {
    String code;
    if (currencyCode != null) {
      code = currencyCode;
    } else if (context != null) {
      code = CurrencyController.of(context).currencyCode;
    } else {
      code = 'EUR'; // default fallback
    }

    final info = _currencyInfo[code] ?? _currencyInfo['EUR']!;

    final formatter = NumberFormat.currency(
      locale: info.locale,
      symbol: info.symbol,
      decimalDigits: info.decimalDigits,
    );

    return formatter.format(value);
  }

  /// Returns the symbol for the given currency code.
  /// If [currencyCode] is null, reads from context.
  static String symbol({String? currencyCode, BuildContext? context}) {
    String code;
    if (currencyCode != null) {
      code = currencyCode;
    } else if (context != null) {
      code = CurrencyController.of(context).currencyCode;
    } else {
      code = 'EUR';
    }

    return _currencyInfo[code]?.symbol ?? '€';
  }

  /// Returns the full list of supported currencies.
  static List<CurrencyInfo> get supportedCurrencies => _sortedCurrencies;

  /// Returns a human-readable label for the currency.
  /// e.g. "EUR - Euro (€)" or "USD - Dólar Americano ($)"
  static String label(String code) {
    final info = _currencyInfo[code];
    if (info == null) return code;
    return '${info.code} - ${info.name} (${info.symbol})';
  }

  /// Returns the currency name in the appropriate language.
  static String name(String code) {
    final info = _currencyInfo[code];
    if (info == null) return code;
    return info.name;
  }

  /// List of "major" currencies shown first in the picker.
  static const List<String> _priorityCodes = [
    'EUR',
    'USD',
    'AOA',
    'BRL',
    'GBP',
    'JPY',
    'CHF',
    'CAD',
    'AUD',
    'CNY',
  ];

  /// Returns currencies in priority order (major first, then rest).
  static final List<CurrencyInfo> _sortedCurrencies = () {
    final priority = <CurrencyInfo>[];
    final rest = <CurrencyInfo>[];
    for (final info in _currencyInfo.values) {
      if (_priorityCodes.contains(info.code)) {
        priority.add(info);
      } else {
        rest.add(info);
      }
    }
    priority.sort((a, b) =>
        _priorityCodes.indexOf(a.code).compareTo(_priorityCodes.indexOf(b.code)));
    rest.sort((a, b) => a.code.compareTo(b.code));
    return [...priority, ...rest];
  }();

  // ── ALL SUPPORTED CURRENCIES ──────────────────────────────
  static final Map<String, CurrencyInfo> _currencyInfo = {
    // ── Europe ───────────────────────────────────────────────
    'EUR': const CurrencyInfo(
      code: 'EUR',
      name: 'Euro',
      nameEn: 'Euro',
      symbol: '\u20AC',
      locale: 'pt_BR',
      decimalDigits: 2,
    ),
    'GBP': const CurrencyInfo(
      code: 'GBP',
      name: 'Libra Esterlina',
      nameEn: 'Pound Sterling',
      symbol: '\u00A3',
      locale: 'en_GB',
      decimalDigits: 2,
    ),
    'CHF': const CurrencyInfo(
      code: 'CHF',
      name: 'Franco Suíço',
      nameEn: 'Swiss Franc',
      symbol: 'CHF',
      locale: 'de_CH',
      decimalDigits: 2,
    ),
    'SEK': const CurrencyInfo(
      code: 'SEK',
      name: 'Coroa Sueca',
      nameEn: 'Swedish Krona',
      symbol: 'kr',
      locale: 'sv_SE',
      decimalDigits: 2,
    ),
    'NOK': const CurrencyInfo(
      code: 'NOK',
      name: 'Coroa Norueguesa',
      nameEn: 'Norwegian Krone',
      symbol: 'kr',
      locale: 'nb_NO',
      decimalDigits: 2,
    ),
    'DKK': const CurrencyInfo(
      code: 'DKK',
      name: 'Coroa Dinamarquesa',
      nameEn: 'Danish Krone',
      symbol: 'kr',
      locale: 'da_DK',
      decimalDigits: 2,
    ),
    'PLN': const CurrencyInfo(
      code: 'PLN',
      name: 'Zloty Polonês',
      nameEn: 'Polish Zloty',
      symbol: 'z\u0142',
      locale: 'pl_PL',
      decimalDigits: 2,
    ),
    'CZK': const CurrencyInfo(
      code: 'CZK',
      name: 'Coroa Checa',
      nameEn: 'Czech Koruna',
      symbol: 'K\u010D',
      locale: 'cs_CZ',
      decimalDigits: 2,
    ),
    'HUF': const CurrencyInfo(
      code: 'HUF',
      name: 'Forint Húngaro',
      nameEn: 'Hungarian Forint',
      symbol: 'Ft',
      locale: 'hu_HU',
      decimalDigits: 0,
    ),
    'RON': const CurrencyInfo(
      code: 'RON',
      name: 'Leu Romeno',
      nameEn: 'Romanian Leu',
      symbol: 'lei',
      locale: 'ro_RO',
      decimalDigits: 2,
    ),
    'BGN': const CurrencyInfo(
      code: 'BGN',
      name: 'Lev Búlgaro',
      nameEn: 'Bulgarian Lev',
      symbol: '\u043B\u0432',
      locale: 'bg_BG',
      decimalDigits: 2,
    ),
    'HRK': const CurrencyInfo(
      code: 'HRK',
      name: 'Kuna Croata',
      nameEn: 'Croatian Kuna',
      symbol: 'kn',
      locale: 'hr_HR',
      decimalDigits: 2,
    ),
    'RSD': const CurrencyInfo(
      code: 'RSD',
      name: 'Dinar Sérvio',
      nameEn: 'Serbian Dinar',
      symbol: '\u0434\u0438\u043D',
      locale: 'sr_RS',
      decimalDigits: 0,
    ),
    'TRY': const CurrencyInfo(
      code: 'TRY',
      name: 'Lira Turca',
      nameEn: 'Turkish Lira',
      symbol: '\u20BA',
      locale: 'tr_TR',
      decimalDigits: 2,
    ),

    // ── Americas ──────────────────────────────────────────────
    'USD': const CurrencyInfo(
      code: 'USD',
      name: 'Dólar Americano',
      nameEn: 'US Dollar',
      symbol: '\$',
      locale: 'en_US',
      decimalDigits: 2,
    ),
    'CAD': const CurrencyInfo(
      code: 'CAD',
      name: 'Dólar Canadense',
      nameEn: 'Canadian Dollar',
      symbol: 'C\$',
      locale: 'en_CA',
      decimalDigits: 2,
    ),
    'MXN': const CurrencyInfo(
      code: 'MXN',
      name: 'Peso Mexicano',
      nameEn: 'Mexican Peso',
      symbol: 'MX\$',
      locale: 'es_MX',
      decimalDigits: 2,
    ),
    'BRL': const CurrencyInfo(
      code: 'BRL',
      name: 'Real Brasileiro',
      nameEn: 'Brazilian Real',
      symbol: 'R\$',
      locale: 'pt_BR',
      decimalDigits: 2,
    ),
    'ARS': const CurrencyInfo(
      code: 'ARS',
      name: 'Peso Argentino',
      nameEn: 'Argentine Peso',
      symbol: 'AR\$',
      locale: 'es_AR',
      decimalDigits: 2,
    ),
    'CLP': const CurrencyInfo(
      code: 'CLP',
      name: 'Peso Chileno',
      nameEn: 'Chilean Peso',
      symbol: 'CLP\$',
      locale: 'es_CL',
      decimalDigits: 0,
    ),
    'COP': const CurrencyInfo(
      code: 'COP',
      name: 'Peso Colombiano',
      nameEn: 'Colombian Peso',
      symbol: 'COL\$',
      locale: 'es_CO',
      decimalDigits: 0,
    ),
    'PEN': const CurrencyInfo(
      code: 'PEN',
      name: 'Sol Peruano',
      nameEn: 'Peruvian Sol',
      symbol: 'S/',
      locale: 'es_PE',
      decimalDigits: 2,
    ),
    'UYU': const CurrencyInfo(
      code: 'UYU',
      name: 'Peso Uruguaio',
      nameEn: 'Uruguayan Peso',
      symbol: '\$U',
      locale: 'es_UY',
      decimalDigits: 2,
    ),

    // ── Africa ────────────────────────────────────────────────
    'AOA': const CurrencyInfo(
      code: 'AOA',
      name: 'Kwanza Angolano',
      nameEn: 'Angolan Kwanza',
      symbol: 'Kz',
      locale: 'pt_AO',
      decimalDigits: 2,
    ),
    'ZAR': const CurrencyInfo(
      code: 'ZAR',
      name: 'Rand Sul-Africano',
      nameEn: 'South African Rand',
      symbol: 'R',
      locale: 'en_ZA',
      decimalDigits: 2,
    ),
    'NGN': const CurrencyInfo(
      code: 'NGN',
      name: 'Naira Nigeriana',
      nameEn: 'Nigerian Naira',
      symbol: '\u20A6',
      locale: 'en_NG',
      decimalDigits: 2,
    ),
    'KES': const CurrencyInfo(
      code: 'KES',
      name: 'Xelim Queniano',
      nameEn: 'Kenyan Shilling',
      symbol: 'KSh',
      locale: 'en_KE',
      decimalDigits: 2,
    ),
    'EGP': const CurrencyInfo(
      code: 'EGP',
      name: 'Libra Egípcia',
      nameEn: 'Egyptian Pound',
      symbol: 'E\u00A3',
      locale: 'ar_EG',
      decimalDigits: 2,
    ),
    'MAD': const CurrencyInfo(
      code: 'MAD',
      name: 'Dirham Marroquino',
      nameEn: 'Moroccan Dirham',
      symbol: 'MAD',
      locale: 'ar_MA',
      decimalDigits: 2,
    ),
    'CVE': const CurrencyInfo(
      code: 'CVE',
      name: 'Escudo Cabo-verdiano',
      nameEn: 'Cape Verdean Escudo',
      symbol: '\$',
      locale: 'pt_CV',
      decimalDigits: 0,
    ),
    'MZN': const CurrencyInfo(
      code: 'MZN',
      name: 'Metical Moçambicano',
      nameEn: 'Mozambican Metical',
      symbol: 'MT',
      locale: 'pt_MZ',
      decimalDigits: 2,
    ),
    'STN': const CurrencyInfo(
      code: 'STN',
      name: 'Dobra São-tomense',
      nameEn: 'São Tomé Dobra',
      symbol: 'Db',
      locale: 'pt_ST',
      decimalDigits: 2,
    ),
    'XOF': const CurrencyInfo(
      code: 'XOF',
      name: 'Franco CFA (BCEAO)',
      nameEn: 'West African CFA Franc',
      symbol: 'CFA',
      locale: 'fr_SN',
      decimalDigits: 0,
    ),
    'XAF': const CurrencyInfo(
      code: 'XAF',
      name: 'Franco CFA (BEAC)',
      nameEn: 'Central African CFA Franc',
      symbol: 'FCFA',
      locale: 'fr_CM',
      decimalDigits: 0,
    ),
    'GHS': const CurrencyInfo(
      code: 'GHS',
      name: 'Cedi Ganês',
      nameEn: 'Ghanaian Cedi',
      symbol: 'GH\u20B5',
      locale: 'en_GH',
      decimalDigits: 2,
    ),
    'TZS': const CurrencyInfo(
      code: 'TZS',
      name: 'Xelim Tanzaniano',
      nameEn: 'Tanzanian Shilling',
      symbol: 'TSh',
      locale: 'en_TZ',
      decimalDigits: 0,
    ),
    'UGX': const CurrencyInfo(
      code: 'UGX',
      name: 'Xelim Ugandense',
      nameEn: 'Ugandan Shilling',
      symbol: 'USh',
      locale: 'en_UG',
      decimalDigits: 0,
    ),
    'RWF': const CurrencyInfo(
      code: 'RWF',
      name: 'Franco Ruandês',
      nameEn: 'Rwandan Franc',
      symbol: 'RF',
      locale: 'en_RW',
      decimalDigits: 0,
    ),
    'ETB': const CurrencyInfo(
      code: 'ETB',
      name: 'Birr Etíope',
      nameEn: 'Ethiopian Birr',
      symbol: 'Br',
      locale: 'am_ET',
      decimalDigits: 2,
    ),

    // ── Asia ──────────────────────────────────────────────────
    'JPY': const CurrencyInfo(
      code: 'JPY',
      name: 'Iene Japonês',
      nameEn: 'Japanese Yen',
      symbol: '\u00A5',
      locale: 'ja_JP',
      decimalDigits: 0,
    ),
    'CNY': const CurrencyInfo(
      code: 'CNY',
      name: 'Yuan Chinês',
      nameEn: 'Chinese Yuan',
      symbol: '\u00A5',
      locale: 'zh_CN',
      decimalDigits: 2,
    ),
    'KRW': const CurrencyInfo(
      code: 'KRW',
      name: 'Won Sul-Coreano',
      nameEn: 'South Korean Won',
      symbol: '\u20A9',
      locale: 'ko_KR',
      decimalDigits: 0,
    ),
    'INR': const CurrencyInfo(
      code: 'INR',
      name: 'Rupia Indiana',
      nameEn: 'Indian Rupee',
      symbol: '\u20B9',
      locale: 'en_IN',
      decimalDigits: 2,
    ),
    'SGD': const CurrencyInfo(
      code: 'SGD',
      name: 'Dólar de Singapura',
      nameEn: 'Singapore Dollar',
      symbol: 'S\$',
      locale: 'en_SG',
      decimalDigits: 2,
    ),
    'HKD': const CurrencyInfo(
      code: 'HKD',
      name: 'Dólar de Hong Kong',
      nameEn: 'Hong Kong Dollar',
      symbol: 'HK\$',
      locale: 'en_HK',
      decimalDigits: 2,
    ),
    'TWD': const CurrencyInfo(
      code: 'TWD',
      name: 'Dólar Taiwanês',
      nameEn: 'New Taiwan Dollar',
      symbol: 'NT\$',
      locale: 'zh_TW',
      decimalDigits: 0,
    ),
    'THB': const CurrencyInfo(
      code: 'THB',
      name: 'Baht Tailandês',
      nameEn: 'Thai Baht',
      symbol: '\u0E3F',
      locale: 'th_TH',
      decimalDigits: 2,
    ),
    'MYR': const CurrencyInfo(
      code: 'MYR',
      name: 'Ringgit Malaio',
      nameEn: 'Malaysian Ringgit',
      symbol: 'RM',
      locale: 'ms_MY',
      decimalDigits: 2,
    ),
    'IDR': const CurrencyInfo(
      code: 'IDR',
      name: 'Rupia Indonésia',
      nameEn: 'Indonesian Rupiah',
      symbol: 'Rp',
      locale: 'id_ID',
      decimalDigits: 0,
    ),
    'PHP': const CurrencyInfo(
      code: 'PHP',
      name: 'Peso Filipino',
      nameEn: 'Philippine Peso',
      symbol: '\u20B1',
      locale: 'en_PH',
      decimalDigits: 2,
    ),
    'VND': const CurrencyInfo(
      code: 'VND',
      name: 'Dong Vietnamita',
      nameEn: 'Vietnamese Dong',
      symbol: '\u20AB',
      locale: 'vi_VN',
      decimalDigits: 0,
    ),
    'PKR': const CurrencyInfo(
      code: 'PKR',
      name: 'Rupia Paquistanesa',
      nameEn: 'Pakistani Rupee',
      symbol: '\u20A8',
      locale: 'en_PK',
      decimalDigits: 0,
    ),
    'BDT': const CurrencyInfo(
      code: 'BDT',
      name: 'Taka Bangladesh',
      nameEn: 'Bangladeshi Taka',
      symbol: '\u09F3',
      locale: 'bn_BD',
      decimalDigits: 2,
    ),
    'ILS': const CurrencyInfo(
      code: 'ILS',
      name: 'Shekel Israelense',
      nameEn: 'Israeli New Shekel',
      symbol: '\u20AA',
      locale: 'he_IL',
      decimalDigits: 2,
    ),
    'SAR': const CurrencyInfo(
      code: 'SAR',
      name: 'Riyal Saudita',
      nameEn: 'Saudi Riyal',
      symbol: 'SAR',
      locale: 'ar_SA',
      decimalDigits: 2,
    ),
    'AED': const CurrencyInfo(
      code: 'AED',
      name: 'Dirham dos EAU',
      nameEn: 'UAE Dirham',
      symbol: 'AED',
      locale: 'ar_AE',
      decimalDigits: 2,
    ),
    'QAR': const CurrencyInfo(
      code: 'QAR',
      name: 'Riyal Catarense',
      nameEn: 'Qatari Riyal',
      symbol: 'QAR',
      locale: 'ar_QA',
      decimalDigits: 2,
    ),
    'KWD': const CurrencyInfo(
      code: 'KWD',
      name: 'Dinar Kuwaitiano',
      nameEn: 'Kuwaiti Dinar',
      symbol: 'KWD',
      locale: 'ar_KW',
      decimalDigits: 3,
    ),

    // ── Oceania ───────────────────────────────────────────────
    'AUD': const CurrencyInfo(
      code: 'AUD',
      name: 'Dólar Australiano',
      nameEn: 'Australian Dollar',
      symbol: 'A\$',
      locale: 'en_AU',
      decimalDigits: 2,
    ),
    'NZD': const CurrencyInfo(
      code: 'NZD',
      name: 'Dólar Neozelandês',
      nameEn: 'New Zealand Dollar',
      symbol: 'NZ\$',
      locale: 'en_NZ',
      decimalDigits: 2,
    ),
    'FJD': const CurrencyInfo(
      code: 'FJD',
      name: 'Dólar de Fiji',
      nameEn: 'Fijian Dollar',
      symbol: 'FJ\$',
      locale: 'en_FJ',
      decimalDigits: 2,
    ),
  };
}

