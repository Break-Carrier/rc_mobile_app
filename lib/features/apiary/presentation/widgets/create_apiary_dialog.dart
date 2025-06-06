import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/apiary.dart';
import '../../domain/usecases/create_apiary.dart';
import '../../domain/usecases/update_apiary.dart';
import '../bloc/apiary_bloc.dart';
import '../bloc/apiary_event.dart';

/// Dialogue de création/édition d'un rucher
class CreateApiaryDialog extends StatefulWidget {
  final Apiary? apiary; // null pour création, rempli pour édition

  const CreateApiaryDialog({
    super.key,
    this.apiary,
  });

  @override
  State<CreateApiaryDialog> createState() => _CreateApiaryDialogState();
}

class _CreateApiaryDialogState extends State<CreateApiaryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  bool _isEditing = false;
  bool _hasCoordinates = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.apiary != null;

    if (_isEditing) {
      final apiary = widget.apiary!;
      _nameController.text = apiary.name;
      _locationController.text = apiary.location;
      _descriptionController.text = apiary.description;

      if (apiary.hasCoordinates) {
        _hasCoordinates = true;
        _latitudeController.text = apiary.latitude.toString();
        _longitudeController.text = apiary.longitude.toString();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isEditing ? Icons.edit : Icons.add,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isEditing ? 'Modifier le rucher' : 'Nouveau rucher',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Formulaire
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom du rucher',
                          hintText: 'Ex: Rucher du jardin',
                          prefixIcon: Icon(Icons.hive_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le nom est obligatoire';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Localisation
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Localisation',
                          hintText: 'Ex: Toulouse, France',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La localisation est obligatoire';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (optionnel)',
                          hintText: 'Décrivez votre rucher...',
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 16),

                      // Coordonnées GPS
                      CheckboxListTile(
                        title: const Text('Ajouter les coordonnées GPS'),
                        subtitle: const Text(
                            'Pour localiser précisément votre rucher'),
                        value: _hasCoordinates,
                        onChanged: (value) {
                          setState(() {
                            _hasCoordinates = value ?? false;
                            if (!_hasCoordinates) {
                              _latitudeController.clear();
                              _longitudeController.clear();
                            }
                          });
                        },
                      ),

                      if (_hasCoordinates) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _latitudeController,
                                decoration: const InputDecoration(
                                  labelText: 'Latitude',
                                  hintText: '43.6047',
                                  prefixIcon: Icon(Icons.gps_fixed),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                  signed: true,
                                ),
                                validator: _hasCoordinates
                                    ? (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Obligatoire';
                                        }
                                        final lat = double.tryParse(value);
                                        if (lat == null ||
                                            lat < -90 ||
                                            lat > 90) {
                                          return 'Invalide';
                                        }
                                        return null;
                                      }
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _longitudeController,
                                decoration: const InputDecoration(
                                  labelText: 'Longitude',
                                  hintText: '1.4442',
                                  prefixIcon: Icon(Icons.gps_fixed),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                  signed: true,
                                ),
                                validator: _hasCoordinates
                                    ? (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Obligatoire';
                                        }
                                        final lng = double.tryParse(value);
                                        if (lng == null ||
                                            lng < -180 ||
                                            lng > 180) {
                                          return 'Invalide';
                                        }
                                        return null;
                                      }
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _submitForm,
                    child: Text(_isEditing ? 'Modifier' : 'Créer'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();

    double? latitude;
    double? longitude;

    if (_hasCoordinates) {
      latitude = double.tryParse(_latitudeController.text.trim());
      longitude = double.tryParse(_longitudeController.text.trim());
    }

    if (_isEditing) {
      // Mise à jour
      context.read<ApiaryBloc>().add(
            UpdateApiaryRequested(
              UpdateApiaryParams(
                apiaryId: widget.apiary!.id,
                name: name,
                location: location,
                description: description.isNotEmpty ? description : '',
                latitude: latitude,
                longitude: longitude,
              ),
            ),
          );
    } else {
      // Création
      context.read<ApiaryBloc>().add(
            CreateApiaryRequested(
              CreateApiaryParams(
                name: name,
                location: location,
                description: description.isNotEmpty ? description : '',
                latitude: latitude,
                longitude: longitude,
              ),
            ),
          );
    }

    Navigator.of(context).pop();
  }
}
