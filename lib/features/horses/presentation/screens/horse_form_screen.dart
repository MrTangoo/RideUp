import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/validators.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_text_field.dart';
import '../providers/horses_provider.dart';

class HorseFormScreen extends ConsumerStatefulWidget {
  final String? horseId;

  const HorseFormScreen({
    super.key,
    this.horseId,
  });

  @override
  ConsumerState<HorseFormScreen> createState() => _HorseFormScreenState();
}

class _HorseFormScreenState extends ConsumerState<HorseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _healthInfoController = TextEditingController();
  final _particularitiesController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedSex;
  File? _selectedPhoto;
  bool _isLoading = false;

  final List<String> _sexOptions = ['Mâle', 'Femelle', 'Hongre'];

  @override
  void initState() {
    super.initState();
    if (widget.horseId != null) {
      _loadHorseData();
    }
  }

  Future<void> _loadHorseData() async {
    final horse = await ref.read(horseProvider(widget.horseId!).future);
    _nameController.text = horse.name;
    _breedController.text = horse.breed ?? '';
    _selectedSex = horse.sex;
    _ageController.text = horse.age?.toString() ?? '';
    _weightController.text = horse.weight?.toString() ?? '';
    _heightController.text = horse.height?.toString() ?? '';
    _healthInfoController.text = horse.healthInfo ?? '';
    _particularitiesController.text = horse.particularities ?? '';
    _notesController.text = horse.notes ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _healthInfoController.dispose();
    _particularitiesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final result = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir une photo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final image = await picker.pickImage(source: result);
      if (image != null) {
        setState(() {
          _selectedPhoto = File(image.path);
        });
      }
    }
  }

  Future<void> _saveHorse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final controller = ref.read(horsesControllerProvider.notifier);
    String? error;

    if (widget.horseId == null) {
      // Create new horse
      error = await controller.createHorse(
        name: _nameController.text.trim(),
        breed: _breedController.text.trim().isEmpty ? null : _breedController.text.trim(),
        sex: _selectedSex,
        age: _ageController.text.isEmpty ? null : int.tryParse(_ageController.text),
        weight: _weightController.text.isEmpty ? null : double.tryParse(_weightController.text),
        height: _heightController.text.isEmpty ? null : double.tryParse(_heightController.text),
        healthInfo: _healthInfoController.text.trim().isEmpty ? null : _healthInfoController.text.trim(),
        particularities: _particularitiesController.text.trim().isEmpty ? null : _particularitiesController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        photo: _selectedPhoto,
      );
    } else {
      // Update existing horse
      error = await controller.updateHorse(
        horseId: widget.horseId!,
        name: _nameController.text.trim(),
        breed: _breedController.text.trim().isEmpty ? null : _breedController.text.trim(),
        sex: _selectedSex,
        age: _ageController.text.isEmpty ? null : int.tryParse(_ageController.text),
        weight: _weightController.text.isEmpty ? null : double.tryParse(_weightController.text),
        height: _heightController.text.isEmpty ? null : double.tryParse(_heightController.text),
        healthInfo: _healthInfoController.text.trim().isEmpty ? null : _healthInfoController.text.trim(),
        particularities: _particularitiesController.text.trim().isEmpty ? null : _particularitiesController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        photo: _selectedPhoto,
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } else {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.horseId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier le cheval' : 'Ajouter un cheval'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photo picker
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    image: _selectedPhoto != null
                        ? DecorationImage(
                            image: FileImage(_selectedPhoto!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedPhoto == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ajouter une photo',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Name
            CustomTextField(
              controller: _nameController,
              label: 'Nom *',
              prefixIcon: Icons.favorite,
              validator: Validators.validateHorseName,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Breed
            CustomTextField(
              controller: _breedController,
              label: 'Race',
              prefixIcon: Icons.pets,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Sex
            DropdownButtonFormField<String>(
              value: _selectedSex,
              decoration: InputDecoration(
                labelText: 'Sexe',
                prefixIcon: const Icon(Icons.wc),
                enabled: !_isLoading,
              ),
              items: _sexOptions.map((sex) {
                return DropdownMenuItem(
                  value: sex,
                  child: Text(sex),
                );
              }).toList(),
              onChanged: _isLoading ? null : (value) {
                setState(() => _selectedSex = value);
              },
            ),
            const SizedBox(height: 16),

            // Age
            CustomTextField(
              controller: _ageController,
              label: 'Âge (années)',
              prefixIcon: Icons.cake,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  return Validators.validateAge(value);
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Weight
            CustomTextField(
              controller: _weightController,
              label: 'Poids (kg)',
              prefixIcon: Icons.scale,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  return Validators.validateWeight(value);
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Height
            CustomTextField(
              controller: _heightController,
              label: 'Taille (cm)',
              prefixIcon: Icons.height,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  return Validators.validateHeight(value);
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            const SizedBox(height: 24),

            Text(
              'Informations complémentaires',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Health Info
            CustomTextField(
              controller: _healthInfoController,
              label: 'Informations santé',
              prefixIcon: Icons.medical_services_outlined,
              maxLines: 3,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Particularities
            CustomTextField(
              controller: _particularitiesController,
              label: 'Particularités',
              prefixIcon: Icons.info_outline,
              maxLines: 3,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Notes
            CustomTextField(
              controller: _notesController,
              label: 'Notes',
              prefixIcon: Icons.note_outlined,
              maxLines: 3,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 32),

            // Save button
            CustomButton(
              text: isEdit ? 'Enregistrer' : 'Ajouter',
              onPressed: _isLoading ? null : _saveHorse,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
