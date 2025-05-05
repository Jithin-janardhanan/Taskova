// main.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class PostcodeLookupApp extends StatelessWidget {
  const PostcodeLookupApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UK Postcode Lookup Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PostcodeLookupScreen(),
    );
  }
}

class PostcodeLookupScreen extends StatefulWidget {
  const PostcodeLookupScreen({Key? key}) : super(key: key);

  @override
  _PostcodeLookupScreenState createState() => _PostcodeLookupScreenState();
}

class _PostcodeLookupScreenState extends State<PostcodeLookupScreen> {
  final TextEditingController _postcodeController = TextEditingController();
  bool _isLoading = false;
  String _resultMessage = '';
  List<Map<String, dynamic>> _addresses = [];
  bool _hasError = false;

  Future<void> _lookupPostcode() async {
    final postcode = _postcodeController.text.trim();
    
    if (postcode.isEmpty) {
      setState(() {
        _resultMessage = 'Please enter a postcode';
        _hasError = true;
        _addresses = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _resultMessage = '';
      _addresses = [];
      _hasError = false;
    });

    try {
      // First, validate the postcode using the postcodes.io API
      final validationResponse = await http.get(
        Uri.parse('https://api.postcodes.io/postcodes/$postcode/validate'),
      );
      
      final validationData = json.decode(validationResponse.body);
      
      if (!validationData['result']) {
        setState(() {
          _resultMessage = 'Invalid UK postcode';
          _hasError = true;
          _isLoading = false;
        });
        return;
      }

      // Get basic postcode data
      final postcodeResponse = await http.get(
        Uri.parse('https://api.postcodes.io/postcodes/$postcode'),
      );
      
      final postcodeData = json.decode(postcodeResponse.body);
      
      if (postcodeResponse.statusCode != 200) {
        setState(() {
          _resultMessage = 'Error: ${postcodeData['error']}';
          _hasError = true;
          _isLoading = false;
        });
        return;
      }

      // Now try to get addresses using a different API
      // Note: This is a mock implementation as most address lookup APIs require authentication
      // In a real app, you would use a service like GetAddress.io, Ideal Postcodes, or Ordnance Survey
      
      try {
        // Mock API call to demonstrate - in reality you would use a real API with your API key
        // final addressResponse = await http.get(
        //   Uri.parse('https://api.getaddress.io/find/$postcode?api-key=YOUR_API_KEY'),
        // );
        
        // Instead, we'll create some mock data based on the postcode
        await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
        
        final mockAddresses = _generateMockAddresses(postcode);
        
        setState(() {
          if (mockAddresses.isEmpty) {
            _resultMessage = 'No address data available for this postcode';
          } else {
            _resultMessage = 'Found ${mockAddresses.length} addresses for $postcode';
            _addresses = mockAddresses;
          }
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _resultMessage = 'Could not retrieve address data: ${e.toString()}';
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _resultMessage = 'Error: ${e.toString()}';
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  // Generate mock address data for demonstration purposes
  List<Map<String, dynamic>> _generateMockAddresses(String postcode) {
    // For this demo, we'll create 3-5 addresses with house numbers based on the postcode
    final addresses = <Map<String, dynamic>>[];
    
    // Use the postcode to determine some characteristics
    final normalizedPostcode = postcode.replaceAll(' ', '').toUpperCase();
    int seed = 0;
    for (int i = 0; i < normalizedPostcode.length; i++) {
      seed += normalizedPostcode.codeUnitAt(i);
    }
    
    final random = seed % 100;
    final numAddresses = 3 + (random % 3); // 3-5 addresses
    
    String streetName = "High Street";
    if (random < 33) {
      streetName = "Church Road";
    } else if (random < 66) {
      streetName = "Station Road";
    }
    
    for (int i = 1; i <= numAddresses; i++) {
      final houseNumber = (random + i * 2) % 100;
      addresses.add({
        "house_number": houseNumber.toString(),
        "address_line1": "$houseNumber $streetName",
        "address_line2": "",
        "town_or_city": "London",
        "county": "Greater London",
        "postcode": postcode.toUpperCase(),
      });
    }
    
    return addresses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UK Postcode Lookup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter a UK postcode to find addresses',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _postcodeController,
              decoration: const InputDecoration(
                labelText: 'Postcode',
                hintText: 'e.g. SW1A 2AA',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _lookupPostcode,
              child: _isLoading
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Searching...'),
                      ],
                    )
                  : const Text('Find Addresses'),
            ),
            if (_resultMessage.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _hasError ? Colors.red.shade50 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _hasError ? Colors.red.shade200 : Colors.blue.shade200,
                  ),
                ),
                child: Text(
                  _resultMessage,
                  style: TextStyle(
                    color: _hasError ? Colors.red.shade800 : Colors.blue.shade800,
                  ),
                ),
              ),
            if (_addresses.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Addresses Found:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final address = _addresses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(address['house_number'] ?? 'N/A'),
                        ),
                        title: Text(address['address_line1']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (address['address_line2']?.isNotEmpty ?? false)
                              Text(address['address_line2']),
                            Text('${address['town_or_city']}, ${address['county']}'),
                            Text(address['postcode']),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _postcodeController.dispose();
    super.dispose();
  }
}