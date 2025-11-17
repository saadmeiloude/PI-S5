class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime? birthDate;
  final String? profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.birthDate,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      profileImage: json['profileImage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'birthDate': birthDate?.toIso8601String(),
      'profileImage': profileImage,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    DateTime? birthDate,
    String? profileImage,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String location;
  final double rating;
  final int reviewCount;
  final String? profileImage;
  final String qualifications;
  final int experienceYears;
  final bool isAvailable;
  final List<WorkingHour> workingHours;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.location,
    required this.rating,
    required this.reviewCount,
    this.profileImage,
    required this.qualifications,
    required this.experienceYears,
    this.isAvailable = true,
    required this.workingHours,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      location: json['location'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      profileImage: json['profile_image'] as String?,
      qualifications: json['qualifications'] as String,
      experienceYears: json['experience_years'] as int? ?? 0,
      isAvailable: json['is_available'] as bool? ?? true,
      workingHours:
          [], // Default empty, can be populated from clinic_address or other logic
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'location': location,
      'rating': rating,
      'reviewCount': reviewCount,
      'profileImage': profileImage,
      'qualifications': qualifications,
      'experienceYears': experienceYears,
      'isAvailable': isAvailable,
      'workingHours': workingHours.map((e) => e.toJson()).toList(),
    };
  }
}

class WorkingHour {
  final String days;
  final String hours;
  final bool isClosed;

  WorkingHour({required this.days, required this.hours, this.isClosed = false});

  factory WorkingHour.fromJson(Map<String, dynamic> json) {
    return WorkingHour(
      days: json['days'] as String,
      hours: json['hours'] as String,
      isClosed: json['isClosed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'days': days, 'hours': hours, 'isClosed': isClosed};
  }
}

class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String specialty;
  final DateTime date;
  final String time;
  final AppointmentStatus status;
  final String? notes;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.status,
    this.notes,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      specialty: json['specialty'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'specialty': specialty,
      'date': date.toIso8601String(),
      'time': time,
      'status': status.toString().split('.').last,
      'notes': notes,
    };
  }
}

enum AppointmentStatus { scheduled, completed, cancelled, rescheduled }

class Review {
  final String id;
  final String doctorId;
  final String reviewer;
  final String time;
  final int rating;
  final String reviewText;
  final int likes;
  final int dislikes;

  Review({
    required this.id,
    required this.doctorId,
    required this.reviewer,
    required this.time,
    required this.rating,
    required this.reviewText,
    required this.likes,
    required this.dislikes,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      reviewer: json['reviewer'] as String,
      time: json['time'] as String,
      rating: json['rating'] as int,
      reviewText: json['reviewText'] as String,
      likes: json['likes'] as int,
      dislikes: json['dislikes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'reviewer': reviewer,
      'time': time,
      'rating': rating,
      'reviewText': reviewText,
      'likes': likes,
      'dislikes': dislikes,
    };
  }
}
