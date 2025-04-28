import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const CustomTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

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
            child: BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 6.0,
              color: Colors.white,
              elevation: 0,
              child: SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    // Home Button
                    GestureDetector(
                      onTap: () => onTabSelected(0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.home_filled,
                            color:
                                selectedIndex == 0
                                    ? Color(0xFF54AF75)
                                    : Color(0xFF8A8A8A),
                            size: 30,
                          ),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color:
                                  selectedIndex == 0
                                      ? Color(0xFF54AF75)
                                      : Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5), // Space for center button
                    // Help Button
                    GestureDetector(
                      onTap: () => onTabSelected(2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.help_outline,
                            color:
                                selectedIndex == 2
                                    ? Color(0xFF54AF75)
                                    : Color(0xFF8A8A8A),
                            size: 30,
                          ),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color:
                                  selectedIndex == 2
                                      ? Color(0xFF54AF75)
                                      : Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Search Button
        Positioned(
          top: -25,
          child: GestureDetector(
            onTap: () => onTabSelected(1),
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color:
                    selectedIndex == 1 ? Color(0xFF54A555) : Color(0xFF54AF75),
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
