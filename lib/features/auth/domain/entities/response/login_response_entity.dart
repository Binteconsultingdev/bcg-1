class LoginResponseEntity {
  final String token;
  final int userId;
  final String nombre;
  final String usuario;
  final String area;
  final String? logoUrl;

  LoginResponseEntity({
    required this.token,
    required this.userId,
    required this.nombre,
    required this.usuario,
    required this.area,
    this.logoUrl,
  });
}

class UserEntity {
  final int id;
  final String email;
  final String rol;
  final String nombreCompleto;
  final String telefono;
  final String stripeId;

  UserEntity({
    required this.id,
    required this.email,
    required this.rol,
    required this.nombreCompleto,
    required this.telefono,
    required this.stripeId,
  });
}