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
final RxBool showResults = false.obs;

  // 👇 Callback opcional para texto libre
  void Function(String)? onFreeText;

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }

void onSearchChanged(String value) async {
  isSearching.value = value.isNotEmpty;
  
  // 👇 Solo reabre si el usuario NO lo ocultó manualmente
  if (value.isNotEmpty && !manuallyClosed) {
    showResults.value = true;
  }
  if (value.isEmpty) {
    showResults.value = false;
    manuallyClosed = false; // reset al limpiar
  }

  onFreeText?.call(value);
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

void toggleResults() {
  showResults.value = !showResults.value;
  manuallyClosed = !showResults.value; // 👈 marca si fue cierre manual
}

bool manuallyClosed = false;

void clearSearch({bool notifyParent = false}) {
  searchCtrl.clear();
  isSearching.value = false;
  showResults.value = false;
  manuallyClosed = false; // 👈 reset
  searchResults.clear();
  selectedClient.value = null;
  if (notifyParent) onFreeText?.call('');
}

 
void selectClient(ClientEntity client, {required Function(ClientEntity) onSelected}) {
  selectedClient.value = client;
  onSelected(client);
  isSearching.value = false;
  showResults.value = false; // 👈 oculta al seleccionar
  searchResults.clear();
}

}