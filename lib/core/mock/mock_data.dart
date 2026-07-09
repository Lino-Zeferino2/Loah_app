import 'package:flutter/material.dart';
import '../../models/goal_model.dart';
import '../../models/task_model.dart';

/// Single source of mock data for the whole app.
///
/// Today this is just static Dart lists — no persistence, no network.
/// When we migrate to Firebase, this class gets replaced by real
/// repositories, but every screen already reads goals/tasks *through*
/// this class, so the migration won't touch screen code.
class MockData {
  MockData._();

  static final List<GoalModel> goals = [
    GoalModel(
      id: 'goal_emergency_fund',
      title: 'Reserva de Emergência',
      category: 'Finanças',
      term: GoalTerm.curtoPrazo,
      progressMode: GoalProgressMode.manualValue,
      current: 4250,
      target: 5000,
      progressColor: Colors.brown.shade400,
    ),
    const GoalModel(
      id: 'goal_daily_workout',
      title: 'Treino Diário',
      category: 'Saúde',
      term: GoalTerm.curtoPrazo,
      progressMode: GoalProgressMode.manualValue,
      current: 12,
      target: 30,
    ),
    const GoalModel(
      id: 'goal_eurotrip',
      title: 'Eurotrip 2024',
      category: 'Viagem',
      description: 'Poupar para passagens e hospedagem em Paris e Roma.',
      term: GoalTerm.medioPrazo,
      progressMode: GoalProgressMode.manualValue,
      current: 2500,
      target: 10000,
      imageAsset: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800',
    ),
    // Checklist-mode example: progress comes from linked tasks below,
    // not from a manual current/target value.
    const GoalModel(
      id: 'goal_cloud_certification',
      title: 'Certificação Cloud',
      category: 'Carreira',
      term: GoalTerm.medioPrazo,
      progressMode: GoalProgressMode.taskChecklist,
      progressColor: Colors.green,
    ),
    // Same style as the reference screenshot: a manualValue goal that
    // ALSO has milestone tasks (which don't drive the %, just organize
    // the sub-steps), a photo background and a target date.
    GoalModel(
      id: 'goal_buy_car',
      title: 'Comprar um Carro',
      category: 'Financeiro',
      description:
          'Meta para adquirir um veículo seminovo para facilitar a locomoção '
          'diária e viagens em família. Foco em modelos híbridos ou econômicos.',
      term: GoalTerm.medioPrazo,
      progressMode: GoalProgressMode.manualValue,
      current: 16250,
      target: 25000,
      progressColor: Colors.lightBlueAccent,
      targetDate: DateTime(2024, 12, 1),
      imageAsset: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800',
    ),
    const GoalModel(
      id: 'goal_apartment_downpayment',
      title: 'Entrada do Apartamento',
      category: 'Investimento',
      description: 'Investimento de longo prazo.',
      term: GoalTerm.longoPrazo,
      progressMode: GoalProgressMode.manualValue,
      current: 1500,
      target: 12500,
    ),
  ];

  static final List<TaskModel> tasks = [
    const TaskModel(
      id: 'task_quarterly_report',
      title: 'Finalizar relatório trimestral',
      subtitle: 'Hoje, 17:00',
    ),
    const TaskModel(
      id: 'task_leg_day',
      title: 'Treino de perna e cardio',
      subtitle: 'Academia, 19:30',
    ),
    const TaskModel(
      id: 'task_review_budget',
      title: 'Revisar orçamento mensal',
      subtitle: 'Concluído',
      isDone: true,
    ),
    // Sub-tasks for the Cloud Certification goal (checklist-mode) —
    // note the matching goalId. 2/4 done = 50% progress.
    const TaskModel(
      id: 'task_cloud_module_1',
      title: 'Módulo 1 — Fundamentos',
      goalId: 'goal_cloud_certification',
      isDone: true,
    ),
    const TaskModel(
      id: 'task_cloud_module_2',
      title: 'Módulo 2 — Redes e Segurança',
      goalId: 'goal_cloud_certification',
      isDone: true,
    ),
    const TaskModel(
      id: 'task_cloud_module_3',
      title: 'Módulo 3 — Armazenamento',
      goalId: 'goal_cloud_certification',
    ),
    const TaskModel(
      id: 'task_cloud_module_4',
      title: 'Módulo 4 — Simulado final',
      goalId: 'goal_cloud_certification',
    ),
    // Milestones for "Comprar um Carro" — organizational only, they
    // don't drive its % (that comes from current/target), matching the
    // reference screenshot's "Marcos & Tarefas" list.
    TaskModel(
      id: 'task_car_down_payment',
      title: 'Guardar R\$ 5.000 de entrada',
      goalId: 'goal_buy_car',
      isDone: true,
      completedAt: DateTime(2024, 10, 15),
    ),
    const TaskModel(
      id: 'task_car_research_suv',
      title: 'Pesquisar modelos (SUV vs sedã)',
      goalId: 'goal_buy_car',
    ),
    const TaskModel(
      id: 'task_car_test_drive',
      title: 'Agendar test-drives',
      goalId: 'goal_buy_car',
    ),
  ];
}