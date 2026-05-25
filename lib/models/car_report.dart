class ReportImage {
  final int? id;
  final int? reportId;
  final String imagePath;
  final String label; // e.g. Front, Back, Engine, etc.

  ReportImage({
    this.id,
    this.reportId,
    required this.imagePath,
    required this.label,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (reportId != null) 'report_id': reportId,
      'image_path': imagePath,
      'label': label,
    };
  }

  factory ReportImage.fromMap(Map<String, dynamic> map) {
    return ReportImage(
      id: map['id'] as int?,
      reportId: map['report_id'] as int?,
      imagePath: map['image_path'] as String,
      label: map['label'] as String? ?? 'General',
    );
  }
}

class CarReport {
  final int? id;
  final String model;
  final String owner;
  final String ownerName;
  final String ownerMobile;
  final String kilometers;
  final String vimo;
  
  // Body Pillars (બોડી ૧ થી ૪ થાંભલી)
  final String bodyDent1;
  final String bodyDent2;
  final String bodyDent3;
  final String bodyDent4;
  
  // Dickey (ડેકી)
  final String dickey;
  
  // Doors (૧ થી ૪ દરવાજા)
  final String door1;
  final String door2;
  final String door3;
  final String door4;
  
  // Touchup (ગાડી મા કેટલો tachap)
  final String touchup;
  
  // AC & Interior (AC, Intriyal)
  final String ac;
  final String interior;
  
  // Engine (એન્જિન Lin, oil chek, ધુમાડો, આવાજ)
  final String engineLine;
  final String engineOilCheck;
  final String engineSmoke;
  final String engineNoise;
  
  // Driving (Gadi ચાલવામાં, સસ્પેન્સ, પીકઅપ, બ્રેક, ગેર, ગાડી ચાલુ કરવા મા)
  final String drivingCondition;
  final String suspension;
  final String pickup;
  final String brake;
  final String gear;
  final String startingCondition;
  
  // Glasses (ગાડી ના કાચો ૧ થી ૪)
  final String glass1;
  final String glass2;
  final String glass3;
  final String glass4;
  
  // Fender (૧ ડ્રાઇવ સાઇડ, ૨ ખાલી સાઇડ)
  final String fenderDriver;
  final String fenderPassenger;
  
  // Bonnet (૧ અંદર થી, ૨ ઉપર થી)
  final String bonnetInside;
  final String bonnetOutside;
  
  // Sold status fields
  final String status; // 'unsold' or 'sold'
  final String? customerName;
  final String? customerMobile;
  final String? customerAddress;
  final String? soldPrice;
  final String? soldDate;
  final String? remarks;

  // Meta
  final String createdAt;
  
  // List of images
  final List<ReportImage> images;

  CarReport({
    this.id,
    required this.model,
    required this.owner,
    required this.ownerName,
    required this.ownerMobile,
    required this.kilometers,
    required this.vimo,
    required this.bodyDent1,
    required this.bodyDent2,
    required this.bodyDent3,
    required this.bodyDent4,
    required this.dickey,
    required this.door1,
    required this.door2,
    required this.door3,
    required this.door4,
    required this.touchup,
    required this.ac,
    required this.interior,
    required this.engineLine,
    required this.engineOilCheck,
    required this.engineSmoke,
    required this.engineNoise,
    required this.drivingCondition,
    required this.suspension,
    required this.pickup,
    required this.brake,
    required this.gear,
    required this.startingCondition,
    required this.glass1,
    required this.glass2,
    required this.glass3,
    required this.glass4,
    required this.fenderDriver,
    required this.fenderPassenger,
    required this.bonnetInside,
    required this.bonnetOutside,
    this.status = 'unsold',
    this.customerName,
    this.customerMobile,
    this.customerAddress,
    this.soldPrice,
    this.soldDate,
    this.remarks,
    required this.createdAt,
    this.images = const [],
  });

  CarReport copyWith({
    int? id,
    String? model,
    String? owner,
    String? ownerName,
    String? ownerMobile,
    String? kilometers,
    String? vimo,
    String? bodyDent1,
    String? bodyDent2,
    String? bodyDent3,
    String? bodyDent4,
    String? dickey,
    String? door1,
    String? door2,
    String? door3,
    String? door4,
    String? touchup,
    String? ac,
    String? interior,
    String? engineLine,
    String? engineOilCheck,
    String? engineSmoke,
    String? engineNoise,
    String? drivingCondition,
    String? suspension,
    String? pickup,
    String? brake,
    String? gear,
    String? startingCondition,
    String? glass1,
    String? glass2,
    String? glass3,
    String? glass4,
    String? fenderDriver,
    String? fenderPassenger,
    String? bonnetInside,
    String? bonnetOutside,
    String? status,
    String? customerName,
    String? customerMobile,
    String? customerAddress,
    String? soldPrice,
    String? soldDate,
    String? remarks,
    String? createdAt,
    List<ReportImage>? images,
  }) {
    return CarReport(
      id: id ?? this.id,
      model: model ?? this.model,
      owner: owner ?? this.owner,
      ownerName: ownerName ?? this.ownerName,
      ownerMobile: ownerMobile ?? this.ownerMobile,
      kilometers: kilometers ?? this.kilometers,
      vimo: vimo ?? this.vimo,
      bodyDent1: bodyDent1 ?? this.bodyDent1,
      bodyDent2: bodyDent2 ?? this.bodyDent2,
      bodyDent3: bodyDent3 ?? this.bodyDent3,
      bodyDent4: bodyDent4 ?? this.bodyDent4,
      dickey: dickey ?? this.dickey,
      door1: door1 ?? this.door1,
      door2: door2 ?? this.door2,
      door3: door3 ?? this.door3,
      door4: door4 ?? this.door4,
      touchup: touchup ?? this.touchup,
      ac: ac ?? this.ac,
      interior: interior ?? this.interior,
      engineLine: engineLine ?? this.engineLine,
      engineOilCheck: engineOilCheck ?? this.engineOilCheck,
      engineSmoke: engineSmoke ?? this.engineSmoke,
      engineNoise: engineNoise ?? this.engineNoise,
      drivingCondition: drivingCondition ?? this.drivingCondition,
      suspension: suspension ?? this.suspension,
      pickup: pickup ?? this.pickup,
      brake: brake ?? this.brake,
      gear: gear ?? this.gear,
      startingCondition: startingCondition ?? this.startingCondition,
      glass1: glass1 ?? this.glass1,
      glass2: glass2 ?? this.glass2,
      glass3: glass3 ?? this.glass3,
      glass4: glass4 ?? this.glass4,
      fenderDriver: fenderDriver ?? this.fenderDriver,
      fenderPassenger: fenderPassenger ?? this.fenderPassenger,
      bonnetInside: bonnetInside ?? this.bonnetInside,
      bonnetOutside: bonnetOutside ?? this.bonnetOutside,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      customerMobile: customerMobile ?? this.customerMobile,
      customerAddress: customerAddress ?? this.customerAddress,
      soldPrice: soldPrice ?? this.soldPrice,
      soldDate: soldDate ?? this.soldDate,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      images: images ?? this.images,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'model': model,
      'owner': owner,
      'owner_name': ownerName,
      'owner_mobile': ownerMobile,
      'kilometers': kilometers,
      'vimo': vimo,
      'body_dent_1': bodyDent1,
      'body_dent_2': bodyDent2,
      'body_dent_3': bodyDent3,
      'body_dent_4': bodyDent4,
      'dickey': dickey,
      'door_1': door1,
      'door_2': door2,
      'door_3': door3,
      'door_4': door4,
      'touchup': touchup,
      'ac': ac,
      'interior': interior,
      'engine_line': engineLine,
      'engine_oil_check': engineOilCheck,
      'engine_smoke': engineSmoke,
      'engine_noise': engineNoise,
      'driving_condition': drivingCondition,
      'suspension': suspension,
      'pickup': pickup,
      'brake': brake,
      'gear': gear,
      'starting_condition': startingCondition,
      'glass_1': glass1,
      'glass_2': glass2,
      'glass_3': glass3,
      'glass_4': glass4,
      'fender_driver': fenderDriver,
      'fender_passenger': fenderPassenger,
      'bonnet_inside': bonnetInside,
      'bonnet_outside': bonnetOutside,
      'status': status,
      'customer_name': customerName,
      'customer_mobile': customerMobile,
      'customer_address': customerAddress,
      'sold_price': soldPrice,
      'sold_date': soldDate,
      'remarks': remarks,
      'created_at': createdAt,
    };
  }

  factory CarReport.fromMap(Map<String, dynamic> map, {List<ReportImage> images = const []}) {
    return CarReport(
      id: map['id'] as int?,
      model: map['model'] as String? ?? '',
      owner: map['owner'] as String? ?? '',
      ownerName: map['owner_name'] as String? ?? '',
      ownerMobile: map['owner_mobile'] as String? ?? '',
      kilometers: map['kilometers'] as String? ?? '',
      vimo: map['vimo'] as String? ?? '',
      bodyDent1: map['body_dent_1'] as String? ?? '',
      bodyDent2: map['body_dent_2'] as String? ?? '',
      bodyDent3: map['body_dent_3'] as String? ?? '',
      bodyDent4: map['body_dent_4'] as String? ?? '',
      dickey: map['dickey'] as String? ?? '',
      door1: map['door_1'] as String? ?? '',
      door2: map['door_2'] as String? ?? '',
      door3: map['door_3'] as String? ?? '',
      door4: map['door_4'] as String? ?? '',
      touchup: map['touchup'] as String? ?? '',
      ac: map['ac'] as String? ?? '',
      interior: map['interior'] as String? ?? '',
      engineLine: map['engine_line'] as String? ?? '',
      engineOilCheck: map['engine_oil_check'] as String? ?? '',
      engineSmoke: map['engine_smoke'] as String? ?? '',
      engineNoise: map['engine_noise'] as String? ?? '',
      drivingCondition: map['driving_condition'] as String? ?? '',
      suspension: map['suspension'] as String? ?? '',
      pickup: map['pickup'] as String? ?? '',
      brake: map['brake'] as String? ?? '',
      gear: map['gear'] as String? ?? '',
      startingCondition: map['starting_condition'] as String? ?? '',
      glass1: map['glass_1'] as String? ?? '',
      glass2: map['glass_2'] as String? ?? '',
      glass3: map['glass_3'] as String? ?? '',
      glass4: map['glass_4'] as String? ?? '',
      fenderDriver: map['fender_driver'] as String? ?? '',
      fenderPassenger: map['fender_passenger'] as String? ?? '',
      bonnetInside: map['bonnet_inside'] as String? ?? '',
      bonnetOutside: map['bonnet_outside'] as String? ?? '',
      status: map['status'] as String? ?? 'unsold',
      customerName: map['customer_name'] as String?,
      customerMobile: map['customer_mobile'] as String?,
      customerAddress: map['customer_address'] as String?,
      soldPrice: map['sold_price'] as String?,
      soldDate: map['sold_date'] as String?,
      remarks: map['remarks'] as String?,
      createdAt: map['created_at'] as String? ?? '',
      images: images,
    );
  }
}
