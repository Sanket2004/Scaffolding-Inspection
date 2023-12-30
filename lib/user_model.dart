class UserModel {
  String? name;
  String? email;
  String? phone;
  String? work;
  String? role;
  String? profilePic;
  String? id;

  UserModel({
    this.name,
    this.email,
    this.phone,
    this.work,
    this.role,
    this.profilePic,
    this.id,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'work': work,
        'role': role,
        'profilePic': profilePic,
        'id': id,
      };
}
