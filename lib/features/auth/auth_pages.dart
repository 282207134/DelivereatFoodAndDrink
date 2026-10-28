import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/app_state.dart';
import '../../ui/components.dart';
import '../../ui/theme.dart';

class Brand extends StatelessWidget {
  final bool white;
  const Brand({super.key, this.white = false});
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        'assets/images/logo-white.png',
        width: 120,
        height: 120,
        color: white ? Colors.white : orange,
      ),
      const SizedBox(height: 16),
      Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Deliver',
              style: TextStyle(color: white ? Colors.white : orange),
            ),
            TextSpan(
              text: 'eat',
              style: TextStyle(color: white ? Colors.white : ink),
            ),
          ],
        ),
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
      ),
    ],
  );
}

class SplashPage extends StatefulWidget {
  final bool preview;
  const SplashPage({super.key, this.preview = false});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? timer;
  @override
  void initState() {
    super.initState();
    if (!widget.preview) {
      timer = Timer(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        final s = AppScope.of(context);
        Navigator.pushReplacementNamed(
          context,
          s.signedIn
              ? '/home'
              : s.onboarded
              ? '/welcome'
              : '/onboarding/1/0',
        );
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: orange,
    body: Center(child: Brand(white: true)),
  );
}

class OnboardingPage extends StatelessWidget {
  final int version, step;
  const OnboardingPage({super.key, required this.version, required this.step});
  void next(BuildContext context) {
    if (step < 2) {
      Navigator.pushReplacementNamed(
        context,
        '/onboarding/$version/${step + 1}',
      );
    } else {
      finish(context);
    }
  }

  void finish(BuildContext context) {
    final s = AppScope.of(context);
    s.onboarded = true;
    s.save();
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final light = version == 1;
    final scale = MediaQuery.sizeOf(context).width / 375;
    const titles = [
      'Lorem ipsum dolor sit amet consecteur explicit',
      'Convallis egestas duis neque faucibus.',
      'Nibh pretium nibh sit odio ipsum rhoncus quis vitae a.',
    ];
    const descriptions = [
      'Semper in cursus magna et eu varius nunc adipiscing. Elementum justo, laoreet id sem semper parturient.',
      'Sit tincidunt cras ipsum euismod tincidunt est bibendum faucibus egestas. Integer massa in viverra ut sed lorem eleifend senectus.',
      'Ullamcorper imperdiet urna id non sed est sem. Rhoncus amet, enim purus gravida donec aliquet. Nibh sem tellus habitant.',
    ];
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (light) Container(color: const Color(0xFFFFECD0)),
          if (light)
            Positioned(
              top: [105.0, 81.0, -12.0][step] * scale,
              left: [-70.0, 20.0, -6.0][step] * scale,
              width: [479.0, 354.0, 381.0][step] * scale,
              height: [311.0, 293.0, 528.0][step] * scale,
              child: AssetImageView(
                'onboarding1-${step + 1}',
                fit: BoxFit.contain,
              ),
            )
          else
            AssetImageView('onboarding$version-${step + 1}'),
          if (!light)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0x30171725),
                    Color(0xF2171725),
                  ],
                  stops: [0, .4, 1],
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
              decoration: light
                  ? const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.elliptical(200, 40),
                      ),
                    )
                  : null,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: version == 3
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    Text(
                      titles[step],
                      textAlign: version == 3
                          ? TextAlign.start
                          : TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: light ? ink : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      descriptions[step],
                      textAlign: version == 3
                          ? TextAlign.start
                          : TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: light ? muted : Colors.white70,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: version == 3
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          height: 9,
                          width: i == step ? 30 : 9,
                          decoration: BoxDecoration(
                            color: i == step
                                ? orange
                                : light
                                ? pale
                                : Colors.white38,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 44),
                    if (version == 3)
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => finish(context),
                              child: const Text('Skip'),
                            ),
                          ),
                          Expanded(
                            child: PrimaryButton(
                              'Next',
                              onPressed: () => next(context),
                            ),
                          ),
                        ],
                      )
                    else
                      PrimaryButton('Next', onPressed: () => next(context)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(flex: 2),
            const Brand(),
            const SizedBox(height: 18),
            const Text(
              'Enter your registered\nPhone Number to Sign Up',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 14),
            ),
            const Spacer(flex: 3),
            PrimaryButton('Sign In', onPressed: () => go(context, '/login')),
            const SizedBox(height: 16),
            PrimaryButton(
              'Register',
              onPressed: () => go(context, '/register'),
            ),
            TextButton(
              onPressed: () => home(context),
              child: const Text(
                'Explore as guest',
                style: TextStyle(color: muted, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

enum AuthMode { login, register, reset, newPassword }

class AuthPage extends StatefulWidget {
  final AuthMode mode;
  const AuthPage({super.key, required this.mode});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      email = TextEditingController(),
      password = TextEditingController(),
      confirm = TextEditingController();
  bool visible = false, agree = false;
  @override
  void dispose() {
    for (final c in [name, email, password, confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  String? requiredField(String? value) => value == null || value.trim().isEmpty
      ? 'Please fill in this field'
      : null;
  String? emailRule(String? value) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value ?? '')
      ? null
      : 'Enter a valid email address';
  String? passwordRule(String? value) =>
      (value?.length ?? 0) < 6 ? 'Use at least 6 characters' : null;
  void submit() {
    if (!form.currentState!.validate()) return;
    final s = AppScope.of(context);
    switch (widget.mode) {
      case AuthMode.login:
        if (s.password != null && password.text != s.password) {
          toast(context, 'Incorrect demo password');
          return;
        }
        s.name = name.text.trim();
        s.signedIn = true;
        s.save();
        home(context);
      case AuthMode.register:
        if (!agree) {
          toast(context, 'Please accept the terms and privacy policy');
          return;
        }
        s.name = name.text.trim();
        s.email = email.text.trim();
        s.password = password.text;
        s.save();
        go(context, '/verification', arguments: 'register');
      case AuthMode.reset:
        s.email = email.text.trim();
        s.save();
        go(context, '/verification', arguments: 'reset');
      case AuthMode.newPassword:
        s.password = password.text;
        toast(context, 'Demo password updated');
        Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.mode;
    final login = mode == AuthMode.login,
        register = mode == AuthMode.register,
        reset = mode == AuthMode.reset,
        newPassword = mode == AuthMode.newPassword;
    final title = login
        ? 'Let’s Sign you in'
        : register
        ? 'Register'
        : reset
        ? 'Reset Password'
        : 'Create New Password';
    final sub = login
        ? 'Enter your registered\nname to Sign in'
        : register
        ? 'Fill the details and Create New\nAccount'
        : reset
        ? 'Recover your account password'
        : 'Enter your new password';
    return PageFrame(
      title: '',
      scroll: false,
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 64),
            child: IntrinsicHeight(
              child: Form(
                key: form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      sub,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: muted, fontSize: 14),
                    ),
                    SizedBox(height: reset ? 40 : 48),
                    if (login || register)
                      LabeledField(
                        'Name',
                        hint: 'Enter your name',
                        controller: name,
                        validator: requiredField,
                      ),
                    if (register || reset)
                      LabeledField(
                        'Email Address',
                        hint: reset ? 'Email@gmail.com' : 'Enter your email',
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        validator: emailRule,
                      ),
                    if (!reset)
                      LabeledField(
                        newPassword ? 'New password' : 'Password',
                        hint: newPassword
                            ? 'Enter new password'
                            : 'Enter your password',
                        controller: password,
                        obscure: !visible,
                        validator: passwordRule,
                        suffix: IconButton(
                          tooltip: 'Show password',
                          onPressed: () => setState(() => visible = !visible),
                          icon: Icon(
                            visible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: muted,
                          ),
                        ),
                      ),
                    if (newPassword)
                      LabeledField(
                        'Confirm password',
                        hint: 'Confirm password',
                        controller: confirm,
                        obscure: !visible,
                        validator: (v) =>
                            v == password.text ? null : 'Passwords must match',
                      ),
                    if (login) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => go(context, '/reset'),
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Or Sign up with',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _social('G', const Color(0xFFF3F8FA), Colors.blue),
                          _social('', ink, Colors.white, icon: Icons.apple),
                          _social('f', const Color(0xFF4267A9), Colors.white),
                        ],
                      ),
                    ],
                    if (register)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: Checkbox(
                              value: agree,
                              onChanged: (v) => setState(() => agree = v!),
                              activeColor: orange,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Wrap(
                              children: [
                                const Text(
                                  'I agree to the ',
                                  style: TextStyle(fontSize: 11, color: muted),
                                ),
                                GestureDetector(
                                  onTap: () => go(context, '/privacy'),
                                  child: const Text(
                                    'Terms and Services\nand Privacy Policy',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    if (!reset) const Spacer(),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      login
                          ? 'Sign In'
                          : register
                          ? 'Register'
                          : reset
                          ? 'Next'
                          : 'Reset',
                      onPressed: submit,
                    ),
                    if (login || register) ...[
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            login
                                ? 'Don’t have an account?'
                                : 'Already have an account?',
                            style: const TextStyle(color: muted, fontSize: 12),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(
                              context,
                              login ? '/register' : '/login',
                            ),
                            child: Text(
                              login ? 'Register' : 'Sign In',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (reset) const Spacer(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _social(String text, Color bg, Color fg, {IconData? icon}) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: CircleAvatar(
      radius: 32,
      backgroundColor: bg,
      child: IconButton(
        tooltip: 'Demo social sign in',
        onPressed: () {
          AppScope.of(context).signedIn = true;
          AppScope.of(context).save();
          toast(context, 'Demo social sign in');
          home(context);
        },
        icon: icon != null
            ? Icon(icon, color: fg, size: 30)
            : Text(
                text,
                style: TextStyle(
                  fontSize: 28,
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    ),
  );
}

enum CodeMode { verification, pin, confirmPin }

class CodePage extends StatefulWidget {
  final CodeMode mode;
  final String flow;
  const CodePage({super.key, required this.mode, this.flow = 'reset'});
  @override
  State<CodePage> createState() => _CodePageState();
}

class _CodePageState extends State<CodePage> {
  final controllers = List.generate(4, (_) => TextEditingController());
  final focus = List.generate(4, (_) => FocusNode());
  bool show = false;
  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    for (final f in focus) {
      f.dispose();
    }
    super.dispose();
  }

  void submit() {
    final code = controllers.map((c) => c.text).join();
    if (code.length != 4) {
      toast(context, 'Enter all four digits');
      return;
    }
    final s = AppScope.of(context);
    if (widget.mode == CodeMode.verification) {
      if (code != '1234') {
        toast(context, 'Use the demo verification code: 1234');
        return;
      }
      if (widget.flow == 'register') {
        s.signedIn = true;
        s.save();
        home(context);
      } else {
        go(context, '/new-password');
      }
    } else if (widget.mode == CodeMode.pin) {
      s.pendingPin = code;
      go(context, '/confirm-pin');
    } else {
      if (s.pendingPin != code) {
        toast(context, 'PINs do not match. Please try again.');
        return;
      }
      s.pin = code;
      s.pendingPin = null;
      toast(context, 'Demo PIN set for this session');
      Navigator.pushNamedAndRemoveUntil(context, '/profile', (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final verify = widget.mode == CodeMode.verification;
    return PageFrame(
      title: '',
      child: Column(
        children: [
          const SizedBox(height: 60),
          Text(
            verify
                ? 'Verifying Your Account'
                : widget.mode == CodeMode.pin
                ? 'Enter Your PIN'
                : 'Confirm Your PIN',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (verify) ...[
            const SizedBox(height: 12),
            Text(
              'We have just sent you a 4 digit code via\nyour email ${AppScope.of(context).email}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: muted),
            ),
          ],
          const SizedBox(height: 48),
          Row(
            children: List.generate(
              4,
              (i) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: TextField(
                    controller: controllers[i],
                    focusNode: focus[i],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    obscureText: !verify && !show,
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: pale,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) {
                      if (v.isNotEmpty && i < 3) focus[i + 1].requestFocus();
                      if (v.isEmpty && i > 0) focus[i - 1].requestFocus();
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (!verify)
            TextButton(
              onPressed: () => setState(() => show = !show),
              child: Text(
                show ? 'HIDE PIN' : 'SHOW PIN',
                style: const TextStyle(color: green, fontSize: 12),
              ),
            ),
          const SizedBox(height: 40),
          PrimaryButton('Continue', onPressed: submit),
          const SizedBox(height: 30),
          if (verify)
            TextButton(
              onPressed: () => toast(context, 'Demo code resent: 1234'),
              child: const Text('Didn’t receive code? Resend'),
            ),
          if (verify)
            const Text(
              'Demo verification code: 1234',
              style: TextStyle(color: muted, fontSize: 11),
            ),
        ],
      ),
    );
  }
}
