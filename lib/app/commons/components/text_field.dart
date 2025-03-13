import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';

class MyTextField extends StatefulWidget {
  const MyTextField({
    Key? key,
    this.fieldKey,
    required this.controller,
    this.phoneIndicatifController,
    this.hintText = '',
    this.labelText = '',
    this.isPassword = false,
    this.maskInputs,
    this.keyboardType,
    this.maxLength,
    this.counterText = '',
    this.maxLines = 1,
    this.inputTextSize = TextSizes.fourteen,
    this.prefixIcon,
    this.prefixIconColor,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.errorText = '',
    this.height = 45,
    this.textCapitalization = TextCapitalization.words,
    this.onSaved,
    this.validator,
    this.onChanged,
    this.afterDateNow = false,
    this.isDate = false,
    this.isPhone = false,
    this.filled = true,
    this.focusNode,
  }) : super(key: key);

  final Key? fieldKey;
  final TextEditingController controller;
  final TextEditingController? phoneIndicatifController;
  final String hintText;
  final String labelText;
  final List<TextInputFormatter>? maskInputs;
  final TextInputType? keyboardType;
  final int? maxLength;
  final String? counterText;
  final int maxLines;
  final double inputTextSize;
  final bool isPassword;
  final bool isDate;
  final bool isPhone;
  final String? prefixIcon;
  final Color? prefixIconColor;
  final String? suffixIcon;
  final String? errorText;
  final bool enabled;
  final bool readOnly;
  final TextCapitalization textCapitalization;
  final double? height;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool afterDateNow;
  final bool filled;
  final FocusNode? focusNode;

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  get fieldKey => widget.fieldKey;

  get controller => widget.controller;

  get hintText => widget.hintText;

  get labelText => widget.labelText;
  get maskInputs => widget.maskInputs;
  get keyboardType => widget.keyboardType;
  get maxLength => widget.maxLength;
  get counterText => widget.counterText;
  get maxLines => widget.maxLines;
  get inputTextSize => widget.inputTextSize;

  get isPassword => widget.isPassword;
  get prefixIcon => widget.prefixIcon;
  get prefixIconColor => widget.prefixIconColor;
  get suffixIcon => widget.suffixIcon;
  get enabled => widget.enabled;
  get readOnly => widget.readOnly;
  get errorText => widget.errorText;
  get height => widget.height;
  get textCapitalization => widget.textCapitalization;
  get onSaved => widget.onSaved;
  get validator => widget.validator;
  get onChanged => widget.onChanged;
  get isDate => widget.isDate;
  get isPhone => widget.isPhone;
  get focusNode => widget.focusNode;
  get afterDateNow => widget.afterDateNow;
  get filled => widget.filled;
  get phoneIndicatifController => widget.phoneIndicatifController;

  bool _obscureText = true;

  DateTime selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          child: tf(context),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Visibility(
            visible: errorText.isNotEmpty,
            child: Text(
              errorText,
              style:
              TextStyles.montserratMedium(
                  textSize: TextSizes.twelve,
                  textColor: colorRed),
            ),
          ),
        ),
      ],
    );
  }

  Widget tf(BuildContext context) {
     if ((isDate == false && isPhone == false)) {
      return TextFormField(
        controller: controller,
        key: fieldKey,
        obscureText: isPassword ? _obscureText : false,
        keyboardAppearance: Brightness.light,
        onSaved: onSaved,
        validator: validator,
        style: TextStyles.montserratMedium(textColor: colorBlack,),
        maxLines: maxLines,
        maxLength: maxLength,
        cursorColor: colorGreen,
        inputFormatters: maskInputs,
        onChanged: onChanged,
        keyboardType: keyboardType ?? TextInputType.text,
        textCapitalization: textCapitalization,
        focusNode: focusNode,
        readOnly: readOnly,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8),
          filled: filled,
          fillColor: colorGrey3,
          border: InputBorder.none,
          counterText: counterText,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: colorBlack),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: colorGrey3),
            borderRadius: BorderRadius.circular(10),
          ),
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintText: hintText,
          labelText: labelText,
          enabled: enabled,
          hintStyle: TextStyles.montserratMedium(textSize: inputTextSize),
          labelStyle: TextStyles.montserratMedium(),
          prefixIcon: (prefixIcon != null)
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SvgPicture.asset(
                    prefixIcon,
                    color: prefixIconColor,
                  ),
                )
              : null,
          suffixIcon: !isPassword
              ? ((suffixIcon != null)
                  ? SvgPicture.asset(
                      suffixIcon,
                    )
                  : null)
              : GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  child: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: colorGreen.withValues(alpha: 0.5),
                  ),
                ),
        ),
      );
    } else if ((isPhone == true)) {
      return TextFormField(
        controller: controller,
        key: fieldKey,
        keyboardAppearance: Brightness.light,
        onSaved: onSaved,
        validator: validator,
        style: TextStyles.montserratMedium(textColor: colorBlack),
        maxLines: maxLines,
        cursorColor: colorGreen3,
        inputFormatters: maskInputs,
        onChanged: onChanged,
        keyboardType: TextInputType.phone,
        focusNode: focusNode,
        readOnly: readOnly,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8),
          filled: true,
          fillColor: colorGrey3,
          border: InputBorder.none,
          counterText: counterText,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: colorGrey3),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: colorGrey3),
            borderRadius: BorderRadius.circular(10),
          ),
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintText: hintText,
          labelText: labelText,
          enabled: enabled,
          hintStyle: TextStyles.montserratMedium(textSize: inputTextSize),
          labelStyle: TextStyles.montserratMedium(),
          suffixIcon: !isPassword
              ? ((suffixIcon != null)
                  ? SvgPicture.asset(
                      suffixIcon,
                    )
                  : null)
              : GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  child: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: colorOrangeLight,
                  ),
                ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          _selectDate(context);
        },
        child: TextFormField(
          enabled: false,
          controller: controller,
          textAlign: TextAlign.center,
          key: fieldKey,
          obscureText: isPassword ? _obscureText : false,
          keyboardAppearance: Brightness.light,
          onSaved: onSaved,
          validator: validator,
          style: TextStyles.montserratMedium(textColor: colorBlack),
          maxLines: maxLines,
          cursorColor: colorGreen3,
          focusNode: focusNode,
          readOnly: readOnly,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8),
            filled: true,
            fillColor: colorGrey3,
            border: InputBorder.none,
            counterText: counterText,
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: colorGrey3),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: colorGrey3),
              borderRadius: BorderRadius.circular(10),
            ),
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: hintText,
            labelText: labelText,
            enabled: enabled,
            hintStyle: TextStyles.montserratMedium(textSize: inputTextSize),
            labelStyle: TextStyles.montserratMedium(),
            prefixIcon: (prefixIcon != null)
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SvgPicture.asset(
                      prefixIcon,
                      color: prefixIconColor,
                    ),
                  )
                : null,
            suffixIcon: !isPassword
                ? ((suffixIcon != null)
                    ? SvgPicture.asset(
                        suffixIcon,
                      )
                    : null)
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    child: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: colorOrangeLight,
                    ),
                  ),
          ),
        ),
      );
    }
  }

  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1910),
      lastDate: afterDateNow ? DateTime(2100) : DateTime.now(),
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
        String day = selectedDate.day.toString();
        String month = selectedDate.month.toString();
        if (selectedDate.day < 10) {
          day = "0$day";
        }
        if (selectedDate.month < 10) {
          month = "0$month";
        }
        widget.controller.text = " $day/$month/${selectedDate.year}";
      });
    }
  }
}

Widget get requiredField {
  return RichText(
    text: const TextSpan(
      children: <TextSpan>[
        TextSpan(
          text: '*',
          style: TextStyle(
            color: colorGrey1,
            fontFamily: 'avenir_demi_bold',
            fontSize: 14,
          ),
        ),
        TextSpan(
          text: ' Champ obligatoire',
          style: TextStyle(
              fontSize: 14, fontFamily: 'avenir_regular', color: colorGrey1),
        ),
      ],
    ),
  );
}
