class Patient {
  String uid;
  String city;
  String email;
  String firstName;
  String lastName;
  String profileImageUrl;

  String phoneNumber;

  Patient({
    required this.uid,
    required this.city,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.profileImageUrl,
    required this.phoneNumber,
  });

  factory Patient.fromMap(Map<dynamic, dynamic> map, String uid) {
    return Patient(
      uid: uid,
      city: map['city'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      profileImageUrl: map['profileImageUrl'],
      phoneNumber: map['phoneNumber'],
    );
  }
}
