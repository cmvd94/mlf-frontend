import '../../domain/entities/party_entity.dart';

class PartyModel extends PartyEntity {
  const PartyModel({
    required super.id,
    required super.partyCode,
    required super.name,
    super.contactPerson,
    super.phoneNumber,
    super.email,
    super.address,
    super.gstin,
    super.isActive,
    super.createdAt,
  });

  factory PartyModel.fromJson(Map<String, dynamic> json) {
    return PartyModel(
      id: json['_id']?.toString() ?? '',
      partyCode: json['partyCode']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      contactPerson: json['contactPerson']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      gstin: json['gstin']?.toString() ?? '',
      isActive: json['isActive'] == null ? true : json['isActive'] as bool,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toCreatePayload() {
    return {
      'name': name,
      if (partyCode.isNotEmpty) 'partyCode': partyCode,
      if (contactPerson.isNotEmpty) 'contactPerson': contactPerson,
      if (phoneNumber.isNotEmpty) 'phoneNumber': phoneNumber,
      if (email.isNotEmpty) 'email': email,
      if (address.isNotEmpty) 'address': address,
      if (gstin.isNotEmpty) 'gstin': gstin,
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toUpdatePayload() {
    return {
      'name': name,
      'partyCode': partyCode,
      'contactPerson': contactPerson,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'gstin': gstin,
      'isActive': isActive,
    };
  }
}
