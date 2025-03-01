import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/app.dart';
import 'package:t_store/features/authentication/screens/password_config/reset_pass.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/constants/text_strings.dart';

class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body:  Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            //headings
            Text(TTexts.forgetPasswordTitle, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: TSizes.spaceBtwItems),
                Text(TTexts.forgetPasswordSubTitle, style: Theme.of(context).textTheme.labelMedium,),
                const SizedBox(height: TSizes.spaceBtwSections *2),

            //Text Field
            TextFormField(
              decoration: InputDecoration(labelText: TTexts.email,prefixIcon: Icon(Iconsax.direct_right)),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            //submit button
            SizedBox(width: double.infinity,child: ElevatedButton(onPressed: () => Get.to(()=> const ResetPassword()), child: const Text(TTexts.submit))),

          ],
        ),
      ),
    );
  }
}