import 'package:flutter/material.dart';
import 'package:eldcare/admin/presentation/adminstyles/adminstyles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/admin/blocs/delivery_charges/delivery_charges_bloc.dart';

class DeliveryChargesPage extends StatefulWidget {
  const DeliveryChargesPage({super.key});

  @override
  DeliveryChargesPageState createState() => DeliveryChargesPageState();
}

class DeliveryChargesPageState extends State<DeliveryChargesPage> {
  final _formKey = GlobalKey<FormState>();
  final _baseChargeController = TextEditingController();
  final _perKmChargeController = TextEditingController();
  final _minimumOrderValueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<DeliveryChargesBloc>().add(LoadDeliveryCharges());
  }

  @override
  void dispose() {
    _baseChargeController.dispose();
    _perKmChargeController.dispose();
    _minimumOrderValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Charges Setup',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: AdminStyles.primaryColor,
      ),
      body: BlocConsumer<DeliveryChargesBloc, DeliveryChargesState>(
        listener: (context, state) {
          if (state is DeliveryChargesLoaded) {
            _baseChargeController.text = state.charges.baseCharge.toString();
            _perKmChargeController.text = state.charges.perKmCharge.toString();
            _minimumOrderValueController.text =
                state.charges.minimumOrderValue.toString();
          } else if (state is DeliveryChargesSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Delivery charges saved successfully')),
            );
          }
        },
        builder: (context, state) {
          if (state is DeliveryChargesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state is DeliveryChargesLoaded
                          ? 'Update Delivery Charges'
                          : 'Set Delivery Charges',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AdminStyles.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _baseChargeController,
                      label: 'Base Charge (₹)',
                      icon: Icons.monetization_on,
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _perKmChargeController,
                      label: 'Per Km Charge (₹)',
                      icon: Icons.directions_car,
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _minimumOrderValueController,
                      label: 'Minimum Order Value for Free Delivery (₹)',
                      icon: Icons.shopping_cart,
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminStyles.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            state is DeliveryChargesLoaded
                                ? 'Update Charges'
                                : 'Save Charges',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AdminStyles.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          if (double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<DeliveryChargesBloc>().add(SaveDeliveryCharges(
            baseCharge: double.parse(_baseChargeController.text),
            perKmCharge: double.parse(_perKmChargeController.text),
            minimumOrderValue: double.parse(_minimumOrderValueController.text),
          ));
    }
  }
}
