import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ocr_controler.dart';
import '../utils/responsive.dart';

class ResponsiveImagePreview extends StatelessWidget {
  final VoidCallback? onTap;
  const ResponsiveImagePreview({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OCRController>();

    return Obx(() {
      final imagePath = controller.pickedImagePath.value;
      final imageHeight = Responsive.cardHeight(220);

      return Container(
        width: double.infinity,
        height: imageHeight,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: imagePath.isNotEmpty
            ? ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              Image.file(
                File(imagePath),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: Responsive.padding(12),
                right: Responsive.padding(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: controller.clearImage,
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: Responsive.iconSize(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(Responsive.padding(20)),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: GestureDetector(
                onTap: onTap,
                child: Icon(
                  Icons.cloud_upload_outlined,
                  size: Responsive.iconSize(48),
                  color: Colors.blue.shade400,
                ),
              ),
            ),
            SizedBox(height: Responsive.padding(16)),
            Text(
              'Upload an Image',
              style: TextStyle(
                fontSize: Responsive.fontSize(18),
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: Responsive.padding(8)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.padding(20),
              ),
              child: Text(
                'Tap to select from camera, gallery, or PDF\nSupports JPG, PNG, PDF formats',
                style: TextStyle(
                  fontSize: Responsive.fontSize(14),
                  color: Colors.grey.shade500,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    });
  }
}