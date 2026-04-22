import 'dart:io';

import 'package:bcg/common/widgets/alert/snackbar_helper.dart';
import 'package:bcg/features/quotes/presentation/widget/pdf_options_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfController extends GetxController {
  final RxBool isDownloading = false.obs;
  final RxDouble downloadProgress = 0.0.obs;
  final RxBool isLoadingPdf = false.obs;
  final pdfUrl = Rxn<String>();
  final lastDownloadedPath = Rxn<String>();

  String folio = '';

  void setPdfUrl(String url) => pdfUrl.value = url;

  /// Extrae el nombre del archivo desde la URL.
  String _fileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segment = uri.pathSegments.last;
      if (segment.endsWith('.pdf') && segment.isNotEmpty) return segment;
    } catch (_) {}
    return ' ${folio}_${DateTime.now().millisecondsSinceEpoch}.pdf';
  }

  void showOptionsSheet(BuildContext context) {
    if (pdfUrl.value == null || pdfUrl.value!.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => PdfOptionsSheet(
        onSendWhatsApp: sendWhatsApp,
        onDownloadPdf: downloadPdf,
        onOpenPdf: openDownloadedPdf,
        isDownloading: isDownloading,
        downloadProgress: downloadProgress,
        lastDownloadedPath: lastDownloadedPath,
      ),
    );
  }

  Future<void> sendWhatsApp() async {
    final url = pdfUrl.value;
    if (url == null || url.isEmpty) return;

    try {
      isLoadingPdf.value = true;

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final fileName = _fileNameFromUrl(url); // ← usa nombre de la URL
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Cotización $folio',
          text: 'Te comparto la cotización $folio',
        );
      } else {
        showErrorSnackbar('No se pudo descargar el PDF');
      }
    } catch (_) {
      showErrorSnackbar('Error al compartir PDF');
    } finally {
      isLoadingPdf.value = false;
    }
  }

  Future<void> downloadPdf() async {
    final url = pdfUrl.value;
    if (url == null || url.isEmpty) return;

    try {
      isDownloading.value = true;
      downloadProgress.value = 0;

      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        showErrorSnackbar('No se pudo descargar el PDF');
        return;
      }

      final fileName = _fileNameFromUrl(url); // ← usa nombre de la URL

      final String savePath;
      if (Platform.isAndroid) {
        savePath = '/storage/emulated/0/Download/$fileName';
      } else {
        final dir = await getApplicationDocumentsDirectory();
        savePath = '${dir.path}/$fileName';
      }

      final file = File(savePath);
      await file.writeAsBytes(response.bodyBytes);

      lastDownloadedPath.value = savePath;
      showSuccessSnackbar('PDF guardado en Descargas');
    } catch (e) {
      showErrorSnackbar('Error al descargar PDF: $e');
    } finally {
      isDownloading.value = false;
    }
  }

  Future<void> openDownloadedPdf() async {
    final path = lastDownloadedPath.value;
    if (path == null || path.isEmpty) return;
    await OpenFilex.open(path);
  }

  void reset() {
    pdfUrl.value = null;
    lastDownloadedPath.value = null;
    isDownloading.value = false;
    downloadProgress.value = 0.0;
    isLoadingPdf.value = false;
    folio = '';
  }
}