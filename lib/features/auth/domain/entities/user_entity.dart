class UserEntity {
  final String id;
  final String phoneNumber;
  final String? name;
  final String? email;
  final String token;

  const UserEntity({
    required this.id,
    required this.phoneNumber,
    this.name,
    this.email,
    required this.token,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          phoneNumber == other.phoneNumber;

  @override
  int get hashCode => id.hashCode ^ phoneNumber.hashCode;
}
