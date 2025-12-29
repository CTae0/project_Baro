import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

/// 네이버 지도 위젯
///
/// 민원 작성 시 위치를 선택하기 위한 네이버 지도 컴포넌트입니다.
/// 모바일(Android/iOS)에서만 실제 지도를 표시하고, 그 외 플랫폼에서는 플레이스홀더를 표시합니다.
class NaverMapWidget extends StatefulWidget {
  final double height;
  final Function(double lat, double lng)? onLocationSelected;
  final bool readOnly;
  final double? initialLatitude;
  final double? initialLongitude;

  const NaverMapWidget({
    super.key,
    this.height = 200,
    this.onLocationSelected,
    this.readOnly = false,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<NaverMapWidget> createState() => _NaverMapWidgetState();
}

class _NaverMapWidgetState extends State<NaverMapWidget> {
  NaverMapController? _mapController;
  NLatLng? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.readOnly && widget.initialLatitude != null && widget.initialLongitude != null) {
      // 읽기 전용 모드: 초기 좌표로 설정
      setState(() {
        _currentPosition = NLatLng(widget.initialLatitude!, widget.initialLongitude!);
        _isLoading = false;
      });
    } else {
      _getCurrentLocation();
    }
  }

  /// GPS 현재 위치 가져오기
  Future<void> _getCurrentLocation() async {
    try {
      // 위치 서비스 활성화 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = '위치 서비스가 비활성화되어 있습니다.';
          _isLoading = false;
        });
        return;
      }

      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = '위치 권한이 거부되었습니다.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = '위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.';
          _isLoading = false;
        });
        return;
      }

      // 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _currentPosition = NLatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // 지도 카메라 이동 (지도가 준비된 경우)
      if (_mapController != null) {
        _mapController!.updateCamera(
          NCameraUpdate.scrollAndZoomTo(
            target: _currentPosition!,
            zoom: 15,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = '위치를 가져올 수 없습니다: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 플랫폼 확인: 모바일이 아니면 플레이스홀더 표시
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    if (!isMobile) {
      return _buildPlatformNotSupportedState();
    }

    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            NaverMap(
              options: NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: _currentPosition ?? const NLatLng(37.5666, 126.9784), // 기본: 서울시청
                  zoom: 15,
                ),
                indoorEnable: false,
                // locationButtonEnable 제거됨 (v1.4.0+): 대신 NMyLocationButtonWidget 사용
                consumeSymbolTapEvents: false,
              ),
              onMapReady: (controller) {
                _mapController = controller;

                // 현재 위치에 마커 추가
                if (_currentPosition != null) {
                  _addMarker(_currentPosition!);
                }
              },
              onMapTapped: (point, latLng) {
                // 읽기 전용 모드에서는 탭 무시
                if (widget.readOnly) return;

                // 지도 탭 시 마커 위치 변경
                _addMarker(latLng);

                // 콜백 호출
                if (widget.onLocationSelected != null) {
                  widget.onLocationSelected!(latLng.latitude, latLng.longitude);
                }
              },
            ),
            // 내 위치 버튼 (v1.4.0+ 위젯 방식)
            if (_mapController != null && !widget.readOnly)
              Positioned(
                right: 16,
                bottom: 16,
                child: NMyLocationButtonWidget(
                  mapController: _mapController!,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 플랫폼 미지원 상태 UI (Web, Windows, macOS, Linux)
  Widget _buildPlatformNotSupportedState() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.map_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                '지도는 모바일 앱에서만 사용 가능합니다',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Android 또는 iOS 기기에서 앱을 실행해주세요',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // 테스트용 기본 위치 선택 (서울시청)
                  if (widget.onLocationSelected != null) {
                    widget.onLocationSelected!(37.5666, 126.9784);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('테스트 위치 선택됨: 서울시청'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.location_on, size: 16),
                label: const Text('테스트 위치 선택 (서울시청)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B7DE9),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 마커 추가
  void _addMarker(NLatLng position) {
    if (_mapController == null) return;

    // 기존 마커 제거
    _mapController!.clearOverlays();

    // 새 마커 추가
    final marker = NMarker(
      id: 'current_location',
      position: position,
    );

    _mapController!.addOverlay(marker);

    // 카메라 이동
    _mapController!.updateCamera(
      NCameraUpdate.scrollAndZoomTo(
        target: position,
        zoom: 15,
      ),
    );
  }

  /// 로딩 상태 UI
  Widget _buildLoadingState() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('위치 정보를 가져오는 중...'),
          ],
        ),
      ),
    );
  }

  /// 에러 상태 UI
  Widget _buildErrorState() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[700],
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? '지도를 불러올 수 없습니다',
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _getCurrentLocation();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
