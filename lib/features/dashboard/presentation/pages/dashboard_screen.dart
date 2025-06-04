import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/bloc/dashboard_bloc.dart';
import '../widgets/dashboard_states.dart';
import '../widgets/global_stats_card.dart';
import '../widgets/apiaries_section.dart';
import '../widgets/recent_alerts_section.dart';
import '../widgets/quick_actions_section.dart';

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
        title: const Text('🏡 Ruche Connectée'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: () =>
                context.read<DashboardBloc>().add(RefreshDashboardData()),
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return switch (state) {
            DashboardInitial() => const DashboardLoadingWidget(),
            DashboardLoading() => const DashboardLoadingWidget(),
            DashboardError() => DashboardErrorWidget(message: state.message),
            DashboardLoaded() => _LoadedContent(state: state),
            _ => const DashboardLoadingWidget(),
          };
        },
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
      return const NoApiariesWidget();
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
            // Résumé Global
            GlobalStatsCard(apiaries: state.apiaries),

            const SizedBox(height: 20),

            // Mes Ruchers
            ApiariesSection(apiaries: state.apiaries),

            const SizedBox(height: 20),

            // Alertes Récentes
            const RecentAlertsSection(),

            const SizedBox(height: 20),

            // Actions rapides
            const QuickActionsSection(),
          ],
        ),
      ),
    );
  }
}
