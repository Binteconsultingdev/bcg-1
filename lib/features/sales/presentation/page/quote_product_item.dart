import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/common/widgets/product_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    this.readOnly = false, // <-- default false
  });

  @override
  Widget build(BuildContext context) {
    final sinExistencia = availableQuantity <= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeColor.paddingMedium,
        vertical: ThemeColor.paddingMedium,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductThumbnail(imageUrl: imageUrl ?? '', size: 54),
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
                if (sinExistencia) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 13, color: Colors.amber),
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
                ],
                const SizedBox(height: 8),
                if (!readOnly) // <-- oculta controles en readOnly
                  _QuantityControls(quantity: quantity, onChanged: onQuantityChanged)
                else
                  Obx(() => Text(
                    'Cant: ${quantity.value % 1 == 0 ? quantity.value.toInt() : quantity.value}',
                    style: ThemeColor.bodySmall.copyWith(
                      color: ThemeColor.textSecondaryColor,
                    ),
                  )),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!readOnly) // <-- oculta botón eliminar en readOnly
                GestureDetector(
                  onTap: onRemove,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.delete_outline, color: ThemeColor.errorColor, size: 20),
                  ),
                ),
              SizedBox(height: readOnly ? 0 : 14),
              Obx(
                () => Text(
                  '\$${total.value.toStringAsFixed(2)}',
                  style: ThemeColor.subtitleMedium.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityControls extends StatefulWidget {
  final RxDouble quantity;
  final void Function(double) onChanged;
  const _QuantityControls({required this.quantity, required this.onChanged});

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
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.remove, () {
            if (qty > 1) widget.onChanged(qty - 1);
          }, color: ThemeColor.backgroundColor),
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
                if (parsed != null && parsed > 0) widget.onChanged(parsed);
              },
            ),
          ),
          _btn(
            Icons.add,
            () => widget.onChanged(qty + 1),
            color: ThemeColor.primaryColor,
            iconColor: Colors.white,
          ),
        ],
      );
    });
  }

  Widget _btn(
    IconData icon,
    VoidCallback onTap, {
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
