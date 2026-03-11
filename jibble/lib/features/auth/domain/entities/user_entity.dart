class UserEntity {
  final String id;
  final String? email;
  final String? createdAt;

  const UserEntity({required this.id, this.email, this.createdAt});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserEntity &&
        other.id == id &&
        other.email == email &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ createdAt.hashCode;
}
