import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/bloc/dashboard_bloc.dart';
import '../widgets/global_stats_card.dart';
import '../widgets/apiary_overview_card.dart';
import '../widgets/critical_alerts_section.dart';
import '../../../../core/models/apiary.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc()..add(LoadDashboardData()),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<DashboardBloc>().add(RefreshDashboardData()),
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return switch (state) {
            DashboardInitial() => const _LoadingWidget(),
            DashboardLoading() => const _LoadingWidget(),
            DashboardError() => _ErrorWidget(message: state.message),
            DashboardLoaded() => _LoadedContent(state: state),
            _ => const _LoadingWidget(),
          };
        },
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement du tableau de bord...'),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;

  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                context.read<DashboardBloc>().add(LoadDashboardData()),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

class _LoadedContent extends StatelessWidget {
  final DashboardLoaded state;

  const _LoadedContent({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.apiaries.isEmpty) {
      return const _NoApiariesWidget();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(RefreshDashboardData());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Statistiques globales
            GlobalStatsCard(
              apiaryCount: state.apiaries.length,
              hiveCount: _getTotalHiveCount(state.apiaries),
              alertCount: _getCriticalAlertCount(),
            ),

            const SizedBox(height: 24),

            // Section Mes Ruchers
            _buildSectionHeader(context, 'Mes Ruchers', Icons.home_work),
            const SizedBox(height: 16),

            // Cards des ruchers
            ...state.apiaries.map((apiary) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ApiaryOverviewCard(
                    apiary: apiary,
                    onTap: () => _navigateToApiary(context, apiary),
                  ),
                )),

            const SizedBox(height: 24),

            // Alertes critiques
            const CriticalAlertsSection(),

            const SizedBox(height: 24),

            // Actions rapides
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 28,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions rapides',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.add,
                    label: 'Ajouter Rucher',
                    onTap: () {
                      // TODO: Navigation vers ajout rucher
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fonction à implémenter')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.settings,
                    label: 'Paramètres',
                    onTap: () => context.go('/settings'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _getTotalHiveCount(List<Apiary> apiaries) {
    return apiaries.fold(0, (total, apiary) => total + apiary.hiveIds.length);
  }

  int _getCriticalAlertCount() {
    // TODO: Implémenter le compte des alertes critiques
    return 0;
  }

  void _navigateToApiary(BuildContext context, Apiary apiary) {
    context.go('/apiary/${apiary.id}/hives');
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoApiariesWidget extends StatelessWidget {
  const _NoApiariesWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home_work_outlined,
                size: 64,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Bienvenue !',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun rucher configuré',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Commencez par ajouter votre premier rucher pour gérer vos ruches',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigation vers ajout rucher
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonction à implémenter')),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un rucher'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
