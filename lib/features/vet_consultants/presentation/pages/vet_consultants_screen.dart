import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/page_header.dart';
import 'package:frontend/features/vet_consultants/application/vet_consultants_providers.dart';
import 'package:frontend/features/vet_consultants/data/models/vet_consultant_dto.dart';
import 'package:frontend/features/vet_consultants/presentation/widgets/vet_consultant_card.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class VetConsultantsScreen extends ConsumerStatefulWidget {
  const VetConsultantsScreen({super.key});

  @override
  ConsumerState<VetConsultantsScreen> createState() =>
      _VetConsultantsScreenState();
}

class _VetConsultantsScreenState extends ConsumerState<VetConsultantsScreen> {
  /// Врач, по которому сейчас идёт переход (блокирует повторные тапы).
  int? _pendingId;

  /// Флоу: фиксируем обращение (аналитика админа) и открываем WhatsApp.
  /// Сам диалог идёт вне приложения, поэтому падение аналитики не должно
  /// мешать пользователю написать врачу.
  Future<void> _contact(VetConsultantDto consultant) async {
    setState(() => _pendingId = consultant.id);

    try {
      await ref.read(registerConsultationClickProvider)(consultant.id);
    } catch (_) {
      // Статистика не критична — продолжаем открывать чат.
    }

    if (mounted) await _openWhatsApp(consultant);
    if (mounted) setState(() => _pendingId = null);
  }

  Future<void> _openWhatsApp(VetConsultantDto consultant) async {
    final l10n = context.l10n;
    final phone = consultant.whatsappDigits;

    var opened = false;
    if (phone.isNotEmpty) {
      final appUri = Uri.parse('whatsapp://send?phone=$phone');
      final webUri = Uri.parse('https://wa.me/$phone');

      try {
        opened = await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }

      if (!opened) {
        try {
          opened = await launchUrl(
            webUri,
            mode: LaunchMode.externalApplication,
          );
        } catch (_) {
          opened = false;
        }
      }
    }

    if (!opened && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.supportOpenWhatsappError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final consultantsAsync = ref.watch(vetConsultantsProvider);

    return AppScaffold(
      bottomNavIndex: 4,
      farmName: l10n.farmName,
      body: AppPage(
        child: Column(
          children: [
            const SizedBox(height: 10),
            HerdPageHeader(
              title: l10n.vetConsultantsTitle,
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/more');
                }
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: consultantsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => _ErrorState(
                  message: e is ApiException ? e.message : e.toString(),
                  onRetry: () => ref.invalidate(vetConsultantsProvider),
                ),
                data: (consultants) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(vetConsultantsProvider);
                      await ref.read(vetConsultantsProvider.future);
                    },
                    child: consultants.isEmpty
                        ? const _EmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 4, bottom: 24),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: consultants.length,
                            itemBuilder: (_, i) {
                              final c = consultants[i];
                              return VetConsultantCard(
                                consultant: c,
                                busy: _pendingId == c.id,
                                onWhatsApp: () => _contact(c),
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 50),
        Image.asset('assets/image/noResult.png', width: 220),
        const SizedBox(height: 20),
        Text(
          l10n.vetConsultantsEmptyTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.vetConsultantsEmptySubtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppColors.additional3),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.errorPrefix(message),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.primary3),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            onPressed: onRetry,
            child: Text(
              l10n.retry,
              style: const TextStyle(color: AppColors.primary1),
            ),
          ),
        ],
      ),
    );
  }
}
