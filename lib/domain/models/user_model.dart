class UserModel {
   final String id;
   final String firstName;
   final String? lastName;
   final String username;

   const UserModel({
     required this.id,
     required this.firstName,
     this.lastName,
     required this.username,
   });

   String get fullName => '$firstName ${lastName ?? ""}'.trim();

   factory UserModel.fromJson(Map<String, dynamic> json) {
     return UserModel(
       id: json['id'] as String? ?? '',
       firstName: json['firstName'] as String? ?? '',
       lastName: json['lastName'] as String?,
       username: json['username'] as String? ?? '',
     );
   }

   Map<String, dynamic> toJson() {
     return {
       'id': id,
       'firstName': firstName,
       'lastName': lastName,
       'username': username,
     };
   }
 }
