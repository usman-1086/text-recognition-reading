import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final List<Widget>? actions;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: Responsive.maxContentWidth(),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(Responsive.padding(20)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(Responsive.padding(8)),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(Responsive.padding(8)),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: Responsive.iconSize(20),
                    ),
                  ),

                ),
                SizedBox(width: Responsive.padding(12)),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(18),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (actions != null) ...actions!,
              ],
            ),
          ),
          // Content
          child,
        ],
      ),
    );
  }

}


