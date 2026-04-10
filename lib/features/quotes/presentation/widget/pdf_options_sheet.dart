import 'package:bcg/common/theme/App_Theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PdfOptionsSheet extends StatelessWidget {
  final VoidCallback onSendWhatsApp;
  final VoidCallback onDownloadPdf;
  final RxBool isDownloading;
  final RxDouble downloadProgress;
final VoidCallback onOpenPdf;  
  final Rxn<String> lastDownloadedPath; 
  const PdfOptionsSheet({
     super.key,
    required this.onSendWhatsApp,
    required this.onDownloadPdf,
    required this.onOpenPdf,
    required this.isDownloading,
    required this.downloadProgress,
    required this.lastDownloadedPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ThemeColor.surfaceColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ThemeColor.largeRadius),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + ThemeColor.paddingMedium,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: ThemeColor.paddingSmall),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ThemeColor.dividerColor,
              borderRadius: ThemeColor.circularBorderRadius,
            ),
          ),
          const SizedBox(height: ThemeColor.paddingMedium),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: ThemeColor.successColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: ThemeColor.successColor,
              size: 36,
            ),
          ),
          const SizedBox(height: ThemeColor.paddingSmall),
          Text('¡Listo!', style: ThemeColor.headingSmall),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: ThemeColor.paddingLarge),
            child: Text(
              'Tu cotización ha sido creada con éxito.\nPuedes consultarla en cualquier momento desde el módulo de cotizaciones.',
              style: ThemeColor.bodySmall.copyWith(color: ThemeColor.textSecondaryColor),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: ThemeColor.paddingLarge),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: ThemeColor.paddingMedium),
            child: ThemeColor.widgetButton(
              text: 'Enviar por WhatsApp',
              backgroundColor: const Color(0xFF25D366),
              textColor: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              padding: const EdgeInsets.symmetric(vertical: 14),
              borderRadius: ThemeColor.mediumRadius,
              onPressed: onSendWhatsApp,
              showShadow: false,
            ),
          ),
          const SizedBox(height: ThemeColor.paddingSmall),
         Padding(
            padding: const EdgeInsets.symmetric(horizontal: ThemeColor.paddingMedium),
            child: Obx(() {
              if (isDownloading.value) {
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: ThemeColor.circularBorderRadius,
                      child: LinearProgressIndicator(
                        value: downloadProgress.value,
                        minHeight: 6,
                        backgroundColor: ThemeColor.dividerColor,
                        color: ThemeColor.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Descargando ${(downloadProgress.value * 100).toStringAsFixed(0)}%',
                      style: ThemeColor.caption.copyWith(color: ThemeColor.textSecondaryColor),
                    ),
                  ],
                );
              }

              // Ya descargado: muestra botón "Abrir PDF"
              if (lastDownloadedPath.value != null) {
                return Column(
                  children: [
                    ThemeColor.widgetButton(
                      text: 'Abrir PDF descargado',
                      backgroundColor: ThemeColor.primaryColor,
                      textColor: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      borderRadius: ThemeColor.mediumRadius,
                      showShadow: false,
                      onPressed: onOpenPdf,
                    ),
                    const SizedBox(height: ThemeColor.paddingSmall),
                    // Botón secundario para volver a descargar
                    GestureDetector(
                      onTap: onDownloadPdf,
                      child: Text(
                        'Descargar de nuevo',
                        style: ThemeColor.bodySmall.copyWith(
                          color: ThemeColor.textSecondaryColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                );
              }

              // Sin descarga aún
              return ThemeColor.widgetButton(
                text: 'Descargar PDF',
                backgroundColor: ThemeColor.backgroundColor,
                textColor: ThemeColor.textPrimaryColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                padding: const EdgeInsets.symmetric(vertical: 14),
                borderRadius: ThemeColor.mediumRadius,
                borderColor: ThemeColor.dividerColor,
                borderWidth: 1.5,
                showShadow: false,
                onPressed: onDownloadPdf,
              );
            }),
          ),
        ],
      ),
    );
  }
}