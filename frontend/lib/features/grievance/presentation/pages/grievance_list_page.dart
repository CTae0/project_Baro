import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../data/models/grievance_mock_data.dart';
import '../widgets/grievance_card.dart';

/// 민원 리스트 페이지 (홈 화면)
///
/// Privacy-First 원칙:
/// - 지도를 사용하지 않고 리스트 형태로만 민원을 표시
/// - 빠른 로딩과 데이터 절약
/// - 당근마켓/인스타그램 스타일의 피드 UI
class GrievanceListPage extends ConsumerWidget {
  const GrievanceListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 샘플 데이터 가져오기
    final grievances = GrievanceMock.getSampleData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('BARO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: 알림 페이지로 이동
            },
          ),
        ],
      ),
      body: grievances.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              itemCount: grievances.length,
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemBuilder: (context, index) {
                final grievance = grievances[index];
                return GrievanceCard(
                  grievance: grievance,
                  onTap: () {
                    // 민원 상세 페이지로 이동
                    context.push('/grievance/${grievance.id}');
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(Routes.grievanceCreate);
        },
        icon: const Icon(Icons.edit),
        label: const Text('민원 작성'),
      ),
    );
  }

  /// 빈 상태 UI (데이터가 없을 때)
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            '등록된 민원이 없습니다',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 12),
          Text(
            '첫 번째 민원을 등록해보세요!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }
}
