class Doctor {
  String uid;
  String category;
  String city;
  String email;
  String firstName;
  String lastName;
  String profileImageUrl;
  String qualification;
  String phoneNumber;
  String yearsOfExperience;

  int numberOfReviews;
  int totalReviews;

  Doctor({
    required this.uid,
    required this.category,
    required this.city,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.profileImageUrl,
    required this.qualification,
    required this.phoneNumber,
    required this.yearsOfExperience,
    required this.numberOfReviews,
    required this.totalReviews,
  });

  factory Doctor.fromMap(Map<dynamic, dynamic> map, String uid) {
    return Doctor(
      uid: uid,
      category: map['category'],
      city: map['city'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      profileImageUrl: map['profileImageUrl'],
      qualification: map['qualification'],
      phoneNumber: map['phoneNumber'],
      yearsOfExperience: map['yearsOfExperience'],
      numberOfReviews: map['numberOfReviews'],
      totalReviews: map['totalReviews'],
    );
  }
}
