import 'package:bottom_nav_bar_animation/floating_dialog_button.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bottom NavBar Demo',
      theme: ThemeData(
        primaryColor: const Color(0xFF5CB8FE),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          unselectedItemColor: Color(0xFF8B8CED),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _Body()),
          _BottomAppBar(),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Events',
        style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _BottomAppBar extends StatelessWidget {
  const _BottomAppBar();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 88,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Icon(
                    Icons.star,
                    color: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
                  ),
                ),
                Expanded(
                  child: Icon(
                    Icons.search,
                    color: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
                  ),
                ),
                const Expanded(
                  child: SizedBox.shrink(),
                ),
                Expanded(
                  child: Icon(
                    Icons.thunderstorm,
                    color: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
                  ),
                ),
                Expanded(
                  child: Icon(
                    Icons.menu,
                    color: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: FloatingDialogButton(
            dialogItems: [
              FloatingDialogItem(
                label: 'Reminder',
                onTap: () {},
              ),
              FloatingDialogItem(
                label: 'Camera',
                onTap: () {},
              ),
              FloatingDialogItem(
                label: 'Attachment',
                onTap: () {},
              ),
              FloatingDialogItem(
                label: 'Text Note',
                onTap: () {},
              ),
            ],
          ),
        )
      ],
    );
  }
}
