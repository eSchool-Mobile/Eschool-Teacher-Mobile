import 'package:eschool_saas_staff/data/models/staffTeacher/payment.dart';
import 'package:flutter/foundation.dart';

class PaidFeeDetails {
  final int? id;
  final int? feesId;
  final int? studentId;
  final bool isFullyPaid;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final List<PaymentHistory> paymentHistory;

  PaidFeeDetails({
    this.id,
    this.feesId,
    this.studentId,
    required this.isFullyPaid,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.paymentHistory,
  });

  PaidFeeDetails copyWith({
    int? id,
    int? feesId,
    int? studentId,
    bool? isFullyPaid,
    double? totalAmount,
    double? paidAmount,
    double? remainingAmount,
    List<PaymentHistory>? paymentHistory,
  }) {
    return PaidFeeDetails(
      id: id ?? this.id,
      feesId: feesId ?? this.feesId,
      studentId: studentId ?? this.studentId,
      isFullyPaid: isFullyPaid ?? this.isFullyPaid,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      paymentHistory: paymentHistory ?? this.paymentHistory,
    );
  }

  factory PaidFeeDetails.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('payment_status')) {
      final paymentStatus = PaymentStatus.fromJson(
          Map<String, dynamic>.from(json['payment_status'] ?? {}));

      final List<PaymentHistory> history = [];
      if (json.containsKey('payment_history')) {
        if (json['payment_history'] is List) {
          history.addAll((json['payment_history'] as List)
              .map((item) => PaymentHistory.fromJson(
                  Map<String, dynamic>.from(item ?? {})))
              .toList());
        } else if (json['payment_history'] is Map) {
          try {
            final Map<String, dynamic> paymentMap =
                Map<String, dynamic>.from(json['payment_history']);
            final values = paymentMap.values.toList();
            if (values.isNotEmpty) {
              history.addAll(values
                  .map((item) => PaymentHistory.fromJson(
                      Map<String, dynamic>.from(item ?? {})))
                  .toList());
            }
          } catch (e) {
            debugPrint("Error parsing payment_history: $e");
          }
        }
      }

      return PaidFeeDetails(
        id: json['id'] as int?,
        feesId: json['fees_id'] as int?,
        studentId: json['student_id'] as int?,
        isFullyPaid: paymentStatus.isFullyPaid,
        totalAmount: paymentStatus.totalAmount,
        paidAmount: paymentStatus.paidAmount,
        remainingAmount: paymentStatus.remainingAmount,
        paymentHistory: history,
      );
    } else {
      return PaidFeeDetails(
        id: json['id'] as int?,
        feesId: json['fees_id'] as int?,
        studentId: json['student_id'] as int?,
        isFullyPaid: (json['is_fully_paid'] as int?) == 1,
        totalAmount: double.parse(
            (json['total_amount'] ?? json['amount'] ?? 0).toString()),
        paidAmount: double.parse((json['amount'] ?? 0).toString()),
        remainingAmount: 0.0,
        paymentHistory: [],
      );
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fees_id': feesId,
        'student_id': studentId,
        'is_fully_paid': isFullyPaid,
        'total_amount': totalAmount,
        'paid_amount': paidAmount,
        'remaining_amount': remainingAmount,
        'payment_history': paymentHistory
            .map((p) => {
                  'id': p.id,
                  'amount': p.amount,
                  'payment_date': p.paymentDate,
                  'payment_method': p.paymentMethod,
                  'proof_image': p.proofImage,
                })
            .toList(),
      };
}
