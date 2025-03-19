import 'package:eldcare/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:eldcare/elduser/blocs/appointment/appointment_bloc.dart';
import 'package:eldcare/elduser/blocs/appointment/appointment_event.dart';
import 'package:eldcare/elduser/blocs/appointment/appointment_state.dart';
import 'package:eldcare/shared/models/appointment.dart';
import 'package:intl/intl.dart';

class BookAppointmentScreen extends StatefulWidget {
  final Appointment appointmentToBook;
  final double? consultationFee;

  const BookAppointmentScreen({
    super.key,
    required this.appointmentToBook,
    this.consultationFee,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  late Razorpay _razorpay;
  bool _isProcessing = false;
  String? _pendingAppointmentId;
  double? _consultationFee;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _consultationFee = widget.consultationFee ??
        widget.appointmentToBook.consultationFee ??
        500.0;

    print("Initial consultation fee: $_consultationFee");
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("Payment successful with ID: ${response.paymentId}");

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment successful!')),
    );

    // Send payment completion event
    context.read<AppointmentBloc>().add(
          CompleteAppointmentPayment(
            appointmentId: _pendingAppointmentId ?? '',
            paymentId: response.paymentId ?? '',
            success: true,
          ),
        );

    // Force navigation after a short delay to ensure DB operations start
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        // Refresh appointments
        final userId = widget.appointmentToBook.userId;
        if (userId.isNotEmpty) {
          context.read<AppointmentBloc>().add(FetchUserAppointments(userId));
        }

        // Navigate back regardless of bloc state
        Navigator.of(context).pop(true);
      }
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Payment failed: ${response.message ?? "Error occurred"}')),
    );
    context.read<AppointmentBloc>().add(
          CompleteAppointmentPayment(
            appointmentId: _pendingAppointmentId ?? '',
            paymentId: '',
            success: false,
          ),
        );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('External wallet selected: ${response.walletName}')),
    );
  }

  void _initiatePayment() {
    setState(() {
      _isProcessing = true;
    });

    context.read<AppointmentBloc>().add(
          InitiateAppointmentPayment(widget.appointmentToBook),
        );
  }

  void _openRazorpayCheckout(Map<String, dynamic> paymentDetails) {
    setState(() {
      _pendingAppointmentId = paymentDetails['appointmentId'];
    });

    var options = {
      'key': Config.razorpayKey,
      'amount': _consultationFee! * 100,
      'name': 'EldCare',
      'description': paymentDetails['description'] ??
          'Consultation with ${widget.appointmentToBook.doctorName}',
      'order_id': paymentDetails['orderId'] ?? '',
      'prefill': {
        'contact': paymentDetails['userPhone'] ?? '',
        'email': paymentDetails['userEmail'] ?? '',
        'name': widget.appointmentToBook.userName
      },
      'theme': {
        'color': '#4CAF50',
      },
      'notes': {
        'appointmentId': _pendingAppointmentId ?? '',
        'doctorName': widget.appointmentToBook.doctorName,
        'appointmentTime': DateFormat('yyyy-MM-dd HH:mm')
            .format(widget.appointmentToBook.appointmentTime),
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing payment: $e')),
      );
    }
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    final double consultationFee = _consultationFee ?? 500.0;
    final double tax = 0.0;
    final double totalAmount = consultationFee + tax;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
      ),
      body: BlocConsumer<AppointmentBloc, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentPaymentInitiated) {
            setState(() {
              _pendingAppointmentId = state.pendingAppointmentId;
              _isProcessing = false;
            });
            _openRazorpayCheckout(state.paymentDetails);
          } else if (state is AppointmentActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );

            // Make sure to refresh appointments before navigation
            final userId = widget.appointmentToBook.userId;
            if (userId.isNotEmpty) {
              context
                  .read<AppointmentBloc>()
                  .add(FetchUserAppointments(userId));
            }

            Navigator.of(context).pop(true);
          } else if (state is AppointmentActionFailure) {
            setState(() {
              _isProcessing = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Appointment Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                            'Doctor', widget.appointmentToBook.doctorName),
                        _buildInfoRow(
                            'Date',
                            dateFormat.format(
                                widget.appointmentToBook.appointmentDate)),
                        _buildInfoRow(
                            'Time',
                            timeFormat.format(
                                widget.appointmentToBook.appointmentTime)),
                        _buildInfoRow('Duration',
                            '${widget.appointmentToBook.durationMinutes} minutes'),
                        _buildInfoRow('Reason for visit',
                            widget.appointmentToBook.reason),
                        const Divider(height: 32),
                        const Text(
                          'Payment Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('Consultation Fee',
                            _formatCurrency(consultationFee)),
                        _buildInfoRow('Tax', _formatCurrency(tax)),
                        const Divider(height: 16),
                        _buildInfoRow(
                            'Total Amount', _formatCurrency(totalAmount),
                            isBold: true),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Payment Terms:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Payment must be completed to confirm your appointment\n'
                  '• The consultation fee is non-refundable if cancelled less than 12 hours before the appointment\n'
                  '• You will receive a digital receipt after successful payment',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed:
                      _isProcessing || state is AppointmentActionInProgress
                          ? null
                          : _initiatePayment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.green,
                  ),
                  child: state is AppointmentActionInProgress || _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Proceed to Payment',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
