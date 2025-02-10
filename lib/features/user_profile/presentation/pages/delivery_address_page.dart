import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:online_dukans_user/core/config/common_widgets/custom_app_bar.dart';
import 'package:online_dukans_user/core/config/services/secure_storage_service.dart';
import 'package:online_dukans_user/core/config/utils/token_manager.dart';
import 'package:online_dukans_user/features/user_profile/data/services/address_service.dart';
import 'package:online_dukans_user/features/user_profile/data/services/city_service.dart';
import 'package:online_dukans_user/features/user_profile/data/services/pincode_service.dart';
import 'package:online_dukans_user/features/user_profile/data/services/state_service.dart';
import 'package:online_dukans_user/features/user_profile/model/address_model.dart';
// import 'package:onlinedukans_user/core/config/common_widgets/custom_app_bar.dart';
// import 'package:onlinedukans_user/features/user_profile/data/services/address_service.dart';
// import 'package:onlinedukans_user/features/user_profile/data/services/city_service.dart';
// import 'package:onlinedukans_user/features/user_profile/data/services/pincode_service.dart';
// import 'package:onlinedukans_user/features/user_profile/data/services/state_service.dart';
// import 'package:onlinedukans_user/features/user_profile/model/address_model.dart';
// import 'package:onlinedukans_user/core/config/services/secure_storage_service.dart';
// import 'package:onlinedukans_user/core/config/utils/token_manager.dart';

class DeliveryAddressesPage extends StatefulWidget {
  const DeliveryAddressesPage({super.key});

  @override
  State<DeliveryAddressesPage> createState() => _DeliveryAddressesPageState();
}

class _DeliveryAddressesPageState extends State<DeliveryAddressesPage> {
  final AddressService _addressService = AddressService();
  final CityService _cityService = CityService();
  final StateService _stateService = StateService();
  final PincodeService _pincodeService = PincodeService();
  final TokenManager _tokenManager = TokenManager(SecureStorageService());

  List<AddressModel> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _tokenManager.getUser();
      final userId = user?['id'];

      if (userId == null) {
        throw Exception("User ID not found");
      }

      final addresses = await _addressService.getAddressesByUserId(userId);

      for (var address in addresses) {
        address.city = await _fetchCityNameById(address.cityId);
        address.state = await _fetchStateNameById(address.stateId);
        address.pincode = await _fetchPincodeById(address.pincodeId);
      }

      setState(() {
        _addresses = addresses;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$error")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _fetchCityNameById(String? cityId) async {
    try {
      if (cityId == null) return "Unknown City";
      final city = await _cityService.getCityByCityId(cityId);
      return city.city;
    } catch (e) {
      debugPrint("Error fetching city name: $e");
      return "Unknown City";
    }
  }

  Future<String> _fetchStateNameById(String? stateId) async {
    try {
      if (stateId == null) return "Unknown State";
      final state = await _stateService.getStateById(stateId);
      return state.state;
    } catch (e) {
      debugPrint("Error fetching state name: $e");
      return "Unknown State";
    }
  }

  Future<String> _fetchPincodeById(String? pincodeId) async {
    try {
      if (pincodeId == null) return "Unknown Pincode";
      final pincode = await _pincodeService.getPincodeById(pincodeId);
      return pincode.pincode.toString();
    } catch (e) {
      debugPrint("Error fetching pincode: $e");
      return "Unknown Pincode";
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    try {
      await _addressService.deleteAddress(addressId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Address deleted successfully")),
      );
      _fetchAddresses(); // Refresh the list after deletion
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting address: $error")),
      );
    }
  }

  Future<void> _setDefaultAddress(String userId, String addressId) async {
    try {
      await _addressService.setDefaultAddress(userId, addressId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Default address set successfully")),
      );
      _fetchAddresses(); // Refresh the list after updating default address
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error setting default address: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(centerTitle: true, title: "My Delivery Addresses"),
      body: Column(
        children: [
          // Green Container at the top (Fixed)
          Container(
              height: 60,
              color: Color.fromARGB(255, 124, 175, 76),
              width: double.infinity,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to the "Add New Delivery Address" page when the container is tapped
                        context.push("/add_new_delivery_address");
                      },
                      child: Container(
                        height: 40,
                        width: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(0.0),
                            topRight: Radius.circular(10.0),
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(0.0),
                          ),
                          color: Colors.red,
                        ),
                        child: Center(
                          child: const Text(
                            '+ Add New Address',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    )),
              )),
          // List of addresses (Scrollable)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _addresses.isEmpty
                    ? const Center(child: Text("No addresses found"))
                    : ListView.builder(
                        itemCount: _addresses.length,
                        itemBuilder: (context, index) {
                          final address = _addresses[index];
                          final userId = address.userId;
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    "${address.firstName} ${address.lastName}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Column containing the address details
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                "Address: ${address.houseNumber}, ${address.address}"),
                                            Text(
                                                "Landmark: ${address.landmark ?? "N/A"}"),
                                            Text(
                                                "Street: ${address.street ?? "N/A"}"),
                                            Text("Pincode: ${address.pincode}"),
                                            Text("City: ${address.city}"),
                                            Text("State: ${address.state}"),
                                          ],
                                        ),
                                      ),
                                      // Green tick for default address
                                      if (address.defaultAddress == 1)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 25.0),
                                          child: const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 24,
                                          ),
                                        ),
                                      // Set default button
                                      if (address.defaultAddress != 1)
                                        TextButton(
                                          child: const Text("Set Default",
                                              style: TextStyle(
                                                  color: Colors.green)),
                                          onPressed: () {
                                            if (userId != null) {
                                              _setDefaultAddress(
                                                  userId, address.id!);
                                            }
                                          },
                                        ),
                                      // Column for Edit and Delete buttons
                                      Column(
                                        children: [
                                          // Edit button inside rounded container
                                          Container(
                                            height: 40,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.blue),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: TextButton(
                                              onPressed: () async {
                                                await context.push(
                                                    "/edit_delivery_address/${address.id}");
                                                _fetchAddresses();
                                              },
                                              child: const Text(
                                                'Edit',
                                                style: TextStyle(
                                                    color: Colors.blue),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                              height:
                                                  30), // Space between Edit and Delete buttons
                                          // Delete button inside rounded container
                                          Container(
                                            height: 40,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              border:
                                                  Border.all(color: Colors.red),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: TextButton(
                                              onPressed: () async {
                                                final confirmDelete =
                                                    await showDialog<bool>(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          "Delete Address"),
                                                      content: const Text(
                                                          "Are you sure you want to delete this address?"),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(false),
                                                          child: const Text(
                                                              "Cancel"),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(true),
                                                          child: const Text(
                                                              "Delete"),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );

                                                if (confirmDelete == true) {
                                                  _deleteAddress(address.id!);
                                                }
                                              },
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(
                                    color: Colors
                                        .green), // Green divider after each address
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     await context.push("/add_new_delivery_address");
      //     _fetchAddresses();
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
