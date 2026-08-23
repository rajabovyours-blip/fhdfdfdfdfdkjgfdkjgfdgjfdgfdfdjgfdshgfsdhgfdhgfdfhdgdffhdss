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
    const CategoryEntity(id: 'cat-1', name: LocalizedString(uz: 'Bricks and Blocks', ru: 'Bricks and Blocks', en: 'Bricks and Blocks'), imageUrl: 'assets/images/categories/cat-1.webp'),
    const CategoryEntity(id: 'cat-2', name: LocalizedString(uz: 'Cement and Mixtures', ru: 'Cement and Mixtures', en: 'Cement and Mixtures'), imageUrl: 'assets/images/categories/cat-2.webp'),
    const CategoryEntity(id: 'cat-3', name: LocalizedString(uz: 'Lumber', ru: 'Lumber', en: 'Lumber'), imageUrl: 'assets/images/categories/cat-3.webp'),
    const CategoryEntity(id: 'cat-4', name: LocalizedString(uz: 'Rebar and Metal', ru: 'Rebar and Metal', en: 'Rebar and Metal'), imageUrl: 'assets/images/categories/cat-4.webp'),
    const CategoryEntity(id: 'cat-5', name: LocalizedString(uz: 'Roofing Materials', ru: 'Roofing Materials', en: 'Roofing Materials'), imageUrl: 'assets/images/categories/cat-5.webp'),
    const CategoryEntity(id: 'cat-6', name: LocalizedString(uz: 'Thermal Insulation', ru: 'Thermal Insulation', en: 'Thermal Insulation'), imageUrl: 'assets/images/categories/cat-6.webp'),
    const CategoryEntity(id: 'cat-7', name: LocalizedString(uz: 'Paints and Varnishes', ru: 'Paints and Varnishes', en: 'Paints and Varnishes'), imageUrl: 'assets/images/categories/cat-7.webp'),
    const CategoryEntity(id: 'cat-8', name: LocalizedString(uz: 'Plumbing', ru: 'Plumbing', en: 'Plumbing'), imageUrl: 'assets/images/categories/cat-8.webp'),
    const CategoryEntity(id: 'cat-9', name: LocalizedString(uz: 'Electrical Equipment', ru: 'Electrical Equipment', en: 'Electrical Equipment'), imageUrl: 'assets/images/categories/cat-9.webp'),
    const CategoryEntity(id: 'cat-10', name: LocalizedString(uz: 'Construction Tools', ru: 'Construction Tools', en: 'Construction Tools'), imageUrl: 'assets/images/categories/cat-10.webp'),
    const CategoryEntity(id: 'cat-11', name: LocalizedString(uz: 'Sand and Gravel', ru: 'Sand and Gravel', en: 'Sand and Gravel'), imageUrl: 'assets/images/categories/cat-11.webp'),
    const CategoryEntity(id: 'cat-12', name: LocalizedString(uz: 'Drywall and Profiles', ru: 'Drywall and Profiles', en: 'Drywall and Profiles'), imageUrl: 'assets/images/categories/cat-12.webp'),
    const CategoryEntity(id: 'cat-13', name: LocalizedString(uz: 'Tiles and Ceramics', ru: 'Tiles and Ceramics', en: 'Tiles and Ceramics'), imageUrl: 'assets/images/categories/cat-13.webp'),
    const CategoryEntity(id: 'cat-14', name: LocalizedString(uz: 'Doors and Windows', ru: 'Doors and Windows', en: 'Doors and Windows'), imageUrl: 'assets/images/categories/cat-14.webp'),
    const CategoryEntity(id: 'cat-15', name: LocalizedString(uz: 'Locks and Hardware', ru: 'Locks and Hardware', en: 'Locks and Hardware'), imageUrl: 'assets/images/categories/cat-15.webp'),
    const CategoryEntity(id: 'cat-16', name: LocalizedString(uz: 'Floor Coverings', ru: 'Floor Coverings', en: 'Floor Coverings'), imageUrl: 'assets/images/categories/cat-16.webp'),
    const CategoryEntity(id: 'cat-17', name: LocalizedString(uz: 'Waterproofing', ru: 'Waterproofing', en: 'Waterproofing'), imageUrl: 'assets/images/categories/cat-17.webp'),
    const CategoryEntity(id: 'cat-18', name: LocalizedString(uz: 'Glass and Mirrors', ru: 'Glass and Mirrors', en: 'Glass and Mirrors'), imageUrl: 'assets/images/categories/cat-18.webp'),
    const CategoryEntity(id: 'cat-19', name: LocalizedString(uz: 'Construction Adhesives', ru: 'Construction Adhesives', en: 'Construction Adhesives'), imageUrl: 'assets/images/categories/cat-19.webp'),
    const CategoryEntity(id: 'cat-20', name: LocalizedString(uz: 'Mounting Foam', ru: 'Mounting Foam', en: 'Mounting Foam'), imageUrl: 'assets/images/categories/cat-20.webp'),
    const CategoryEntity(id: 'cat-21', name: LocalizedString(uz: 'Water Pipes', ru: 'Water Pipes', en: 'Water Pipes'), imageUrl: 'assets/images/categories/cat-21.webp'),
    const CategoryEntity(id: 'cat-22', name: LocalizedString(uz: 'Sewage Systems', ru: 'Sewage Systems', en: 'Sewage Systems'), imageUrl: 'assets/images/categories/cat-22.webp'),
    const CategoryEntity(id: 'cat-23', name: LocalizedString(uz: 'Heating Systems', ru: 'Heating Systems', en: 'Heating Systems'), imageUrl: 'assets/images/categories/cat-23.webp'),
    const CategoryEntity(id: 'cat-24', name: LocalizedString(uz: 'Ventilation', ru: 'Ventilation', en: 'Ventilation'), imageUrl: 'assets/images/categories/cat-24.webp'),
    const CategoryEntity(id: 'cat-25', name: LocalizedString(uz: 'Lighting Fixtures', ru: 'Lighting Fixtures', en: 'Lighting Fixtures'), imageUrl: 'assets/images/categories/cat-25.webp'),
    const CategoryEntity(id: 'cat-26', name: LocalizedString(uz: 'Cables and Wires', ru: 'Cables and Wires', en: 'Cables and Wires'), imageUrl: 'assets/images/categories/cat-26.webp'),
    const CategoryEntity(id: 'cat-27', name: LocalizedString(uz: 'Sockets and Switches', ru: 'Sockets and Switches', en: 'Sockets and Switches'), imageUrl: 'assets/images/categories/cat-27.webp'),
    const CategoryEntity(id: 'cat-28', name: LocalizedString(uz: 'Circuit Breakers and Panels', ru: 'Circuit Breakers and Panels', en: 'Circuit Breakers and Panels'), imageUrl: 'assets/images/categories/cat-28.webp'),
    const CategoryEntity(id: 'cat-29', name: LocalizedString(uz: 'Rotary Hammers', ru: 'Rotary Hammers', en: 'Rotary Hammers'), imageUrl: 'assets/images/categories/cat-29.webp'),
    const CategoryEntity(id: 'cat-30', name: LocalizedString(uz: 'Angle Grinders', ru: 'Angle Grinders', en: 'Angle Grinders'), imageUrl: 'assets/images/categories/cat-30.webp'),
    const CategoryEntity(id: 'cat-31', name: LocalizedString(uz: 'Drills and Screwdrivers', ru: 'Drills and Screwdrivers', en: 'Drills and Screwdrivers'), imageUrl: 'assets/images/categories/cat-31.webp'),
    const CategoryEntity(id: 'cat-32', name: LocalizedString(uz: 'Laser Levels', ru: 'Laser Levels', en: 'Laser Levels'), imageUrl: 'assets/images/categories/cat-32.webp'),
    const CategoryEntity(id: 'cat-33', name: LocalizedString(uz: 'Measuring Tools', ru: 'Measuring Tools', en: 'Measuring Tools'), imageUrl: 'assets/images/categories/cat-33.webp'),
    const CategoryEntity(id: 'cat-34', name: LocalizedString(uz: 'Hand Tools', ru: 'Hand Tools', en: 'Hand Tools'), imageUrl: 'assets/images/categories/cat-34.webp'),
    const CategoryEntity(id: 'cat-35', name: LocalizedString(uz: 'Hammers', ru: 'Hammers', en: 'Hammers'), imageUrl: 'assets/images/categories/cat-35.webp'),
    const CategoryEntity(id: 'cat-36', name: LocalizedString(uz: 'Screwdrivers', ru: 'Screwdrivers', en: 'Screwdrivers'), imageUrl: 'assets/images/categories/cat-36.webp'),
    const CategoryEntity(id: 'cat-37', name: LocalizedString(uz: 'Pliers and Tongs', ru: 'Pliers and Tongs', en: 'Pliers and Tongs'), imageUrl: 'assets/images/categories/cat-37.webp'),
    const CategoryEntity(id: 'cat-38', name: LocalizedString(uz: 'Spatulas and Trowels', ru: 'Spatulas and Trowels', en: 'Spatulas and Trowels'), imageUrl: 'assets/images/categories/cat-38.webp'),
    const CategoryEntity(id: 'cat-39', name: LocalizedString(uz: 'Construction Buckets', ru: 'Construction Buckets', en: 'Construction Buckets'), imageUrl: 'assets/images/categories/cat-39.webp'),
    const CategoryEntity(id: 'cat-40', name: LocalizedString(uz: 'Ladders', ru: 'Ladders', en: 'Ladders'), imageUrl: 'assets/images/categories/cat-40.webp'),
    const CategoryEntity(id: 'cat-41', name: LocalizedString(uz: 'Saws and Cutting', ru: 'Saws and Cutting', en: 'Saws and Cutting'), imageUrl: 'assets/images/categories/cat-41.webp'),
    const CategoryEntity(id: 'cat-42', name: LocalizedString(uz: 'Sandpaper', ru: 'Sandpaper', en: 'Sandpaper'), imageUrl: 'assets/images/categories/cat-42.webp'),
    const CategoryEntity(id: 'cat-43', name: LocalizedString(uz: 'Construction Helmets', ru: 'Construction Helmets', en: 'Construction Helmets'), imageUrl: 'assets/images/categories/cat-43.webp'),
    const CategoryEntity(id: 'cat-44', name: LocalizedString(uz: 'Work Gloves', ru: 'Work Gloves', en: 'Work Gloves'), imageUrl: 'assets/images/categories/cat-44.webp'),
    const CategoryEntity(id: 'cat-45', name: LocalizedString(uz: 'Safety Shoes', ru: 'Safety Shoes', en: 'Safety Shoes'), imageUrl: 'assets/images/categories/cat-45.webp'),
    const CategoryEntity(id: 'cat-46', name: LocalizedString(uz: 'Safety Glasses', ru: 'Safety Glasses', en: 'Safety Glasses'), imageUrl: 'assets/images/categories/cat-46.webp'),
    const CategoryEntity(id: 'cat-47', name: LocalizedString(uz: 'Liquid Nails', ru: 'Liquid Nails', en: 'Liquid Nails'), imageUrl: 'assets/images/categories/cat-47.webp'),
    const CategoryEntity(id: 'cat-48', name: LocalizedString(uz: 'Sealants', ru: 'Sealants', en: 'Sealants'), imageUrl: 'assets/images/categories/cat-48.webp'),
    const CategoryEntity(id: 'cat-49', name: LocalizedString(uz: 'Construction Tape', ru: 'Construction Tape', en: 'Construction Tape'), imageUrl: 'assets/images/categories/cat-49.webp'),
    const CategoryEntity(id: 'cat-50', name: LocalizedString(uz: 'Dowels and Screws', ru: 'Dowels and Screws', en: 'Dowels and Screws'), imageUrl: 'assets/images/categories/cat-50.webp'),
    const CategoryEntity(id: 'cat-51', name: LocalizedString(uz: 'Nails', ru: 'Nails', en: 'Nails'), imageUrl: 'assets/images/categories/cat-51.webp'),
    const CategoryEntity(id: 'cat-52', name: LocalizedString(uz: 'Bolts and Nuts', ru: 'Bolts and Nuts', en: 'Bolts and Nuts'), imageUrl: 'assets/images/categories/cat-52.webp'),
    const CategoryEntity(id: 'cat-53', name: LocalizedString(uz: 'Chains and Cables', ru: 'Chains and Cables', en: 'Chains and Cables'), imageUrl: 'assets/images/categories/cat-53.webp'),
    const CategoryEntity(id: 'cat-54', name: LocalizedString(uz: 'Construction Nets', ru: 'Construction Nets', en: 'Construction Nets'), imageUrl: 'assets/images/categories/cat-54.webp'),
    const CategoryEntity(id: 'cat-55', name: LocalizedString(uz: 'Polyethylene Films', ru: 'Polyethylene Films', en: 'Polyethylene Films'), imageUrl: 'assets/images/categories/cat-55.webp'),
    const CategoryEntity(id: 'cat-56', name: LocalizedString(uz: 'Scales', ru: 'Scales', en: 'Scales'), imageUrl: 'assets/images/categories/cat-56.webp'),
    const CategoryEntity(id: 'cat-57', name: LocalizedString(uz: 'Wheelbarrows', ru: 'Wheelbarrows', en: 'Wheelbarrows'), imageUrl: 'assets/images/categories/cat-57.webp'),
    const CategoryEntity(id: 'cat-58', name: LocalizedString(uz: 'Cement Mixers', ru: 'Cement Mixers', en: 'Cement Mixers'), imageUrl: 'assets/images/categories/cat-58.webp'),
    const CategoryEntity(id: 'cat-59', name: LocalizedString(uz: 'Welding Machines', ru: 'Welding Machines', en: 'Welding Machines'), imageUrl: 'assets/images/categories/cat-59.webp'),
    const CategoryEntity(id: 'cat-60', name: LocalizedString(uz: 'Electrodes', ru: 'Electrodes', en: 'Electrodes'), imageUrl: 'assets/images/categories/cat-60.webp'),
    const CategoryEntity(id: 'cat-61', name: LocalizedString(uz: 'Compressors', ru: 'Compressors', en: 'Compressors'), imageUrl: 'assets/images/categories/cat-61.webp'),
  ];

}
