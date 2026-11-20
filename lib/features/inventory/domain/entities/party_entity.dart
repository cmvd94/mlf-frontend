class PartyEntity {
  final String id;
  final String partyCode;
  final String name;
  final String contactPerson;
  final String phoneNumber;
  final String email;
  final String address;
  final String gstin;
  final bool isActive;
  final DateTime? createdAt;

  const PartyEntity({
    required this.id,
    required this.partyCode,
    required this.name,
    this.contactPerson = '',
    this.phoneNumber = '',
    this.email = '',
    this.address = '',
    this.gstin = '',
    this.isActive = true,
    this.createdAt,
  });
}
