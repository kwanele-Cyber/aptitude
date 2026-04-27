import 'package:flutter/material.dart';

class SkillChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;

  const SkillChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected || onTap == null
              ? const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFFEC4899)])
              : null,
          color: isSelected || onTap == null
              ? null
              : const Color(0xFF7C3AED).withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFF7C3AED).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected || onTap == null ? Colors.white : const Color(0xFF9D6FEF),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onDeleted != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onDeleted,
                child: const Icon(Icons.close, size: 14, color: Colors.white70),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
