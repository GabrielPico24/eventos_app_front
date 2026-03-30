import 'package:event_app/features/auth/presentation/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();

    ref.listenManual<AuthState>(
      authControllerProvider,
      (previous, next) {
        if (!mounted) return;

        if (next.isAuthenticated && next.role != null) {
          if (next.role == UserRole.admin) {
            context.go('/home-admin');
          } else {
            context.go('/home-user');
          }
        }

        if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              behavior: SnackBarBehavior.floating,
            ),
          );
          ref.read(authControllerProvider.notifier).clearError();
        }
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final media = MediaQuery.of(context);
    final size = media.size;
    final width = size.width;
    final height = size.height;
    final keyboardHeight = media.viewInsets.bottom;
    final isKeyboardOpen = keyboardHeight > 0;

    final isSmall = height < 700;
    final horizontalPadding = width * 0.07;
    final headerHeight = isKeyboardOpen
        ? (isSmall ? height * 0.18 : height * 0.20)
        : (isSmall ? height * 0.34 : height * 0.36);
    const cardOverlap = 45.0;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardTop = headerHeight - cardOverlap;
              final cardMinHeight = constraints.maxHeight - cardTop;

              return Stack(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: headerHeight,
                        width: double.infinity,
                        child: _TopHeader(
                          isSmall: isSmall,
                          width: width,
                          height: height,
                          isKeyboardOpen: isKeyboardOpen,
                        ),
                      ),
                      const Expanded(
                        child: ColoredBox(color: Colors.white),
                      ),
                    ],
                  ),
                  Positioned(
                    top: cardTop,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(34),
                            topRight: Radius.circular(34),
                            bottomLeft: Radius.circular(34),
                            bottomRight: Radius.circular(34)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          isKeyboardOpen ? 22 : (isSmall ? 28 : 25),
                          horizontalPadding,
                          isKeyboardOpen ? 18 : 28,
                        ),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: _submitted
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bienvenido',
                                style: TextStyle(
                                  fontSize: isSmall ? 32 : 25,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF181A20),
                                  height: 1.0,
                                ),
                              ),
                              SizedBox(height: isKeyboardOpen ? 8 : 10),
                              const Text(
                                'Inicia sesión para continuar',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF8B90A0),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(
                                  height: isKeyboardOpen
                                      ? 14
                                      : (isSmall ? 24 : 20)),
                              _CustomTextField(
                                focusNode: _emailFocusNode,
                                controller: _emailController,
                                hintText: 'Correo electrónico',
                                prefixIcon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  final text = value?.trim() ?? '';
                                  if (text.isEmpty) {
                                    return 'Ingresa tu correo';
                                  }
                                  final emailRegex =
                                      RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                                  if (!emailRegex.hasMatch(text)) {
                                    return 'Correo no válido';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(_passwordFocusNode);
                                },
                              ),
                              SizedBox(height: isKeyboardOpen ? 8 : 8),
                              _CustomTextField(
                                focusNode: _passwordFocusNode,
                                controller: _passwordController,
                                hintText: 'Contraseña',
                                prefixIcon: Icons.lock_outline_rounded,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                suffixIcon: IconButton(
                                  splashRadius: 20,
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFF9AA0A6),
                                  ),
                                ),
                                validator: (value) {
                                  final text = value?.trim() ?? '';
                                  if (text.isEmpty) {
                                    return 'Ingresa tu contraseña';
                                  }
                                  if (text.length < 6) {
                                    return 'Mínimo 6 caracteres';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) => _submit(),
                              ),
                              SizedBox(height: isKeyboardOpen ? 0 : 4),
                              if (!isKeyboardOpen)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF2D4ECF),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: isKeyboardOpen ? 2 : 4,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      '¿Olvidaste tu contraseña?',
                                      style: TextStyle(
                                        fontSize: isKeyboardOpen ? 13 : 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              SizedBox(height: isKeyboardOpen ? 10 : 28),
                              SizedBox(height: isKeyboardOpen ? 4 : 28),
                              SizedBox(
                                width: double.infinity,
                                height: isKeyboardOpen ? 54 : 58,
                                child: ElevatedButton(
                                  onPressed:
                                      authState.isLoading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: const Color(0xFF2D4ECF),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        const Color(0xFF2D4ECF)
                                            .withOpacity(0.65),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: authState.isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Ingresar',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    setState(() {
      _submitted = true;
    });

    if (!_formKey.currentState!.validate()) return;

    ref.read(authControllerProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }
}

class _TopHeader extends StatelessWidget {
  final bool isSmall;
  final double width;
  final double height;
  final bool isKeyboardOpen;

  const _TopHeader({
    required this.isSmall,
    required this.width,
    required this.height,
    required this.isKeyboardOpen,
  });

  @override
  Widget build(BuildContext context) {
    final bigBubble = isKeyboardOpen ? width * 0.20 : width * 0.28;
    final smallBubble = isKeyboardOpen ? width * 0.10 : width * 0.13;
    final centerCircle = isKeyboardOpen ? width * 0.16 : width * 0.22;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -(bigBubble * 0.30),
            top: isKeyboardOpen ? 8 : (isSmall ? 34 : 44),
            child: _Bubble(
              size: bigBubble,
              color: const Color(0xFF3557D6),
              icon: Icons.auto_awesome_outlined,
            ),
          ),
          Positioned(
            left: width * 0.11,
            top: isKeyboardOpen ? 26 : (isSmall ? 92 : 108),
            child: _Bubble(
              size: smallBubble,
              color: const Color(0xFF4D6EF0),
              icon: Icons.stars_rounded,
            ),
          ),
          Positioned(
            right: -(bigBubble * 0.30),
            top: isKeyboardOpen ? 8 : (isSmall ? 34 : 44),
            child: _Bubble(
              size: bigBubble,
              color: const Color(0xFF3557D6),
              icon: Icons.calendar_month_outlined,
            ),
          ),
          Positioned(
            right: width * 0.11,
            top: isKeyboardOpen ? 26 : (isSmall ? 92 : 108),
            child: _Bubble(
              size: smallBubble,
              color: const Color(0xFF4D6EF0),
              icon: Icons.bolt_rounded,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(
                top: isKeyboardOpen ? 4 : (isSmall ? 10 : 18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: centerCircle,
                    height: centerCircle,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: isKeyboardOpen
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                    ),
                    child: Icon(
                      Icons.event_note_rounded,
                      size: centerCircle * 0.42,
                      color: const Color(0xFF2D4ECF),
                    ),
                  ),
                  SizedBox(height: isKeyboardOpen ? 8 : (isSmall ? 14 : 18)),
                  if (!isKeyboardOpen)
                    Text(
                      'App Eventos',
                      style: TextStyle(
                        fontSize: isKeyboardOpen ? 16 : (isSmall ? 22 : 24),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF20242C),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final double size;
  final Color color;
  final IconData icon;

  const _Bubble({
    required this.size,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.97,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Center(
          child: Icon(
            icon,
            size: size * 0.42,
            color: Colors.white.withOpacity(0.35),
          ),
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final VoidCallback? onTap;

  const _CustomTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.focusNode,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      onTap: onTap,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF1A1A1A),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFFA0A4AB),
          fontSize: 15.5,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: const Color(0xFF9AA0A6),
          size: 22,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF7F8FC),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        errorMaxLines: 1,
        errorStyle: const TextStyle(
          fontSize: 11.5,
          height: 1.0,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Color(0xFFE6EAF2),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Color(0xFF2D4ECF),
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Color(0xFFE05555),
            width: 1.1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Color(0xFFE05555),
            width: 1.2,
          ),
        ),
      ),
    );
  }
}
