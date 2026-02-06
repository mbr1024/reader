import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../data/auth_service.dart';

/// 简洁现代的登录页 - 参考 Linear / Notion / 微信读书风格
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _agreeToTerms = true;
  bool _isLoginMode = true;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 设置状态栏为深色图标
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                
                // 关闭按钮
                _buildCloseButton(),
                
                const SizedBox(height: 48),
                
                // 欢迎语
                _buildWelcomeText(),
                
                const SizedBox(height: 48),
                
                // 表单
                _buildForm(),
                
                const SizedBox(height: 24),
                
                // 登录按钮
                _buildSubmitButton(),
                
                const SizedBox(height: 24),
                
                // 切换登录/注册
                _buildModeSwitch(),
                
                const SizedBox(height: 48),
                
                // 第三方登录
                _buildThirdPartySection(),
                
                const SizedBox(height: 32),
                
                // 用户协议
                _buildAgreement(),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: () => context.go('/bookshelf'),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.close,
          size: 18,
          color: Color(0xFF666666),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isLoginMode ? '欢迎回来' : '创建账号',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isLoginMode ? '登录以同步你的阅读进度' : '注册后开启阅读之旅',
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF888888),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        // 邮箱输入
        _buildInputField(
          controller: _emailController,
          focusNode: _emailFocus,
          label: '邮箱',
          hint: '请输入邮箱地址',
          keyboardType: TextInputType.emailAddress,
        ),
        
        const SizedBox(height: 16),
        
        // 密码输入
        _buildInputField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          label: '密码',
          hint: _isLoginMode ? '请输入密码' : '设置密码（至少6位）',
          obscureText: _obscurePassword,
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 20,
              color: const Color(0xFFAAAAAA),
            ),
          ),
        ),
        
        if (_isLoginMode) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                // TODO: 忘记密码
              },
              child: const Text(
                '忘记密码？',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    final isFocused = focusNode.hasFocus;
    final hasContent = controller.text.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF444444),
          ),
        ),
        const SizedBox(height: 8),
        // 输入框
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isFocused 
                  ? const Color(0xFF1A1A1A) 
                  : hasContent 
                      ? const Color(0xFFE0E0E0)
                      : Colors.transparent,
              width: isFocused ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w500,
            ),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFBBBBBB),
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: suffixIcon,
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final isEnabled = !_isLoading && _agreeToTerms;
    
    return GestureDetector(
      onTap: isEnabled ? _handleSubmit : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: isEnabled ? const Color(0xFF1A1A1A) : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  _isLoginMode ? '登录' : '注册',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isEnabled ? Colors.white : const Color(0xFF999999),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildModeSwitch() {
    return Center(
      child: GestureDetector(
        onTap: () => setState(() => _isLoginMode = !_isLoginMode),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14),
            children: [
              TextSpan(
                text: _isLoginMode ? '还没有账号？' : '已有账号？',
                style: const TextStyle(color: Color(0xFF888888)),
              ),
              TextSpan(
                text: _isLoginMode ? '立即注册' : '立即登录',
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThirdPartySection() {
    return Column(
      children: [
        // 分割线
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: const Color(0xFFF0F0F0),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '或',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFFAAAAAA),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: const Color(0xFFF0F0F0),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // 第三方登录按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              icon: Icons.wechat,
              color: const Color(0xFF07C160),
              label: '微信',
            ),
            const SizedBox(width: 24),
            _buildSocialButton(
              icon: Icons.apple,
              color: const Color(0xFF000000),
              label: 'Apple',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label登录暂未开放'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF333333),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      },
      child: Container(
        width: 140,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgreement() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text.rich(
          TextSpan(
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFAAAAAA),
              height: 1.5,
            ),
            children: [
              const TextSpan(text: '登录即表示同意'),
              TextSpan(
                text: '《用户协议》',
                style: const TextStyle(color: Color(0xFF666666)),
                recognizer: TapGestureRecognizer()..onTap = () {},
              ),
              const TextSpan(text: '和'),
              TextSpan(
                text: '《隐私政策》',
                style: const TextStyle(color: Color(0xFF666666)),
                recognizer: TapGestureRecognizer()..onTap = () {},
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    if (email.isEmpty) {
      _showError('请输入邮箱');
      return;
    }
    
    if (password.isEmpty) {
      _showError('请输入密码');
      return;
    }
    
    if (!_isLoginMode && password.length < 6) {
      _showError('密码至少6位');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService.instance;
      
      if (_isLoginMode) {
        await authService.loginWithEmail(email: email, password: password);
        _showSuccess('登录成功');
      } else {
        await authService.register(email: email, password: password);
        _showSuccess('注册成功');
      }
      
      if (mounted) {
        context.go('/bookshelf');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF43A047),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
