import 'package:flutter/material.dart';

import '../../../../utils/app_theme.dart';

class CharacterSheetErrorCard extends StatelessWidget {
  final String message;

  const CharacterSheetErrorCard({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class CharacterSheetSuccessCard extends StatelessWidget {
  final String path;
  final String characterName;
  final VoidCallback onPreview;
  final VoidCallback onShare;
  final VoidCallback onRegenerate;
  final VoidCallback onGoHome;

  const CharacterSheetSuccessCard({
    super.key,
    required this.path,
    required this.characterName,
    required this.onPreview,
    required this.onShare,
    required this.onRegenerate,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = path.split('/').last;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'Sheet Generated!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            fileName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),

          const SizedBox(height: 14),

          // Botón de ancho completo: correcto dentro de Column.
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                foregroundColor: Colors.white,
              ),
              onPressed: onPreview,
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: const Text('Preview'),
            ),
          ),

          const SizedBox(height: 8),

          // Botones en Row: deben usar Expanded.
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: onShare,
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRegenerate,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Regenerate'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Botón de ancho completo: correcto dentro de Column.
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onGoHome,
              icon: const Icon(Icons.home, size: 18),
              label: const Text('Back to Home'),
            ),
          ),
        ],
      ),
    );
  }
}