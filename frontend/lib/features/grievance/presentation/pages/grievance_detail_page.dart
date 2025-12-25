import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../providers/grievance_detail_provider.dart';

/// 민원 상세 페이지
class GrievanceDetailPage extends ConsumerWidget {
  final String grievanceId;

  const GrievanceDetailPage({
    super.key,
    required this.grievanceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grievanceAsync = ref.watch(grievanceDetailProvider(grievanceId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('민원 상세'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: 공유 기능
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: 더보기 메뉴
            },
          ),
        ],
      ),
      body: grievanceAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
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
                '민원을 불러올 수 없습니다',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(grievanceDetailProvider(grievanceId)),
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (grievance) => ListView(
          padding: EdgeInsets.zero,
          children: [
            // 이미지 갤러리 (있는 경우)
            if (grievance.images.isNotEmpty) _buildImageGallery(grievance.images),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상태 배지
                  _buildStatusBadge(context, grievance.status),
                  const SizedBox(height: 12),

                  // 제목
                  Text(
                    grievance.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // 위치 및 날짜
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        grievance.location,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('yyyy-MM-dd').format(grievance.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // 내용
                  Text(
                    grievance.content,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  // 작성자 정보 (있는 경우)
                  if (grievance.userName != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 20,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '작성자: ${grievance.userName}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[700],
                                ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // 공감 버튼
                  _buildLikeButton(context, ref, grievanceId, grievance),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 이미지 갤러리 위젯
  Widget _buildImageGallery(List<String> images) {
    return SizedBox(
      height: 300,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              CachedNetworkImage(
                imageUrl: images[index],
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                ),
              ),
              // 이미지 카운터
              if (images.length > 1)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${index + 1}/${images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// 상태 배지
  Widget _buildStatusBadge(BuildContext context, String status) {
    Color badgeColor;
    String badgeText;

    switch (status) {
      case 'pending':
        badgeColor = Colors.orange;
        badgeText = '접수 대기';
        break;
      case 'in_progress':
        badgeColor = Colors.blue;
        badgeText = '처리 중';
        break;
      case 'resolved':
        badgeColor = Colors.green;
        badgeText = '해결 완료';
        break;
      default:
        badgeColor = Colors.grey;
        badgeText = '알 수 없음';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 공감 버튼
  Widget _buildLikeButton(BuildContext context, WidgetRef ref, String id, grievance) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          // 공감 토글
          await ref.read(grievanceDetailProvider(id).notifier).toggleLike();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: grievance.isLiked ? Colors.red[50] : Colors.grey[100],
          foregroundColor: grievance.isLiked ? Colors.red : Colors.grey[700],
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        icon: Icon(
          grievance.isLiked ? Icons.favorite : Icons.favorite_border,
          size: 24,
        ),
        label: Text(
          '공감 ${grievance.likeCount}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
