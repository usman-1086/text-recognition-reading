import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/custom_app_bar.dart';
import '../../components/stat_card.dart';
import '../../components/section_card.dart';
import '../../components/custom_button.dart';
import '../../components/responsive_image_preview.dart';
import '../../utils/responsive.dart';
import '../controllers/ocr_controler.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OCRController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          const CustomAppBar(
            title: 'OCR Reader',
            subtitle: 'Extract and listen to text from images',
          ),
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: Responsive.maxContentWidth(),
                ),
                padding: EdgeInsets.all(Responsive.padding(20)),
                child: Column(
                  children: [
                    // Quick Stats
                    _buildQuickStats(controller),
                    SizedBox(height: Responsive.padding(24)),

                    // Image Upload Section
                    _buildImageUploadSection(controller),
                    SizedBox(height: Responsive.padding(24)),

                    // Audio Controls Section
                    _buildAudioControlsSection(controller),
                    SizedBox(height: Responsive.padding(24)),

                    // Recognized Text Section
                    _buildRecognizedTextSection(controller),
                    SizedBox(height: Responsive.padding(20)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: _buildFloatingActionButton(controller),
    );
  }

  Widget _buildQuickStats(OCRController controller) {
    return Obx(() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: StatCard(
              icon: Icons.image_outlined,
              title: 'Images',
              value: controller.hasImage ? '1' : '0',
              color: Colors.blue,
            ),
          ),
          SizedBox(width: Responsive.padding(16)),
          Expanded(
            child: StatCard(
              icon: Icons.text_fields,
              title: 'Characters',
              value: controller.characterCount.toString(),
              color: Colors.green,
            ),
          ),
          SizedBox(width: Responsive.padding(16)),
          Expanded(
            child: StatCard(
              icon: Icons.volume_up,
              title: 'Status',
              value: controller.isSpeaking.value ? 'Playing' : 'Ready',
              color: Colors.orange,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildImageUploadSection(OCRController controller) {
    return SectionCard(
      title: 'Image Upload',
      icon: Icons.photo_camera_outlined,
      iconColor: Colors.blue.shade600,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: Responsive.padding(20),
              right: Responsive.padding(20),
              bottom: Responsive.padding(20)
            ),
            child:  ResponsiveImagePreview(onTap: (){
              return _showSourceModal(controller);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioControlsSection(OCRController controller) {
    return Obx(() => SectionCard(
      title: 'Audio Controls',
      icon: Icons.headphones_outlined,
      iconColor: Colors.green.shade600,
      actions: [
        if (controller.isSpeaking.value)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.padding(12),
              vertical: Responsive.padding(6),
            ),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: Responsive.padding(8)),
                Text(
                  'Playing',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(12),
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Responsive.padding(20),
          0,
          Responsive.padding(20),
          Responsive.padding(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Play',
                icon: Icons.play_arrow_rounded,
                backgroundColor: controller.isSpeaking.value || !controller.hasText
                    ? Colors.grey.shade300
                    : Colors.green.shade500,
                onPressed: controller.isSpeaking.value || !controller.hasText
                    ? null
                    : controller.speakText,
              ),
            ),
            SizedBox(width: Responsive.padding(16)),
            Expanded(
              child: CustomButton(
                text: 'Stop',
                icon: Icons.stop_rounded,
                backgroundColor: !controller.isSpeaking.value
                    ? Colors.grey.shade300
                    : Colors.red.shade500,
                onPressed: !controller.isSpeaking.value ? null : controller.stopSpeaking,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildRecognizedTextSection(OCRController controller) {
    return Obx(() => SectionCard(
      title: 'Extracted Text',
      icon: Icons.text_snippet_outlined,
      iconColor: Colors.purple.shade600,
      actions: [
        if (controller.hasText)
          IconButton(
            onPressed: controller.copyTextToClipboard,
            icon: Icon(
              Icons.copy_rounded,
              color: Colors.purple.shade600,
              size: Responsive.iconSize(20),
            ),
            tooltip: 'Copy text',
          ),
      ],
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: Responsive.cardHeight(180),
        ),
        padding: EdgeInsets.all(Responsive.padding(20)),
        child: controller.recognizedText.value.isEmpty
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.text_fields_outlined,
              size: Responsive.iconSize(48),
              color: Colors.grey.shade300,
            ),
            SizedBox(height: Responsive.padding(16)),
            Text(
              'No text extracted yet',
              style: TextStyle(
                fontSize: Responsive.fontSize(16),
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(height: Responsive.padding(8)),
            Text(
              'Upload an image or PDF to extract text',
              style: TextStyle(
                fontSize: Responsive.fontSize(14),
                color: Colors.grey.shade400,
              ),
            ),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              controller.recognizedText.value,
              style: TextStyle(
                fontSize: Responsive.fontSize(16),
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: Responsive.padding(16)),
            Container(
              padding: EdgeInsets.all(Responsive.padding(12)),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: Responsive.iconSize(16),
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: Responsive.padding(8)),
                  Text(
                    '${controller.characterCount} characters • ${controller.wordCount} words',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(12),
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  // Widget _buildFloatingActionButton(OCRController controller) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [Colors.blue.shade600, Colors.purple.shade600],
  //       ),
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.blue.withOpacity(0.3),
  //           blurRadius: 12,
  //           offset: const Offset(0, 6),
  //         ),
  //       ],
  //     ),
  //     child: FloatingActionButton.extended(
  //       onPressed: () => _showSourceModal(controller),
  //       backgroundColor: Colors.transparent,
  //       elevation: 0,
  //       icon: Icon(
  //         Icons.add_a_photo_outlined,
  //         color: Colors.white,
  //         size: Responsive.iconSize(20),
  //       ),
  //       label: Text(
  //         'Quick Scan',
  //         style: TextStyle(
  //           color: Colors.white,
  //           fontWeight: FontWeight.w600,
  //           fontSize: Responsive.fontSize(14),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void _showSourceModal(OCRController controller) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.symmetric(
          vertical: Responsive.padding(24),
          horizontal: Responsive.padding(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: Responsive.padding(20)),
            Text(
              'Select Source',
              style: TextStyle(
                fontSize: Responsive.fontSize(20),
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: Responsive.padding(24)),
            _buildSourceOption(
              icon: Icons.photo_library_outlined,
              title: 'Photo Library',
              subtitle: 'Choose from gallery',
              color: Colors.blue,
              onTap: () {
                Get.back();
                controller.pickImageAndProcess(ImageSource.gallery);
              },
            ),
            SizedBox(height: Responsive.padding(12)),
            _buildSourceOption(
              icon: Icons.camera_alt_outlined,
              title: 'Camera',
              subtitle: 'Take a new photo',
              color: Colors.green,
              onTap: () {
                Get.back();
                controller.pickImageAndProcess(ImageSource.camera);
              },
            ),
            SizedBox(height: Responsive.padding(12)),
            _buildSourceOption(
              icon: Icons.picture_as_pdf_outlined,
              title: 'PDF Document',
              subtitle: 'Extract text from PDF',
              color: Colors.red,
              onTap: () {
                Get.back();
                controller.pickPdfAndProcess();
              },
            ),
            SizedBox(height: Responsive.padding(20)),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(
          horizontal: Responsive.padding(20),
          vertical: Responsive.padding(8),
        ),
        leading: Container(
          padding: EdgeInsets.all(Responsive.padding(12)),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: Responsive.iconSize(24),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: Responsive.fontSize(16),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: Responsive.fontSize(14),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey.shade400,
          size: Responsive.iconSize(16),
        ),
      ),
    );
  }
}