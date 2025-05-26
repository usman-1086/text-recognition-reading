import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

class OCRController extends GetxController {
  // Observables
  final RxString pickedImagePath = RxString('');
  final RxString recognizedText = RxString('');
  final RxBool isRecognizing = RxBool(false);
  final RxBool isSpeaking = RxBool(false);

  // Services
  late TextRecognizer textRecognizer;
  late ImagePicker imagePicker;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void onInit() {
    super.onInit();
    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    imagePicker = ImagePicker();
    _initializeTTS();
  }

  @override
  void onClose() {
    textRecognizer.close();
    super.onClose();
  }

  void _initializeTTS() {
    flutterTts.setCompletionHandler(() {
      isSpeaking.value = false;
    });
  }

  // Computed properties
  int get characterCount => recognizedText.value.length;
  int get wordCount => recognizedText.value.isEmpty ? 0 : recognizedText.value.split(' ').length;
  bool get hasImage => pickedImagePath.value.isNotEmpty;
  bool get hasText => recognizedText.value.isNotEmpty;

  String cleanText(String input) {
    return input
        .replaceAll(RegExp(r'^\s*[-•*·▪—]+\s*', multiLine: true), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> speakText() async {
    if (recognizedText.value.isEmpty) return;

    try {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1.0);
      await flutterTts.speak(recognizedText.value);
      isSpeaking.value = true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to speak text: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await flutterTts.stop();
      isSpeaking.value = false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to stop speaking: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> pickImageAndProcess(ImageSource source) async {
    try {
      final pickedImage = await imagePicker.pickImage(source: source);
      if (pickedImage == null) return;

      pickedImagePath.value = pickedImage.path;
      isRecognizing.value = true;

      final inputImage = InputImage.fromFilePath(pickedImage.path);
      final RecognizedText result = await textRecognizer.processImage(inputImage);

      final rawText = result.blocks
          .map((block) => block.lines.map((line) => line.text).join('\n'))
          .join('\n\n');

      recognizedText.value = cleanText(rawText);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to process image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isRecognizing.value = false;
    }
  }

  Future<void> pickPdfAndProcess() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) return;

      final pdfPath = result.files.single.path!;
      pickedImagePath.value = '';
      isRecognizing.value = true;

      final document = await PdfDocument.openFile(pdfPath);
      final tempDir = await getTemporaryDirectory();
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
        if (bytes == null) continue;

        final imageFile = File('${tempDir.path}/page_$i.png');
        await imageFile.writeAsBytes(bytes);

        final inputImage = InputImage.fromFilePath(imageFile.path);
        final result = await textRecognizer.processImage(inputImage);

        final rawText = result.blocks
            .map((block) => block.lines.map((line) => line.text).join('\n'))
            .join('\n\n');

        fullText += '--- Page $i ---\n${cleanText(rawText)}\n\n';
      }

      recognizedText.value = fullText.trim();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to process PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isRecognizing.value = false;
    }
  }

  Future<void> copyTextToClipboard() async {
    if (recognizedText.value.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: recognizedText.value));
      Get.snackbar(
        'Success',
        'Text copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    }
  }

  void clearImage() {
    pickedImagePath.value = '';
    recognizedText.value = '';
  }

  void clearText() {
    recognizedText.value = '';
  }
}