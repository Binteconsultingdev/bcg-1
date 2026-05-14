import 'package:bcg/features/client/domain/entities/account_statement_entity.dart';

class AccountStatementModel extends AccountStatementEntity {
  AccountStatementModel({required super.clienteId,  });
  factory AccountStatementModel.fromJson(Map<String, dynamic> json) {
    return AccountStatementModel(
      clienteId: json['clienteId'], 
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'clienteId': clienteId, 
    };
  }
  factory AccountStatementModel.fromEntity(AccountStatementEntity entity) {
    return AccountStatementModel(
      clienteId: entity.clienteId, 
     );
  }
 
}
