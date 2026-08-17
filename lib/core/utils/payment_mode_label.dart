import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../domain/models/hotel.dart';

/// Localized display label for a hotel's [HotelPaymentMode]. Shared by the web
/// admin panel and the mobile app so the three modes read the same everywhere.
String hotelPaymentModeLabel(AppLocalizations l, HotelPaymentMode mode) {
  switch (mode) {
    case HotelPaymentMode.payAtProperty:
      return l.paymentModePayAtProperty;
    case HotelPaymentMode.payAtApp:
      return l.paymentModePayAtApp;
    case HotelPaymentMode.payPartial:
      return l.paymentModePayPartial;
  }
}

/// Localized label for the payment mode stored on a reservation (its raw DB
/// string). Falls back to a dash when the mode is unknown/absent.
String reservationPaymentModeLabel(AppLocalizations l, String? dbValue) {
  if (dbValue == null) return '—';
  return hotelPaymentModeLabel(l, HotelPaymentMode.fromDbValue(dbValue));
}
