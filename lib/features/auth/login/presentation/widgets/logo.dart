import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    // الارتفاع يتناسب مع الشاشة: 272 على الهواتف العادية، أقل على الصغيرة
    final height = (MediaQuery.sizeOf(context).height * 0.32).clamp(
      220.0,
      272.0,
    );
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Color(0xff7A1F4B),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        image: DecorationImage(
          image: AssetImage("assets/images/patterns/plum_weave_tile.png"),
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/logo/logo_mark.png', width: 84),
          SizedBox(height: 10),
          Text(
            'توبنا'.tr,
            style: TextStyle(
              fontFamily: 'ReemKufi',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'أصالة تليق بكل مناسبة'.tr,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
