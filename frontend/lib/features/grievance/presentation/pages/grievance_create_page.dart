import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../map/presentation/widgets/naver_map_widget.dart';
import '../../domain/entities/grievance_category.dart';
import '../../domain/usecases/create_grievance_usecase.dart';
import '../providers/grievance_providers.dart';
import '../providers/grievance_list_provider.dart';

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

  // 선택된 카테고리 (기본값: etc)
  GrievanceCategory _selectedCategory = GrievanceCategory.etc;

  // 이미지 선택 관련
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];

  // 제출 중 상태
  bool _isSubmitting = false;

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

            // 카테고리 선택
            DropdownButtonFormField<GrievanceCategory>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: '카테고리',
                hintText: '민원 카테고리를 선택하세요',
              ),
              isExpanded: true,
              items: GrievanceCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(
                    category.label,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
              validator: (value) {
                if (value == null) {
                  return '카테고리를 선택해주세요';
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
                onPressed: _isSubmitting ? null : _submitGrievance,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
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
          '민원 현장 사진을 추가하세요 (선택사항, 최대 10개)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 12),

        // 선택된 이미지가 있으면 미리보기 표시
        if (_selectedImages.isNotEmpty) ...[
          _buildImagePreview(),
          const SizedBox(height: 12),
        ],

        // 이미지 추가 버튼들
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.photo_library),
                label: const Text('갤러리'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickImageFromCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('카메라'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 이미지 미리보기 위젯
  Widget _buildImagePreview() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          final image = _selectedImages[index];
          return Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.only(right: 8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 이미지 표시
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(image.path),
                    fit: BoxFit.cover,
                  ),
                ),

                // 삭제 버튼
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),

                // 순서 표시 (왼쪽 하단)
                Positioned(
                  bottom: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 갤러리에서 여러 이미지 선택
  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();

      if (images.isEmpty) return;

      // 기존 선택 + 새 선택 합쳐서 최대 10개
      final totalImages = _selectedImages.length + images.length;

      if (totalImages > 10) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('최대 10개까지 선택 가능합니다')),
        );

        // 10개까지만 추가
        final remaining = 10 - _selectedImages.length;
        setState(() {
          _selectedImages.addAll(images.take(remaining));
        });
      } else {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 선택 실패: $e')),
      );
    }
  }

  /// 카메라로 사진 촬영
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);

      if (image == null) return;

      if (_selectedImages.length >= 10) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('최대 10개까지 선택 가능합니다')),
        );
        return;
      }

      setState(() {
        _selectedImages.add(image);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진 촬영 실패: $e')),
      );
    }
  }

  /// 선택된 이미지 삭제
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  /// 민원 제출
  Future<void> _submitGrievance() async {
    // 유효성 검증
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

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

    // 중복 제출 방지
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      // Django API로 민원 생성
      final usecase = ref.read(createGrievanceUseCaseProvider);
      final result = await usecase.call(CreateGrievanceParams(
        title: _titleController.text.trim(),
        content: _descriptionController.text.trim(),
        category: _selectedCategory.value,
        latitude: _selectedLat!,
        longitude: _selectedLng!,
        imagePaths: _selectedImages.map((img) => img.path).toList(),
      ));

      if (!mounted) return;

      result.fold(
        // 실패 시
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('오류: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isSubmitting = false);
        },
        // 성공 시
        (grievance) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('민원이 등록되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
          // 민원 리스트 새로고침
          ref.invalidate(grievanceListProvider);
          context.pop();
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('예상치 못한 오류: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isSubmitting = false);
    }
  }
}
