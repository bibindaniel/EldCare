import 'package:flutter/material.dart';
import 'package:eldcare/core/theme/colors.dart';
import 'package:eldcare/core/theme/font.dart';
import 'package:eldcare/elduser/models/order.dart';
import 'package:lottie/lottie.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eldcare/pharmacy/model/shop.dart';

class OrderDetailsScreen extends StatefulWidget {
  final MedicineOrder order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Shop? shopDetails;
  String userName = '';

  @override
  void initState() {
    super.initState();
    _fetchShopDetails();
    _fetchUserDetails();
  }

  Future<void> _fetchShopDetails() async {
    try {
      final shopDoc = await FirebaseFirestore.instance
          .collection('shops')
          .doc(widget.order.shopId)
          .get();

      if (shopDoc.exists) {
        final data = shopDoc.data() as Map<String, dynamic>;
        data['id'] = shopDoc.id;
        setState(() {
          shopDetails = Shop.fromMap(data);
        });
      }
    } catch (e) {
      print('Error fetching shop details: $e');
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.order.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc.data()?['name'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${widget.order.id}', style: AppFonts.appBarTitle),
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildOrderStatus(),
            _buildOrderTimeline(),
            _buildOrderSummary(),
            _buildOrderItems(),
            // _buildDeliveryAddress(),
            _buildDownloadBillButton(context),
            _buildBackToHomeButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatus() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: kLightPrimaryColor,
              shape: BoxShape.circle,
            ),
            child: Lottie.asset(_getStatusAnimation(), width: 100, height: 100),
          ),
          const SizedBox(height: 16),
          Text(_getStatusTitle(),
              style: AppFonts.headline4.copyWith(color: kPrimaryColor)),
          const SizedBox(height: 8),
          Text(
            _getStatusDescription(),
            style: AppFonts.bodyText2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTimeline() {
    final List<Map<String, dynamic>> stages = [
      {
        'icon': Icons.check_circle_outline,
        'title': 'Order Placed',
        'isCompleted': true,
      },
      {
        'icon': Icons.local_pharmacy_outlined,
        'title': 'Confirmed by Pharmacy',
        'isCompleted': [
          'readyForPickup',
          'assignedToDelivery',
          'inTransit',
          'completed'
        ].contains(widget.order.status),
      },
      {
        'icon': Icons.local_shipping_outlined,
        'title': 'Out for Delivery',
        'isCompleted': ['inTransit', 'completed'].contains(widget.order.status),
      },
      {
        'icon': Icons.done_all,
        'title': 'Delivered',
        'isCompleted': widget.order.status == 'completed',
      },
    ];

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Timeline', style: AppFonts.headline5),
            const SizedBox(height: 16),
            ...List.generate(stages.length, (index) {
              final stage = stages[index];
              final isLast = index == stages.length - 1;

              return TimelineTile(
                alignment: TimelineAlign.start,
                isFirst: index == 0,
                isLast: isLast,
                indicatorStyle: IndicatorStyle(
                  width: 24,
                  color: stage['isCompleted'] ? kSuccessColor : kNeutralColor,
                  iconStyle: IconStyle(
                    color: Colors.white,
                    iconData: stage['isCompleted'] ? Icons.check : Icons.circle,
                  ),
                ),
                endChild: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    stage['title'],
                    style: (stage['isCompleted']
                            ? AppFonts.bodyText1Colored
                            : AppFonts.bodyText1)
                        .copyWith(
                            color: stage['isCompleted']
                                ? kSuccessColor
                                : kSecondaryTextColor),
                  ),
                ),
                beforeLineStyle: LineStyle(
                  color: stage['isCompleted'] ? kSuccessColor : kNeutralColor,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Summary',
                style: AppFonts.headline5.copyWith(color: kPrimaryColor)),
            const Divider(height: 24, thickness: 1),
            if (shopDetails != null) ...[
              Text('Pharmacy Details',
                  style: AppFonts.bodyText2.copyWith(color: kPrimaryColor)),
              const SizedBox(height: 8),
              _buildSummaryItem('Name', shopDetails!.name),
              _buildSummaryItem('License No.', shopDetails!.licenseNumber),
              _buildSummaryItem('Phone', shopDetails!.phoneNumber),
              _buildSummaryItem('Email', shopDetails!.email),
              const Divider(height: 16, thickness: 1),
            ],
            Text('Order Details',
                style: AppFonts.bodyText2.copyWith(color: kPrimaryColor)),
            const SizedBox(height: 8),
            _buildSummaryItem('Order ID', '#${widget.order.id}'),
            _buildSummaryItem('Total Amount',
                '₹${widget.order.totalAmount.toStringAsFixed(2)}'),
            _buildSummaryItem('Status', _getStatusTitle()),
            _buildSummaryItem('Placed on', _formatDate(widget.order.createdAt)),
            _buildSummaryItem('Payment ID', widget.order.paymentId),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppFonts.bodyText2.copyWith(color: kSecondaryTextColor)),
          Text(value,
              style: AppFonts.bodyText1
                  .copyWith(fontWeight: FontWeight.bold, color: kTextColor)),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Items',
                style: AppFonts.headline5.copyWith(color: kPrimaryColor)),
            const Divider(height: 24, thickness: 1),
            ...widget.order.items.map((item) => _buildOrderItemRow(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemRow(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${item.medicineName} x${item.quantity}',
              style: AppFonts.bodyText2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '₹${(item.price * item.quantity).toStringAsFixed(2)}',
            style: AppFonts.bodyText2Colored,
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadBillButton(context) {
    if (widget.order.status != 'completed') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        onPressed: () => _generateAndDownloadBill(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccentColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.download, color: Colors.white),
            const SizedBox(width: 8),
            Text('Download Bill',
                style: AppFonts.button.copyWith(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Future<void> _generateAndDownloadBill(BuildContext context) async {
    try {
      // Request storage permission for Android
      if (Platform.isAndroid) {
        // For Android 13 and above (SDK 33+)
        if (await Permission.storage.isDenied) {
          final status = await Permission.storage.request();
          if (!status.isGranted) {
            // Also try requesting manage external storage permission
            final manageStatus =
                await Permission.manageExternalStorage.request();
            if (!manageStatus.isGranted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Storage permission is required to download the bill'),
                  backgroundColor: kErrorColor,
                ),
              );
              return;
            }
          }
        }
      }

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generating bill...'),
          backgroundColor: kPrimaryColor,
          duration: Duration(seconds: 1),
        ),
      );

      final pdf = pw.Document();

      // Add pages to the PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              _buildHeader(),
              pw.SizedBox(height: 20),
              _buildOrderInfo(),
              pw.SizedBox(height: 20),
              _buildItemsTable(),
              pw.SizedBox(height: 20),
              _buildTotal(),
              pw.SizedBox(height: 40),
              _buildFooter(),
            ];
          },
        ),
      );

      // Get the downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        // For Android 11 (API level 30) and above
        if (await Permission.manageExternalStorage.request().isGranted) {
          directory = Directory('/storage/emulated/0/Download');
        } else {
          final dirs = await getExternalStorageDirectories();
          directory = dirs?.first;
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      final String filePath =
          '${directory.path}/Order_${widget.order.id}_bill.pdf';

      // Save the PDF file
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bill downloaded to Downloads folder'),
          backgroundColor: kSuccessColor,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Error generating PDF: $e'); // For debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating bill: ${e.toString()}'),
          backgroundColor: kErrorColor,
        ),
      );
    }
  }

  pw.Widget _buildHeader() {
    return pw.Container(
      decoration: pw.BoxDecoration(
          border: pw.Border(
              bottom: pw.BorderSide(width: 2, color: PdfColors.grey300))),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (shopDetails != null) ...[
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Shop Details (Left Side)
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        shopDetails!.name.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.teal900,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Container(
                        padding: const pw.EdgeInsets.only(left: 2),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              shopDetails!.address,
                              style: const pw.TextStyle(
                                fontSize: 11,
                                color: PdfColors.grey800,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Phone: ${shopDetails!.phoneNumber}',
                              style: const pw.TextStyle(fontSize: 11),
                            ),
                            pw.Text(
                              'Email: ${shopDetails!.email}',
                              style: const pw.TextStyle(fontSize: 11),
                            ),
                            pw.Text(
                              'License No: ${shopDetails!.licenseNumber}',
                              style: const pw.TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Invoice Details (Right Side)
                pw.Container(
                  width: 200,
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.teal50,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.teal900,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Invoice No:',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        '#${widget.order.id}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Date:',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        DateFormat('dd MMMM yyyy, HH:mm')
                            .format(widget.order.createdAt),
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          pw.SizedBox(height: 20),
        ],
      ),
    );
  }

  pw.Widget _buildOrderInfo() {
    return pw.Container(
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.grey100,
      ),
      padding: const pw.EdgeInsets.all(15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'BILLING DETAILS',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal900,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Delivery Address
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Delivery Address:',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '${widget.order.deliveryAddress.address.houseName}\n'
                      '${widget.order.deliveryAddress.address.street}\n'
                      '${widget.order.deliveryAddress.address.city}, '
                      '${widget.order.deliveryAddress.address.state}\n'
                      'PIN: ${widget.order.deliveryAddress.address.postalCode}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              // Order Details
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Contact Details:',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Phone: ${widget.order.phoneNumber}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Payment Details:',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Payment ID: ${widget.order.paymentId}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildItemsTable() {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColors.teal50,
          ),
          children: [
            _buildTableHeader('Item Description'),
            _buildTableHeader('Qty'),
            _buildTableHeader('Price'),
            _buildTableHeader('Amount'),
          ],
        ),
        // Items
        ...widget.order.items.map((item) => pw.TableRow(
              children: [
                _buildTableCell(item.medicineName),
                _buildTableCell(item.quantity.toString(),
                    align: pw.TextAlign.center),
                _buildTableCell('₹${item.price.toStringAsFixed(2)}',
                    align: pw.TextAlign.right),
                _buildTableCell(
                  '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                  align: pw.TextAlign.right,
                ),
              ],
            )),
      ],
    );
  }

  pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.teal900,
        ),
      ),
    );
  }

  pw.Widget _buildTableCell(String text,
      {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 11),
        textAlign: align,
      ),
    );
  }

  pw.Widget _buildTotal() {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 200,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: pw.BoxDecoration(
                color: PdfColors.teal50,
                border: pw.Border.all(color: PdfColors.teal900),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Amount:',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.teal900,
                    ),
                  ),
                  pw.Text(
                    '₹${widget.order.totalAmount.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.teal900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.SizedBox(height: 20),
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          padding: const pw.EdgeInsets.all(10),
          child: pw.Column(
            children: [
              pw.Text(
                'Thank you for your purchase!',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.teal900,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                'For any queries, please contact our support team.',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          'This is a computer-generated invoice and does not require a signature.',
          style: pw.TextStyle(
            fontSize: 9,
            color: PdfColors.grey600,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildBackToHomeButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: OutlinedButton(
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: kPrimaryColor),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home, color: kPrimaryColor),
            const SizedBox(width: 8),
            Text('Back to home',
                style: AppFonts.button
                    .copyWith(color: kPrimaryColor, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  String _getStatusAnimation() {
    switch (widget.order.status) {
      case 'pending':
        return 'assets/animations/pending.json';
      case 'confirmed':
        return 'assets/animations/waiting.json';
      case 'readyForPickup':
      case 'assignedToDelivery':
        return 'assets/animations/waiting.json';
      case 'inTransit':
        return 'assets/animations/delivery.json';
      case 'completed':
        return 'assets/animations/completed.json';
      case 'cancelled':
        return 'assets/animations/cancelled.json';
      default:
        return 'assets/animations/waiting.json';
    }
  }

  String _getStatusTitle() {
    switch (widget.order.status) {
      case 'pending':
        return 'Order Placed';
      case 'confirmed':
        return 'Order Confirmed';
      case 'readyForPickup':
        return 'Ready for Pickup';
      case 'assignedToDelivery':
      case 'inTransit':
        return 'Out for Delivery';
      case 'completed':
        return 'Order Delivered';
      case 'cancelled':
        return 'Order Cancelled';
      default:
        return 'Processing Order';
    }
  }

  String _getStatusDescription() {
    switch (widget.order.status) {
      case 'pending':
        return 'Your order has been placed and is awaiting confirmation from the pharmacy.';
      case 'confirmed':
        return 'The pharmacy has confirmed your order and is preparing it.';
      case 'readyForPickup':
        return 'Your order is ready and waiting for a delivery person to pick it up.';
      case 'assignedToDelivery':
        return 'A delivery person has been assigned to your order.';
      case 'inTransit':
        return 'Your order is on its way to you.';
      case 'completed':
        return 'Your order has been delivered. Enjoy!';
      case 'cancelled':
        return 'We\'re sorry, but your order has been cancelled.';
      default:
        return 'We\'re processing your order. Please wait for updates.';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
