class Panel {
  final String panelSerial;
  final String productType;
  final String? preparedBy;
  final String? startDate;
  final String? projectName;
  final String? verifiedBy;
  final String? remarks;
  final String status;
  final String companyName;
  final List<Component>? components;

  Panel({
    required this.panelSerial,
    required this.productType,
    this.preparedBy,
    this.startDate,
    this.projectName,
    this.verifiedBy,
    this.remarks,
    required this.status,
    required this.companyName,
    this.components,
  });

  factory Panel.fromJson(Map<String, dynamic> json) {
    return Panel(
      projectName: json['projectName'],
      panelSerial: json['panel_sr_no'] ?? '',
      startDate: json['startDate'],
      verifiedBy: json['verifiedBy'],
      companyName: json['companyName'] ?? 'Newen Systems Pvt Ltd',
      status: json['status'] ?? '',
      productType: json['productType'] ?? '',
      preparedBy: json['preparedBy'],
      remarks: json['remarks'],
      components: json['components'] != null
          ? (json['components'] as List)
              .map((i) => Component.fromJson(i))
              .toList()
          : null,
    );
  }
}

class Component {
  final String sectionName;
  final String componentName;
  final String make;
  final String serialNumber;

  Component({
    required this.sectionName,
    required this.componentName,
    required this.make,
    required this.serialNumber,
  });

  factory Component.fromJson(Map<String, dynamic> json) {
    return Component(
      sectionName: json['sectionName'] ?? '',
      componentName: json['componentName'] ?? '',
      make: json['make'] ?? '',
      serialNumber: json['serialNumber'] ?? '',
    );
  }
}
