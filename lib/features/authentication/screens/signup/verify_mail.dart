/*

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:t_store/common/widgets/success_screen/success_screen.dart';
import 'package:t_store/features/authentication/screens/login/login.dart';
import 'package:t_store/utils/constants/image_strings.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/constants/text_strings.dart';
import 'package:t_store/utils/helpers/helper_functions.dart';


class VerifyMailScreen extends StatelessWidget {
  const VerifyMailScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: ()=> Get.offAll(() =>const LoginScreen()), icon: const Icon(CupertinoIcons.clear))
        ],
      ),
      body: SingleChildScrollView(

        child: Padding(
          padding:const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              //image
                Image(
                  image:const  AssetImage(TImages.deliveredEmailIllustration),
                  width: THelperFunctions.screenWidth() *0.6, 
                ),
                const SizedBox(height: TSizes.spaceBtwSections,),

                //title and subltitle
                Text(TTexts.confirmEmail, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center,),
                const SizedBox(height: TSizes.spaceBtwItems),
                Text('support@saravanan.com', style: Theme.of(context).textTheme.labelLarge, textAlign: TextAlign.center,),
                const SizedBox(height: TSizes.spaceBtwItems),
                Text(TTexts.confirmEmailSubTitle, style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center,),
                const SizedBox(height: TSizes.spaceBtwSections),

                //buttons

                SizedBox(width: double.infinity,child: ElevatedButton(onPressed: () =>Get.to(() => SuccessScreen(
                  image: TImages.staticSuccessIllustration, 
                  title: TTexts.yourAccountCreatedTitle, subtitle: TTexts.yourAccountCreatedSubTitle, 
                onPressed: () => Get.to(() => const LoginScreen()),
                )
                ), 
                child: const Text(TTexts.tContinue)),),
                const SizedBox(height: TSizes.spaceBtwItems),
                SizedBox(width: double.infinity,child: TextButton(onPressed: () {}, child: const Text(TTexts.resendEmail)),)

            ],
            )
        )
      ),
    );
  }
}

*/