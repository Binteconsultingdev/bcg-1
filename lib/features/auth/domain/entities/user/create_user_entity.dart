class CreateUserEntity {
  final String name;
  final String email;
  final String password;
  final String dateofbirth;
  final String gender;
  final String bio;
  final String heightcm;
  final String primarylanguage;
  final String city;
  final String lat;
  final String lng;
  final List<int> interestsIds;

  final List<int> qualitiesIds;
  CreateUserEntity({
    required this.name,
    required this.email,
    required this.password,
    required this.dateofbirth,
    required this.gender,
    required this.bio,
    required this.heightcm,
    required this.primarylanguage,
    required this.city,
    required this.lat,
    required this.lng,
    required this.interestsIds,
    required this.qualitiesIds,
  });
}
