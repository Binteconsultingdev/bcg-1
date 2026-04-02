import 'package:bcg/common/services/auth_service.dart';
import 'package:bcg/common/settings/routes_names.dart';
import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/features/client/domain/entities/client_entity.dart';
import 'package:bcg/features/client/presentation/controller/client_controller.dart';
import 'package:bcg/features/quotes/domain/entities/get_quote_entity.dart';
import 'package:bcg/features/quotes/presentation/controller/quotes_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
class ClientSearchSheet extends StatefulWidget {
  final ClientController clientCtrl;
  final ValueChanged<ClientEntity> onSelected;

  const ClientSearchSheet({
    required this.clientCtrl,
    required this.onSelected,
  });

  @override
  State<ClientSearchSheet> createState() => ClientSearchSheetState();
}

class ClientSearchSheetState extends State<ClientSearchSheet> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Carga inicial sin filtro
    widget.clientCtrl.fetchClients();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    widget.clientCtrl.fetchClients(client: value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: ThemeColor.backgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ThemeColor.largeRadius),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: ThemeColor.paddingSmall),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ThemeColor.dividerColor,
              borderRadius: ThemeColor.circularBorderRadius,
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeColor.paddingMedium,
              vertical: ThemeColor.paddingSmall,
            ),
            child: Row(
              children: [
                const Spacer(),
                Text('Seleccionar Cliente', style: ThemeColor.headingSmall),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    'X',
                    style: ThemeColor.subtitleLarge
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: ThemeColor.dividerColor),
          // Buscador
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeColor.paddingMedium,
              vertical: ThemeColor.paddingSmall,
            ),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: ThemeColor.surfaceColor,
                borderRadius: ThemeColor.mediumBorderRadius,
                border: Border.all(color: ThemeColor.dividerColor),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearch,
                style: ThemeColor.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Buscar cliente...',
                  hintStyle: ThemeColor.bodyMedium
                      .copyWith(color: ThemeColor.textSecondaryColor),
                  prefixIcon: const Icon(Icons.search,
                      color: ThemeColor.textSecondaryColor, size: 20),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          // Lista
          Expanded(
            child: Obx(() {
              if (widget.clientCtrl.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                      color: ThemeColor.primaryColor),
                );
              }

              if (widget.clientCtrl.clients.isEmpty) {
                return Center(
                  child: Text(
                    'Sin clientes',
                    style: ThemeColor.bodyMedium.copyWith(
                        color: ThemeColor.textSecondaryColor),
                  ),
                );
              }

              return ListView.separated(
                controller: widget.clientCtrl.scrollController,
                padding: const EdgeInsets.symmetric(
                    horizontal: ThemeColor.paddingMedium),
                itemCount: widget.clientCtrl.clients.length + 1,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: ThemeColor.dividerColor),
                itemBuilder: (_, i) {
                  if (i == widget.clientCtrl.clients.length) {
                    return Obx(() {
                      if (widget.clientCtrl.isLoadingMore.value) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: CircularProgressIndicator(
                                color: ThemeColor.primaryColor),
                          ),
                        );
                      }
                      return const SizedBox(height: 16);
                    });
                  }

                  final client = widget.clientCtrl.clients[i];
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 4),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: ThemeColor.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: ThemeColor.primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      client.displayName ?? '-',
                      style: ThemeColor.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: client.owes != null && client.owes! > 0
                        ? Text(
                            'Saldo: \$${client.owes!.toStringAsFixed(2)}',
                            style: ThemeColor.caption.copyWith(
                                color: ThemeColor.errorColor),
                          )
                        : null,
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: ThemeColor.textSecondaryColor,
                    ),
                    onTap: () {
                      widget.onSelected(client);
                      Navigator.of(context).pop();
                    },
                  );
                },
              );
            }),
          ),
          SizedBox(
              height: MediaQuery.of(context).padding.bottom +
                  ThemeColor.paddingSmall),
        ],
      ),
    );
  }
}