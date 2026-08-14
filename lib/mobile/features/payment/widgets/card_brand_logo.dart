import 'package:flutter/material.dart';
import '../../../../core/utils/card_brand.dart';

/// Card-network / PayPal logos rendered from the bundled brand images
/// (`images/visa.png`, `images/mastercard.png`, `images/paypal.png`).
///
/// Each logo shows in its natural colours by default. Pass a [color] to tint it
/// (e.g. white on the dark burgundy card) — the image's alpha is used as a mask.
class CardBrandLogo extends StatelessWidget {
  final CardBrand brand;
  final double height;

  /// When false, the logo is dimmed — used in the "accepted brands" row to
  /// highlight only the detected brand.
  final bool active;

  const CardBrandLogo({
    super.key,
    required this.brand,
    this.height = 22,
    this.active = true,
  });

  @override
  Widget build(BuildContext context) {
    final Widget logo;
    switch (brand) {
      case CardBrand.visa:
        logo = VisaLogo(height: height);
        break;
      case CardBrand.mastercard:
        logo = MastercardLogo(height: height);
        break;
      case CardBrand.unknown:
        logo = Icon(
          Icons.credit_card,
          size: height,
          color: const Color(0xFF6B6B6B),
        );
        break;
    }
    return Opacity(opacity: active ? 1 : 0.3, child: logo);
  }
}

/// Renders a brand PNG at a fixed [height], optionally tinted to [color].
Widget _brandImage(String asset, double height, Color? color) {
  return Image.asset(
    asset,
    height: height,
    fit: BoxFit.contain,
    color: color,
    colorBlendMode: color != null ? BlendMode.srcIn : null,
  );
}

/// Visa logo. Uses the blue Visa mark everywhere by default; set [plain] to use
/// the plain mark (used on the dark burgundy card, tinted white). Pass [color]
/// to tint for dark backgrounds.
class VisaLogo extends StatelessWidget {
  final double height;
  final Color? color;
  final bool plain;
  const VisaLogo({super.key, this.height = 22, this.color, this.plain = false});

  @override
  Widget build(BuildContext context) => _brandImage(
    plain ? 'images/visa.png' : 'images/visa_blue.png',
    height,
    color,
  );
}

/// Mastercard logo. Natural colours by default; pass white for dark backgrounds.
class MastercardLogo extends StatelessWidget {
  final double height;
  final Color? color;
  const MastercardLogo({super.key, this.height = 22, this.color});

  @override
  Widget build(BuildContext context) =>
      _brandImage('images/mastercard.png', height, color);
}

/// PayPal logo. Natural colours by default; pass white for dark backgrounds.
class PaypalLogo extends StatelessWidget {
  final double height;
  final Color? color;
  const PaypalLogo({super.key, this.height = 20, this.color});

  @override
  Widget build(BuildContext context) =>
      _brandImage('images/paypal.png', height, color);
}

/// Row of the payment brands Romio accepts (Mastercard · Visa · PayPal), shown
/// on the card-number field and on option rows.
class AcceptedBrandsRow extends StatelessWidget {
  /// When set, only this brand is highlighted (others dimmed) — used live while
  /// the guest types a card number. When null, all are shown at full opacity.
  final CardBrand? highlight;
  final double height;

  const AcceptedBrandsRow({super.key, this.highlight, this.height = 20});

  @override
  Widget build(BuildContext context) {
    bool on(CardBrand b) => highlight == null || highlight == b;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CardBrandLogo(
          brand: CardBrand.mastercard,
          height: height,
          active: on(CardBrand.mastercard),
        ),
        const SizedBox(width: 8),
        CardBrandLogo(
          brand: CardBrand.visa,
          height: height,
          active: on(CardBrand.visa),
        ),
        const SizedBox(width: 8),
        Opacity(
          opacity: highlight == null ? 1 : 0.3,
          child: PaypalLogo(height: height),
        ),
      ],
    );
  }
}
