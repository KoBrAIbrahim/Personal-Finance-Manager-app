import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardFeatureSlider extends StatelessWidget {
  const DashboardFeatureSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'icon': Icons.pie_chart,
        'label': 'Snapshot',
        'onTap': () => context.push('/snapshot'),
      },
      {
        'icon': Icons.history,
        'label': 'Snapshot History',
        'onTap': () => context.push('/snapshotList'),
      },
      {
        'icon': Icons.show_chart,
        'label': 'Snapshot Chart',
        'onTap': () => context.push('/snapshotchart'),
      },
      {
        'icon': Icons.flag,
        'label': 'Goals',
        'onTap': () => context.push('/goals'),
      },
      {
        'icon': Icons.remove_red_eye,
        'label': 'View Goals',
        'onTap': () => context.push('/viewgoals'),
      },
    ];

    final controller = PageController(viewportFraction: 0.65);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 120,
      child: PageView.builder(
        controller: controller,
        itemCount: features.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              double value = 1.0;
              if (controller.position.haveDimensions) {
                value = controller.page! - index;
                value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
              }

              return Center(
                child: Transform(
                  transform: Matrix4.identity()
                    ..scale(value)
                    ..rotateY((1 - value) * 0.2),
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: features[index]['onTap'] as VoidCallback,
                    child: Container(
                      width: 180,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            features[index]['icon'] as IconData,
                            color: const Color(0xFF0077B6),
                            size: 30,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            features[index]['label'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
