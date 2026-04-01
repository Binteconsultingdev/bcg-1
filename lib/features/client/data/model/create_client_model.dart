import 'package:bcg/features/client/domain/entities/create_client_entity.dart';

class CreateClientModel extends CreateClientEntity {
  CreateClientModel({required super.company, required super.name, required super.email, required super.phone});
  factory CreateClientModel.fromEntity(CreateClientEntity entity) {
    return CreateClientModel(company: entity.company, name: entity.name, email: entity.email, phone: entity.phone);
  }
  
  Map<String, dynamic> toJson() {
    return {
      'empresa':company,
      'nombre':name,
      'correo':email,
      'telefono':phone,
    };
  }
}