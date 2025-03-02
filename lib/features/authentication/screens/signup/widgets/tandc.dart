import 'package:flutter/material.dart';
import 'package:t_store/utils/constants/colors.dart';
import 'package:t_store/utils/constants/sizes.dart';
import 'package:t_store/utils/constants/text_strings.dart';
import 'package:t_store/utils/helpers/helper_functions.dart';

class TTandC extends StatelessWidget {
  final Function(bool) onChanged;

  const TTandC({
    super.key,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dark= THelperFunctions.isDarkMode(context);
    return Row(
      children: [
        SizedBox(width: 24, height: 24, child: Checkbox(
          value: false,
          onChanged: (value) => onChanged(value ?? false),
        )),
        const SizedBox(width: TSizes.spaceBtwItems),
        Text.rich(
          TextSpan(children: [
            TextSpan(text: '${TTexts.iAgreeTo} ', style: Theme.of(context).textTheme.bodySmall),
            TextSpan(text: '${TTexts.privacyPolicy} ', style: Theme.of(context).textTheme.bodyMedium!.apply(
              color: dark ? TColors.white :TColors.primary,
              decoration: TextDecoration.underline,
              decorationColor: dark ? TColors.white : TColors.primary,)),
        
        TextSpan (text: '${TTexts.and} ', style: Theme.of(context).textTheme.bodySmall),
        
        TextSpan(text: TTexts.termsOfUse, style: Theme.of(context).textTheme.bodyMedium!.apply(
              color: dark ? TColors.white :TColors.primary,
              decoration: TextDecoration.underline,
              decorationColor: dark ? TColors.white : TColors.primary,)),
        
          ]),
        )
          ],
          );
  }
}

