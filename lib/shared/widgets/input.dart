// ignore_for_file: prefer_const_constructors, constant_identifier_names, annotate_overrides, overridden_fields, use_key_in_widget_constructors, must_be_immutable

import 'package:idile_mobile_app/shared/widgets/app_buttons.dart';
import 'package:idile_mobile_app/core/utils/package_export.dart';
import 'package:idile_mobile_app/core/utils/size_config.dart';
import 'package:idile_mobile_app/core/theme/colors.dart';
import 'package:idile_mobile_app/shared/widgets/app_text.dart';

class GlobalTextField extends StatefulWidget {
  final String fieldName;
  final TextInputType keyBoardType;
  final FocusNode? focusNode;
  final TextEditingController textController;
  final int maxLength;
  final bool isCenterText;
  final bool isEyeVisible;
  final bool removeSpace;
  final bool obscureText;
  final bool isOptional;
  final Function(String?)? onChanged;
  final bool readOnly;
  final double? borderRadius;
  final VoidCallback? onTap;
  final Widget? prefix;
  final Widget? prefixIcon;
  final Widget? suffix;
  final bool isNotePad;
  final String? confirmPasswordMatch;
  final String? Function(String?)? validator;
  final Color? fillColor;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;
  final bool autofocus;
  final TextCapitalization? textCapitalization;

  const GlobalTextField({
    super.key,
    required this.fieldName,
    required this.keyBoardType,
    required this.textController,
    this.focusNode,
    this.removeSpace = true,
    this.obscureText = false,
    this.isCenterText = false,
    this.isEyeVisible = false,
    this.isOptional = false,
    this.readOnly = false,
    this.onChanged,
    this.maxLength = 19935,
    this.borderRadius,
    this.onTap,
    this.prefix,
    this.prefixIcon,
    this.suffix,
    this.isNotePad = false,
    this.confirmPasswordMatch,
    this.validator,
    this.fillColor,
    this.textInputAction,
    this.autofillHints,
    this.onFieldSubmitted,
    this.autofocus = false,
    this.textCapitalization,
  });

  @override
  State<GlobalTextField> createState() => _GlobalTextFieldState();
}

class _GlobalTextFieldState extends State<GlobalTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.onSurface;
    final muted = theme.brightness == Brightness.dark
        ? Colors.white60
        : AppColors.muted;
    final fieldColor =
        widget.fillColor ??
        (theme.brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.white);
    final borderColor = theme.brightness == Brightness.dark
        ? Colors.white24
        : AppColors.line;
    final radius = widget.borderRadius ?? 12;
    return TextFormField(
      controller: widget.textController,
      keyboardType: widget.keyBoardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      autofocus: widget.autofocus,
      obscureText: _isObscured,
      focusNode: widget.focusNode,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      enabled: true,
      maxLines: widget.isNotePad ? 10 : 1,
      minLines: widget.isNotePad
          ? widget.maxLength <= 100
                ? 3
                : 6
          : 1,
      enableInteractiveSelection: widget.readOnly == true
          ? false
          : true, // prevents long press/double tap menu
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textAlign: widget.isCenterText ? TextAlign.center : TextAlign.start,
      textCapitalization:
          widget.textCapitalization ??
          (widget.keyBoardType == TextInputType.name
              ? TextCapitalization.sentences
              : TextCapitalization.none),
      inputFormatters: _buildInputFormatters(),
      cursorColor: AppColors.signal,
      style: TextStyle(
        color: foreground,
        fontFamily: "Mulish",
        fontSize: 12.textSize,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelText: widget.fieldName,
        labelStyle: TextStyle(
          color: muted,
          fontFamily: "Mulish",
          fontSize: 12.textSize,
          fontWeight: FontWeight.w400,
        ),
        isDense: true,
        filled: true,
        fillColor: fieldColor,
        prefixIconColor: muted,
        suffixIconColor: muted,
        //  prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        suffixIcon: widget.isEyeVisible
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
                icon: Icon(
                  _isObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: muted,
                  size: 25,
                ),
              )
            : widget.suffix,
        prefix: widget.prefix,
        prefixIcon: widget.prefixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: borderColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.signal, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
        errorStyle: TextStyle(
          color: theme.colorScheme.error,
          fontSize: 10,
          height: 1.1,
        ),
      ),
      validator: widget.validator ?? (value) => _validateField(value),
    );
  }

  List<TextInputFormatter> _buildInputFormatters() {
    List<TextInputFormatter> formatters = [];

    if (widget.removeSpace) {
      formatters.add(FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s")));
    }

    if (widget.keyBoardType == TextInputType.phone) {
      formatters.add(FilteringTextInputFormatter.deny(RegExp(r'^0+')));
    }

    if (widget.keyBoardType == TextInputType.number) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    }

    formatters.add(LengthLimitingTextInputFormatter(widget.maxLength));

    return formatters;
  }

  String? _validateField(String? value) {
    if (widget.isOptional && (value == null || value.isEmpty)) {
      return null;
    }

    if (value == null || value.isEmpty) {
      return 'This input is empty';
    }

    if (widget.obscureText) {
      final passwordRegex = RegExp(
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$',
      );
      if (!passwordRegex.hasMatch(value)) {
        return 'Password must contain uppercase, lowercase, and number';
      }
      // Confirm password match check (only for confirm password field)
      if (widget.confirmPasswordMatch != null &&
          value != widget.confirmPasswordMatch) {
        return 'Passwords do not match';
      }
    }

    if (widget.keyBoardType == TextInputType.emailAddress) {
      String trimmed = value.trim();
      if (!EmailValidator.validate(trimmed)) {
        return 'Not a valid email';
      }
    }

    if (widget.keyBoardType == TextInputType.phone && value.length != 10) {
      return 'Phone number must be 10 digits';
    }

    if (widget.keyBoardType == TextInputType.number) {
      final numberOnlyRegex = RegExp(r'^\d+$');
      if (!numberOnlyRegex.hasMatch(value)) {
        return 'Only digits are allowed. No special characters.';
      }
    }

    return null;
  }
}

// Phone Number Input with Country Code Dropdown

class GlobalPhoneTextField extends StatefulWidget {
  final String fieldName;
  final TextEditingController textController;
  final int maxLength;
  final FocusNode? focusNode;
  final Function(MobileNumber?)? onChanged;
  final Function(Country?)? onCountryChanged;
  final bool isOptional;
  final Color? fillColor;
  final double? borderRadius;

  const GlobalPhoneTextField({
    super.key,
    required this.fieldName,
    required this.textController,
    this.maxLength = 35,
    this.focusNode,
    this.onChanged,
    this.onCountryChanged,
    this.isOptional = false,
    this.fillColor,
    this.borderRadius,
  });

  @override
  State<GlobalPhoneTextField> createState() => _GlobalPhoneTextFieldState();
}

class _GlobalPhoneTextFieldState extends State<GlobalPhoneTextField> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final foreground = colors.onSurface;
    final muted = colors.onSurfaceVariant;
    final fieldColor =
        widget.fillColor ??
        (isDark ? AppColors.surfaceDark : AppColors.white);
    final borderColor = isDark ? Colors.white24 : AppColors.line;
    final radius = widget.borderRadius ?? 14;
    return IntlMobileField(
      controller: widget.textController,
      initialCountryCode: "NG",
      focusNode: widget.focusNode,
      onCountryChanged: widget.onCountryChanged,
      onChanged: widget.onChanged,
      enabled: true,
      disableLengthCounter: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textAlign: TextAlign.start,
      style: TextStyle(
        color: foreground,
        fontFamily: "Mulish",
        fontSize: 12.textSize,
        fontWeight: FontWeight.w400,
      ),
      inputFormatters: [LengthLimitingTextInputFormatter(widget.maxLength)],
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelText: widget.fieldName,
        labelStyle: TextStyle(
          color: muted,
          fontFamily: "Mulish",
          fontSize: 12.textSize,
          fontWeight: FontWeight.w400,
        ),
        isDense: true,
        filled: true,
        fillColor: fieldColor,
        //  prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
        contentPadding: EdgeInsets.symmetric(
          vertical: 2.heightAdjusted,
          horizontal: 2.widthAdjusted,
        ),
        suffixIcon: Icon(Icons.contacts, color: muted, size: 15),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: borderColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: colors.error),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.signal, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        errorStyle: TextStyle(
          color: colors.error,
          fontSize: 10,
          height: 1.1,
        ),
      ),
      validator: (mobileNumber) {
        if (widget.isOptional &&
            (mobileNumber == null || mobileNumber.number.isEmpty)) {
          return null;
        }
        if (mobileNumber == null || mobileNumber.number.isEmpty) {
          return 'Please, Enter a mobile number';
        }
        if (!RegExp(r'^[0-9]+$').hasMatch(mobileNumber.number)) {
          return 'Only digits are allowed';
        }
        return null;
      },
    );
  }
}

class SearchableDropdownOption<T> {
  final T value;
  final String label;

  const SearchableDropdownOption({required this.value, required this.label});
}

/// Project-wide searchable dropdown field.
///
/// The user sees an option's [SearchableDropdownOption.label], while
/// [onChanged] receives its typed [SearchableDropdownOption.value]. This lets
/// API-backed forms display a person's name while submitting their id.
class GlobalSearchableDropdown<T> extends StatelessWidget {
  final String title;
  final String hintText;
  final T? value;
  final List<SearchableDropdownOption<T>> options;
  final ValueChanged<T> onChanged;
  final bool showSearch;
  final bool enabled;
  final String emptyMessage;

  const GlobalSearchableDropdown({
    super.key,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
    this.hintText = 'Choose',
    this.showSearch = true,
    this.enabled = true,
    this.emptyMessage = 'No options are currently available.',
  });

  Future<void> _open(BuildContext context) async {
    final selectedLabel = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomDropdownBottomSheet(
        title: title,
        options: [for (final option in options) option.label],
        showSearch: showSearch,
        emptyMessage: emptyMessage,
      ),
    );
    if (selectedLabel == null) return;

    final selected = options.firstWhere(
      (option) => option.label == selectedLabel,
    );
    onChanged(selected.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.onSurface;
    final muted = theme.brightness == Brightness.dark
        ? Colors.white60
        : AppColors.muted;
    final fieldColor = theme.brightness == Brightness.dark
        ? AppColors.surfaceDark
        : AppColors.white;
    final borderColor = theme.brightness == Brightness.dark
        ? Colors.white24
        : AppColors.line;
    SearchableDropdownOption<T>? selected;
    for (final option in options) {
      if (option.value == value) {
        selected = option;
        break;
      }
    }

    return Semantics(
      button: true,
      enabled: enabled,
      label: '$title. Searchable dropdown.',
      child: Opacity(
        opacity: enabled ? 1 : .55,
        child: Material(
          color: fieldColor,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: enabled ? () => _open(context) : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  if (showSearch) ...[
                    Icon(Icons.search, size: 21, color: muted),
                    addHorizontalSpacing(2.56),
                  ],
                  Expanded(
                    child: AppText(
                      text: selected?.label ?? hintText,
                      type: AppTextType.bodySmall,
                      color: selected == null ? muted : foreground,
                      fontFamily: 'Mulish',
                      fontSize: 12.textSize,
                      fontWeight: FontWeight.w400,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  addHorizontalSpacing(2.05),
                  Icon(Icons.keyboard_arrow_down_rounded, color: muted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomDropdownBottomSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final bool showSearch;
  final String emptyMessage;

  const CustomDropdownBottomSheet({
    super.key,
    required this.title,
    required this.options,
    this.showSearch = false,
    this.emptyMessage = 'No options are currently available.',
  });

  @override
  State<CustomDropdownBottomSheet> createState() =>
      _CustomDropdownBottomSheetState();
}

class _CustomDropdownBottomSheetState extends State<CustomDropdownBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  late List<String> _filteredOptions;

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredOptions = widget.options
            .where((item) => item.toLowerCase().contains(query))
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.onSurface;
    final muted = theme.brightness == Brightness.dark
        ? Colors.white60
        : AppColors.muted;
    final surface = theme.brightness == Brightness.dark
        ? AppColors.surfaceDark
        : AppColors.white;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: 50.heightAdjusted,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title + Close Icon
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AppText(
                        text: widget.title,
                        type: AppTextType.bodySmall,
                        fontSize: 12.textSize,
                        color: foreground,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Source Sans 3',
                      ),
                    ),
                    IconButton(
                      color: foreground,
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Optional Search Field
              if (widget.showSearch && widget.options.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GlobalTextField(
                    fieldName: 'Search...',
                    keyBoardType: TextInputType.text,
                    textController: _searchController,
                    isOptional: true,
                    removeSpace: false,
                    maxLength: 100,
                    borderRadius: 12,
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),

              // Options
              Flexible(
                child: _filteredOptions.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people_outline_rounded,
                                color: muted,
                                size: 32,
                              ),
                              addVerticalSpacing(1.18),
                              AppText(
                                text: widget.options.isEmpty
                                    ? widget.emptyMessage
                                    : 'No matching results.',
                                type: AppTextType.bodySmall,
                                color: muted,
                                fontWeight: FontWeight.w600,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: _filteredOptions.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (_, index) {
                          final item = _filteredOptions[index];
                          return Material(
                            color: surface,
                            child: ListTile(
                              title: AppText(
                                text: item,
                                type: AppTextType.bodySmall,
                                fontSize: 12.textSize,
                                color: foreground,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Source Sans 3',
                              ),
                              onTap: () => Navigator.pop(context, item),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomMultipleDropdownBottomSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final bool showSearch;

  /// Values that should already be selected when opening
  final List<String> initialSelected;

  const CustomMultipleDropdownBottomSheet({
    super.key,
    required this.title,
    required this.options,
    this.showSearch = false,
    this.initialSelected = const [],
  });

  @override
  State<CustomMultipleDropdownBottomSheet> createState() =>
      _CustomMultipleDropdownBottomSheetState();
}

class _CustomMultipleDropdownBottomSheetState
    extends State<CustomMultipleDropdownBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  late List<String> _filteredOptions;

  /// Stores user selections
  late Set<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
    _selectedItems = widget.initialSelected
        .toSet(); // 👈 start with pre-selected

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredOptions = widget.options
            .where((item) => item.toLowerCase().contains(query))
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmSelection() {
    Navigator.pop(context, _selectedItems.toList());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: 0),
      child: Container(
        height: 80.heightAdjusted,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Title + Close Icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: AppText(
                      isBody: false,
                      text: widget.title,
                      textAlign: TextAlign.start,
                      fontSize: 15,
                      color: colors.onSurface,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppButton(
                    text: "Done",
                    onPressed: _confirmSelection,
                    widthPercent: 20,
                    heightPercent: 4,
                    isGradient: true,
                    btnColor: AppColors.primary,
                    isLoading: false,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: colors.onSurfaceVariant,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Optional Search
            if (widget.showSearch)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: GlobalTextField(
                  fieldName: 'Search...',
                  keyBoardType: TextInputType.text,
                  textController: _searchController,
                  prefixIcon: const Icon(Icons.search),
                  borderRadius: 12,
                  removeSpace: false,
                  isOptional: true,
                ),
              ),

            // List with checkboxes
            Expanded(
              child: ListView.separated(
                itemCount: _filteredOptions.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final item = _filteredOptions[index];
                  final isSelected = _selectedItems.contains(item);

                  return CheckboxListTile(
                    value: isSelected,
                    title: AppText(
                      isBody: false,
                      text: item,
                      textAlign: TextAlign.start,
                      fontSize: 12,
                      color: colors.onSurface,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w400,
                    ),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedItems.add(item);
                        } else {
                          _selectedItems.remove(item);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
