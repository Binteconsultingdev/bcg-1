import 'package:bcg/features/client/domain/entities/account_statement_entity.dart';

class AccountStatementModel extends AccountStatementEntity {
  AccountStatementModel({required super.clienteId, required super.startdate, required super.enddate});
  factory AccountStatementModel.fromJson(Map<String, dynamic> json) {
    return AccountStatementModel(
      clienteId: json['clienteId'],
      startdate: json['fechaInicio'],
      enddate: json['fechaFin'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'clienteId': clienteId,
      'fechaInicio': startdate,
      'fechaFin': enddate,
    };
  }
  factory AccountStatementModel.fromEntity(AccountStatementEntity entity) {
    return AccountStatementModel(
      clienteId: entity.clienteId,
      startdate: entity.startdate,
      enddate: entity.enddate,
     );
  }
 
}
