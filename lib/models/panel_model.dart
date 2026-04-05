class Panel {
  final String panelSerial;
  final String productType;
  final String? preparedBy;
  final String? startDate;
  final String? projectName;
  final String? referenceDocument;
  final String? verifiedBy;
  final String? remarks;
  final String status;
  final List<Component>? components;

  Panel({
    required this.panelSerial,
    required this.productType,
    this.preparedBy,
    this.startDate,
    this.projectName,
    this.referenceDocument,
    this.verifiedBy,
    this.remarks,
    required this.status,
    this.components,
  });

  factory Panel.fromJson(Map<String, dynamic> json) {
    return Panel(
      panelSerial: json['panel_serial'] ?? '',
      productType: json['product_type'] ?? '',
      preparedBy: json['prepared_by'],
      startDate: json['start_date'],
      projectName: json['project_name'],
      referenceDocument: json['reference_document'],
      verifiedBy: json['verified_by'],
      remarks: json['remarks'],
      status: json['status'] ?? '',
      components: json['components'] != null
          ? (json['components'] as List)
              .map((i) => Component.fromJson(i))
              .toList()
          : null,
    );
  }
}

class Component {
  final int id;
  final String sectionName;
  final String componentName;
  final String make;
  final String serialNumber;

  Component({
    required this.id,
    required this.sectionName,
    required this.componentName,
    required this.make,
    required this.serialNumber,
  });

  factory Component.fromJson(Map<String, dynamic> json) {
    return Component(
      id: json['id'] ?? 0,
      sectionName: json['section_name'] ?? '',
      componentName: json['component_name'] ?? '',
      make: json['make'] ?? '',
      serialNumber: json['serial_number'] ?? '',
    );
  }
}
