import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding/personal_info_screen.dart';
import 'models/user_onboarding_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    await AuthService.initialize();
    runApp(const CalistreetApp());
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF1A1A1A),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Erro de Conexão',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Erro: $e',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Tentar reinicializar
                    main();
                  },
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CalistreetApp extends StatelessWidget {
  const CalistreetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calistreet',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        primaryColor: const Color(0xFF007AFF),
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    if (user != null) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isPasswordVisible = false;
  bool _agreedToTerms = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Branding
              const Text(
                'Calistreet',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isSignUp ? 'Insira seus dados para começar.' : 'Junte-se à nossa comunidade',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 48),

              // Nome (Visível apenas em Cadastro)
              if (_isSignUp)
                _buildInputField(
                  controller: _nameController,
                  hintText: 'Seu nome completo',
                  icon: Icons.person_outline,
                ),
              if (_isSignUp) const SizedBox(height: 16),
              
              // Input Fields: Email e Senha
              _buildInputField(
                controller: _emailController,
                hintText: _isSignUp ? 'seuemail@exemplo.com' : 'E-mail',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _passwordController,
                hintText: _isSignUp ? 'Crie uma senha forte' : 'Senha',
                icon: Icons.lock_outline,
                isPassword: true,
                isPasswordVisible: _isPasswordVisible,
                onTogglePassword: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              const SizedBox(height: 32),

              // CHECKBOX: Termos (Visível apenas em Cadastro)
              if (_isSignUp)
                _buildTermsCheckbox(),
              if (_isSignUp) const SizedBox(height: 16),

              const SizedBox(height: 16),

              // Primary Action Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handlePrimaryAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isSignUp ? 'Cadastrar' : 'Entrar',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Social Login Separator
              Row(
                children: [
                  const Expanded(child: Divider(color: Colors.grey)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Ou ${_isSignUp ? 'cadastre-se' : 'entre'} com',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const Expanded(child: Divider(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 24),

              // Social Login Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildSocialButton(
                      icon: FontAwesomeIcons.google,
                      label: 'Google',
                      onPressed: _handleGoogleLogin,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSocialButton(
                      icon: FontAwesomeIcons.facebook,
                      label: 'Facebook',
                      onPressed: _handleFacebookLogin,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Toggle Login/Signup
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isSignUp ? 'Já tem uma conta?' : "Não tem uma conta?",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  TextButton(
                    onPressed: _toggleMode,
                    child: Text(
                      _isSignUp ? 'Entrar' : 'Cadastrar',
                      style: const TextStyle(
                        color: Color(0xFF007AFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String label = '',
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          ),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !isPasswordVisible,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: Icon(icon, color: Colors.grey),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: onTogglePassword,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Checkbox de termos
  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (bool? newValue) {
              setState(() {
                _agreedToTerms = newValue ?? false;
              });
            },
            activeColor: const Color(0xFF4CAF50),
            checkColor: Colors.black,
            side: const BorderSide(color: Color(0xFF404040), width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: 'Eu concordo com os ',
              style: const TextStyle(color: Colors.white, fontSize: 14),
              children: [
                TextSpan(
                  text: 'Termos de Uso',
                  style: const TextStyle(color: Color(0xFF4CAF50), decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()..onTap = () { /* TODO: Abrir Termos */ },
                ),
                const TextSpan(text: ' e ', style: TextStyle(color: Colors.white)),
                TextSpan(
                  text: 'Política de Privacidade.',
                  style: const TextStyle(color: Color(0xFF4CAF50), decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()..onTap = () { /* TODO: Abrir Política */ },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: icon == FontAwesomeIcons.google
                    ? Colors.red
                    : const Color(0xFF1877F2),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePrimaryAction() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Por favor, preencha todos os campos');
      return;
    }
    
    // Cadastro
    if (_isSignUp) {
      if (_nameController.text.isEmpty) {
        _showSnackBar('O campo Nome é obrigatório.');
        return;
      }
      if (!_agreedToTerms) {
        _showSnackBar('Você deve concordar com os Termos de Uso e Privacidade.');
        return;
      }
      
      try {
        final result = await AuthService.signUp(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
        );
        AuthService.setCurrentUser(result);
        
        _showSnackBar('Usuário criado! Iniciando Onboarding...');
        
        // Inicia o Onboarding, passando o nome para o DTO
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PersonalInfoScreen(
              onboardingData: UserOnboardingData(
                name: _nameController.text,
              ), 
            ),
          ),
        );
        
      } catch (e) {
        String errorMessage = 'Erro desconhecido';

        if (e.toString().contains('User already registered')) {
          errorMessage = 'Este email já está cadastrado';
        } else if (e.toString().contains('Password should be at least')) {
          errorMessage = 'Senha deve ter pelo menos 6 caracteres';
        } else if (e.toString().contains('Invalid email')) {
          errorMessage = 'Email inválido';
        } else {
          errorMessage = 'Erro: ${e.toString()}';
        }

        _showSnackBar(errorMessage);
      }
      return;
    }

    // Login
    try {
      final result = await AuthService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      AuthService.setCurrentUser(result);
      _showSnackBar('Bem-vindo de volta!');
      _navigateToHome();
    } catch (e) {
      String errorMessage = 'Erro desconhecido';

      if (e.toString().contains('Email ou senha incorretos')) {
        errorMessage = 'Email ou senha incorretos';
      } else {
        errorMessage = 'Erro: ${e.toString()}';
      }

      _showSnackBar(errorMessage);
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _handleGoogleLogin() {
    // TODO: Implementar Google authentication
    print('Google login');
  }

  void _handleFacebookLogin() {
    // TODO: Implementar Facebook authentication
    print('Facebook login');
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1877F2),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
