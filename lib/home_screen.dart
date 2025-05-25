import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'image_preview.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;

  Future<void> _speakText() async {
    if (recognizedText.isEmpty) return;

    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(recognizedText);

    setState(() {
      isSpeaking = true;
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });
  }

  Future<void> _stopText() async {
    await flutterTts.stop();
    setState(() {
      isSpeaking = false;
    });
  }

  Future<void> _pickPdfAndProcess() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.single.path == null) return;

    final pdfPath = result.files.single.path!;
    setState(() {
      pickedImagePath = null;
      isRecognizing = true;
    });

    try {
      final document = await PdfDocument.openFile(pdfPath);
      final tempDir = await getTemporaryDirectory();
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

      String fullText = '';

      for (int i = 1; i <= document.pagesCount; i++) {
        final page = await document.getPage(i);
        final pageImage = await page.render(
          width: page.width,
          height: page.height,
          format: PdfPageImageFormat.png,
        );
        await page.close();

        final bytes = pageImage?.bytes;
        if (bytes == null) {
          debugPrint('Page $i skipped due to null image bytes.');
          continue;
        }

        // Save image to file
        final imageFile = File('${tempDir.path}/page_$i.png');
        await imageFile.writeAsBytes(bytes);

        // Process image with ML Kit
        final inputImage = InputImage.fromFilePath(imageFile.path);
        final result = await textRecognizer.processImage(inputImage);

        final pageText = result.blocks
            .map((block) => block.lines.map((line) => line.text).join('\n'))
            .join('\n\n');

        fullText += '--- Page $i ---\n$pageText\n\n';
      }

      setState(() {
        recognizedText = fullText.trim();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing PDF: $e')),
      );
    } finally {
      setState(() {
        isRecognizing = false;
      });
    }
  }


  late TextRecognizer textRecognizer;
  late ImagePicker imagePicker;

  String? pickedImagePath;
  String recognizedText = "";

  bool isRecognizing = false;

  @override
  void initState() {
    super.initState();
    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    imagePicker = ImagePicker();
  }

  void _pickImageAndProcess({required ImageSource source}) async {
    final pickedImage = await imagePicker.pickImage(source: source);
    if (pickedImage == null) return;

    setState(() {
      pickedImagePath = pickedImage.path;
      isRecognizing = true;
    });

    try {
      final inputImage = InputImage.fromFilePath(pickedImage.path);
      final RecognizedText result = await textRecognizer.processImage(inputImage);

      recognizedText = result.blocks.map((block) =>
          block.lines.map((line) => line.text).join('\n')
      ).join('\n\n');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isRecognizing = false;
      });
    }
  }

  void _chooseImageSourceModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageAndProcess(source: ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Picture'),
              onTap: () {
                Navigator.pop(context);
                _pickImageAndProcess(source: ImageSource.camera);
              },
            ),

            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Pick a PDF'),
              onTap: () {
                Navigator.pop(context);
                _pickPdfAndProcess();
              },
            ),


          ],
        ),
      ),
    );
  }

  void _copyTextToClipboard() async {
    if (recognizedText.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: recognizedText));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Recognition and Reading'),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Image Preview
              ImagePreview(imagePath: pickedImagePath,),
              const SizedBox(height: 16),

              // Pick Image Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.image_search),
                  label: isRecognizing
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Pick Image'),
                  onPressed: isRecognizing ? null : _chooseImageSourceModal,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const Divider(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: isSpeaking ? null : _speakText,
                    icon: Icon(Icons.volume_up),
                    label: Text('Read Aloud'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: isSpeaking ? _stopText : null,
                    icon: Icon(Icons.stop),
                    label: Text('Stop'),
                  ),
                ],
              ),


              // Recognized Text Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recognized Text",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: _copyTextToClipboard,
                    tooltip: 'Copy text',
                  ),
                ],
              ),

              // Recognized Text Output
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      recognizedText.isEmpty
                          ? 'No text recognized yet.'
                          : recognizedText,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
