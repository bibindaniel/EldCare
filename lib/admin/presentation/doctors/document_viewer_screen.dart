import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentViewerScreen extends StatelessWidget {
  final String url;
  final String title;
  final String documentType;

  const DocumentViewerScreen({
    Key? key,
    required this.url,
    required this.title,
    required this.documentType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _launchURL(context),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadDocument(context),
          ),
        ],
      ),
      body: _buildDocumentView(context),
    );
  }

  Widget _buildDocumentView(BuildContext context) {
    try {
      print('Loading document: $url'); // Debug print
      print('Document type: $documentType'); // Debug print

      if (documentType.contains('pdf') ||
          documentType.contains('certificate') ||
          documentType.contains('degree') ||
          documentType.contains('license')) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('PDF Document'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _launchURL(context),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open PDF'),
              ),
            ],
          ),
        );
      } else {
        // Assume it's an image for other document types
        return PhotoView(
          imageProvider: NetworkImage(url),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          loadingBuilder: (context, event) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image: $error'); // Debug print
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading image: $error'),
                ],
              ),
            );
          },
        );
      }
    } catch (e) {
      print('Error in _buildDocumentView: $e'); // Debug print
      return Center(
        child: Text('Error: ${e.toString()}'),
      );
    }
  }

  Future<void> _launchURL(BuildContext context) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening document: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _downloadDocument(BuildContext context) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not download document';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading document: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
