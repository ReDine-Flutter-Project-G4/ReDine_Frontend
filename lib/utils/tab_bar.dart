import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final TabController tabController;

  const CustomTabBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 15,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: TabBar(
                controller: tabController,
                indicator: const DotIndicator(color: Color(0xFF54AF75)),
                labelColor: Color(0xFF54AF75),
                unselectedLabelColor: Color(0xFF8A8A8A),
                tabs: [
                  // Home tab
                  Icon(Icons.home_filled, size: 30),
                  const SizedBox(width: 5),
                  // Help tab
                  Icon(Icons.help_outline, size: 30),
                ],
              ),
            ),
          ),
        ),
        // Floating Search Button
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          top: tabController.index == 1 ? -30 : -25,
          child: GestureDetector(
            onTap: () {
              tabController.animateTo(1); // Switch to search tab
            },
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFF54AF75),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(Icons.search, size: 42, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class DotIndicator extends Decoration {
  final Color color;

  const DotIndicator({required this.color});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _DotPainter(color: color);
  }
}

class _DotPainter extends BoxPainter {
  final Color color;

  _DotPainter({required this.color});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Paint paint =
        Paint()
          ..color = color
          ..isAntiAlias = true;

    final Offset circleOffset = Offset(
      offset.dx + configuration.size!.width / 2,
      offset.dy + configuration.size!.height - 25,
    );

    canvas.drawCircle(circleOffset, 3, paint);
  }
}
