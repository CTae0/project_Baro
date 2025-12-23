import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

            // 위치 선택 (네이버 지도 연동 예정)
            Card(
              child: InkWell(
                onTap: _selectLocation,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF2B7DE9)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '위치 선택',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '지도에서 민원 위치를 선택하세요',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 사진 첨부 (이미지 피커 연동 예정)
            Card(
              child: InkWell(
                onTap: _pickImages,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.photo_camera, color: Color(0xFF00C853)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '사진 첨부',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '민원 현장 사진을 추가하세요',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectLocation() {
    // TODO: 네이버 지도 페이지로 이동하여 위치 선택
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('지도 기능은 곧 구현됩니다')),
    );
  }

  void _pickImages() {
    // TODO: 이미지 피커로 사진 선택
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('사진 첨부 기능은 곧 구현됩니다')),
    );
  }

  void _submitGrievance() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: 민원 등록 API 호출
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('민원이 등록되었습니다')),
      );
      context.pop();
    }
  }
}
