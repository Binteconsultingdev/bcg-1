import 'package:bcg/features/client/domain/entities/client_entity.dart';

class ClientModel extends ClientEntity {
  ClientModel({required super.id, required super.displayName, required super.owes});

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(id: json['id'], displayName: json['nombreMostrar'], owes: json['adeuda']
     
    );
  }
  factory ClientModel.fromEntity(ClientEntity entity) {
    return ClientModel(id: entity.id, displayName: entity.displayName, owes: entity.owes
     
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id':id,
      'nombreMostrar':displayName,
      'adeuda':owes
    };
  }
}