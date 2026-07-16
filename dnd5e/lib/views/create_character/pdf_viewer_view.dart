import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../utils/app_theme.dart';

class PdfViewerView extends StatefulWidget {
  final String filePath;
  final String title;
  final bool showHomeButton;

  const PdfViewerView({
    super.key,
    required this.filePath,
    required this.title,
    this.showHomeButton = false,
  });

  @override
  State<PdfViewerView> createState() => _PdfViewerViewState();
}

class _PdfViewerViewState extends State<PdfViewerView> {
  final GlobalKey<SfPdfViewerState> _pdfKey = GlobalKey();
  final PdfViewerController _controller = PdfViewerController();

  int _currentPage = 1;
  int _totalPages = 0;
  String? _error;

  @override
  void initState() {
    super.initState();

    final file = File(widget.filePath);
    if (!file.existsSync()) {
      _error = 'No se encontró el PDF generado en: ${widget.filePath}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.error),
            ),
          ),
        ),
      );
    }

    final file = File(widget.filePath);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            if (_totalPages > 0)
              Text(
                'Page $_currentPage of $_totalPages',
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
          ],
        ),
        actions: [
          if (widget.showHomeButton)
            IconButton(
              icon: const Icon(Icons.home),
              tooltip: 'Back to Home',
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share PDF',
            onPressed: () => Share.shareXFiles([
              XFile(widget.filePath),
            ], subject: widget.title),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            tooltip: 'Zoom in',
            onPressed: () {
              _controller.zoomLevel = (_controller.zoomLevel + 0.25).clamp(
                0.5,
                4.0,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            tooltip: 'Zoom out',
            onPressed: () {
              _controller.zoomLevel = (_controller.zoomLevel - 0.25).clamp(
                0.5,
                4.0,
              );
            },
          ),
        ],
      ),
      body: SfPdfViewer.file(
        file,
        key: _pdfKey,
        controller: _controller,
        onDocumentLoaded: (details) {
          setState(() => _totalPages = details.document.pages.count);
        },
        onDocumentLoadFailed: (details) {
          setState(() {
            _error = 'No se pudo abrir el PDF: ${details.description}';
          });
        },
        onPageChanged: (details) {
          setState(() => _currentPage = details.newPageNumber);
        },
        canShowScrollHead: true,
        canShowScrollStatus: true,
        pageSpacing: 4,
      ),
      bottomNavigationBar: _totalPages > 1
          ? Container(
              height: 48,
              color: Colors.grey.shade900,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                    onPressed: _currentPage > 1
                        ? () => _controller.previousPage()
                        : null,
                  ),
                  Text(
                    '$_currentPage / $_totalPages',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    onPressed: _currentPage < _totalPages
                        ? () => _controller.nextPage()
                        : null,
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
