import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../map/presentation/widgets/naver_map_widget.dart';

/// 민원 작성 페이지
///
/// 네이버 지도를 사용하여 정확한 위치를 선택하고
/// 사진과 함께 민원을 등록합니다.
class GrievanceCreatePage extends ConsumerStatefulWidget {
  const GrievanceCreatePage({super.key});

  @override
  ConsumerState<GrievanceCreatePage> createState() =>
      _GrievanceCreatePageState();
}

class _GrievanceCreatePageState extends ConsumerState<GrievanceCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // 선택된 위치 정보
  double? _selectedLat;
  double? _selectedLng;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('민원 작성'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _submitGrievance,
            child: const Text('등록'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 제목 입력
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                hintText: '민원 제목을 입력하세요',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '제목을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 설명 입력
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '상세 설명',
                hintText: '민원 내용을 상세히 입력하세요',
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '상세 설명을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 사진 등록 영역
            _buildPhotoUploadArea(),
            const SizedBox(height: 16),

            // 네이버 지도 위젯
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 20,
                      color: Color(0xFF2B7DE9),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '위치 확인',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '지도를 탭하여 민원 위치를 선택하세요',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 12),
                NaverMapWidget(
                  height: 250,
                  onLocationSelected: (lat, lng) {
                    setState(() {
                      _selectedLat = lat;
                      _selectedLng = lng;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('위치 선택: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 민원 접수하기 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitGrievance,
                child: const Text(
                  '민원 접수하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// 사진 등록 영역 UI
  Widget _buildPhotoUploadArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.photo_camera,
              size: 20,
              color: Color(0xFF00C853),
            ),
            const SizedBox(width: 8),
            Text(
              '사진 추가',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '민원 현장 사진을 추가하세요 (선택사항)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _pickImages,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(
                color: Colors.grey[300]!,
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '카메라 / 갤러리',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 이미지 선택 (임시)
  void _pickImages() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('사진 첨부 기능은 향후 구현 예정입니다')),
    );
  }

  /// 민원 제출
  void _submitGrievance() {
    if (_formKey.currentState?.validate() ?? false) {
      // 위치 선택 확인
      if (_selectedLat == null || _selectedLng == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('지도에서 위치를 선택해주세요'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // TODO: 실제 API 호출
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '민원이 등록되었습니다\n위치: ${_selectedLat!.toStringAsFixed(4)}, ${_selectedLng!.toStringAsFixed(4)}',
          ),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    }
  }
}
