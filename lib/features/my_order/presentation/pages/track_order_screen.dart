import 'package:flutter/material.dart';
import 'package:toubna/core/widgets/app_image.dart';
import 'package:get/get.dart';
import 'package:toubna/core/widgets/error_state_view.dart';
import 'package:toubna/core/data/catalog.dart';
import 'package:toubna/core/theme/app_colors.dart';
import 'package:toubna/core/widgets/page_header.dart';
import 'package:toubna/core/widgets/shimmer.dart';
import 'package:toubna/features/my_order/data/order_models.dart';
import 'package:toubna/features/my_order/presentation/controllers/track_order_controller.dart';
import 'package:toubna/features/my_order/presentation/widgets/order_card.dart';
import 'package:toubna/features/my_order/presentation/widgets/order_status_style.dart';

class TrackOrderScreen extends GetView<TrackOrderController> {
  const TrackOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final order = controller.order.value;
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  title: order.status.isActive
                      ? 'تتبع الطلب'.tr
                      : 'تفاصيل الطلب'.tr,
                  subtitle: 'طلب @p0'.trParams({'p0': order.number}),
                ),
                const SizedBox(height: 16),
                if (controller.hasError)
                  ErrorStateView(
                    error: controller.error.value!,
                    onRetry: controller.retry,
                  )
                else if (controller.isLoading.value)
                  const _TrackSkeleton()
                else ...[
                  _StatusHero(order: order),
                  const SizedBox(height: 14),
                  _Section(
                    title: 'مراحل الطلب'.tr,
                    child: _Timeline(entries: controller.timeline),
                  ),
                  if (order.status == OrderStatus.outForDelivery &&
                      order.courierName != null) ...[
                    const SizedBox(height: 14),
                    _Section(
                      title: 'المندوب'.tr,
                      child: _CourierRow(order: order),
                    ),
                  ],
                  const SizedBox(height: 14),
                  _Section(
                    title: 'عنوان التوصيل'.tr,
                    child: _IconRow(
                      icon: 'assets/icons/location.png',
                      text: order.address,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _Section(
                    title: 'المنتجات (@p0)'.trParams({
                      'p0': controller.countText(order.itemCount),
                    }),
                    child: Column(
                      children: [
                        for (final (i, item) in order.items.indexed) ...[
                          if (i > 0) const Divider(height: 20),
                          _ItemRow(item: item),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _Section(
                    title: 'ملخص الدفع'.tr,
                    child: _Summary(order: order),
                  ),
                ],
              ],
            ),
          ),
        ),
        bottomNavigationBar: _BottomActions(order: order),
      );
    });
  }
}

/// هيكل صفحة التتبع أثناء التحميل.
class _TrackSkeleton extends StatelessWidget {
  const _TrackSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget section(List<Widget> children) => SkeletonCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Bone.line(width: 110, height: 16),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
    Widget step() => const Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Bone.circle(size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.line(width: 120, height: 14),
                SizedBox(height: 6),
                Bone.line(width: 170, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Bone(height: 170, radius: 20),
          const SizedBox(height: 14),
          section([step(), step(), step(), step()]),
          const SizedBox(height: 14),
          section(const [
            Row(
              children: [
                Bone(width: 40, height: 40, radius: 12),
                SizedBox(width: 12),
                Expanded(child: Bone.line(height: 14)),
              ],
            ),
          ]),
          const SizedBox(height: 14),
          section(const [
            Row(
              children: [
                Bone(width: 56, height: 64, radius: 12),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Bone.line(width: 100, height: 14),
                      SizedBox(height: 8),
                      Bone.line(width: 70),
                    ],
                  ),
                ),
                Bone.line(width: 70, height: 14),
              ],
            ),
          ]),
        ],
      ),
    );
  }
}

/// بطاقة الحالة العنابية أعلى الصفحة.
class _StatusHero extends StatelessWidget {
  final Order order;

  const _StatusHero({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order.status;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage('assets/images/patterns/plum_weave_tile_soft.png'),
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.asset(status.icon, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.label,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      status.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (status.isActive) ...[
            const SizedBox(height: 18),
            OrderProgressBar(
              status: status,
              activeColor: AppColors.goldLight,
              inactiveColor: Colors.white.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 6),
            Text(
              'المرحلة @p0 من @p1'.trParams({
                'p0': '${status.stepIndex + 1}',
                'p1': '${OrderStatus.steps.length}',
              }),
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
          if (order.eta != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const ImageIcon(
                    AssetImage('assets/icons/clock.png'),
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'التوصيل المتوقع: '.tr,
                        children: [
                          TextSpan(
                            text: order.eta,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// الخط الزمني العمودي لمراحل الطلب.
class _Timeline extends StatelessWidget {
  final List<TimelineEntry> entries;

  const _Timeline({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (i, entry) in entries.indexed)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 28,
                  child: Column(
                    children: [
                      _StepDot(state: entry.state),
                      if (i < entries.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            color:
                                entries[i + 1].state == TimelineState.upcoming
                                ? AppColors.border
                                : entries[i + 1].state ==
                                      TimelineState.cancelled
                                ? AppColors.danger.withValues(alpha: 0.4)
                                : AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: i < entries.length - 1 ? 18 : 0,
                    ),
                    child: _StepText(entry: entry),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StepText extends StatelessWidget {
  final TimelineEntry entry;

  const _StepText({required this.entry});

  @override
  Widget build(BuildContext context) {
    final upcoming = entry.state == TimelineState.upcoming;
    final titleColor = switch (entry.state) {
      TimelineState.upcoming => AppColors.textMuted,
      TimelineState.cancelled => AppColors.danger,
      _ => AppColors.textDark,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                entry.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: upcoming ? FontWeight.w500 : FontWeight.bold,
                  color: titleColor,
                ),
              ),
            ),
            if (entry.time != null) ...[
              const SizedBox(width: 8),
              Text(
                entry.time!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
        if (!upcoming)
          Text(
            entry.description,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final TimelineState state;

  const _StepDot({required this.state});

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      TimelineState.done => _circle(
        color: AppColors.primary,
        child: const Icon(Icons.check, size: 16, color: Colors.white),
      ),
      TimelineState.cancelled => _circle(
        color: AppColors.danger,
        child: const Icon(Icons.close, size: 16, color: Colors.white),
      ),
      TimelineState.current => const _PulsingDot(),
      TimelineState.upcoming => _circle(
        color: Colors.white,
        border: AppColors.border,
      ),
    };
  }

  static Widget _circle({required Color color, Color? border, Widget? child}) =>
      Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: border == null ? null : Border.all(color: border, width: 2),
        ),
        child: child,
      );
}

/// المرحلة الحالية: نقطة ذهبية بنبض خفيف (يتوقف لو الحركة مقفولة في الجهاز).
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.gold.withValues(
            alpha: 0.15 + 0.2 * _controller.value,
          ),
        ),
        child: child,
      ),
      child: Container(
        width: 14,
        height: 14,
        decoration: const BoxDecoration(
          color: AppColors.gold,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _CourierRow extends GetView<TrackOrderController> {
  final Order order;

  const _CourierRow({required this.order});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary,
          child: Text(
            order.courierName!.characters.first,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.courierName!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                order.courierPhone ?? '',
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'اتصلي بالمندوب'.tr,
          onPressed: controller.callCourier,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primary,
            fixedSize: const Size(44, 44),
          ),
          icon: const Icon(Icons.call, size: 20, color: Colors.white),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'نسخ رقم المندوب'.tr,
          onPressed: controller.copyCourierPhone,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primarySoft,
            fixedSize: const Size(44, 44),
          ),
          icon: const ImageIcon(
            AssetImage('assets/icons/phone.png'),
            size: 22,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _IconRow extends StatelessWidget {
  final String icon;
  final String text;

  const _IconRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: AppColors.textBody),
          ),
        ),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  final OrderItem item;

  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AppImage(item.image, width: 56, height: 64),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                item.kind,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                'الكمية: @p0'.trParams({'p0': '${item.qty}'}),
                style: const TextStyle(fontSize: 13, color: AppColors.textBody),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          formatPrice(item.lineTotal),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  final Order order;

  const _Summary({required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _line('المجموع الفرعي'.tr, formatPrice(order.subtotal)),
        _line('التوصيل'.tr, formatPrice(order.deliveryFee)),
        if (order.discount > 0)
          _line('الخصم'.tr, '- ${formatPrice(order.discount)}'),
        const Divider(height: 20),
        _line('الإجمالي'.tr, order.totalText, bold: true),
        const SizedBox(height: 12),
        _IconRow(icon: 'assets/icons/cash.png', text: order.paymentMethod),
      ],
    );
  }

  Widget _line(String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: bold ? 16 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: bold ? AppColors.textDark : AppColors.textMuted,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 18 : 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: bold ? AppColors.primary : AppColors.textDark,
          ),
        ),
      ],
    ),
  );
}

class _BottomActions extends GetView<TrackOrderController> {
  final Order order;

  const _BottomActions({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order.status;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (status.canCancel) ...[
                Expanded(
                  child: OrderButton.outlined(
                    label: 'إلغاء الطلب'.tr,
                    color: AppColors.danger,
                    onTap: controller.confirmCancel,
                  ),
                ),
                const SizedBox(width: 10),
              ] else if (!status.isActive) ...[
                Expanded(
                  child: OrderButton.outlined(
                    label: 'تواصلي معنا'.tr,
                    onTap: controller.contactUs,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: status.isActive
                    ? OrderButton.primary(
                        label: 'تواصلي معنا'.tr,
                        icon: 'assets/icons/phone.png',
                        onTap: controller.contactUs,
                      )
                    : OrderButton.primary(
                        label: 'إعادة الطلب'.tr,
                        icon: 'assets/icons/bag.png',
                        onTap: controller.reorder,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
