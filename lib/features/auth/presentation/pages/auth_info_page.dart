import 'package:flutter/material.dart';
import '../widgets/user_info_widget.dart';

/// Page d'information sur l'authentification
///
/// Explique le système d'authentification et affiche
/// les informations de l'utilisateur connecté
class AuthInfoPage extends StatelessWidget {
  const AuthInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentification'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations utilisateur
            const UserInfoWidget(showLogoutButton: true),

            const SizedBox(height: 24),

            // Titre de section
            Text(
              'Système d\'authentification',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            // Description
            const Text(
              'L\'application Ruche Connectée utilise Firebase Authentication '
              'pour sécuriser l\'accès à vos données de monitoring IoT.',
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),

            // Fonctionnalités
            _buildFeatureSection(
              'Fonctionnalités de sécurité',
              [
                _FeatureItem(
                  icon: Icons.security,
                  title: 'Authentification sécurisée',
                  description:
                      'Connexion par email et mot de passe avec Firebase',
                ),
                _FeatureItem(
                  icon: Icons.cloud,
                  title: 'Données synchronisées',
                  description: 'Vos ruchers et ruches sont liés à votre compte',
                ),
                _FeatureItem(
                  icon: Icons.vpn_key,
                  title: 'Session persistante',
                  description: 'Restez connecté entre les sessions',
                ),
                _FeatureItem(
                  icon: Icons.logout,
                  title: 'Déconnexion facile',
                  description:
                      'Déconnectez-vous à tout moment en toute sécurité',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Architecture
            _buildFeatureSection(
              'Architecture Clean Code',
              [
                _FeatureItem(
                  icon: Icons.architecture,
                  title: 'Clean Architecture',
                  description:
                      'Organisation modulaire avec séparation des couches',
                ),
                _FeatureItem(
                  icon: Icons.stream,
                  title: 'BLoC Pattern',
                  description: 'Gestion d\'état réactive avec flutter_bloc',
                ),
                _FeatureItem(
                  icon: Icons.security_update_good,
                  title: 'Gestion d\'erreurs',
                  description:
                      'Traitement robuste des erreurs d\'authentification',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Note technique
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Note technique',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'L\'authentification utilise Firebase Auth pour l\'authentification '
                    'et Realtime Database pour stocker les profils utilisateur étendus. '
                    'Cette approche hybride offre sécurité et flexibilité.',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSection(String title, List<_FeatureItem> features) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      feature.icon,
                      color: Colors.amber.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          feature.description,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

/// Élément de fonctionnalité
class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
