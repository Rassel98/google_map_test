
class TestCallClass {
  void testFunction() {
    try {
      //print(jsonData);
      List<ProductLine> productLines = ProductLineFromJson(jsonData);
      for (var productLine in productLines) {
        print('Product Line: ${productLine.productLine}');
        for (var product in productLine.products!) {
          print('  Part Number: ${product.partNumber}');
          print('  Orderable: ${product.orderable}');
          print('  Description: ${product.description}');
        }
        print('-------------------');
      }
    } catch (e) {
      print('Error decoding JSON: $e');
    }
  }
}

class Product {
  String? partNumber;
  bool? orderable;
  String? description;

  Product({
    this.partNumber,
    this.orderable,
    this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      partNumber: json['partNumber'],
      orderable: json['orderable'],
      description: json['description'],
    );
  }
}

List<ProductLine> ProductLineFromJson(dynamic str) => List<ProductLine>.from((str as List<dynamic>).map((x) => ProductLine.fromJson(x)));

class ProductLine {
  String? productLine;
  List<Product>? products;

  ProductLine({
    this.productLine,
    this.products,
  });

  factory ProductLine.fromJson(Map<String, dynamic> json) {
    final List<Product> products = (json[json.keys.first] as List).map((productJson) => Product.fromJson(productJson)).toList();

    return ProductLine(
      productLine: json.keys.first,
      products: products,
    );
  }
}

var jsonData = [
  {
    "Product line 1": [
      {"partNumber": "160-9013-900", "orderable": true, "description": "Part Number Description"},
      {"partNumber": "160-9104-900", "orderable": true, "description": "Part Number Description"},
      {"partNumber": "160-9105-900", "orderable": false, "description": "Part Number Description"}
    ]
  },
  {
    "Product line 2": [
      {"partNumber": "160-9113-900", "orderable": true, "description": "Part Number Description"},
      {"partNumber": "160-9114-900", "orderable": true, "description": "Part Number Description"},
      {"partNumber": "160-9115-900", "orderable": false, "description": "Part Number Description"}
    ]
  },
  {
    "Product line 3": [
      {"partNumber": "160-9205-900", "orderable": true, "description": "Part Number Description"},
      {"partNumber": "160-9211-900", "orderable": true, "description": "Part Number Description"},
      {"partNumber": "160-9212-900", "orderable": false, "description": "Part Number Description"}
    ]
  }
];
