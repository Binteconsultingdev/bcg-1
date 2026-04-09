import 'package:bcg/features/client/domain/entities/client_entity.dart';
import 'package:bcg/features/client/presentation/controller/client_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientSearchController extends GetxController {
  late final ClientController _clientCtrl = Get.find<ClientController>();

  final RxList<ClientEntity> searchResults = <ClientEntity>[].obs;
  final RxBool isSearching = false.obs;
  final RxBool isLoadingSearch = false.obs;
  final TextEditingController searchCtrl = TextEditingController();

  final Rx<ClientEntity?> selectedClient = Rx<ClientEntity?>(null);

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }

  Future<void> onSearchChanged(String value) async {
    isSearching.value = value.isNotEmpty;

    if (value.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isLoadingSearch.value = true;
      await _clientCtrl.fetchClients(client: value.trim());
      searchResults.assignAll(_clientCtrl.clients);
    } catch (_) {
      searchResults.clear();
    } finally {
      isLoadingSearch.value = false;
    }
  }

  void clearSearch() {
    searchCtrl.clear();
    isSearching.value = false;
    searchResults.clear();
    selectedClient.value = null;
  }

void selectClient(ClientEntity client, {required Function(ClientEntity) onSelected}) {
  selectedClient.value = client;
  onSelected(client);
  isSearching.value = false;
  searchResults.clear();
}
}