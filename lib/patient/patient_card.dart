import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'patient.dart';

class PatientCard extends StatelessWidget {
  final Patient patient;

  const PatientCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xffF0EFFF),
        border: Border.all(color: const Color(0xffC8C4FF)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Card(
        color: const Color(0xffF0EFFF),
        elevation: 0.0,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        child: ListTile(
          leading: Container(
            width: 55,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: const Color(0xff0064FA)),
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(patient.profileImageUrl),
            ),
          ),
          title: Text(
            '${patient.firstName} ${patient.lastName}',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Mail: ${patient.email}',
                    style: GoogleFonts.poppins(fontSize: 13),
                  )
                ],
              ),
              Text(
                'City: ${patient.city}',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              Text(
                'Phone: ${patient.phoneNumber}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                  color: const Color(0xffFA9600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
