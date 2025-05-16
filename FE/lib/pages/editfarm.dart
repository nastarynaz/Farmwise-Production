import 'package:farmwise_app/logic/api/iot.dart';
import 'package:farmwise_app/logic/logicGlobal.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:farmwise_app/logic/api/farms.dart';

class EditFarmPage extends StatefulWidget {
  final String farmId;

  const EditFarmPage({Key? key, required this.farmId}) : super(key: key);

  @override
  State<EditFarmPage> createState() => _EditFarmPageState();
}

class _EditFarmPageState extends State<EditFarmPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final TextEditingController _iotController = TextEditingController();
  String? _selectedFarmType;
  String? _ioID;
  double _latitude = 0.0;
  double _longitude = 0.0;
  bool _isLoading = false;
  bool _locationObtained = false;
  bool _isInitialDataLoaded = false;

  // List of available farm types
  final List<String> _farmTypes = [
    'Corn',
    'Rice',
    'Soybean',
    'Wheat',
    'Vegetables',
    'Fruit',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadFarmData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadFarmData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch farm data using the farmId
      final farmResponse = await getFarmDetails(fID: int.parse(widget.farmId));

      if (farmResponse.statusCode == 200) {
        final farm = farmResponse.response;

        setState(() {
          _nameController.text = farm!.name;
          _selectedFarmType = farm.type;
          _latitude = farm.location.$1;
          _longitude = farm.location.$2;
          _iotController.text = farm.ioID ?? '';
          _locationObtained = true;
          _isInitialDataLoaded = true;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load farm: ${farmResponse.err}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load farm data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await updateFarmDetails(
          fID: int.parse(widget.farmId),
          location: (_latitude, _longitude),
          type: _selectedFarmType!.trim(),
          name: _nameController.text.trim(),
          ioID: _ioID,
        );

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Farm updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/managefarm');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating farm: ${response.err}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if coordinates have been updated from the location picker
    if (coordinate != null && _isInitialDataLoaded) {
      setState(() {
        _latitude = coordinate!.latitude;
        _longitude = coordinate!.longitude;
        _locationObtained = true;
      });

      print('Updated coordinates: $_latitude, $_longitude');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/managefarm'),
        ),
        title: const Text('Edit Farm'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      // Farm Name Field
                      _customFormInput(
                        controller: _nameController,
                        labelText: 'Farm Name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name for your farm (e.g. Pak Budi\'s Corn Farm)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Farm Type Dropdown
                      _dropdownFormField(),
                      const SizedBox(height: 20),
                      // Location Card
                      _locationCard(),
                      const SizedBox(height: 20),
                      //IOT
                      _addTools(),

                      const SizedBox(height: 30),
                      // Submit Button
                      _submitButton(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _addTools() {
    // Add a controller for the text field
    return Column(
      children: [
        // Input field with placeholder text
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: TextField(
            controller: _iotController,
            decoration: InputDecoration(
              hintText: 'Enter your IoT ID',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.green),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
            ),
          ),
        ),
        // Original button with updated onPressed function
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              // Show alert dialog when button is pressed
              final hasil = await checkIoT(_iotController.text);
              if (!hasil) {
                _iotController.text = '';
              }
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      hasil == true ? 'IoT Connected!' : 'Connection Failed',
                    ),
                    content: Text(
                      hasil == true
                          ? 'Connecting to IoT device: ${_iotController.text}'
                          : 'Connection Can\'t be Established',
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
              _ioID = _iotController.text == '' ? null : _iotController.text;
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green,
              disabledBackgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.green),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: Colors.green),
                const SizedBox(width: 20),
                const Text(
                  'Connect IOT',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _customFormInput({
    required TextEditingController controller,
    required String labelText,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        cursorColor: Colors.black,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
          floatingLabelStyle: const TextStyle(color: Colors.black),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 20,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _dropdownFormField() {
    return DropdownButtonFormField<String>(
      value:
          _farmTypes.indexOf(_selectedFarmType!) == -1
              ? "Other"
              : _selectedFarmType,
      decoration: InputDecoration(
        labelText: 'Select Farm Type',
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      icon: const Icon(Icons.arrow_drop_down),
      validator: (value) => value == null ? 'Please select a farm type' : null,
      items:
          _farmTypes.map((type) {
            return DropdownMenuItem<String>(value: type, child: Text(type));
          }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedFarmType = value;
        });
      },
    );
  }

  Widget _locationCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Farm Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Lat: ${_latitude.toStringAsFixed(4)}\nLng: ${_longitude.toStringAsFixed(4)}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 12),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.green),
                      onPressed: () {
                        context.push('/location_picker');
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _locationObtained ? _submitForm : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: const Text(
          'UPDATE FARM',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
