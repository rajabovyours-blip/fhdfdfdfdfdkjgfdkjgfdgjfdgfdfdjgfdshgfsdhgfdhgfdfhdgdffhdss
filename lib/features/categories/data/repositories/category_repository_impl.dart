import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';
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
    const CategoryEntity(id: 'cat-1', name: LocalizedString(uz: "G'isht va Bloklar", ru: "G'isht va Bloklar", en: "G'isht va Bloklar"), imageUrl: 'assets/images/categories/cat-1.webp'),
    const CategoryEntity(id: 'cat-2', name: LocalizedString(uz: 'Sement va Qorishmalar', ru: 'Sement va Qorishmalar', en: 'Sement va Qorishmalar'), imageUrl: 'assets/images/categories/cat-2.webp'),
    const CategoryEntity(id: 'cat-3', name: LocalizedString(uz: "Taxta va Yog'och", ru: "Taxta va Yog'och", en: "Taxta va Yog'och"), imageUrl: 'assets/images/categories/cat-3.webp'),
    const CategoryEntity(id: 'cat-4', name: LocalizedString(uz: 'Armatura va Metall', ru: 'Armatura va Metall', en: 'Armatura va Metall'), imageUrl: 'assets/images/categories/cat-4.webp'),
    const CategoryEntity(id: 'cat-5', name: LocalizedString(uz: 'Tom yopish materiallari', ru: 'Tom yopish materiallari', en: 'Tom yopish materiallari'), imageUrl: 'assets/images/categories/cat-5.webp'),
    const CategoryEntity(id: 'cat-6', name: LocalizedString(uz: 'Issiqlik izolyatsiyasi', ru: 'Issiqlik izolyatsiyasi', en: 'Issiqlik izolyatsiyasi'), imageUrl: 'assets/images/categories/cat-6.webp'),
    const CategoryEntity(id: 'cat-7', name: LocalizedString(uz: "Bo'yoqlar va Laklar", ru: "Bo'yoqlar va Laklar", en: "Bo'yoqlar va Laklar"), imageUrl: 'assets/images/categories/cat-7.webp'),
    const CategoryEntity(id: 'cat-8', name: LocalizedString(uz: 'Santexnika', ru: 'Santexnika', en: 'Santexnika'), imageUrl: 'assets/images/categories/cat-8.webp'),
    const CategoryEntity(id: 'cat-9', name: LocalizedString(uz: 'Elektr uskunalari', ru: 'Elektr uskunalari', en: 'Elektr uskunalari'), imageUrl: 'assets/images/categories/cat-9.webp'),
    const CategoryEntity(id: 'cat-10', name: LocalizedString(uz: 'Qurilish asboblari', ru: 'Qurilish asboblari', en: 'Qurilish asboblari'), imageUrl: 'assets/images/categories/cat-10.webp'),
    const CategoryEntity(id: 'cat-11', name: LocalizedString(uz: "Qum va Shag'al", ru: "Qum va Shag'al", en: "Qum va Shag'al"), imageUrl: 'assets/images/categories/cat-11.webp'),
    const CategoryEntity(id: 'cat-12', name: LocalizedString(uz: 'Gipsokarton va Profillar', ru: 'Gipsokarton va Profillar', en: 'Gipsokarton va Profillar'), imageUrl: 'assets/images/categories/cat-12.webp'),
    const CategoryEntity(id: 'cat-13', name: LocalizedString(uz: 'Kafel va Keramika', ru: 'Kafel va Keramika', en: 'Kafel va Keramika'), imageUrl: 'assets/images/categories/cat-13.webp'),
    const CategoryEntity(id: 'cat-14', name: LocalizedString(uz: 'Eshik va Derazalar', ru: 'Eshik va Derazalar', en: 'Eshik va Derazalar'), imageUrl: 'assets/images/categories/cat-14.webp'),
    const CategoryEntity(id: 'cat-15', name: LocalizedString(uz: 'Qulf va Furnituralar', ru: 'Qulf va Furnituralar', en: 'Qulf va Furnituralar'), imageUrl: 'assets/images/categories/cat-15.webp'),
    const CategoryEntity(id: 'cat-16', name: LocalizedString(uz: 'Poydevor qoplamalari', ru: 'Poydevor qoplamalari', en: 'Poydevor qoplamalari'), imageUrl: 'assets/images/categories/cat-16.webp'),
    const CategoryEntity(id: 'cat-17', name: LocalizedString(uz: 'Gidroizolyatsiya', ru: 'Gidroizolyatsiya', en: 'Gidroizolyatsiya'), imageUrl: 'assets/images/categories/cat-17.webp'),
    const CategoryEntity(id: 'cat-18', name: LocalizedString(uz: "Oyna va Ko'zgular", ru: "Oyna va Ko'zgular", en: "Oyna va Ko'zgular"), imageUrl: 'assets/images/categories/cat-18.webp'),
    const CategoryEntity(id: 'cat-19', name: LocalizedString(uz: 'Qurilish yelimlari', ru: 'Qurilish yelimlari', en: 'Qurilish yelimlari'), imageUrl: 'assets/images/categories/cat-19.webp'),
    const CategoryEntity(id: 'cat-20', name: LocalizedString(uz: "Montaj ko'pigi", ru: "Montaj ko'pigi", en: "Montaj ko'pigi"), imageUrl: 'assets/images/categories/cat-20.webp'),
    const CategoryEntity(id: 'cat-21', name: LocalizedString(uz: 'Suv quvurlari', ru: 'Suv quvurlari', en: 'Suv quvurlari'), imageUrl: 'assets/images/categories/cat-21.webp'),
    const CategoryEntity(id: 'cat-22', name: LocalizedString(uz: 'Kanalizatsiya tizimlari', ru: 'Kanalizatsiya tizimlari', en: 'Kanalizatsiya tizimlari'), imageUrl: 'assets/images/categories/cat-22.webp'),
    const CategoryEntity(id: 'cat-23', name: LocalizedString(uz: 'Isitish tizimlari', ru: 'Isitish tizimlari', en: 'Isitish tizimlari'), imageUrl: 'assets/images/categories/cat-23.webp'),
    const CategoryEntity(id: 'cat-24', name: LocalizedString(uz: 'Ventilyatsiya', ru: 'Ventilyatsiya', en: 'Ventilyatsiya'), imageUrl: 'assets/images/categories/cat-24.webp'),
    const CategoryEntity(id: 'cat-25', name: LocalizedString(uz: 'Yoritish moslamalari', ru: 'Yoritish moslamalari', en: 'Yoritish moslamalari'), imageUrl: 'assets/images/categories/cat-25.webp'),
    const CategoryEntity(id: 'cat-26', name: LocalizedString(uz: 'Kabel va Simlar', ru: 'Kabel va Simlar', en: 'Kabel va Simlar'), imageUrl: 'assets/images/categories/cat-26.webp'),
    const CategoryEntity(id: 'cat-27', name: LocalizedString(uz: 'Rozetka va Viklyuchatellar', ru: 'Rozetka va Viklyuchatellar', en: 'Rozetka va Viklyuchatellar'), imageUrl: 'assets/images/categories/cat-27.webp'),
    const CategoryEntity(id: 'cat-28', name: LocalizedString(uz: 'Avtomatlar va Shitlar', ru: 'Avtomatlar va Shitlar', en: 'Avtomatlar va Shitlar'), imageUrl: 'assets/images/categories/cat-28.webp'),
    const CategoryEntity(id: 'cat-29', name: LocalizedString(uz: 'Perforatorlar', ru: 'Perforatorlar', en: 'Perforatorlar'), imageUrl: 'assets/images/categories/cat-29.webp'),
    const CategoryEntity(id: 'cat-30', name: LocalizedString(uz: 'Bolgarkalar', ru: 'Bolgarkalar', en: 'Bolgarkalar'), imageUrl: 'assets/images/categories/cat-30.webp'),
    const CategoryEntity(id: 'cat-31', name: LocalizedString(uz: 'Drel va Shurupovyortlar', ru: 'Drel va Shurupovyortlar', en: 'Drel va Shurupovyortlar'), imageUrl: 'assets/images/categories/cat-31.webp'),
    const CategoryEntity(id: 'cat-32', name: LocalizedString(uz: 'Lazerli sathlar', ru: 'Lazerli sathlar', en: 'Lazerli sathlar'), imageUrl: 'assets/images/categories/cat-32.webp'),
    const CategoryEntity(id: 'cat-33', name: LocalizedString(uz: "O'lchov asboblari", ru: "O'lchov asboblari", en: "O'lchov asboblari"), imageUrl: 'assets/images/categories/cat-33.webp'),
    const CategoryEntity(id: 'cat-34', name: LocalizedString(uz: "Qo'l asboblari", ru: "Qo'l asboblari", en: "Qo'l asboblari"), imageUrl: 'assets/images/categories/cat-34.webp'),
    const CategoryEntity(id: 'cat-35', name: LocalizedString(uz: "Bolg'alar", ru: "Bolg'alar", en: "Bolg'alar"), imageUrl: 'assets/images/categories/cat-35.webp'),
    const CategoryEntity(id: 'cat-36', name: LocalizedString(uz: 'Otvyortkalar', ru: 'Otvyortkalar', en: 'Otvyortkalar'), imageUrl: 'assets/images/categories/cat-36.webp'),
    const CategoryEntity(id: 'cat-37', name: LocalizedString(uz: 'Ombirlar', ru: 'Ombirlar', en: 'Ombirlar'), imageUrl: 'assets/images/categories/cat-37.webp'),
    const CategoryEntity(id: 'cat-38', name: LocalizedString(uz: 'Shpatel va Kelmalar', ru: 'Shpatel va Kelmalar', en: 'Shpatel va Kelmalar'), imageUrl: 'assets/images/categories/cat-38.webp'),
    const CategoryEntity(id: 'cat-39', name: LocalizedString(uz: 'Qurilish chelaklari', ru: 'Qurilish chelaklari', en: 'Qurilish chelaklari'), imageUrl: 'assets/images/categories/cat-39.webp'),
    const CategoryEntity(id: 'cat-40', name: LocalizedString(uz: 'Narvonlar', ru: 'Narvonlar', en: 'Narvonlar'), imageUrl: 'assets/images/categories/cat-40.webp'),
    const CategoryEntity(id: 'cat-41', name: LocalizedString(uz: 'Arra va Kesuvchi asboblar', ru: 'Arra va Kesuvchi asboblar', en: 'Arra va Kesuvchi asboblar'), imageUrl: 'assets/images/categories/cat-41.webp'),
    const CategoryEntity(id: 'cat-42', name: LocalizedString(uz: "Qumqog'oz (Shkurka)", ru: "Qumqog'oz (Shkurka)", en: "Qumqog'oz (Shkurka)"), imageUrl: 'assets/images/categories/cat-42.webp'),
    const CategoryEntity(id: 'cat-43', name: LocalizedString(uz: 'Qurilish kaskalari', ru: 'Qurilish kaskalari', en: 'Qurilish kaskalari'), imageUrl: 'assets/images/categories/cat-43.webp'),
    const CategoryEntity(id: 'cat-44', name: LocalizedString(uz: "Qo'lqoplar", ru: "Qo'lqoplar", en: "Qo'lqoplar"), imageUrl: 'assets/images/categories/cat-44.webp'),
    const CategoryEntity(id: 'cat-45', name: LocalizedString(uz: 'Maxsus poyabzallar', ru: 'Maxsus poyabzallar', en: 'Maxsus poyabzallar'), imageUrl: 'assets/images/categories/cat-45.webp'),
    const CategoryEntity(id: 'cat-46', name: LocalizedString(uz: "Himoya ko'zoynaklari", ru: "Himoya ko'zoynaklari", en: "Himoya ko'zoynaklari"), imageUrl: 'assets/images/categories/cat-46.webp'),
    const CategoryEntity(id: 'cat-47', name: LocalizedString(uz: 'Suyuq mixlar', ru: 'Suyuq mixlar', en: 'Suyuq mixlar'), imageUrl: 'assets/images/categories/cat-47.webp'),
    const CategoryEntity(id: 'cat-48', name: LocalizedString(uz: 'Germetiklar', ru: 'Germetiklar', en: 'Germetiklar'), imageUrl: 'assets/images/categories/cat-48.webp'),
    const CategoryEntity(id: 'cat-49', name: LocalizedString(uz: 'Qurilish skotchi', ru: 'Qurilish skotchi', en: 'Qurilish skotchi'), imageUrl: 'assets/images/categories/cat-49.webp'),
    const CategoryEntity(id: 'cat-50', name: LocalizedString(uz: 'Dyubel va Samorezlar', ru: 'Dyubel va Samorezlar', en: 'Dyubel va Samorezlar'), imageUrl: 'assets/images/categories/cat-50.webp'),
    const CategoryEntity(id: 'cat-51', name: LocalizedString(uz: 'Mixlar', ru: 'Mixlar', en: 'Mixlar'), imageUrl: 'assets/images/categories/cat-51.webp'),
    const CategoryEntity(id: 'cat-52', name: LocalizedString(uz: 'Bolt va Gaykalar', ru: 'Bolt va Gaykalar', en: 'Bolt va Gaykalar'), imageUrl: 'assets/images/categories/cat-52.webp'),
    const CategoryEntity(id: 'cat-53', name: LocalizedString(uz: 'Zanjir va Troslar', ru: 'Zanjir va Troslar', en: 'Zanjir va Troslar'), imageUrl: 'assets/images/categories/cat-53.webp'),
    const CategoryEntity(id: 'cat-54', name: LocalizedString(uz: "Qurilish to'rlari", ru: "Qurilish to'rlari", en: "Qurilish to'rlari"), imageUrl: 'assets/images/categories/cat-54.webp'),
    const CategoryEntity(id: 'cat-55', name: LocalizedString(uz: 'Polietilen plyonkalar', ru: 'Polietilen plyonkalar', en: 'Polietilen plyonkalar'), imageUrl: 'assets/images/categories/cat-55.webp'),
    const CategoryEntity(id: 'cat-56', name: LocalizedString(uz: 'Tarozilar', ru: 'Tarozilar', en: 'Tarozilar'), imageUrl: 'assets/images/categories/cat-56.webp'),
    const CategoryEntity(id: 'cat-57', name: LocalizedString(uz: "Zambilg'achlar (Tachkalar)", ru: "Zambilg'achlar (Tachkalar)", en: "Zambilg'achlar (Tachkalar)"), imageUrl: 'assets/images/categories/cat-57.webp'),
    const CategoryEntity(id: 'cat-58', name: LocalizedString(uz: 'Beton qorishtirgichlar', ru: 'Beton qorishtirgichlar', en: 'Beton qorishtirgichlar'), imageUrl: 'assets/images/categories/cat-58.webp'),
    const CategoryEntity(id: 'cat-59', name: LocalizedString(uz: 'Svarka apparatlari', ru: 'Svarka apparatlari', en: 'Svarka apparatlari'), imageUrl: 'assets/images/categories/cat-59.webp'),
    const CategoryEntity(id: 'cat-60', name: LocalizedString(uz: 'Elektrodlar', ru: 'Elektrodlar', en: 'Elektrodlar'), imageUrl: 'assets/images/categories/cat-60.webp'),
    const CategoryEntity(id: 'cat-61', name: LocalizedString(uz: 'Kompressorlar', ru: 'Kompressorlar', en: 'Kompressorlar'), imageUrl: 'assets/images/categories/cat-61.webp'),
  ];

}
