import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/hive.dart';
import '../../domain/usecases/create_hive.dart';
import '../bloc/hive_bloc.dart';
import '../bloc/hive_event.dart';

/// Dialogue de création/édition d'une ruche
class CreateHiveDialog extends StatefulWidget {
  final String apiaryId;
  final Hive? hive; // null pour création, rempli pour édition

  const CreateHiveDialog({
    super.key,
    required this.apiaryId,
    this.hive,
  });

  @override
  State<CreateHiveDialog> createState() => _CreateHiveDialogState();
}

class _CreateHiveDialogState extends State<CreateHiveDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isEditing = false;
  String _selectedHiveType = 'Dadant';
  String _selectedMaterial = 'Bois';
  int _frameCount = 10;
  bool _isActive = true;

  final List<String> _hiveTypes = [
    'Dadant',
    'Langstroth',
    'Voirnot',
    'Warré',
    'Top Bar',
    'Autre'
  ];

  final List<String> _materials = ['Bois', 'Plastique', 'Polystyrène', 'Autre'];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.hive != null;

    if (_isEditing) {
      final hive = widget.hive!;
      _nameController.text = hive.name;
      _descriptionController.text = hive.description ?? '';
      _selectedHiveType = hive.hiveType ?? 'Dadant';
      _selectedMaterial = hive.material ?? 'Bois';
      _frameCount = hive.frameCount ?? 10;
      _isActive = hive.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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
                      _isEditing ? 'Modifier la ruche' : 'Nouvelle ruche',
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
                          labelText: 'Nom de la ruche',
                          hintText: 'Ex: Ruche A1',
                          prefixIcon: Icon(Icons.widgets_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le nom est obligatoire';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Type de ruche
                      DropdownButtonFormField<String>(
                        value: _selectedHiveType,
                        decoration: const InputDecoration(
                          labelText: 'Type de ruche',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: _hiveTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedHiveType = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Matériau
                      DropdownButtonFormField<String>(
                        value: _selectedMaterial,
                        decoration: const InputDecoration(
                          labelText: 'Matériau',
                          prefixIcon: Icon(Icons.build_outlined),
                        ),
                        items: _materials.map((material) {
                          return DropdownMenuItem(
                            value: material,
                            child: Text(material),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMaterial = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Nombre de cadres
                      Row(
                        children: [
                          const Icon(Icons.grid_view),
                          const SizedBox(width: 12),
                          Text(
                            'Nombre de cadres',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _frameCount > 1
                                    ? () => setState(() => _frameCount--)
                                    : null,
                                icon: const Icon(Icons.remove),
                              ),
                              Container(
                                width: 60,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$_frameCount',
                                  textAlign: TextAlign.center,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              IconButton(
                                onPressed: _frameCount < 20
                                    ? () => setState(() => _frameCount++)
                                    : null,
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Statut actif
                      SwitchListTile(
                        title: const Text('Ruche active'),
                        subtitle: Text(_isActive
                            ? 'La ruche est en production'
                            : 'La ruche est inactive'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (optionnel)',
                          hintText: 'Notes sur cette ruche...',
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        maxLines: 3,
                      ),
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
    final description = _descriptionController.text.trim();

    if (_isEditing) {
      // TODO: Implémenter la mise à jour
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Modification - À implémenter')),
      );
    } else {
      // Création
      context.read<HiveBloc>().add(
            CreateHiveRequested(
              CreateHiveParams(
                name: name,
                apiaryId: widget.apiaryId,
                description: description.isNotEmpty ? description : '',
                hiveType: _selectedHiveType,
                material: _selectedMaterial,
                frameCount: _frameCount,
              ),
            ),
          );
    }

    Navigator.of(context).pop();
  }
}
