import 'package:flutter/material.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _fullNameController = TextEditingController();
  final _universityController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  static const Color primaryPurple = Color(0xFFA17CFF);
  static const Color darkBackground = Color(0xFF13131A); 
  static const Color inputFieldColor = Colors.white;
  static const Color inputTextColor = Colors.black87;
  static const Color labelColor = Colors.white;

  @override
  void dispose() {
    
    _fullNameController.dispose();
    _universityController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      body: Container(
        
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8E6AFF), 
              darkBackground,    
            ],
            stops: [0.0, 0.4], 
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
              
                const Icon(
                  Icons.swap_calls_rounded, 
                  size: 80,
                  color: labelColor,
                ),
                const SizedBox(height: 15),
                
              
                const Text(
                  'Join SkillSwap',
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Start learning and teaching today',
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),

                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05), 
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      
                      _buildInputField(
                        label: 'Full Name',
                        hint: 'Your Full Name',
                        icon: Icons.person_outline,
                        controller: _fullNameController,
                      ),
                      const SizedBox(height: 15),

                      
                      _buildInputField(
                        label: 'University',
                        hint: 'Your University Name',
                        icon: Icons.school_outlined,
                        controller: _universityController,
                      ),
                      const SizedBox(height: 15),

                      
                      _buildInputField(
                        label: 'Email',
                        hint: 'your.Email@gmail.com',
                        icon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 15),

                      
                      _buildInputField(
                        label: 'Password',
                        hint: 'Enter your password',
                        icon: Icons.lock_outline,
                        controller: _passwordController,
                        isObscure: true, 
                      ),
                      const SizedBox(height: 15),

                      
                      _buildInputField(
                        label: 'Confirm Password',
                        hint: 'Re-enter your password',
                        icon: Icons.lock_outline,
                        controller: _confirmPasswordController,
                        isObscure: true,
                      ),
                      const SizedBox(height: 30),

                     
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            
                            print("Create Account Pressed");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryPurple,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Create account',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Already have an account?',
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                  ],
                ),

                const SizedBox(height: 20),

               
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () {
                   
                      print("Sign In Pressed");
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: primaryPurple, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30), 
              ],
            ),
          ),
        ),
      ),
    );
  }

  
  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isObscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       
        Text(
          label,
          style: const TextStyle(
            color: labelColor,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
       
        Container(
          decoration: BoxDecoration(
            color: inputFieldColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isObscure,
            keyboardType: keyboardType,
            style: const TextStyle(color: inputTextColor),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey[700], size: 20),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none, 
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: primaryPurple, width: 2), 
              ),
            ),
          ),
        ),
      ],
    );
  }
}