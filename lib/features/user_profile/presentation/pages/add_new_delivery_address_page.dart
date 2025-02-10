import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_dukans_user/core/config/common_widgets/custom_app_bar.dart';
import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
import 'package:online_dukans_user/core/config/utils/token_manager.dart';
import 'package:online_dukans_user/features/user_profile/data/services/address_service.dart';
import 'package:online_dukans_user/features/user_profile/data/services/city_service.dart';
import 'package:online_dukans_user/features/user_profile/data/services/pincode_service.dart';
import 'package:online_dukans_user/features/user_profile/data/services/state_service.dart';
import 'package:online_dukans_user/features/user_profile/model/city_model.dart';
import 'package:online_dukans_user/features/user_profile/model/pincode_model.dart';
import 'package:online_dukans_user/features/user_profile/model/state_model.dart';


class AddNewDeliveryAddressPage extends StatefulWidget {
  const AddNewDeliveryAddressPage({super.key});

  @override
  State<AddNewDeliveryAddressPage> createState() =>
      _AddNewDeliveryAddressPageState();
}

class _AddNewDeliveryAddressPageState extends State<AddNewDeliveryAddressPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();

  // Variables for toggle buttons
  bool _isActive = true;
  final bool _defaultAddress = false;

  // Variable for address type
  String? _selectedAddressType;
  final List<String> _addressTypes = ['Home', 'Office', 'Other'];

  // Variables for dropdowns
  List<PincodeModel> _pincodes = [];
  List<CityModel> _cities = [];
  List<StateModel> _states = [];
  String? _selectedPincodeId;
  String? _selectedCityId;
  String? _selectedStateId;

  bool _isLoadingStates = false;
  bool _isLoadingCities = false;
  bool _isLoadingPincodes = false;

  // Services
  final AddressService _addressService = AddressService();
  final PincodeService _pincodeService = PincodeService();
  final CityService _cityService = CityService();
  final StateService _stateService = StateService();
  final TokenManager _tokenManager = TokenManager(SecureStorageService());

  // User Information
  String? _userId;
  String? _createdById;
  String? _lastUpdatedById;

  @override
  void initState() {
    super.initState();
    _fetchStates();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final userData = await _tokenManager.getUser();
      if (userData != null) {
        setState(() {
          _userId = userData['id'] as String?;
          _createdById = _userId; // Assuming createdById is the same as userId
          _lastUpdatedById =
              _userId; // Assuming lastUpdatedById is the same as userId
        });
      } else {
        throw Exception("User data is null");
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user data: $e")),
      );
    }
  }

  Future<void> _fetchStates() async {
    setState(() {
      _isLoadingStates = true;
    });
    try {
      final states = await _stateService.getAllStates();
      setState(() {
        _states = states;
        if (_states.isNotEmpty) {
          _selectedStateId = _states.first.id;
          _fetchCitiesByStateId(_selectedStateId!);
        }
      });
    } catch (e) {
      debugPrint("Error fetching states: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching states: $e")),
      );
    } finally {
      setState(() {
        _isLoadingStates = false;
      });
    }
  }

  Future<void> _fetchCitiesByStateId(String stateId) async {
    setState(() {
      _isLoadingCities = true;
      _cities = [];
      _pincodes = [];
      _selectedCityId = null;
      _selectedPincodeId = null;
    });
    try {
      final cities = await _cityService.getCitiesByStateId(stateId);
      setState(() {
        _cities = cities;
        if (_cities.isNotEmpty) {
          _selectedCityId = _cities.first.id;
          _fetchPincodesByCityId(_selectedCityId!);
        }
      });
    } catch (e) {
      debugPrint("Error fetching cities: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching cities: $e")),
      );
    } finally {
      setState(() {
        _isLoadingCities = false;
      });
    }
  }

  Future<void> _fetchPincodesByCityId(String cityId) async {
    setState(() {
      _isLoadingPincodes = true;
      _pincodes = [];
      _selectedPincodeId = null;
    });
    try {
      final pincodes = await _pincodeService.getPincodeByCityId(cityId);
      setState(() {
        _pincodes = pincodes;
        if (_pincodes.isNotEmpty) {
          _selectedPincodeId = _pincodes.first.id;
        }
      });
    } catch (e) {
      debugPrint("Error fetching pincodes: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching pincodes: $e")),
      );
    } finally {
      setState(() {
        _isLoadingPincodes = false;
      });
    }
  }

  Future<void> _submitAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPincodeId == null ||
        _selectedCityId == null ||
        _selectedStateId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select Pincode, City, and State")),
      );
      return;
    }

    if (_userId == null || _createdById == null || _lastUpdatedById == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("User information is missing. Please try again.")),
      );
      return;
    }

    if (_selectedAddressType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an address type")),
      );
      return;
    }

    setState(() {
      _isLoadingStates = true;
    });

    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final formattedDate = formatter.format(now);

    final newAddress = {
      "first_name": _firstNameController.text.trim(),
      "last_name": _lastNameController.text.trim(),
      "house_number": _houseNumberController.text.trim(),
      "address": _addressController.text.trim(),
      "landmark": _landmarkController.text.trim(),
      "street": _streetController.text.trim(),
      "is_active": _isActive ? 1 : 0,
      "address_type": _selectedAddressType,
      "default_address": _defaultAddress ? 1 : 0,
      "created_date": formattedDate,
      "last_updated_date": formattedDate,
      "userId": _userId!,
      "pincodeId": _selectedPincodeId!,
      "cityId": _selectedCityId!,
      "stateId": _selectedStateId!,
      "createdById": _createdById!,
      "lastUpdatedById": _lastUpdatedById!,
    };

    try {
      final addedAddress = await _addressService.addNewAddress(newAddress);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Address added successfully")),
      );
      Navigator.pop(context, addedAddress);
    } catch (e) {
      debugPrint("Error adding address: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add address: $e")),
      );
    } finally {
      setState(() {
        _isLoadingStates = false;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _houseNumberController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(centerTitle: true, title: "Add Delivery Address"),
      body: _isLoadingStates
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextFormField("First Name",
                              _firstNameController, "First name is required"),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: _buildTextFormField("Last Name",
                              _lastNameController, "Last name is required"),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextFormField(
                              "House Number",
                              _houseNumberController,
                              "House number is required"),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: _buildTextFormField("Street",
                              _streetController, "Street is required"),
                        ),
                      ],
                    ),

                    _buildTextFormField("Address Line", _addressController,
                        "Address is required"),
                    _buildTextFormField("Landmark", _landmarkController, null),

                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Select Address Type",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Column(
                          children: _addressTypes.map((type) {
                            return CheckboxListTile(
                              title: Text(type),
                              value: _selectedAddressType == type,
                              onChanged: (isSelected) {
                                setState(() {
                                  if (isSelected == true) {
                                    _selectedAddressType = type;
                                  }
                                });
                              },
                               activeColor: Colors.red,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildDropdownButtonFormField(
                      "State",
                      _selectedStateId,
                      _states.map((state) {
                        return DropdownMenuItem(
                          value: state.id,
                          child: Text(state.state),
                        );
                      }).toList(),
                      (value) {
                        setState(() {
                          _selectedStateId = value;
                        });
                        if (value != null) {
                          _fetchCitiesByStateId(value);
                        }
                      },
                    ),
                    if (_selectedStateId != null) const SizedBox(height: 16),
                    if (_selectedStateId != null)
                      _isLoadingCities
                          ? Center(child: CircularProgressIndicator())
                          : _buildDropdownButtonFormField(
                              "City",
                              _selectedCityId,
                              _cities.map((city) {
                                return DropdownMenuItem(
                                  value: city.id,
                                  child: Text(city.city),
                                );
                              }).toList(),
                              (value) {
                                setState(() {
                                  _selectedCityId = value;
                                });
                                if (value != null) {
                                  _fetchPincodesByCityId(value);
                                }
                              },
                            ),
                    if (_selectedCityId != null) const SizedBox(height: 16),
                    if (_selectedCityId != null)
                      _isLoadingPincodes
                          ? Center(child: CircularProgressIndicator())
                          : _buildDropdownButtonFormField(
                              "Pincode",
                              _selectedPincodeId,
                              _pincodes.map((pincode) {
                                return DropdownMenuItem(
                                  value: pincode.id,
                                  child: Text(
                                      "${pincode.pincode}-${pincode.postOffice}"),
                                );
                              }).toList(),
                              (value) {
                                setState(() {
                                  _selectedPincodeId = value;
                                });
                              },
                            ),
                    const SizedBox(height: 16),
                    _buildSwitchListTile("Is Active", _isActive,
                        (value) => setState(() => _isActive = value)),
                    //   _buildSwitchListTile("Default Address", _defaultAddress,
                    //  (value) => setState(() => _defaultAddress = value)),
                    const SizedBox(height: 24),
              ElevatedButton(
  onPressed: _submitAddress,
  style: ElevatedButton.styleFrom(
    minimumSize: Size(double.infinity, 50),
    backgroundColor: Colors.red, // Set the button color to red
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8), // Set the corner radius to 5
    ),
  ),
  child: Text(
    "Add Address",
    style: TextStyle(color: Colors.white),
  ),
)


                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextFormField(
      String label, TextEditingController controller, String? errorText) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none, // Remove the border entirely
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: Colors.black,
                  width: 1.0), // Bottom border when not focused
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: Colors.black,
                  width: 1.0), // Bottom border when focused (thicker)
            ),
          ),
          validator: (value) {
            if (errorText != null && (value == null || value.trim().isEmpty)) {
              return errorText;
            }
            return null;
          },
        ));
  }

  Widget _buildDropdownButtonFormField(String label, String? value,
      List<DropdownMenuItem<String>> items, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      items: items,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please select $label";
        }
        return null;
      },
    );
  }

  Widget _buildSwitchListTile(
      String title, bool value, void Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.red,
    );
  }
}
