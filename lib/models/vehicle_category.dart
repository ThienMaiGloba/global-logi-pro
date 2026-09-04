class VehicleCategory {
  final String id;
  final String name;
  final String payload;
  final String operatingArea;
  final String solution;
  final List<String> examples;

  const VehicleCategory({
    required this.id,
    required this.name,
    required this.payload,
    required this.operatingArea,
    required this.solution,
    required this.examples,
  });
}

final List<VehicleCategory> globalLogiFleetList = [
  const VehicleCategory(
    id: '1',
    name: 'Nhóm Đô Thị & Giao Nhanh (Micro-Logistics)',
    payload: 'Dưới 500kg',
    operatingArea: 'Nội thành, hẻm nhỏ',
    solution: 'Giao nhanh, linh hoạt 24/7',
    examples: ['Xe máy giao chuẩn tốc', 'Xe ba gác chuyên dụng', 'Xe tải van nhỏ (<1 tấn)'],
  ),
  const VehicleCategory(
    id: '2',
    name: 'Nhóm Tải Trung & Hàng Tiêu Dùng',
    payload: '1 - 3.5 tấn',
    operatingArea: 'Liên quận, liên tỉnh gần',
    solution: 'Bảo quản hàng tươi sống, phân phối siêu thị',
    examples: ['Xe tải thùng mui bạt / Thùng kín', 'Xe tải đông lạnh (Refrigerated Trucks)'],
  ),
  const VehicleCategory(
    id: '3',
    name: 'Nhóm Tải Nặng & Liên Tỉnh',
    payload: '5 - 15+ tấn',
    operatingArea: 'Liên tỉnh, công trình xây dựng',
    solution: 'Vận chuyển hàng công nghiệp, vật liệu rời',
    examples: ['Xe tải trung & nặng (5t, 8t, 15t, 3-4 chân)', 'Xe ben / Xe tải tự đổ'],
  ),
  const VehicleCategory(
    id: '4',
    name: 'Nhóm Cảng Biển & Chuyên Dụng Nặng',
    payload: '20ft, 40ft, Siêu trường siêu trọng',
    operatingArea: 'Cảng biển, KCN trọng điểm',
    solution: 'Xử lý hàng XNK và máy móc cồng kềnh',
    examples: ['Xe đầu kéo container (20ft & 40ft)', 'Xe cẩu tự hành', 'Xe moóc lùn & chuyên dụng'],
  ),
  const VehicleCategory(
    id: '5',
    name: 'Nhóm Xe Điện Thế Hệ Mới (Green EV Fleet)',
    payload: 'Đa dạng (Xe máy đến xe tải nhẹ)',
    operatingArea: 'Khu vực đô thị lớn, kho thông minh',
    solution: 'Tiết kiệm chi phí nhiên liệu, đạt chuẩn ESG',
    examples: ['Xe máy điện & Xe van điện đô thị', 'Xe tải điện thương mại (EV Commercial Trucks)'],
  ),
  const VehicleCategory(
    id: '6',
    name: 'Nhóm Quốc Tế & Siêu Tải Chuyên Biệt',
    payload: 'Hạng nặng chuyên biệt',
    operatingArea: 'Khai thác mỏ, địa hình khắc nghiệt',
    solution: 'Đáp ứng tiêu chuẩn vận tải khắt khe toàn cầu',
    examples: ['Xe tải khai thác mỏ siêu lớn', 'Xe tải hạng nặng chuyên biệt toàn cầu'],
  ),
];
