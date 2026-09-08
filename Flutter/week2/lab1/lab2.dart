class Product {
  String name;
  double price;

  Product({required this.name, required this.price});

  Product.free({required this.name}) : price = 0;

  double get priceWithVat => price * 1.07;
}

void main() {
  Product normalProduct = Product(name: 'เมาส์', price: 250.0);
  Product freeProduct = Product.free(name: 'สติกเกอร์');

  print('${normalProduct.name} ราคารวม VAT = ${normalProduct.priceWithVat.toStringAsFixed(2)} บาท');
  print('${freeProduct.name} ราคา = ${freeProduct.price} บาท');
}
