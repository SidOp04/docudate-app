import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice/doctor/model/doctor.dart';
import 'package:practice/doctor/widget/doctor_card.dart';
import 'package:practice/doctor/doctor_details_page.dart';

class DoctorSearchPage extends StatefulWidget {
  final List<Doctor> allDoctors;

  const DoctorSearchPage({super.key, required this.allDoctors});

  @override
  State<DoctorSearchPage> createState() => _DoctorSearchPageState();
}

class _DoctorSearchPageState extends State<DoctorSearchPage> {
  List<Doctor> filteredDoctors = [];
  String query = '';

  @override
  void initState() {
    super.initState();
    filteredDoctors = widget.allDoctors;
  }

  void _filterDoctors(String input) {
    setState(() {
      query = input.toLowerCase();
      filteredDoctors = widget.allDoctors.where((doc) {
        final fullName = '${doc.firstName} ${doc.lastName}'.toLowerCase();
        final category = doc.category.toLowerCase();
        return fullName.contains(query) || category.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Doctor'),
        backgroundColor: const Color(0xff006AFA),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by name or category',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _filterDoctors,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredDoctors.isEmpty
                  ? Center(
                      child: Text(
                        'No doctors found.',
                        style: GoogleFonts.poppins(),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredDoctors.length,
                      itemBuilder: (context, index) {
                        final doctor = filteredDoctors[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => DoctorDetailPage(doctor: doctor),
                            ));
                          },
                          child: DoctorCard(doctor: doctor),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
