import 'package:flutter/material.dart';
import 'package:milliy_metr/l10n/app_localizations.dart';

extension L10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension UnitL10nExtension on String {
  String localizedUnit(BuildContext context) {
    final l10n = context.l10n;
    switch (toLowerCase()) {
      case 'dona':
      case 'piece':
      case 'pcs':
        return l10n.unitDona;
      case 'kg': return l10n.unitKg;
      case 'metr': return l10n.unitMetr;
      case 'kv.m': return l10n.unitKvm;
      case 'litr': return l10n.unitLitr;
      case 'komplekt': return l10n.unitKomplekt;
      case 'm3': return l10n.unitM3;
      case 'tonna': return l10n.unitTonna;
      case 'rulon': return l10n.unitRulon;
      case 'qop': return l10n.unitQop;
      default: return this;
    }
  }
}
