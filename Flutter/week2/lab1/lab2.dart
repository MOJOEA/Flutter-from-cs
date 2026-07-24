class Product {
  String name;
  double price;

  Product({required this.name, required this.price});

  Product.free({required this.name}) : price = 0;

  double get priceWithVat => price * 1.07;
}

void main() {
  // สร้างสินค้าปกติ 1 ชิ้น (เมาส์ 250 บาท)
  Product normalProduct = Product(name: 'เมาส์', price: 250.0);
  // สร้างของแถม 1 ชิ้น
  Product freeProduct = Product.free(name: 'สติกเกอร์');

  // พิมพ์ราคารวม VAT ของเมาส์ (.toStringAsFixed(2))
  print('${normalProduct.name} ราคารวม VAT = ${normalProduct.priceWithVat.toStringAsFixed(2)} บาท');
  // พิมพ์ราคาของแถม
  print('${freeProduct.name} ราคา = ${freeProduct.price} บาท');
}
