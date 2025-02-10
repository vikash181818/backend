import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_dukans_user/core/config/common_widgets/custom_app_bar.dart';
import 'package:online_dukans_user/features/user_profile/data/services/address_service.dart';
import 'package:online_dukans_user/features/user_profile/data/services/city_service.dart';
import 'package:online_dukans_user/features/user_profile/data/services/pincode_service.dart';
import 'package:online_dukans_user/features/user_profile/data/services/state_service.dart';
import 'package:online_dukans_user/features/user_profile/model/address_model.dart';
import 'package:online_dukans_user/features/user_profile/model/city_model.dart';
import 'package:online_dukans_user/features/user_profile/model/pincode_model.dart';
import 'package:online_dukans_user/features/user_profile/model/state_model.dart';
// import 'package:intl/intl.dart';
// import 'package:onlinedukans_user/core/config/common_widgets/custom_app_bar.dart';
// import 'package:onlinedukans_user/core/config/services/secure_storage_service.dart';
// import 'package:onlinedukans_user/core/config/utils/token_manager.dart';
// import 'package:onlinedukans_user/features/user_profile/data/services/address_service.dart';
// import 'package:onlinedukans_user/features/user_profile/data/services/city_service.dart';
// import 'package:onlinedukans_user/features/user_profile/data/services/pincode_service.dart';
// import 'package:onlinedukans_user/features/user_profile/data/services/state_service.dart';
// import 'package:onlinedukans_user/features/user_profile/model/address_model.dart';
// import 'package:onlinedukans_user/features/user_profile/model/city_model.dart';
// import 'package:onlinedukans_user/features/user_profile/model/pincode_model.dart';
// import 'package:onlinedukans_user/features/user_profile/model/state_model.dart';

class EditDeliveryAddressPage extends StatefulWidget {
  final String addressId;

  const EditDeliveryAddressPage({required this.addressId, super.key});

  @override
  State<EditDeliveryAddressPage> createState() =>
      _EditDeliveryAddressPageState();
}

class _EditDeliveryAddressPageState extends State<EditDeliveryAddressPage> {
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
  bool _defaultAddress = false;

  // Variable for address type
  String? _selectedAddressType;
  final List<String> _addressTypes = ['Home', 'Office', 'Other'];

  // Variables for dropdowns
  List<PincodeModel> _pincodes = [];
  List<CityModel> _cities = [];
  final List<StateModel> _states = [];
  String? _selectedPincodeId;
  String? _selectedCityId;
  String? _selectedStateId;

  bool _isLoading = true;
  bool _isUpdating = false;

  // Services
  final AddressService _addressService = AddressService();
  final PincodeService _pincodeService = PincodeService();
  final CityService _cityService = CityService();
  final StateService _stateService = StateService();

  // Address Data
  AddressModel? _address;

  @override
  void initState() {
    super.initState();
    _fetchAddressDetails();
  }

  Future<void> _fetchAddressDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final address = await _addressService.getAddressById(widget.addressId);

      setState(() {
        _address = address;

        // Populate fields
        _firstNameController.text = address.firstName ?? '';
        _lastNameController.text = address.lastName ?? '';
        _houseNumberController.text = address.houseNumber ?? '';
        _addressController.text = address.address ?? '';
        _landmarkController.text = address.landmark ?? '';
        _streetController.text = address.street ?? '';
        _isActive = address.isActive == 1;
        _defaultAddress = address.defaultAddress == 1;
        _selectedAddressType = address.addressType ?? 'Home';
        _selectedStateId = address.stateId;
        _selectedCityId = address.cityId;
        _selectedPincodeId = address.pincodeId;

        if (_selectedStateId != null) {
          _fetchStateByStateId(_selectedStateId!);
        }

        if (_selectedStateId != null) {
          _fetchCitiesByStateId(_selectedStateId!);
        }
        if (_selectedCityId != null) {
          _fetchPincodesByCityId(_selectedCityId!);
        }
      });
    } catch (e) {
      debugPrint("Error fetching address: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching address: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCitiesByStateId(String stateId) async {
    try {
      final cities = await _cityService.getCitiesByStateId(stateId);
      setState(() {
        _cities = cities;
      });
    } catch (e) {
      debugPrint("Error fetching cities: $e");
    }
  }

  Future<void> _fetchPincodesByCityId(String cityId) async {
    try {
      final pincodes = await _pincodeService.getPincodeByCityId(cityId);
      setState(() {
        _pincodes = pincodes;
      });
    } catch (e) {
      debugPrint("Error fetching pincodes: $e");
    }
  }

  Future<void> _submitAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAddressType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an address type")),
      );
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final formattedDate = formatter.format(now);

    final updatedAddress = AddressModel(
      id: widget.addressId,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      houseNumber: _houseNumberController.text.trim(),
      address: _addressController.text.trim(),
      landmark: _landmarkController.text.trim(),
      street: _streetController.text.trim(),
      isActive: _isActive ? 1 : 0,
      addressType: _selectedAddressType!,
      defaultAddress: _defaultAddress ? 1 : 0,
      createdDate: _address?.createdDate ?? formattedDate,
      lastUpdatedDate: formattedDate,
      userId: _address?.userId ?? "",
      pincodeId: _selectedPincodeId!,
      cityId: _selectedCityId!,
      stateId: _selectedStateId!,
      createdById: _address?.createdById ?? "",
      lastUpdatedById: _address?.lastUpdatedById ?? "",
    );

    try {
      await _addressService.updateAddress(widget.addressId, updatedAddress);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Address updated successfully")),
      );
      Navigator.pop(context, updatedAddress);
    } catch (e) {
      debugPrint("Error updating address: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update address: $e")),
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(centerTitle: true, title: "Edit Delivery Address"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextFormField("First Name", _firstNameController,
                        "First name is required"),
                    _buildTextFormField("Last Name", _lastNameController,
                        "Last name is required"),
                    _buildTextFormField("House Number", _houseNumberController,
                        "House number is required"),
                    _buildTextFormField(
                        "Address", _addressController, "Address is required"),
                    _buildTextFormField("Landmark", _landmarkController, null),
                    _buildTextFormField("Street", _streetController, null),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
                    _buildDropdownButtonFormField(
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
                    const SizedBox(height: 16),
                    _buildDropdownButtonFormField(
                      "Pincode",
                      _selectedPincodeId,
                      _pincodes.map((pincode) {
                        return DropdownMenuItem(
                          value: pincode.id,
                          child: Text(pincode.pincode.toString()),
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
                    //  _buildSwitchListTile("Default Address", _defaultAddress,
                    //  (value) => setState(() => _defaultAddress = value)),
                    const SizedBox(height: 24),
                    ElevatedButton(
  onPressed: _isUpdating ? null : _submitAddress,
  style: ElevatedButton.styleFrom(
    minimumSize: const Size(double.infinity, 50),
    backgroundColor: Colors.red, // Set the button color to red
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8), // Set the corner radius to 8
    ),
  ),
  child: _isUpdating
      ? const CircularProgressIndicator()
      : const Text(
          "Update Address",
          style: TextStyle(color: Colors.white), // Text color set to white
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
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (errorText != null && (value == null || value.trim().isEmpty)) {
            return errorText;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownButtonFormField(String label, String? value,
      List<DropdownMenuItem<String>> items, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
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

  void _fetchStateByStateId(String stateId) async {
    try {
      final state = await _stateService.getStateById(stateId);
      setState(() {
        // Add the fetched state to the states list if not already present
        if (!_states.any((s) => s.id == state.id)) {
          _states.add(state);
        }
        // Set the selected state ID to the one fetched
        _selectedStateId = state.id;
      });
    } catch (e) {
      debugPrint("Error fetching state by ID: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching state: $e")),
      );
    }
  }
}
