import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _location = TextEditingController();
  final _description = TextEditingController();
  IncidentCategory? _category;
  bool _categoryError = false;
  File? _image;

  @override
  void initState() {
    super.initState();
    context.read<IncidentProvider>().clearError();
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final picked = await ImagePicker()
        .pickImage(source: source, maxWidth: 1280, imageQuality: 80);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take a photo'),
            onTap: () {
              Navigator.pop(context);
              _pick(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from gallery'),
            onTap: () {
              Navigator.pop(context);
              _pick(ImageSource.gallery);
            },
          ),
        ]),
      ),
    );
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState!.validate();
    if (_category == null) setState(() => _categoryError = true);
    if (!formOk || _category == null) return;

    final user = context.read<AuthProvider>().profile!;
    final provider = context.read<IncidentProvider>();
    final ok = await provider.submit(
      user: user,
      title: _title.text,
      description: _description.text,
      location: _location.text,
      category: _category!,
      image: _image,
    );
    if (ok && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted. Thank you!')),
      );
    }
  }

  Widget _catTile(IncidentCategory c) {
    final cs = Theme.of(context).colorScheme;
    final selected = _category == c;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() {
        _category = c;
        _categoryError = false;
      }),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(c.icon, color: selected ? cs.onPrimary : cs.primary),
            const SizedBox(height: 4),
            Text(c.label,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    color: selected ? cs.onPrimary : cs.onSurface)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final cs = Theme.of(context).colorScheme;
    final label = Theme.of(context)
        .textTheme
        .titleSmall
        ?.copyWith(fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: AppBar(title: const Text('Report an Incident')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select a category', style: label),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [for (final c in IncidentCategory.values) _catTile(c)],
                ),
                if (_categoryError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('Choose a category',
                        style: TextStyle(color: cs.error, fontSize: 12)),
                  ),
                const SizedBox(height: 20),
                Text('Title', style: label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    hintText: 'Briefly describe the issue...',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().length < 5)
                      ? 'Enter at least 5 characters'
                      : null,
                ),
                const SizedBox(height: 8),
                Text('Description', style: label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _description,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    hintText: 'What happened, when, impact, etc.',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().length < 10)
                      ? 'Describe the problem (at least 10 characters)'
                      : null,
                ),
                const SizedBox(height: 8),
                Text('Location', style: label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _location,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Block B, Room 204',
                    prefixIcon: Icon(Icons.place_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().length < 3)
                      ? 'Enter where the problem is'
                      : null,
                ),
                const SizedBox(height: 20),
                Text('Add a photo (optional)', style: label),
                const SizedBox(height: 8),
                if (_image == null)
                  InkWell(
                    onTap: _showPhotoOptions,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 90,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_outlined),
                          SizedBox(height: 4),
                          Text('Tap to add photos'),
                        ],
                      ),
                    ),
                  )
                else
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_image!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover),
                      ),
                      IconButton.filled(
                        onPressed: () => setState(() => _image = null),
                        icon: const Icon(Icons.close),
                        tooltip: 'Remove photo',
                      ),
                    ],
                  ),
                if (provider.error != null) ...[
                  const SizedBox(height: 16),
                  Text(provider.error!, style: TextStyle(color: cs.error)),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: provider.isSubmitting ? null : _submit,
                    child: provider.isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Submit Report'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}