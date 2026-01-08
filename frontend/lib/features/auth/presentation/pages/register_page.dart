import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../providers/auth_state_provider.dart';

/// 회원가입 페이지 (3단계)
///
/// Step 1: 이메일 + 비밀번호 + 이름 (한국식 단일 입력)
/// Step 2: 전화번호 입력 (향후 PASS/SMS 인증 확장 가능)
/// Step 3: 닉네임 + 역할 선택 + 약관 동의
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  // PageView 컨트롤러
  final _pageController = PageController();
  int _currentStep = 0;

  // 각 단계별 FormKey
  final _formKeys = [
    GlobalKey<FormState>(), // Step 1
    GlobalKey<FormState>(), // Step 2
    GlobalKey<FormState>(), // Step 3
  ];

  // 등록 데이터
  final _registrationData = _RegistrationData();

  // Step 1 컨트롤러
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();
  final _nameController = TextEditingController(); // 한국식 단일 이름 필드

  // Step 2 컨트롤러
  final _phoneController = TextEditingController();

  // Step 3 컨트롤러
  final _nicknameController = TextEditingController();

  // 상태 플래그
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _obscurePassword2 = true;

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _password2Controller.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBackButton,
        ),
      ),
      body: Column(
        children: [
          // 단계 표시기
          _buildStepIndicator(),

          // PageView
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
            ),
          ),

          // 네비게이션 버튼
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  /// 단계 표시기 (점 3개)
  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index <= _currentStep
                  ? const Color(0xFF2B7DE9) // 활성 (파란색)
                  : Colors.grey[300], // 비활성 (회색)
            ),
          );
        }),
      ),
    );
  }

  /// Step 1: 기본 정보 (이메일, 비밀번호, 이름)
  Widget _buildStep1() {
    return Form(
      key: _formKeys[0],
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            '기본 정보를 입력해주세요',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 24),

          // 이메일
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: '이메일',
              hintText: 'example@email.com',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이메일을 입력해주세요';
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return '올바른 이메일 형식이 아닙니다';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // 비밀번호
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: '비밀번호',
              hintText: '8자 이상 입력',
              prefixIcon: const Icon(Icons.lock),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호를 입력해주세요';
              }
              if (value.length < 8) {
                return '비밀번호는 8자 이상이어야 합니다';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // 비밀번호 확인
          TextFormField(
            controller: _password2Controller,
            obscureText: _obscurePassword2,
            decoration: InputDecoration(
              labelText: '비밀번호 확인',
              hintText: '비밀번호를 다시 입력',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword2 ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() => _obscurePassword2 = !_obscurePassword2);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '비밀번호 확인을 입력해주세요';
              }
              if (value != _passwordController.text) {
                return '비밀번호가 일치하지 않습니다';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // 이름 (한국식 - 단일 필드)
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '이름',
              hintText: '예: 홍길동',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '이름을 입력해주세요';
              }
              if (value.length < 2) {
                return '이름은 최소 2글자 이상이어야 합니다';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// Step 2: 전화번호 입력 (향후 PASS/SMS 인증 확장)
  Widget _buildStep2() {
    return Form(
      key: _formKeys[1],
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            '전화번호를 입력해주세요',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '본인인증은 선택사항입니다',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),

          // 안내 박스
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF2B7DE9),
                  size: 32,
                ),
                const SizedBox(height: 8),
                const Text(
                  'PASS 인증 또는 SMS 인증은 추후 제공될 예정입니다',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '지금은 전화번호만 입력하고 다음 단계로 진행하세요.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 전화번호 입력
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: '전화번호',
              hintText: '010-0000-0000',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return null; // 선택사항
              }
              final phoneRegex = RegExp(r'^010-\d{4}-\d{4}$');
              if (!phoneRegex.hasMatch(value)) {
                return '010-0000-0000 형식으로 입력해주세요';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // 향후 확장을 위한 주석 처리된 버튼
          /* TODO: PASS/SMS 인증 구현 시 활성화
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _startPassVerification,
                  icon: const Icon(Icons.verified_user),
                  label: const Text('PASS 인증'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _startSmsVerification,
                  icon: const Icon(Icons.sms),
                  label: const Text('SMS 인증'),
                ),
              ),
            ],
          ),
          */
        ],
      ),
    );
  }

  /// Step 3: 추가 정보 (닉네임, 역할, 약관)
  Widget _buildStep3() {
    return Form(
      key: _formKeys[2],
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            '추가 정보를 입력해주세요',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 24),

          // 닉네임 (선택)
          TextFormField(
            controller: _nicknameController,
            decoration: const InputDecoration(
              labelText: '닉네임 (선택)',
              hintText: '비워두면 자동으로 생성됩니다',
              prefixIcon: Icon(Icons.badge),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          // 역할 선택
          Text(
            '가입 유형',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),

          // 시민 옵션
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: _registrationData.role == 'citizen'
                    ? const Color(0xFF2B7DE9)
                    : Colors.grey[300]!,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: RadioListTile<String>(
              value: 'citizen',
              groupValue: _registrationData.role,
              onChanged: (value) {
                setState(() => _registrationData.role = value!);
              },
              title: const Text('시민'),
              subtitle: const Text('민원을 등록하고 관리합니다'),
              secondary: const Icon(
                Icons.person,
                color: Color(0xFF2B7DE9),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 정치인 옵션
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: _registrationData.role == 'politician'
                    ? const Color(0xFF2B7DE9)
                    : Colors.grey[300]!,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: RadioListTile<String>(
              value: 'politician',
              groupValue: _registrationData.role,
              onChanged: (value) {
                setState(() => _registrationData.role = value!);
              },
              title: const Text('정치인'),
              subtitle: const Text('민원에 응답하고 해결합니다'),
              secondary: const Icon(
                Icons.how_to_vote,
                color: Color(0xFF2B7DE9),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 서비스 이용약관
          CheckboxListTile(
            value: _registrationData.termsAccepted,
            onChanged: (value) {
              setState(() => _registrationData.termsAccepted = value!);
            },
            title: const Row(
              children: [
                Text('서비스 이용약관'),
                SizedBox(width: 4),
                Text(
                  '(필수)',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
            subtitle: TextButton(
              onPressed: () {
                // TODO: 약관 보기 다이얼로그
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('서비스 이용약관'),
                    content: const SingleChildScrollView(
                      child: Text(
                        '여기에 서비스 이용약관 내용이 표시됩니다.\n\n'
                        '1. 서비스 이용 약관...\n'
                        '2. 개인정보 처리방침...\n'
                        '3. 위치정보 이용약관...',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('확인'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('약관 보기'),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  /// 네비게이션 버튼 (이전/다음/완료)
  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // 이전 버튼 (첫 단계가 아닐 때만)
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('이전'),
              ),
            ),
            const SizedBox(width: 16),
          ],

          // 다음/완료 버튼
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(_currentStep == 2 ? '가입 완료' : '다음'),
            ),
          ),
        ],
      ),
    );
  }

  /// 뒤로가기 버튼 처리
  void _handleBackButton() {
    if (_currentStep > 0) {
      _previousStep();
    } else {
      // 첫 단계에서 뒤로가기 시 확인 다이얼로그
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('회원가입 취소'),
          content: const Text('회원가입을 취소하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('계속 진행'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
                context.pop(); // 회원가입 페이지 나가기
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('취소'),
            ),
          ],
        ),
      );
    }
  }

  /// 다음 단계로 이동
  void _nextStep() {
    // Step 1: 기본 정보 검증
    if (_currentStep == 0) {
      if (!_formKeys[0].currentState!.validate()) return;

      // 데이터 저장
      _registrationData.email = _emailController.text.trim();
      _registrationData.password = _passwordController.text;
      _registrationData.password2 = _password2Controller.text;
      _registrationData.name = _nameController.text.trim();
    }

    // Step 2: 전화번호 (선택적 검증)
    if (_currentStep == 1) {
      if (_phoneController.text.isNotEmpty &&
          !_formKeys[1].currentState!.validate()) {
        return;
      }

      _registrationData.phoneNumber = _phoneController.text.trim();
    }

    // Step 3: 제출
    if (_currentStep == 2) {
      if (!_registrationData.termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('서비스 이용약관에 동의해주세요'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      _submitRegistration();
      return;
    }

    // 다음 단계로 이동
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep++);
  }

  /// 이전 단계로 이동
  void _previousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep--);
  }

  /// 회원가입 제출
  Future<void> _submitRegistration() async {
    setState(() => _isSubmitting = true);

    final nickname = _nicknameController.text.trim().isEmpty
        ? null
        : _nicknameController.text.trim();

    await ref.read(authStateProvider.notifier).register(
          email: _registrationData.email,
          password: _registrationData.password,
          password2: _registrationData.password2,
          name: _registrationData.name.isEmpty ? null : _registrationData.name,
          phoneNumber: _registrationData.phoneNumber.isEmpty
              ? null
              : _registrationData.phoneNumber,
          nickname: nickname,
          role: _registrationData.role,
        );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    // 결과 확인
    final authState = ref.read(authStateProvider);

    authState.when(
      data: (user) {
        if (user != null) {
          // 성공
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('회원가입이 완료되었습니다!'),
              backgroundColor: Color(0xFF00C853),
            ),
          );

          // 홈으로 이동
          context.go(Routes.grievanceList);
        }
      },
      loading: () {},
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }
}

/// 회원가입 데이터 모델
class _RegistrationData {
  // Step 1
  String email = '';
  String password = '';
  String password2 = '';
  String name = ''; // 한국식 단일 이름 필드

  // Step 2
  String phoneNumber = '';
  bool phoneVerified = false;

  // Step 3
  String nickname = '';
  String role = 'citizen';
  bool termsAccepted = false;
}
