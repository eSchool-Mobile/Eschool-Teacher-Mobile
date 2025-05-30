// Updated model for payment status
class PaymentStatus {
  final bool isFullyPaid;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;

  PaymentStatus({
    required this.isFullyPaid,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
  });
  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    // Handle boolean value for is_fully_paid
    bool isFullyPaid = false;
    if (json['is_fully_paid'] is bool) {
      isFullyPaid = json['is_fully_paid'];
    } else if (json['is_fully_paid'] != null) {
      final value = json['is_fully_paid'].toString().toLowerCase();
      isFullyPaid = value == 'true' || value == '1' || value == 'yes';
    }

    // Safely parse numeric values
    double totalAmount = 0.0;
    double paidAmount = 0.0;
    double remainingAmount = 0.0;

    try {
      totalAmount = double.parse((json['total_amount'] ?? 0.0).toString());
    } catch (e) {
      print("Error parsing total_amount: $e");
    }

    try {
      paidAmount = double.parse((json['paid_amount'] ?? 0.0).toString());
    } catch (e) {
      print("Error parsing paid_amount: $e");
    }

    try {
      remainingAmount =
          double.parse((json['remaining_amount'] ?? 0.0).toString());
    } catch (e) {
      print("Error parsing remaining_amount: $e");
    }

    return PaymentStatus(
      isFullyPaid: isFullyPaid,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      remainingAmount: remainingAmount,
    );
  }
}

// Updated model for payment history
class PaymentHistory {
  final int id;
  final double amount;
  final String paymentDate;
  final String paymentMethod;
  final String? proofImage;

  PaymentHistory({
    required this.id,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    this.proofImage,
  });
  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    // Safely extract id field by handling multiple types
    int id = 0;
    if (json['id'] is int) {
      id = json['id'];
    } else if (json['id'] != null) {
      id = int.tryParse(json['id'].toString()) ?? 0;
    }

    // Safely parse amount with error handling
    double amount = 0.0;
    try {
      amount = double.parse((json['amount'] ?? 0.0).toString());
    } catch (e) {
      print("Error parsing amount in PaymentHistory: $e");
    }

    return PaymentHistory(
      id: id,
      amount: amount,
      paymentDate: json['payment_date']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      proofImage: json['proof_image']?.toString(),
    );
  }
}

// Updated model for class section
class ClassSection {
  final String className;
  final String section;

  ClassSection({
    required this.className,
    required this.section,
  });

  String get fullName => "$className $section";
  factory ClassSection.fromJson(Map<String, dynamic> json) {
    return ClassSection(
      className: json['class']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
    );
  }
}
