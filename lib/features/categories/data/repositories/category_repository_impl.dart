import 'package:fpdart/fpdart.dart';

import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/core/localization/localized_string.dart';
import 'package:milliy_metr/features/categories/domain/entities/category_entity.dart';
import 'package:milliy_metr/features/categories/data/datasources/category_remote_datasource.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    bool tree = true,
  });
}

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    bool tree = true,
  }) async {
    return Right(_hardcodedCategories);
  }

  static final List<CategoryEntity> _hardcodedCategories = [
    const CategoryEntity(id: 'cat-1', name: LocalizedString(uz: "G'isht va Bloklar", ru: 'Кирпичи и Блоки', en: 'Bricks and Blocks'), imageUrl: 'assets/images/categories/cat-1.webp'),
    const CategoryEntity(id: 'cat-2', name: LocalizedString(uz: 'Sement va Qorishmalar', ru: 'Цемент и Смеси', en: 'Cement and Mixtures'), imageUrl: 'assets/images/categories/cat-2.webp'),
    const CategoryEntity(id: 'cat-3', name: LocalizedString(uz: "Taxta va Yog'och", ru: 'Пиломатериалы и Дерево', en: 'Timber and Wood'), imageUrl: 'assets/images/categories/cat-3.webp'),
    const CategoryEntity(id: 'cat-4', name: LocalizedString(uz: 'Armatura va Metall', ru: 'Арматура и Металл', en: 'Fittings and Metal'), imageUrl: 'assets/images/categories/cat-4.webp'),
    const CategoryEntity(id: 'cat-5', name: LocalizedString(uz: 'Tom yopish materiallari', ru: 'Кровельные материалы', en: 'Roofing Materials'), imageUrl: 'assets/images/categories/cat-5.webp'),
    const CategoryEntity(id: 'cat-6', name: LocalizedString(uz: 'Issiqlik izolyatsiyasi', ru: 'Теплоизоляция', en: 'Thermal Insulation'), imageUrl: 'assets/images/categories/cat-6.webp'),
    const CategoryEntity(id: 'cat-7', name: LocalizedString(uz: "Bo'yoqlar va Laklar", ru: 'Краски и Лаки', en: 'Paints and Varnishes'), imageUrl: 'assets/images/categories/cat-7.webp'),
    const CategoryEntity(id: 'cat-8', name: LocalizedString(uz: 'Santexnika', ru: 'Сантехника', en: 'Plumbing'), imageUrl: 'assets/images/categories/cat-8.webp'),
    const CategoryEntity(id: 'cat-9', name: LocalizedString(uz: 'Elektr uskunalari', ru: 'Электрооборудование', en: 'Electrical Equipment'), imageUrl: 'assets/images/categories/cat-9.webp'),
    const CategoryEntity(id: 'cat-10', name: LocalizedString(uz: 'Qurilish asboblari', ru: 'Строительные инструменты', en: 'Construction Tools'), imageUrl: 'assets/images/categories/cat-10.webp'),
    const CategoryEntity(id: 'cat-11', name: LocalizedString(uz: "Qum va Shag'al", ru: 'Песок и Щебень', en: 'Sand and Gravel'), imageUrl: 'assets/images/categories/cat-11.webp'),
    const CategoryEntity(id: 'cat-12', name: LocalizedString(uz: 'Gipsokarton va Profillar', ru: 'Гипсокартон и Профили', en: 'Drywall and Profiles'), imageUrl: 'assets/images/categories/cat-12.webp'),
    const CategoryEntity(id: 'cat-13', name: LocalizedString(uz: 'Kafel va Keramika', ru: 'Кафель и Керамика', en: 'Tiles and Ceramics'), imageUrl: 'assets/images/categories/cat-13.webp'),
    const CategoryEntity(id: 'cat-14', name: LocalizedString(uz: 'Eshik va Derazalar', ru: 'Двери и Окна', en: 'Doors and Windows'), imageUrl: 'assets/images/categories/cat-14.webp'),
    const CategoryEntity(id: 'cat-15', name: LocalizedString(uz: 'Qulf va Furnituralar', ru: 'Замки и Фурнитура', en: 'Locks and Hardware'), imageUrl: 'assets/images/categories/cat-15.webp'),
    const CategoryEntity(id: 'cat-16', name: LocalizedString(uz: 'Poydevor qoplamalari', ru: 'Фундаментные покрытия', en: 'Foundation Coatings'), imageUrl: 'assets/images/categories/cat-16.webp'),
    const CategoryEntity(id: 'cat-17', name: LocalizedString(uz: 'Gidroizolyatsiya', ru: 'Гидроизоляция', en: 'Waterproofing'), imageUrl: 'assets/images/categories/cat-17.webp'),
    const CategoryEntity(id: 'cat-18', name: LocalizedString(uz: "Oyna va Ko'zgular", ru: 'Стекло и Зеркала', en: 'Glass and Mirrors'), imageUrl: 'assets/images/categories/cat-18.webp'),
    const CategoryEntity(id: 'cat-19', name: LocalizedString(uz: 'Qurilish yelimlari', ru: 'Строительные клеи', en: 'Construction Adhesives'), imageUrl: 'assets/images/categories/cat-19.webp'),
    const CategoryEntity(id: 'cat-20', name: LocalizedString(uz: "Montaj ko'pigi", ru: 'Монтажная пена', en: 'Mounting Foam'), imageUrl: 'assets/images/categories/cat-20.webp'),
    const CategoryEntity(id: 'cat-21', name: LocalizedString(uz: 'Suv quvurlari', ru: 'Водопроводные трубы', en: 'Water Pipes'), imageUrl: 'assets/images/categories/cat-21.webp'),
    const CategoryEntity(id: 'cat-22', name: LocalizedString(uz: 'Kanalizatsiya tizimlari', ru: 'Канализационные системы', en: 'Sewer Systems'), imageUrl: 'assets/images/categories/cat-22.webp'),
    const CategoryEntity(id: 'cat-23', name: LocalizedString(uz: 'Isitish tizimlari', ru: 'Системы отопления', en: 'Heating Systems'), imageUrl: 'assets/images/categories/cat-23.webp'),
    const CategoryEntity(id: 'cat-24', name: LocalizedString(uz: 'Ventilyatsiya', ru: 'Вентиляция', en: 'Ventilation'), imageUrl: 'assets/images/categories/cat-24.webp'),
    const CategoryEntity(id: 'cat-25', name: LocalizedString(uz: 'Yoritish moslamalari', ru: 'Осветительные приборы', en: 'Lighting Fixtures'), imageUrl: 'assets/images/categories/cat-25.webp'),
    const CategoryEntity(id: 'cat-26', name: LocalizedString(uz: 'Kabel va Simlar', ru: 'Кабели и Провода', en: 'Cables and Wires'), imageUrl: 'assets/images/categories/cat-26.webp'),
    const CategoryEntity(id: 'cat-27', name: LocalizedString(uz: 'Rozetka va Viklyuchatellar', ru: 'Розетки и Выключатели', en: 'Sockets and Switches'), imageUrl: 'assets/images/categories/cat-27.webp'),
    const CategoryEntity(id: 'cat-28', name: LocalizedString(uz: 'Avtomatlar va Shitlar', ru: 'Автоматы и Щитки', en: 'Circuit Breakers and Panels'), imageUrl: 'assets/images/categories/cat-28.webp'),
    const CategoryEntity(id: 'cat-29', name: LocalizedString(uz: 'Perforatorlar', ru: 'Перфораторы', en: 'Rotary Hammers'), imageUrl: 'assets/images/categories/cat-29.webp'),
    const CategoryEntity(id: 'cat-30', name: LocalizedString(uz: 'Bolgarkalar', ru: 'Болгарки', en: 'Angle Grinders'), imageUrl: 'assets/images/categories/cat-30.webp'),
    const CategoryEntity(id: 'cat-31', name: LocalizedString(uz: 'Drel va Shurupovyortlar', ru: 'Дрели и Шуруповерты', en: 'Drills and Screwdrivers'), imageUrl: 'assets/images/categories/cat-31.webp'),
    const CategoryEntity(id: 'cat-32', name: LocalizedString(uz: 'Lazerli sathlar', ru: 'Лазерные уровни', en: 'Laser Levels'), imageUrl: 'assets/images/categories/cat-32.webp'),
    const CategoryEntity(id: 'cat-33', name: LocalizedString(uz: "O'lchov asboblari", ru: 'Измерительные инструменты', en: 'Measuring Tools'), imageUrl: 'assets/images/categories/cat-33.webp'),
    const CategoryEntity(id: 'cat-34', name: LocalizedString(uz: "Qo'l asboblari", ru: 'Ручные инструменты', en: 'Hand Tools'), imageUrl: 'assets/images/categories/cat-34.webp'),
    const CategoryEntity(id: 'cat-35', name: LocalizedString(uz: "Bolg'alar", ru: 'Молотки', en: 'Hammers'), imageUrl: 'assets/images/categories/cat-35.webp'),
    const CategoryEntity(id: 'cat-36', name: LocalizedString(uz: 'Otvyortkalar', ru: 'Отвертки', en: 'Screwdrivers'), imageUrl: 'assets/images/categories/cat-36.webp'),
    const CategoryEntity(id: 'cat-37', name: LocalizedString(uz: 'Ombirlar', ru: 'Плоскогубцы', en: 'Pliers'), imageUrl: 'assets/images/categories/cat-37.webp'),
    const CategoryEntity(id: 'cat-38', name: LocalizedString(uz: 'Shpatel va Kelmalar', ru: 'Шпатели и Кельмы', en: 'Spatulas and Trowels'), imageUrl: 'assets/images/categories/cat-38.webp'),
    const CategoryEntity(id: 'cat-39', name: LocalizedString(uz: 'Qurilish chelaklari', ru: 'Строительные ведра', en: 'Construction Buckets'), imageUrl: 'assets/images/categories/cat-39.webp'),
    const CategoryEntity(id: 'cat-40', name: LocalizedString(uz: 'Narvonlar', ru: 'Лестницы', en: 'Ladders'), imageUrl: 'assets/images/categories/cat-40.webp'),
    const CategoryEntity(id: 'cat-41', name: LocalizedString(uz: 'Arra va Kesuvchi asboblar', ru: 'Пилы и Режущие инструменты', en: 'Saws and Cutting Tools'), imageUrl: 'assets/images/categories/cat-41.webp'),
    const CategoryEntity(id: 'cat-42', name: LocalizedString(uz: "Qumqog'oz (Shkurka)", ru: 'Наждачная бумага', en: 'Sandpaper'), imageUrl: 'assets/images/categories/cat-42.webp'),
    const CategoryEntity(id: 'cat-43', name: LocalizedString(uz: 'Qurilish kaskalari', ru: 'Строительные каски', en: 'Construction Helmets'), imageUrl: 'assets/images/categories/cat-43.webp'),
    const CategoryEntity(id: 'cat-44', name: LocalizedString(uz: "Qo'lqoplar", ru: 'Перчатки', en: 'Gloves'), imageUrl: 'assets/images/categories/cat-44.webp'),
    const CategoryEntity(id: 'cat-45', name: LocalizedString(uz: 'Maxsus poyabzallar', ru: 'Спецобувь', en: 'Safety Shoes'), imageUrl: 'assets/images/categories/cat-45.webp'),
    const CategoryEntity(id: 'cat-46', name: LocalizedString(uz: "Himoya ko'zoynaklari", ru: 'Защитные очки', en: 'Safety Glasses'), imageUrl: 'assets/images/categories/cat-46.webp'),
    const CategoryEntity(id: 'cat-47', name: LocalizedString(uz: 'Suyuq mixlar', ru: 'Жидкие гвозди', en: 'Liquid Nails'), imageUrl: 'assets/images/categories/cat-47.webp'),
    const CategoryEntity(id: 'cat-48', name: LocalizedString(uz: 'Germetiklar', ru: 'Герметики', en: 'Sealants'), imageUrl: 'assets/images/categories/cat-48.webp'),
    const CategoryEntity(id: 'cat-49', name: LocalizedString(uz: 'Qurilish skotchi', ru: 'Строительный скотч', en: 'Construction Tape'), imageUrl: 'assets/images/categories/cat-49.webp'),
    const CategoryEntity(id: 'cat-50', name: LocalizedString(uz: 'Dyubel va Samorezlar', ru: 'Дюбели и Саморезы', en: 'Dowels and Screws'), imageUrl: 'assets/images/categories/cat-50.webp'),
    const CategoryEntity(id: 'cat-51', name: LocalizedString(uz: 'Mixlar', ru: 'Гвозди', en: 'Nails'), imageUrl: 'assets/images/categories/cat-51.webp'),
    const CategoryEntity(id: 'cat-52', name: LocalizedString(uz: 'Bolt va Gaykalar', ru: 'Болты и Гайки', en: 'Bolts and Nuts'), imageUrl: 'assets/images/categories/cat-52.webp'),
    const CategoryEntity(id: 'cat-53', name: LocalizedString(uz: 'Zanjir va Troslar', ru: 'Цепи и Тросы', en: 'Chains and Cables'), imageUrl: 'assets/images/categories/cat-53.webp'),
    const CategoryEntity(id: 'cat-54', name: LocalizedString(uz: "Qurilish to'rlari", ru: 'Строительные сетки', en: 'Construction Nets'), imageUrl: 'assets/images/categories/cat-54.webp'),
    const CategoryEntity(id: 'cat-55', name: LocalizedString(uz: 'Polietilen plyonkalar', ru: 'Полиэтиленовые пленки', en: 'Polyethylene Films'), imageUrl: 'assets/images/categories/cat-55.webp'),
    const CategoryEntity(id: 'cat-56', name: LocalizedString(uz: 'Tarozilar', ru: 'Весы', en: 'Scales'), imageUrl: 'assets/images/categories/cat-56.webp'),
    const CategoryEntity(id: 'cat-57', name: LocalizedString(uz: "Zambilg'achlar (Tachkalar)", ru: 'Тачки', en: 'Wheelbarrows'), imageUrl: 'assets/images/categories/cat-57.webp'),
    const CategoryEntity(id: 'cat-58', name: LocalizedString(uz: 'Beton qorishtirgichlar', ru: 'Бетономешалки', en: 'Concrete Mixers'), imageUrl: 'assets/images/categories/cat-58.webp'),
    const CategoryEntity(id: 'cat-59', name: LocalizedString(uz: 'Svarka apparatlari', ru: 'Сварочные аппараты', en: 'Welding Machines'), imageUrl: 'assets/images/categories/cat-59.webp'),
    const CategoryEntity(id: 'cat-60', name: LocalizedString(uz: 'Elektrodlar', ru: 'Электроды', en: 'Electrodes'), imageUrl: 'assets/images/categories/cat-60.webp'),
    const CategoryEntity(id: 'cat-61', name: LocalizedString(uz: 'Kompressorlar', ru: 'Компрессоры', en: 'Compressors'), imageUrl: 'assets/images/categories/cat-61.webp'),
  ];

}
