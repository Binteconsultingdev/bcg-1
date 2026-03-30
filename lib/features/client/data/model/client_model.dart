import 'package:bcg/features/client/domain/entities/client_entity.dart';

class ClientModel extends ClientEntity {
  ClientModel({required super.id, required super.name});

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
  factory ClientModel.fromEntity(ClientEntity entity) {
    return ClientModel(
      id: entity.id,
      name: entity.name,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}