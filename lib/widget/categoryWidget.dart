import 'package:flutter/material.dart';
import 'package:omkar_app/view/home/priceStroescreen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:omkar_app/models/categoryModel.dart';
import '../constant/app_constant.dart';
import '../constant/colorConst.dart';

class CategoryComponent extends StatelessWidget {
  final CategoryModel? categoryModel;

  const CategoryComponent({super.key, this.categoryModel});

  @override
  Widget build(BuildContext context) {
    // Fixed width for horizontal list items
    const double itemWidth = 80.0;
    // Dynamic height based on screen size
    double imageHeight = Get.width > 360
        ? MediaQuery.of(context).size.height * 0.10
        : MediaQuery.of(context).size.height * 0.12;

    return InkWell(
      onTap: () {
        if (categoryModel?.categoryId != null) {
          Get.to(
            SubCategoryScreen(
              categoryId: categoryModel!.categoryId,
              categoryName: categoryModel!.categoryName,
            ),
            transition: Transition.zoom,
          );
        }
      },
      child: Container(
        width: itemWidth,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: '$IMAGE_URL${categoryModel?.categoryImage ?? ""}',
            height: imageHeight,
            width: itemWidth,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: imageHeight,
              width: itemWidth,
              color: Colors.grey.shade100,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            errorWidget: (_, __, ___) => Container(
              height: imageHeight,
              width: itemWidth,
              color: Colors.grey.shade100,
              alignment: Alignment.center,
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: Colors.grey,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
