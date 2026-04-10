
import 'package:bcg/common/theme/App_Theme.dart';
import 'package:bcg/features/client/domain/entities/client_entity.dart';
import 'package:bcg/features/client/presentation/controller/client_search_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ClientSearchField extends StatelessWidget {
  final Function(ClientEntity) onSelected;
  const ClientSearchField({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ClientSearchController>();

    return Obx(() => ThemeColor.searchTextField(
      controller: ctrl.searchCtrl,
      hintText: 'Buscar cliente...',
      prefixIcon: Icons.person_search_outlined,
      onPrefixTap: ctrl.toggleResults, 
      prefixIconColor: ThemeColor.primaryColor, 
      isLoading: ctrl.isLoadingSearch.value,
      onChanged: ctrl.onSearchChanged,
      onClear: ctrl.clearSearch,
    ));
  }
}



class ClientSearchResults extends StatelessWidget {
  final Function(ClientEntity) onSelected;
  const ClientSearchResults({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ClientSearchController>();

    return Obx(() {
  if (!ctrl.showResults.value) return const SizedBox.shrink();
      if (ctrl.isLoadingSearch.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      final results = ctrl.searchResults;
      if (results.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text('Sin clientes', style: ThemeColor.bodySmall),
        );
      }
      return Container(
        constraints: const BoxConstraints(maxHeight: 220),
        margin: const EdgeInsets.only(top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: ThemeColor.surfaceColor,
          borderRadius: ThemeColor.smallBorderRadius,
          border: Border.all(color: ThemeColor.dividerColor),
          boxShadow: [ThemeColor.lightShadow],
        ),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: results.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: ThemeColor.dividerColor),
          itemBuilder: (_, i) {
            final client = results[i];
            return ListTile(
              dense: true,
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: ThemeColor.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline,
                    color: ThemeColor.primaryColor, size: 16),
              ),
              title: Text(
                client.displayName ?? '-',
                style: ThemeColor.bodyMedium
                    .copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: client.owes != null && client.owes! > 0
                  ? Text(
                      'Saldo: \$${client.owes!.toStringAsFixed(2)}',
                      style: ThemeColor.caption
                          .copyWith(color: ThemeColor.errorColor),
                    )
                  : null,
              trailing: const Icon(Icons.chevron_right,
                  color: ThemeColor.textSecondaryColor, size: 18),
              onTap: () =>
                  ctrl.selectClient(client, onSelected: onSelected),
            );
          },
        ),
      );
    });
  }
}