import 'dart:convert';
import 'package:milliy_metr/features/home/data/models/banner_model.dart';
import 'package:milliy_metr/features/categories/data/models/category_model.dart';
import 'package:milliy_metr/features/products/data/models/product_model.dart';

void main() {
  final bannerJson = {'id': 'b1', 'imageUrl': 'url', 'linkUrl': 'link', 'title': {'uz':'a','ru':'b','en':'c'}, 'subtitle': {'uz':'a','ru':'b','en':'c'}, 'cta': {'uz':'a','ru':'b','en':'c'}};
  print(BannerModel.fromJson(bannerJson));
}
