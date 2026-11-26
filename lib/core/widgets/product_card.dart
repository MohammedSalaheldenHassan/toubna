import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toubna/core/widgets/app_image.dart';

int productGridColumns(double width) {
  if (width >= 900) return 4;
  if (width >= 600) return 3;
  return 2;
}

/// شبكة المنتجات: عدد الأعمدة والارتفاع يتغيروا مع عرض الشاشة وحجم الخط.
SliverGridDelegate productGridDelegate(BuildContext context) {
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: productGridColumns(MediaQuery.sizeOf(context).width),
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    // ارتفاع الكارت: الصورة 150 + النصوص (تكبر مع تكبير الخط)
    mainAxisExtent: 184 + MediaQuery.textScalerOf(context).scale(76),
  );
}

/// كارت المنتج المستخدم في الرئيسية وصفحات الأقسام.
class ProductCard extends StatelessWidget {
  final String name, kind, price, image;
  final bool isNew, isFavorite;
  final VoidCallback onFavorite, onTap;

  const ProductCard({
    super.key,
    required this.name,
    required this.kind,
    required this.price,
    required this.image,
    required this.isNew,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFEADFE3)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(image),
                  if (isNew)
                    PositionedDirectional(
                      top: 10,
                      start: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7A1F4B),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'جديد'.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  PositionedDirectional(
                    top: 4,
                    end: 4,
                    child: IconButton(
                      onPressed: onFavorite,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        fixedSize: const Size(32, 32),
                        minimumSize: const Size(32, 32),
                        padding: EdgeInsets.zero,
                      ),
                      icon: ImageIcon(
                        AssetImage(
                          isFavorite
                              ? 'assets/icons/heart_filled.png'
                              : 'assets/icons/heart.png',
                        ),
                        size: 18,
                        color: isFavorite
                            ? const Color(0xFF7A1F4B)
                            : const Color(0xFF221A22),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF221A22),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    kind,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6B5E66),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // السعر يفضل في سطر واحد حتى على الشاشات الضيقة جدًا
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      price,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7A1F4B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
