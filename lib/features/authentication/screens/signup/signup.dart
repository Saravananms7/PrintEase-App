import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:t_store/common/styles/spacing_styles.dart';
import 'package:t_store/common/widgets/success_screen/success_screen.dart';
import 'package:t_store/features/authentication/screens/login/login.dart';
import 'package:t_store/utils/constants/image_strings.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/constants/text_strings.dart';
import 'package:t_store/utils/helpers/helper_functions.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                TTexts.signupTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Form
              const TSignupForm(),
              const SizedBox(height: TSizes.spaceBtwSections),
            ],
          ),
        ),
      ),
    );
  }
}

class TSignupForm extends StatefulWidget {
  const TSignupForm({super.key});

  @override
  State<TSignupForm> createState() => _TSignupFormState();
}

class _TSignupFormState extends State<TSignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _termsAccepted = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms and conditions')),
      );
      return;
    }

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {
          'full_name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
        },
      );

      if (response.user != null) {
        Get.to(() => const VerifyMailScreen());
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Name Field
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: TTexts.firstName,
              prefixIcon: Icon(Iconsax.user),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          // Email Field
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: TTexts.email,
              prefixIcon: Icon(Iconsax.direct),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.endsWith('@mgits.ac.in')) {
                return 'Please use your MGITS email (@mgits.ac.in)';
              }
              if (!RegExp(r'^[\w-\.]+@mgits\.ac\.in$').hasMatch(value)) {
                return 'Please enter a valid MGITS email';
              }
              return null;
            },
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          // Phone Number Field
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: TTexts.phoneNo,
              prefixIcon: Icon(Iconsax.call),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscureText,
            decoration: InputDecoration(
              labelText: TTexts.password,
              prefixIcon: const Icon(Iconsax.password_check),
              suffixIcon: IconButton(
                icon: Icon(_obscureText ? Iconsax.eye_slash : Iconsax.eye),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: TSizes.spaceBtwSections),

          // Terms and Conditions
          Row(
            children: [
              Checkbox(
                value: _termsAccepted,
                onChanged: (value) {
                  setState(() {
                    _termsAccepted = value ?? false;
                  });
                },
              ),
              const SizedBox(width: TSizes.spaceBtwItems),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${TTexts.iAgreeTo} ',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      TextSpan(
                        text: TTexts.privacyPolicy,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                      TextSpan(
                        text: ' ${TTexts.and} ',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      TextSpan(
                        text: TTexts.termsOfUse,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwSections),

          // Signup Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _termsAccepted ? _signUp : null,
              child: const Text(TTexts.createAccount),
            ),
          ),
        ],
      ),
    );
  }
}

class VerifyMailScreen extends StatefulWidget {
  const VerifyMailScreen({super.key});

  @override
  State<VerifyMailScreen> createState() => _VerifyMailScreenState();
}

class _VerifyMailScreenState extends State<VerifyMailScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  bool _isVerifying = false;

  String get _otpValue => _otpControllers.map((e) => e.text).join();

  Future<void> _verifyOTP() async {
    if (_otpValue.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter complete OTP')),
      );
      return;
    }

    setState(() => _isVerifying = true);
    try {
      final email = Supabase.instance.client.auth.currentUser?.email;
      if (email == null) {
        throw Exception('No email found');
      }

      final response = await Supabase.instance.client.auth.verifyOTP(
        token: _otpValue,
        type: OtpType.signup,
        email: email,
      );

      if (mounted) {
        if (response.session != null) {
          Get.offAll(() => SuccessScreen(
            image: TImages.staticSuccessIllustration,
            title: TTexts.yourAccountCreatedTitle,
            subtitle: TTexts.yourAccountCreatedSubTitle,
            onPressed: () => Get.offAll(() => const LoginScreen()),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid OTP. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? 'your email';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Supabase.instance.client.auth.signOut();
              Get.offAll(() => const LoginScreen());
            },
            icon: const Icon(CupertinoIcons.clear),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              // Image
              Image(
                image: const AssetImage(TImages.deliveredEmailIllustration),
                width: THelperFunctions.screenWidth() * 0.6,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Title and Subtitle
              Text(
                'Enter OTP',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                'Please enter the OTP sent to:',
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                email,
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // OTP Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 50,
                    child: TextFormField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      decoration: const InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        if (value.length == 1 && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        }
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              // Verify Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOTP,
                  child: _isVerifying 
                    ? const CircularProgressIndicator()
                    : const Text('Verify OTP'),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              // Resend OTP Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    try {
                      final email = Supabase.instance.client.auth.currentUser?.email;
                      if (email == null) throw Exception('No email found');
                      
                      await Supabase.instance.client.auth.resend(
                        type: OtpType.signup,
                        email: email,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('OTP resent successfully')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to resend OTP: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  child: const Text('Resend OTP'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}