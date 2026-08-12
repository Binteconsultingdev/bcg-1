import 'dart:io';
import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/common/widgets/product_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class QuoteProductItem extends StatelessWidget {
  final String? imageUrl;
  final String description;
  final double unitPrice;
  final RxDouble total;
  final RxDouble quantity;
  final num availableQuantity;
  final VoidCallback onRemove;
  final void Function(double) onQuantityChanged;
  final bool readOnly;
  final double? maxQuantity;
  final RxDouble? discount;
  final VoidCallback? onDiscountTap;
  final bool allowImageEdit;
  final void Function(String path)? onImageChanged;
  final VoidCallback? onEdit;

  final VoidCallback? onEditPriceTap;
  const QuoteProductItem({
    super.key,
    this.imageUrl,
    required this.description,
    required this.unitPrice,
    required this.total,
    required this.quantity,
    required this.availableQuantity,
    required this.onRemove,
    required this.onQuantityChanged,
    this.readOnly = false,
    this.maxQuantity,
    this.discount,
    this.onDiscountTap,
    this.allowImageEdit = false,
    this.onImageChanged,
    this.onEdit,
    this.onEditPriceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingMedium,
        vertical: ThemeColor.paddingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EditableThumbnail(
                imageUrl: imageUrl,
                allowEdit: allowImageEdit,
                onImageChanged: onImageChanged,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: ThemeColor.subtitleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${unitPrice.toStringAsFixed(2)}',
                      style: ThemeColor.bodyMedium.copyWith(
                        color: ThemeColor.textSecondaryColor,
                      ),
                    ),

                    Obx(() {
                      final qty = quantity.value;
                      final sinExistencia = availableQuantity <= 0;
                      final exceedsStock =
                          !sinExistencia && qty > availableQuantity;

                      if (sinExistencia) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                size: 13,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Sin existencia',
                                style: ThemeColor.caption.copyWith(
                                  color: Colors.amber.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      if (exceedsStock) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 13,
                                color: Colors.orange.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Solo hay ${availableQuantity.toInt()} disponible(s)',
                                style: ThemeColor.caption.copyWith(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    const SizedBox(height: 8),
                    if (!readOnly)
                      _QuantityControls(
                        quantity: quantity,
                        onChanged: onQuantityChanged,
                        maxQuantity: maxQuantity,
                      )
                    else
                      Obx(
                        () => Text(
                          'Cant: ${quantity.value % 1 == 0 ? quantity.value.toInt() : quantity.value}',
                          style: ThemeColor.bodySmall.copyWith(
                            color: ThemeColor.textSecondaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!readOnly)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onEdit != null)
                          GestureDetector(
                            onTap: onEdit,
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.edit_outlined,
                                color: ThemeColor.primaryColor,
                                size: 20,
                              ),
                            ),
                          ),
                        GestureDetector(
                          onTap: onRemove,
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.delete_outline,
                              color: ThemeColor.errorColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: readOnly ? 0 : 14),
                  Obx(
                    () => Text(
                      '\$${total.value.toStringAsFixed(2)}',
                      style: ThemeColor.subtitleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (discount != null)
                    Obx(
                      () => discount!.value > 0
                          ? Text(
                              '-\$${(unitPrice * quantity.value * discount!.value / 100).toStringAsFixed(2)}',
                              style: ThemeColor.caption.copyWith(
                                color: ThemeColor.errorColor,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
            ],
          ),

          if (!readOnly && discount != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (onDiscountTap != null)
                  Obx(
                    () => GestureDetector(
                      onTap: onDiscountTap,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: discount!.value > 0
                              ? ThemeColor.errorColor.withOpacity(0.08)
                              : ThemeColor.successColor.withOpacity(0.03),
                          borderRadius: ThemeColor.circularBorderRadius,
                          border: Border.all(
                            color: discount!.value > 0
                                ? ThemeColor.errorColor.withOpacity(0.35)
                                : ThemeColor.successColor,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_offer_outlined,
                              size: 12,
                              color: discount!.value > 0
                                  ? ThemeColor.errorColor
                                  : ThemeColor.textSecondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              discount!.value > 0
                                  ? '${discount!.value.toStringAsFixed(0)}% desc.'
                                  : 'Agregar descuento',
                              style: ThemeColor.caption.copyWith(
                                color: discount!.value > 0
                                    ? ThemeColor.errorColor
                                    : ThemeColor.textSecondaryColor,
                                fontWeight: discount!.value > 0
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (onEditPriceTap != null)
                  GestureDetector(
                    onTap: onEditPriceTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeColor.infoColor.withOpacity(0.03),
                        borderRadius: ThemeColor.circularBorderRadius,
                        border: Border.all(color: ThemeColor.infoColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.price_change_outlined,
                            size: 12,
                            color: ThemeColor.textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Editar Precio',
                            style: ThemeColor.caption.copyWith(
                              color: ThemeColor.textSecondaryColor,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _EditableThumbnail extends StatefulWidget {
  final String? imageUrl;
  final bool allowEdit;
  final void Function(String path)? onImageChanged;

  const _EditableThumbnail({
    this.imageUrl,
    required this.allowEdit,
    this.onImageChanged,
  });

  @override
  State<_EditableThumbnail> createState() => _EditableThumbnailState();
}

class _EditableThumbnailState extends State<_EditableThumbnail> {
  String? _localPath;

  Future<void> _takePhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (picked == null) return;
    setState(() => _localPath = picked.path);
    widget.onImageChanged?.call(picked.path);
    debugPrint('Imagen seleccionada: ${picked.path}');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.allowEdit ? _takePhoto : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ProductThumbnail(
            imageUrl: widget.imageUrl,
            size: 54,
            localPath: _localPath,
          ),
          if (widget.allowEdit)
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: ThemeColor.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ThemeColor.surfaceColor,
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 11,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuantityControls extends StatefulWidget {
  final RxDouble quantity;
  final void Function(double) onChanged;
  final double? maxQuantity;

  const _QuantityControls({
    required this.quantity,
    required this.onChanged,
    this.maxQuantity,
  });

  @override
  State<_QuantityControls> createState() => _QuantityControlsState();
}

class _QuantityControlsState extends State<_QuantityControls> {
  late final TextEditingController _textCtrl;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(text: widget.quantity.value.toString());
    ever(widget.quantity, (val) {
      final newText = val.toString();
      if (_textCtrl.text != newText) {
        _textCtrl.text = newText;
        _textCtrl.selection = TextSelection.fromPosition(
          TextPosition(offset: newText.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final qty = widget.quantity.value;
      final max = widget.maxQuantity;
      final atMax = max != null && qty >= max;

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(
            Icons.remove,
            qty > 1 ? () => widget.onChanged(qty - 1) : null,
            color: ThemeColor.backgroundColor,
          ),
          SizedBox(
            width: 44,
            height: 28,
            child: TextField(
              controller: _textCtrl,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: ThemeColor.bodyMedium,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                filled: true,
                fillColor: ThemeColor.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: ThemeColor.smallBorderRadius,
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: ThemeColor.smallBorderRadius,
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: ThemeColor.smallBorderRadius,
                  borderSide: const BorderSide(
                    color: ThemeColor.accentColor,
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (v) {
                final parsed = double.tryParse(v);
                if (parsed != null && parsed > 0) {
                  if (max == null || parsed <= max) {
                    widget.onChanged(parsed);
                  } else {
                    final maxText = max % 1 == 0
                        ? max.toInt().toString()
                        : max.toString();
                    _textCtrl.text = maxText;
                    _textCtrl.selection = TextSelection.fromPosition(
                      TextPosition(offset: maxText.length),
                    );
                    widget.onChanged(max);
                  }
                }
              },
            ),
          ),
          _btn(
            Icons.add,
            atMax ? null : () => widget.onChanged(qty + 1),
            color: atMax ? Colors.grey.shade300 : ThemeColor.primaryColor,
            iconColor: atMax ? ThemeColor.textSecondaryColor : Colors.white,
          ),
        ],
      );
    });
  }

  Widget _btn(
    IconData icon,
    VoidCallback? onTap, {
    required Color color,
    Color iconColor = ThemeColor.textPrimaryColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          borderRadius: ThemeColor.smallBorderRadius,
          border: color == ThemeColor.backgroundColor
              ? Border.all(color: ThemeColor.dividerColor)
              : null,
        ),
        child: Icon(icon, size: 14, color: iconColor),
      ),
    );
  }
}
