import 'package:flutter/material.dart';

import '../../../../core/constants/privacy_policy.dart';

/// T-88 · La política de privacidad completa, dentro de la app (D4).
///
/// Se llega sin viaje y sin sesión: desde Parámetros y desde el inicio de
/// sesión de «Nube y cuenta». El texto sale de la misma fuente que
/// `web/privacidad.html`; aquí solo se le da forma.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => const PrivacyPolicyPage()));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    return Scaffold(
      // Como el título de la portada (T-97): a letra 2.0 se reduce, no se corta.
      appBar: AppBar(
          title: const FittedBox(
              fit: BoxFit.scaleDown, child: Text('Política de privacidad'))),
      body: SelectionArea(
        child: ListView(
          key: const ValueKey('privacy-policy-list'),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Text(kPrivacyPolicyTitle, style: text.headlineSmall),
            const SizedBox(height: 4),
            Text(kPrivacyPolicyUpdated,
                style: text.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            for (final section in kPrivacyPolicySections) ...[
              const SizedBox(height: 20),
              Text(section.title,
                  style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              for (final paragraph in section.paragraphs) ...[
                const SizedBox(height: 8),
                _rich(context, paragraph),
              ],
              for (final item in section.items)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('•  ', style: text.bodyLarge),
                    Expanded(child: _rich(context, item)),
                  ]),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _rich(BuildContext context, String source) {
    final colors = Theme.of(context).colorScheme;
    return Text.rich(
      TextSpan(children: [
        for (final run in privacyRuns(source))
          TextSpan(
            text: run.text,
            style: run.bold
                ? const TextStyle(fontWeight: FontWeight.bold)
                : run.code
                    ? TextStyle(backgroundColor: colors.surfaceContainerHighest)
                    : null,
          ),
      ]),
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}
