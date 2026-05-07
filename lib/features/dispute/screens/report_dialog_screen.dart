import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// X05 – Report User
/// Allows a user to raise an issue against another user with evidence attachments.
class ReportDialogScreen extends StatefulWidget {
  /// The ID of the user being reported.
  final String reportedUserId;
  final String reportedUserName;

  const ReportDialogScreen({
    super.key,
    required this.reportedUserId,
    required this.reportedUserName,
  });

  @override
  State<ReportDialogScreen> createState() => _ReportDialogScreenState();
}

class _ReportDialogScreenState extends State<ReportDialogScreen> {
  // ── Form ──────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  final List<String> _categories = [
    'Inappropriate Behaviour',
    'Harassment',
    'Fraud / Scam',
    'No-Show',
    'Unsafe Environment',
    'Other',
  ];

  // ── Evidence ──────────────────────────────────────────────────────────────
  final List<File> _attachedImages = [];
  final ImagePicker _picker = ImagePicker();

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isSubmitting = false;

  // ── Theme colours (matching Aptitude palette) ─────────────────────────────
  static const Color _primary = Color(0xFF5B4FCF);   // purple-ish accent
  static const Color _danger  = Color(0xFFE53935);
  static const Color _bg      = Color(0xFFF6F7FB);
  static const Color _card    = Colors.white;

  // ── Helpers ───────────────────────────────────────────────────────────────
  Future<void> _pickImage() async {
    if (_attachedImages.length >= 3) {
      _showSnack('Maximum 3 images allowed.');
      return;
    }
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _attachedImages.add(File(picked.path)));
    }
  }

  void _removeImage(int index) =>
      setState(() => _attachedImages.removeAt(index));

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      _showSnack('Please select a category.');
      return;
    }

    setState(() => _isSubmitting = true);

    // TODO: Replace with your actual Firebase / API call.
    // Example:
    //   await DisputeRepository.createReport(
    //     reportedUserId : widget.reportedUserId,
    //     category       : _selectedCategory!,
    //     description    : _descriptionController.text.trim(),
    //     evidenceFiles  : _attachedImages,
    //   );
    await Future.delayed(const Duration(seconds: 2)); // Simulated network call

    setState(() => _isSubmitting = false);

    if (!mounted) return;
    _showSnack('Report submitted. Our team will review it shortly.');
    Navigator.pop(context, true); // true = report was submitted
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        elevation: 0.5,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          'Report User',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Who you're reporting ──────────────────────────────────────
            _ReportTargetCard(name: widget.reportedUserName),
            const SizedBox(height: 20),

            // ── Category ─────────────────────────────────────────────────
            _SectionLabel(label: 'Category *'),
            const SizedBox(height: 8),
            _CategoryGrid(
              categories: _categories,
              selected: _selectedCategory,
              onSelect: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 20),

            // ── Description ───────────────────────────────────────────────
            _SectionLabel(label: 'Description *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText:
                    'Describe what happened in detail. Include dates, times, and any relevant context…',
                hintStyle:
                    TextStyle(color: Colors.grey.shade400, fontSize: 13),
                filled: true,
                fillColor: _card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _primary, width: 1.5),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().length < 20) {
                  return 'Please provide at least 20 characters.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ── Evidence images ───────────────────────────────────────────
            _SectionLabel(label: 'Evidence (optional, max 3)'),
            const SizedBox(height: 8),
            _EvidenceRow(
              images: _attachedImages,
              onAdd: _pickImage,
              onRemove: _removeImage,
            ),
            const SizedBox(height: 32),

            // ── Disclaimer ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _danger.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _danger.withOpacity(0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: _danger, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'False reports may result in account suspension. '
                      'Only report genuine violations.',
                      style: TextStyle(
                        color: _danger,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Submit ────────────────────────────────────────────────────
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _danger,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Submit Report',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Sub-widgets
// ═══════════════════════════════════════════════════════════════════════════

class _ReportTargetCard extends StatelessWidget {
  final String name;
  const _ReportTargetCard({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF5B4FCF).withOpacity(0.12),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Color(0xFF5B4FCF),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reporting',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.flag_rounded, color: Color(0xFFE53935)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Colors.black87,
        ),
      );
}

class _CategoryGrid extends StatelessWidget {
  final List<String> categories;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _CategoryGrid({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final isSelected = cat == selected;
        return GestureDetector(
          onTap: () => onSelect(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF5B4FCF)
                  : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF5B4FCF)
                    : Colors.grey.shade300,
              ),
            ),
            child: Text(
              cat,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _EvidenceRow extends StatelessWidget {
  final List<File> images;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const _EvidenceRow({
    required this.images,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Existing images
          ...images.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      entry.value,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => onRemove(entry.key),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Add button
          if (images.length < 3)
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.grey.shade300, style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        color: Colors.grey.shade400, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      'Add Photo',
                      style: TextStyle(
                          color: Colors.grey.shade400, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}