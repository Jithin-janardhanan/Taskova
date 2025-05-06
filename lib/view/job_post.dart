// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class DriverJobPostingPage extends StatefulWidget {
//   const DriverJobPostingPage({Key? key}) : super(key: key);

//   @override
//   _DriverJobPostingPageState createState() => _DriverJobPostingPageState();
// }

// class _DriverJobPostingPageState extends State<DriverJobPostingPage> {
//   final _formKey = GlobalKey<FormState>();

//   // Form controllers
//   final _titleController = TextEditingController(text: 'Drivers Needed TODAY!');
//   final _descriptionController = TextEditingController(text: '');
//   final _hourlyRateController = TextEditingController(text: '15');
//   final _perDeliveryRateController = TextEditingController(text: '3');

//   // Form values
//   DateTime _postDate = DateTime.now();
//   DateTime _startTime = DateTime(
//       DateTime.now().year, DateTime.now().month, DateTime.now().day, 9, 0);
//   DateTime _endTime = DateTime(
//       DateTime.now().year, DateTime.now().month, DateTime.now().day, 17, 0);
//   bool _showHourlyRate = true;
//   bool _showPerDeliveryRate = true;
//   List<String> _complimentaryOptions = [
//     'Meal during shift',
//     'Free drinks',
//     'Fuel allowance'
//   ];
//   List<bool> _selectedComplimentary = [true, false, false];
//   String _newComplimentary = '';

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     _hourlyRateController.dispose();
//     _perDeliveryRateController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _postDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 90)),
//     );
//     if (picked != null && picked != _postDate) {
//       setState(() {
//         _postDate = picked;
//       });
//     }
//   }

//   Future<void> _selectTime(BuildContext context, bool isStartTime) async {
//     TimeOfDay initialTime = isStartTime
//         ? TimeOfDay.fromDateTime(_startTime)
//         : TimeOfDay.fromDateTime(_endTime);

//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: initialTime,
//     );

//     if (picked != null) {
//       setState(() {
//         if (isStartTime) {
//           _startTime = DateTime(
//             _postDate.year,
//             _postDate.month,
//             _postDate.day,
//             picked.hour,
//             picked.minute,
//           );
//         } else {
//           _endTime = DateTime(
//             _postDate.year,
//             _postDate.month,
//             _postDate.day,
//             picked.hour,
//             picked.minute,
//           );
//         }
//       });
//     }
//   }

//   void _addComplimentaryOption() {
//     if (_newComplimentary.isNotEmpty) {
//       setState(() {
//         _complimentaryOptions.add(_newComplimentary);
//         _selectedComplimentary.add(true);
//         _newComplimentary = '';
//       });
//     }
//   }

//   void _publishJobPosting() {
//     if (_formKey.currentState!.validate()) {
//       // Create a job posting object with all the form data
//       final jobPosting = {
//         'title': _titleController.text,
//         'description': _descriptionController.text,
//         'postDate': DateFormat('yyyy-MM-dd').format(_postDate),
//         'startTime': DateFormat('HH:mm').format(_startTime),
//         'endTime': DateFormat('HH:mm').format(_endTime),
//         'hourlyRate': _showHourlyRate ? _hourlyRateController.text : null,
//         'perDeliveryRate':
//             _showPerDeliveryRate ? _perDeliveryRateController.text : null,
//         'complimentary': List.generate(
//           _selectedComplimentary.length,
//           (index) => _selectedComplimentary[index]
//               ? _complimentaryOptions[index]
//               : null,
//         ).where((item) => item != null).toList(),
//       };

//       // Show success dialog
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('Job Posted!'),
//             content: Text(
//                 'Your driver job posting will be published on ${DateFormat('MMMM d, yyyy').format(_postDate)}'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text('OK'),
//               ),
//             ],
//           );
//         },
//       );

//       // For demonstration purposes, print the job posting data
//       print('Job Posting Data: $jobPosting');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Create Driver Job Posting'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Card(
//                 elevation: 4,
//                 margin: const EdgeInsets.only(bottom: 20),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Job Posting Details',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: _titleController,
//                         decoration: const InputDecoration(
//                           labelText: 'Job Title',
//                           border: OutlineInputBorder(),
//                           filled: true,
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter a job title';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: _descriptionController,
//                         decoration: const InputDecoration(
//                           labelText: 'Job Description',
//                           border: OutlineInputBorder(),
//                           filled: true,
//                         ),
//                         maxLines: 5,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter a job description';
//                           }
//                           return null;
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Card(
//                 elevation: 4,
//                 margin: const EdgeInsets.only(bottom: 20),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Schedule Settings',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       ListTile(
//                         title: const Text('Post Date'),
//                         subtitle: Text(
//                           DateFormat('MMMM d, yyyy').format(_postDate),
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         trailing: const Icon(Icons.calendar_today),
//                         onTap: () => _selectDate(context),
//                       ),
//                       const Divider(),
//                       ListTile(
//                         title: const Text('Start Time'),
//                         subtitle: Text(
//                           DateFormat('h:mm a').format(_startTime),
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         trailing: const Icon(Icons.access_time),
//                         onTap: () => _selectTime(context, true),
//                       ),
//                       const Divider(),
//                       ListTile(
//                         title: const Text('End Time'),
//                         subtitle: Text(
//                           DateFormat('h:mm a').format(_endTime),
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         trailing: const Icon(Icons.access_time),
//                         onTap: () => _selectTime(context, false),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Card(
//                 elevation: 4,
//                 margin: const EdgeInsets.only(bottom: 20),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Payment Information',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       CheckboxListTile(
//                         title: const Text('Include Hourly Rate'),
//                         value: _showHourlyRate,
//                         onChanged: (value) {
//                           setState(() {
//                             _showHourlyRate = value ?? true;
//                           });
//                         },
//                       ),
//                       if (_showHourlyRate)
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 8),
//                           child: TextFormField(
//                             controller: _hourlyRateController,
//                             decoration: const InputDecoration(
//                               labelText: 'Hourly Rate (&)',
//                               border: OutlineInputBorder(),
//                               filled: true,
//                               prefixIcon: Icon(Icons.attach_money),
//                             ),
//                             keyboardType: TextInputType.number,
//                             validator: (value) {
//                               if (_showHourlyRate &&
//                                   (value == null || value.isEmpty)) {
//                                 return 'Please enter an hourly rate';
//                               }
//                               return null;
//                             },
//                           ),
//                         ),
//                       const Divider(),
//                       CheckboxListTile(
//                         title: const Text('Include Per Delivery Rate'),
//                         value: _showPerDeliveryRate,
//                         onChanged: (value) {
//                           setState(() {
//                             _showPerDeliveryRate = value ?? true;
//                           });
//                         },
//                       ),
//                       if (_showPerDeliveryRate)
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 8),
//                           child: TextFormField(
//                             controller: _perDeliveryRateController,
//                             decoration: const InputDecoration(
//                               labelText: 'Per Delivery Rate (&)',
//                               border: OutlineInputBorder(),
//                               filled: true,
//                               prefixIcon: Icon(Icons.local_shipping),
//                             ),
//                             keyboardType: TextInputType.number,
//                             validator: (value) {
//                               if (_showPerDeliveryRate &&
//                                   (value == null || value.isEmpty)) {
//                                 return 'Please enter a per delivery rate';
//                               }
//                               return null;
//                             },
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//               Card(
//                 elevation: 4,
//                 margin: const EdgeInsets.only(bottom: 20),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Complimentary Benefits',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       ...List.generate(
//                         _complimentaryOptions.length,
//                         (index) => CheckboxListTile(
//                           title: Text(_complimentaryOptions[index]),
//                           value: _selectedComplimentary[index],
//                           onChanged: (value) {
//                             setState(() {
//                               _selectedComplimentary[index] = value ?? false;
//                             });
//                           },
//                         ),
//                       ),
//                       const Divider(),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: TextFormField(
//                               decoration: const InputDecoration(
//                                 labelText: 'Add New Benefit',
//                                 border: OutlineInputBorder(),
//                                 filled: true,
//                               ),
//                               onChanged: (value) {
//                                 setState(() {
//                                   _newComplimentary = value;
//                                 });
//                               },
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           IconButton(
//                             icon: const Icon(Icons.add_circle),
//                             color: Theme.of(context).primaryColor,
//                             iconSize: 36,
//                             onPressed: _addComplimentaryOption,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _publishJobPosting,
//                   style: ElevatedButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text(
//                     'PUBLISH JOB POSTING',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 40),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DriverJobPostingPage extends StatefulWidget {
  final int businessId; // ID of the business creating the job posting

  const DriverJobPostingPage({
    Key? key,
    required this.businessId,
  }) : super(key: key);

  @override
  _DriverJobPostingPageState createState() => _DriverJobPostingPageState();
}

class _DriverJobPostingPageState extends State<DriverJobPostingPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form controllers
  final _titleController = TextEditingController(text: 'Drivers Needed TODAY!');
  final _descriptionController = TextEditingController(text: '');
  final _hourlyRateController = TextEditingController(text: '15');
  final _perDeliveryRateController = TextEditingController(text: '3');

  // Form values
  DateTime _postDate =
      DateTime.now(); // This is the job shift date, not posting date
  DateTime _startTime = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 9, 0);
  DateTime _endTime = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 17, 0);
  bool _showHourlyRate = true;
  bool _showPerDeliveryRate = true;
  List<String> _complimentaryOptions = [
    'Meal during shift',
    'Free drinks',
    'Fuel allowance'
  ];
  List<bool> _selectedComplimentary = [true, false, false];
  String _newComplimentary = '';

  // API endpoint
  final String _apiUrl = 'http://192.168.20.5:8000/api/job-posts/create/';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _hourlyRateController.dispose();
    _perDeliveryRateController.dispose();
    super.dispose();
  }

  // This method is for selecting the date of the job, not the posting date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _postDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _postDate) {
      setState(() {
        _postDate = picked;

        // Update start and end times to maintain the same hours on the new date
        _startTime = DateTime(picked.year, picked.month, picked.day,
            _startTime.hour, _startTime.minute);

        _endTime = DateTime(picked.year, picked.month, picked.day,
            _endTime.hour, _endTime.minute);
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    TimeOfDay initialTime = isStartTime
        ? TimeOfDay.fromDateTime(_startTime)
        : TimeOfDay.fromDateTime(_endTime);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = DateTime(
            _postDate.year,
            _postDate.month,
            _postDate.day,
            picked.hour,
            picked.minute,
          );
        } else {
          _endTime = DateTime(
            _postDate.year,
            _postDate.month,
            _postDate.day,
            picked.hour,
            picked.minute,
          );
        }
      });
    }
  }

  void _addComplimentaryOption() {
    if (_newComplimentary.isNotEmpty) {
      setState(() {
        _complimentaryOptions.add(_newComplimentary);
        _selectedComplimentary.add(true);
        _newComplimentary = '';
      });
    }
  }

  // Validate time range
  bool _validateTimeRange() {
    return _startTime.isBefore(_endTime);
  }

  // Validate rates
  bool _validateRates() {
    if (_showHourlyRate) {
      double? hourlyRate = double.tryParse(_hourlyRateController.text);
      if (hourlyRate == null || hourlyRate <= 0) return false;
    }

    if (_showPerDeliveryRate) {
      double? perDeliveryRate =
          double.tryParse(_perDeliveryRateController.text);
      if (perDeliveryRate == null || perDeliveryRate <= 0) return false;
    }

    return true;
  }

  Future<void> _publishJobPosting() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct the errors in the form')),
      );
      return;
    }

    // Additional validation for time range
    if (!_validateTimeRange()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    // Additional validation for rates
    if (!_validateRates()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rates must be valid positive numbers')),
      );
      return;
    }

    // At least one selected benefit
    final selectedBenefits = List.generate(
      _selectedComplimentary.length,
      (index) =>
          _selectedComplimentary[index] ? _complimentaryOptions[index] : null,
    ).where((item) => item != null).toList();

    if (selectedBenefits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one benefit')),
      );
      return;
    }

    // Create job posting data
    final Map<String, dynamic> jobPostingData = {
      "business": widget.businessId,
      "title": _titleController.text,
      "description": _descriptionController.text,
      "start_time": DateFormat('HH:mm:ss').format(_startTime),
      "end_time": DateFormat('HH:mm:ss').format(_endTime),
      "hourly_rate": _showHourlyRate ? _hourlyRateController.text : null,
      "per_delivery_rate":
          _showPerDeliveryRate ? _perDeliveryRateController.text : null,
      "complimentary_benefits": selectedBenefits,
      "created_at": DateTime.now().toUtc().toIso8601String(),
      "updated_at": DateTime.now().toUtc().toIso8601String(),
      "is_active": true
    };

    setState(() {
      _isLoading = true;
    });

    try {
      // API call
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(jobPostingData),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        final responseData = json.decode(response.body);
        _showSuccessDialog(responseData);
      } else {
        // Error handling
        final errorData = json.decode(response.body);
        _showErrorDialog(errorData.toString());
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Network error: ${e.toString()}');
    }
  }

  void _showSuccessDialog(dynamic responseData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Job Posted Successfully!'),
          content: Text(
              'Your driver job posting has been published. The job shift is scheduled for ${DateFormat('MMMM d, yyyy').format(_postDate)} from ${DateFormat('h:mm a').format(_startTime)} to ${DateFormat('h:mm a').format(_endTime)}.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to post job: $errorMessage'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Driver Job Posting'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Job Posting Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Job Title',
                                border: OutlineInputBorder(),
                                filled: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a job title';
                                }
                                if (value.length < 5) {
                                  return 'Title must be at least 5 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Job Description',
                                border: OutlineInputBorder(),
                                filled: true,
                              ),
                              maxLines: 5,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a job description';
                                }
                                if (value.length < 20) {
                                  return 'Description must be at least 20 characters';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Schedule Settings',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              title: const Text('Post Date'),
                              subtitle: Text(
                                DateFormat('MMMM d, yyyy').format(_postDate),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              trailing: const Icon(Icons.calendar_today),
                              onTap: () => _selectDate(context),
                            ),
                            const Divider(),
                            ListTile(
                              title: const Text('Start Time'),
                              subtitle: Text(
                                DateFormat('h:mm a').format(_startTime),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              trailing: const Icon(Icons.access_time),
                              onTap: () => _selectTime(context, true),
                            ),
                            const Divider(),
                            ListTile(
                              title: const Text('End Time'),
                              subtitle: Text(
                                DateFormat('h:mm a').format(_endTime),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              trailing: const Icon(Icons.access_time),
                              onTap: () => _selectTime(context, false),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Payment Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            CheckboxListTile(
                              title: const Text('Include Hourly Rate'),
                              value: _showHourlyRate,
                              onChanged: (value) {
                                setState(() {
                                  _showHourlyRate = value ?? true;
                                });
                              },
                            ),
                            if (_showHourlyRate)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: TextFormField(
                                  controller: _hourlyRateController,
                                  decoration: const InputDecoration(
                                    labelText: 'Hourly Rate (£)',
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    prefixIcon: Icon(Icons.attach_money),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (_showHourlyRate &&
                                        (value == null || value.isEmpty)) {
                                      return 'Please enter an hourly rate';
                                    }
                                    if (_showHourlyRate) {
                                      double? rate = double.tryParse(value!);
                                      if (rate == null) {
                                        return 'Please enter a valid number';
                                      }
                                      if (rate <= 0) {
                                        return 'Rate must be greater than zero';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            const Divider(),
                            CheckboxListTile(
                              title: const Text('Include Per Delivery Rate'),
                              value: _showPerDeliveryRate,
                              onChanged: (value) {
                                setState(() {
                                  _showPerDeliveryRate = value ?? true;
                                });
                              },
                            ),
                            if (_showPerDeliveryRate)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: TextFormField(
                                  controller: _perDeliveryRateController,
                                  decoration: const InputDecoration(
                                    labelText: 'Per Delivery Rate (£)',
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    prefixIcon: Icon(Icons.local_shipping),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (_showPerDeliveryRate &&
                                        (value == null || value.isEmpty)) {
                                      return 'Please enter a per delivery rate';
                                    }
                                    if (_showPerDeliveryRate) {
                                      double? rate = double.tryParse(value!);
                                      if (rate == null) {
                                        return 'Please enter a valid number';
                                      }
                                      if (rate <= 0) {
                                        return 'Rate must be greater than zero';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Complimentary Benefits',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...List.generate(
                              _complimentaryOptions.length,
                              (index) => CheckboxListTile(
                                title: Text(_complimentaryOptions[index]),
                                value: _selectedComplimentary[index],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedComplimentary[index] =
                                        value ?? false;
                                  });
                                },
                              ),
                            ),
                            const Divider(),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Add New Benefit',
                                      border: OutlineInputBorder(),
                                      filled: true,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _newComplimentary = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.add_circle),
                                  color: Theme.of(context).primaryColor,
                                  iconSize: 36,
                                  onPressed: _addComplimentaryOption,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _publishJobPosting,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'PUBLISH JOB POSTING',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}
