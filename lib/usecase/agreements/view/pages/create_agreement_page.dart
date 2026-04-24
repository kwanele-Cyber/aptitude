import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/usecase/agreements/agreement_viewmodel.dart';
import 'package:myapp/usecase/auth/auth_viewmodel.dart';
import 'package:go_router/go_router.dart';

import 'package:myapp/core/models/agreement_model.dart';

class CreateAgreementPage extends StatefulWidget {
  final String peerId;
  final AgreementModel? originalAgreement;
  const CreateAgreementPage({super.key, required this.peerId, this.originalAgreement});

  @override
  State<CreateAgreementPage> createState() => _CreateAgreementPageState();
}

class _CreateAgreementPageState extends State<CreateAgreementPage> {
  late final TextEditingController _learnerSkillController;
  late final TextEditingController _mentorSkillController;
  late String _selectedFrequency;
  late double _duration;

  @override
  void initState() {
    super.initState();
    _learnerSkillController = TextEditingController(text: widget.originalAgreement?.learnerSkill ?? '');
    _mentorSkillController = TextEditingController(text: widget.originalAgreement?.mentorSkill ?? '');
    _selectedFrequency = widget.originalAgreement?.frequency ?? 'Weekly';
    _duration = widget.originalAgreement?.duration ?? 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AgreementViewModel>();
    final currentUserId = context.read<AuthViewModel>().user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Propose Agreement'),
        backgroundColor: const Color(0xFF0F2027),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('What will you learn?'),
              _buildTextField(_learnerSkillController, 'e.g. Flutter Development', Icons.school),
              const SizedBox(height: 24),
              _buildSectionTitle('What will you teach in return?'),
              _buildTextField(_mentorSkillController, 'e.g. Graphic Design', Icons.person),
              const SizedBox(height: 24),
              _buildSectionTitle('Frequency'),
              _buildFrequencyDropdown(),
              const SizedBox(height: 24),
              _buildSectionTitle('Duration per Session (Hours)'),
              _buildDurationSlider(),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          final bool success;
                          if (widget.originalAgreement != null) {
                            success = await viewModel.createCounterOffer(
                              originalAgreement: widget.originalAgreement!,
                              learnerSkill: _learnerSkillController.text,
                              mentorSkill: _mentorSkillController.text,
                              frequency: _selectedFrequency,
                              duration: _duration,
                            );
                          } else {
                            success = await viewModel.proposeAgreement(
                              learnerId: currentUserId,
                              mentorId: widget.peerId,
                              learnerSkill: _learnerSkillController.text,
                              mentorSkill: _mentorSkillController.text,
                              frequency: _selectedFrequency,
                              duration: _duration,
                            );
                          }
                          
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(widget.originalAgreement != null ? 'Counter-offer sent!' : 'Agreement proposed!')),
                            );
                            context.pop();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: viewModel.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.originalAgreement != null ? 'Send Counter-Offer' : 'Send Proposal', style: const TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildFrequencyDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: _selectedFrequency,
        isExpanded: true,
        dropdownColor: const Color(0xFF203A43),
        underline: const SizedBox(),
        style: const TextStyle(color: Colors.white, fontSize: 16),
        items: ['Daily', 'Weekly', 'Bi-Weekly', 'Monthly'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) setState(() => _selectedFrequency = value);
        },
      ),
    );
  }

  Widget _buildDurationSlider() {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: _duration,
            min: 0.5,
            max: 5.0,
            divisions: 9,
            activeColor: Colors.blueAccent,
            inactiveColor: Colors.white12,
            onChanged: (value) => setState(() => _duration = value),
          ),
        ),
        Text(
          '${_duration}h',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
