import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice/doctor/doctor_details_page.dart';
import 'package:practice/doctor/model/doctor.dart';
import 'package:practice/doctor/widget/doctor_card.dart';

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('Doctors');
  List<Doctor> _doctors = [];
  List<Doctor> _filteredDoctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    await _database.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      List<Doctor> tmpDoctors = [];
      if (snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          Doctor doctor = Doctor.fromMap(value, key);
          tmpDoctors.add(doctor);
        });
      }
      setState(() {
        _doctors = tmpDoctors;
        _filteredDoctors = tmpDoctors;
        _isLoading = false;
      });
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      if (category == 'See All') {
        _filteredDoctors = _doctors;
      } else {
        _filteredDoctors =
            _doctors.where((doc) => doc.category == category).toList();
      }
    });
  }

  void _showSearchDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.6,
        builder: (_, controller) {
          List<Doctor> filteredDoctors = List.from(_doctors);
          TextEditingController searchController = TextEditingController();

          void _filter(String query) {
            query = query.toLowerCase();
            setState(() {
              filteredDoctors = _doctors.where((doc) {
                final name = '${doc.firstName} ${doc.lastName}'.toLowerCase();
                final category = doc.category.toLowerCase();
                return name.contains(query) || category.contains(query);
              }).toList();
            });
          }

          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              autofocus: true,
                              decoration: const InputDecoration(
                                hintText: 'Search by name or category',
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                setModalState(() {
                                  _filter(value);
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: filteredDoctors.isEmpty
                            ? const Center(child: Text('No doctors found'))
                            : ListView.builder(
                                controller: controller,
                                itemCount: filteredDoctors.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DoctorDetailPage(
                                              doctor: filteredDoctors[index]),
                                        ),
                                      );
                                    },
                                    child: DoctorCard(
                                        doctor: filteredDoctors[index]),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
    },
  );
}


  @override
  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Find your doctor,\nand book an appointment',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.black87),
                        onPressed: () => _showSearchDialog(context),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Find Doctor by Category',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () => _filterByCategory('Cardiology'),
                        child: _buildCategoryCard(
                            context, 'Cardiologist', 'assets/images/heart.png'),
                      ),
                      GestureDetector(
                        onTap: () => _filterByCategory('Dentist'),
                        child: _buildCategoryCard(
                            context, 'Dentist', 'assets/images/dental.png'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () => _filterByCategory('Oncology'),
                        child: _buildCategoryCard(
                            context, 'Oncologist', 'assets/images/onco.png'),
                      ),
                      GestureDetector(
                        onTap: () => _filterByCategory('See All'),
                        child: _buildCategoryCard(
                          context,
                          'See All',
                          'assets/images/grid.png',
                          isHighlighed: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top Doctors',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._filteredDoctors.map(
                    (doctor) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DoctorDetailPage(doctor: doctor),
                          ),
                        );
                      },
                      child: DoctorCard(doctor: doctor),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
  );
}}  


Widget _buildCategoryCard(BuildContext context, String title, dynamic icon,
    {bool isHighlighed = false}) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.4,
    decoration: BoxDecoration(
      color: isHighlighed ? const Color(0xff006AFA) : const Color(0xffF0EFFF),
      borderRadius: BorderRadius.circular(15),
      border: isHighlighed
          ? null
          : Border.all(color: const Color(0xffC8C4FF), width: 2),
    ),
    child: Card(
      color: isHighlighed ? const Color(0xff006AFA) : const Color(0xffF0EFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon is IconData)
              Icon(
                icon,
                size: 40,
                color: isHighlighed ? Colors.white : const Color(0xffF0EFFF),
              )
            else
              Image.asset(
                icon,
                width: 40,
                height: 40,
              ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: isHighlighed ? Colors.white : const Color(0xff006AFA),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
