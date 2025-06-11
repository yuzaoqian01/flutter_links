import 'package:flutter/material.dart';

enum FieldDirection {
  row,
  column,
}

class FieldCell extends StatefulWidget {
  final FieldDirection direction;
  final String? labelText;
  final Widget? prefixIcon;
  final bool required;
  final double spacing;
  final TextStyle? labelStyle;
  final double? labelWidth;
  final String? errorText;
  final Widget? suffixIcon;
  
  // 输入框相关属性
  final TextEditingController? controller;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextStyle? inputStyle;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool showClearButton;
  // 自定义输入区域
  final Widget? child;

  const FieldCell({
    super.key,
    this.direction = FieldDirection.row,
    this.labelText,
    this.prefixIcon,
    this.required = false,
    this.spacing = 16.0,
    this.labelStyle,
    this.labelWidth,
    this.errorText,
    this.suffixIcon,
    this.controller,
    this.hintText,
    this.hintStyle,
    this.inputStyle,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.onChanged,
    this.validator,
    this.showClearButton = true,
    this.child,
  });

  @override
  State<FieldCell> createState() => _FieldCellState();
}

class _FieldCellState extends State<FieldCell> {
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _updateClearButtonState();
    widget.controller?.addListener(_updateClearButtonState);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_updateClearButtonState);
    super.dispose();
  }

  void _updateClearButtonState() {
    final shouldShow = widget.showClearButton && 
                      widget.controller != null && 
                      widget.controller!.text.isNotEmpty &&
                      widget.enabled &&
                      !widget.obscureText;
    
    if (_showClearButton != shouldShow) {
      setState(() {
        _showClearButton = shouldShow;
      });
    }
  }

  void _handleClear() {
    if (widget.controller != null) {
      widget.controller!.clear();
      widget.onChanged?.call('');
    }
  }

  Widget _buildLabel() {
    if (widget.labelText == null) return const SizedBox.shrink();
    
    const defaultLabelStyle = TextStyle(
      fontSize: 16,
      color: Color.fromRGBO(0, 0, 0, 0.9),
    );

    final labelStyle = widget.labelStyle != null
        ? defaultLabelStyle.copyWith(
            fontSize: widget.labelStyle!.fontSize ?? 16,
            color: widget.labelStyle!.color ?? const Color.fromRGBO(0, 0, 0, 0.9),
            fontWeight: widget.labelStyle!.fontWeight,
            letterSpacing: widget.labelStyle!.letterSpacing,
            height: widget.labelStyle!.height,
          )
        : defaultLabelStyle;
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (widget.required)
          const Positioned(
            left: -8,
            top: -4,
            child: Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Text(
          widget.labelText!,
          style: labelStyle,
        ),
      ],
    );
  }

  Widget _buildLabelArea() {
    if (widget.labelText != null) {
      return widget.labelWidth != null
          ? SizedBox(
              width: widget.labelWidth,
              child: _buildLabel(),
            )
          : _buildLabel();
    } else if (widget.prefixIcon != null) {
      return widget.prefixIcon!;
    }
    return const SizedBox.shrink();
  }

  Widget buildInputArea() {
    // 如果提供了自定义child，则使用child
    if (widget.child != null) {
      return Row(
        children: [
          Expanded(child: widget.child!),
          if (widget.suffixIcon != null) ...[
            const SizedBox(width: 8),
            widget.suffixIcon!,
          ],
        ],
      );
    }

    // 否则使用默认的输入框
    return Row(
      children: [
        Expanded(child: inputWidget),
        if (_showClearButton)
          GestureDetector(
            onTap: _handleClear,
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.clear,
                size: 20,
                color: Colors.grey,
              ),
            ),
          ),
        if (widget.suffixIcon != null) ...[
          const SizedBox(width: 8),
          widget.suffixIcon!,
        ],
      ],
    );
  }

  late final inputWidget = TextFormField(
    controller: widget.controller,
    style: widget.inputStyle != null
        ? const TextStyle(fontSize: 16).copyWith(
            fontSize: widget.inputStyle!.fontSize ?? 16,
            color: widget.inputStyle!.color,
            fontWeight: widget.inputStyle!.fontWeight,
            letterSpacing: widget.inputStyle!.letterSpacing,
            height: widget.inputStyle!.height,
          )
        : const TextStyle(fontSize: 16),
    decoration: InputDecoration(
      hintText: widget.hintText,
      hintStyle: widget.hintStyle != null 
          ? const TextStyle(fontSize: 15, color: Colors.grey).copyWith(
              fontSize: widget.hintStyle!.fontSize ?? 15,
              color: widget.hintStyle!.color ?? Colors.grey,
              fontWeight: widget.hintStyle!.fontWeight,
              letterSpacing: widget.hintStyle!.letterSpacing,
              height: widget.hintStyle!.height,
            )
          : const TextStyle(fontSize: 15, color: Colors.grey),
      border: InputBorder.none,
      contentPadding: EdgeInsets.zero,
      isDense: true,
      counterText: '',
    ),
    obscureText: widget.obscureText,
    keyboardType: widget.keyboardType,
    maxLines: widget.maxLines,
    maxLength: widget.maxLength,
    enabled: widget.enabled,
    onChanged: (value) {
      widget.onChanged?.call(value);
      _updateClearButtonState();
    },
    validator: widget.validator,
  );

  @override
  Widget build(BuildContext context) {
    final labelWidget = _buildLabelArea();
    final hasLabel = widget.labelText != null || widget.prefixIcon != null;

    final contentWidgets = <Widget>[
      if (hasLabel) ...[
        labelWidget,
        SizedBox(
          width: widget.direction == FieldDirection.row ? widget.spacing : 0,
          height: widget.direction == FieldDirection.column ? widget.spacing : 0,
        ),
      ],
      widget.direction == FieldDirection.row
          ? Expanded(child: buildInputArea())
          : buildInputArea(),
    ];

    Widget content = widget.direction == FieldDirection.row
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: contentWidgets,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: contentWidgets,
          );

    if (widget.errorText != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          content,
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: widget.spacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: content,
    );
  }
}