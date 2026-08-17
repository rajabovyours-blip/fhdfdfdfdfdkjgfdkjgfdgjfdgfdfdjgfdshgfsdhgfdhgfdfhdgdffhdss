class SellerVerificationEntity {
  final String status;
  final String? rejectionReason;

  SellerVerificationEntity({
    required this.status,
    this.rejectionReason,
  });
}
