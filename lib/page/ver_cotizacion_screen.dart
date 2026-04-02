import 'package:bcg/common/theme/App_Theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ProductoLinea {
  final String nombre;
  final double precioUnitario;
  final int cantidad;

  const ProductoLinea({
    required this.nombre,
    required this.precioUnitario,
    required this.cantidad,
  });

  double get subtotal => precioUnitario * cantidad;
}

class CotizacionDetalle {
  final String folio;
  final String status;
  final String cliente;
  final String validoHasta;
  final List<ProductoLinea> productos;
  final double descuento;
  final double iva;
  final String direccionEntrega;
  final String comentarios;

  const CotizacionDetalle({
    required this.folio,
    required this.status,
    required this.cliente,
    required this.validoHasta,
    required this.productos,
    this.descuento = 0,
    this.iva = 0,
    this.direccionEntrega = '',
    this.comentarios = '',
  });

  double get subtotalProductos =>
      productos.fold(0, (s, p) => s + p.subtotal);

  double get total => subtotalProductos - descuento + iva;
}

class VerCotizacionScreen extends StatefulWidget {
  final CotizacionDetalle? cotizacion;
  const VerCotizacionScreen({super.key, this.cotizacion});

  @override
  State<VerCotizacionScreen> createState() => _VerCotizacionScreenState();
}

class _VerCotizacionScreenState extends State<VerCotizacionScreen> {
  final TextEditingController _comentariosCtrl = TextEditingController();
  late CotizacionDetalle _cot;

  @override
  void initState() {
    super.initState();
    _cot = widget.cotizacion ??
        const CotizacionDetalle(
          folio: '1',
          status: 'Abierta',
          cliente: 'Autotransportes la flecha',
          validoHasta: '06/03/2026',
          productos: [
            ProductoLinea(nombre: 'Aceite de motor', precioUnitario: 350.00, cantidad: 2),
            ProductoLinea(nombre: 'Aceite de motor', precioUnitario: 216.00, cantidad: 1),
          ],
          descuento: 0,
          iva: 168.00,
        );
    _comentariosCtrl.text = _cot.comentarios;
  }

  @override
  void dispose() {
    _comentariosCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'abierta': return ThemeColor.infoColor;
      case 'vencida': return ThemeColor.errorColor;
      case 'vendida': return ThemeColor.successColor;
      default: return ThemeColor.textSecondaryColor;
    }
  }

  void _openAcciones() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AccionesSheet(
        onVender: () {},
        onWhatsApp: () {},
        onPDF: () {},
        onEliminar: () {},
        onEditar: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: ThemeColor.surfaceColor,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeColor.paddingMedium,
            vertical: ThemeColor.paddingMedium,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEstado(),
              _div(),
              _buildCliente(),
              _div(),
              _buildProductos(),
              _div(),
              _buildTotales(),
              _div(),
              _buildDireccion(),
              _div(),
              _buildComentarios(),
              const SizedBox(height: ThemeColor.paddingExtraLarge),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: ThemeColor.surfaceColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios,
            color: ThemeColor.textPrimaryColor, size: 20),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      centerTitle: true,
      title: Text('Cotización # ${_cot.folio}', style: ThemeColor.headingSmall),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_horiz,
              color: ThemeColor.textPrimaryColor, size: 26),
          onPressed: _openAcciones,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, color: ThemeColor.dividerColor),
      ),
    );
  }

  Widget _div() => Divider(height: ThemeColor.paddingLarge, color: ThemeColor.dividerColor);

  Widget _buildEstado() {
    return Row(
      children: [
        Text('Estado', style: ThemeColor.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeColor.paddingSmall + 4, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor(_cot.status),
            borderRadius: ThemeColor.smallBorderRadius,
          ),
          child: Text(_cot.status,
              style: ThemeColor.caption.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildCliente() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Cliente: ',
                style: ThemeColor.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
            Expanded(
              child: Text(
                _cot.cliente,
                style: ThemeColor.bodyMedium.copyWith(
                    color: ThemeColor.infoColor, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text('Válido hasta:  ${_cot.validoHasta}',
            style: ThemeColor.bodyMedium
                .copyWith(color: ThemeColor.textSecondaryColor)),
      ],
    );
  }

  Widget _buildProductos() {
    return Column(
      children: _cot.productos.asMap().entries.map((e) {
        final isLast = e.key == _cot.productos.length - 1;
        return Column(
          children: [
            _ProductoRow(producto: e.value),
            if (!isLast)
              Divider(
                height: ThemeColor.paddingMedium,
                color: ThemeColor.infoColor.withOpacity(0.35),
                thickness: 1,
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTotales() {
    return Column(
      children: [
        _TotalRow(label: 'Subtotal',
            value: '\$${_cot.subtotalProductos.toStringAsFixed(2)}'),
        const SizedBox(height: 6),
        _TotalRow(
          label: 'Agregar un Descuento',
          value: '-\$${_cot.descuento.toStringAsFixed(2)}',
          labelStyle: ThemeColor.bodyMedium
              .copyWith(color: ThemeColor.errorColor, fontWeight: FontWeight.w500),
          valueStyle:
              ThemeColor.bodyMedium.copyWith(color: ThemeColor.errorColor),
        ),
        const SizedBox(height: 6),
        _TotalRow(label: 'I.V.A',
            value: '\$${_cot.iva.toStringAsFixed(2)}'),
        const SizedBox(height: ThemeColor.paddingSmall),
        Divider(color: ThemeColor.dividerColor),
        const SizedBox(height: ThemeColor.paddingSmall),
        _TotalRow(
          label: 'Total a pagar',
          value: '\$${_cot.total.toStringAsFixed(2)}',
          labelStyle: ThemeColor.subtitleLarge.copyWith(fontWeight: FontWeight.w800),
          valueStyle: ThemeColor.subtitleLarge
              .copyWith(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildDireccion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dirección de entrega:',
            style: ThemeColor.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
        if (_cot.direccionEntrega.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(_cot.direccionEntrega,
              style: ThemeColor.bodyMedium
                  .copyWith(color: ThemeColor.textSecondaryColor)),
        ] else
          const SizedBox(height: ThemeColor.paddingLarge),
      ],
    );
  }

  Widget _buildComentarios() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Comentarios',
            style: ThemeColor.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: ThemeColor.paddingSmall),
        Container(
          decoration: BoxDecoration(
            color: ThemeColor.surfaceColor,
            borderRadius: ThemeColor.smallBorderRadius,
            border: Border.all(color: ThemeColor.dividerColor),
          ),
          child: TextField(
            controller: _comentariosCtrl,
            maxLines: 3,
            style: ThemeColor.bodyMedium,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(ThemeColor.paddingSmall),
              hintStyle: ThemeColor.bodyMedium
                  .copyWith(color: ThemeColor.textSecondaryColor),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductoRow extends StatelessWidget {
  final ProductoLinea producto;
  const _ProductoRow({required this.producto});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: ThemeColor.backgroundColor,
            borderRadius: ThemeColor.smallBorderRadius,
            border: Border.all(color: ThemeColor.dividerColor),
          ),
          child: const Icon(Icons.image_outlined,
              color: Color(0xFFBDBDBD), size: 24),
        ),
        const SizedBox(width: ThemeColor.paddingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(producto.nombre,
                  style: ThemeColor.bodyMedium
                      .copyWith(fontWeight: FontWeight.w500)),
              Text('\$${producto.precioUnitario.toStringAsFixed(2)}',
                  style: ThemeColor.bodySmall
                      .copyWith(color: ThemeColor.textSecondaryColor)),
              Text('${producto.cantidad} Unidad',
                  style: ThemeColor.bodySmall
                      .copyWith(color: ThemeColor.textSecondaryColor)),
            ],
          ),
        ),
        Text('\$${producto.subtotal.toStringAsFixed(2)}',
            style: ThemeColor.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const _TotalRow({
    required this.label, required this.value,
    this.labelStyle, this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: labelStyle ?? ThemeColor.bodyMedium)),
        Text(value, style: valueStyle ?? ThemeColor.bodyMedium),
      ],
    );
  }
}

class _AccionesSheet extends StatelessWidget {
  final VoidCallback onVender;
  final VoidCallback onWhatsApp;
  final VoidCallback onPDF;
  final VoidCallback onEliminar;
  final VoidCallback onEditar;

  const _AccionesSheet({
    required this.onVender, required this.onWhatsApp, required this.onPDF,
    required this.onEliminar, required this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColor.backgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ThemeColor.largeRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: ThemeColor.paddingSmall),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: ThemeColor.dividerColor,
              borderRadius: ThemeColor.circularBorderRadius,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeColor.paddingMedium,
              vertical: ThemeColor.paddingSmall,
            ),
            child: Row(
              children: [
                const Spacer(),
                Text('Acciones', style: ThemeColor.headingSmall),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text('X',
                      style: ThemeColor.subtitleLarge
                          .copyWith(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: ThemeColor.dividerColor),
          const SizedBox(height: ThemeColor.paddingMedium),

          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: ThemeColor.paddingMedium),
            child: Column(
              children: [
                _AccionBtn(label: 'Vender',
                    onTap: () { Navigator.of(context).pop(); onVender(); }),
                const SizedBox(height: ThemeColor.paddingSmall),
                _AccionBtn(label: 'Enviar por WhatsApp',
                    onTap: () { Navigator.of(context).pop(); onWhatsApp(); }),
                const SizedBox(height: ThemeColor.paddingSmall),
                _AccionBtn(label: 'Descargar PDF',
                    onTap: () { Navigator.of(context).pop(); onPDF(); }),
              ],
            ),
          ),

          const SizedBox(height: ThemeColor.paddingMedium),
          Divider(height: 1, color: ThemeColor.dividerColor),
          const SizedBox(height: ThemeColor.paddingMedium),

          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: ThemeColor.paddingMedium),
            child: Row(
              children: [
                Expanded(
                  child: ThemeColor.widgetButton(
                    text: 'Eliminar',
                    onPressed: () { Navigator.of(context).pop(); onEliminar(); },
                    backgroundColor: ThemeColor.surfaceColor,
                    textColor: ThemeColor.errorColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    padding: const EdgeInsets.symmetric(
                        vertical: ThemeColor.paddingMedium),
                    borderRadius: ThemeColor.smallRadius,
                    borderColor: ThemeColor.errorColor,
                    borderWidth: 1.5,
                    showShadow: false,
                  ),
                ),
                const SizedBox(width: ThemeColor.paddingSmall),
                Expanded(
                  child: ThemeColor.widgetButton(
                    text: 'Editar',
                    onPressed: () { Navigator.of(context).pop(); onEditar(); },
                    backgroundColor: ThemeColor.primaryColor,
                    textColor: ThemeColor.textLightColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    padding: const EdgeInsets.symmetric(
                        vertical: ThemeColor.paddingMedium),
                    borderRadius: ThemeColor.smallRadius,
                    customShadow: ThemeColor.darkShadow,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ThemeColor.paddingLarge),
        ],
      ),
    );
  }
}

class _AccionBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AccionBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: ThemeColor.paddingMedium,
          horizontal: ThemeColor.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: ThemeColor.surfaceColor,
          borderRadius: ThemeColor.smallBorderRadius,
          border: Border.all(color: ThemeColor.dividerColor),
          boxShadow: [ThemeColor.lightShadow],
        ),
        child: Text(label,
            style: ThemeColor.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: ThemeColor.textPrimaryColor,
            )),
      ),
    );
  }
}