import 'package:flutter/material.dart';

const double dialogOpenedThreshold = 10;
const double buttonSize = 56;
const double bottomPadding = 14;

class _FloatingDialogButtonState extends State<FloatingDialogButton> with SingleTickerProviderStateMixin {
  static const double itemHeight = 42;
  static const int minItems = 3;
  static const int maxItems = 10;

  late AnimationController _animationController;
  bool isDialogOpened = false;
  bool isButtonHeld = false;
  bool isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      value: 0,
      lowerBound: 0,
      upperBound: _topDialogOffset,
      duration: const Duration(milliseconds: 250),
    );

    _animationController.addListener(() => setState(() {}));
    _animationController.addStatusListener((status) {
      final bool newValue;
      if (status == AnimationStatus.forward || status == AnimationStatus.reverse) {
        newValue = true;
      } else {
        newValue = false;
      }

      if (newValue != isAnimating) {
        setState(() => isAnimating = newValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_animationController.value != 0 || isDialogOpened) ...[
          Positioned.fill(
            child: CustomPaint(
              painter: Painter(
                isDialogOpened: isDialogOpened,
                offset: _animationController.value,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: _topDialogOffset,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _showDialogItems ? 1 : 0,
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: itemHeight),
                  shrinkWrap: true,
                  physics: widget.dialogItems.length > 10
                      ? const BouncingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  children: widget.dialogItems.map((e) {
                    return Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        height: itemHeight,
                        child: GestureDetector(
                          onTap: e.onTap,
                          child: Text(
                            e.label,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.normal,
                                ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
        Container(
          alignment: Alignment.bottomCenter,
          margin: EdgeInsets.only(
            bottom: isDialogOpened ? _topDialogOffset - 18 : bottomPadding + _animationController.value,
          ),
          child: GestureDetector(
            onTap: () => setState(() => isDialogOpened = false),
            onVerticalDragUpdate: (details) {
              if (isDialogOpened) return;
              if (!isButtonHeld) {
                setState(() => isButtonHeld = true);
              }

              if ((details.localPosition.dy - (buttonSize / 2)) < 0) {
                _animationController.value = (details.localPosition.dy - (buttonSize / 2)).abs();
              }

              if (_shouldMarkDialogOpened) {
                setState(() => isDialogOpened = true);
              }
            },
            onVerticalDragEnd: (_) {
              _animationController.reverse();
              setState(() => isButtonHeld = false);
            },
            onVerticalDragCancel: () {
              _animationController.reverse();
              setState(() => isButtonHeld = false);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: buttonSize,
              width: buttonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDialogOpened ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).primaryColor,
              ),
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 400),
                turns: isDialogOpened ? 1.0 / 8.0 : 0,
                child: Icon(
                  Icons.add,
                  color: isDialogOpened ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool get _shouldMarkDialogOpened {
    if (_animationController.value > _topDialogOffset - dialogOpenedThreshold - itemHeight) return true;
    return false;
  }

  bool get _showDialogItems => (isDialogOpened && (!isButtonHeld && !isAnimating));

  double get _topDialogOffset {
    const double minHeight = itemHeight * minItems;
    const double maxHeight = itemHeight * maxItems;
    // one extra item for of bottom/top padding for the item list
    final double currentHeight = (itemHeight * (widget.dialogItems.length + 1)).toDouble();
    if (currentHeight < minHeight) {
      return minHeight;
    } else if (currentHeight > maxHeight) {
      return maxHeight;
    }

    return currentHeight;
  }
}

class Painter extends CustomPainter {
  static const double _bendSize = 12;

  final Color color;
  final bool isDialogOpened;
  final double offset;

  const Painter({
    required this.color,
    required this.offset,
    required this.isDialogOpened,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    paint.color = color.withOpacity(_getOpacity(size));
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 1;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    if (isDialogOpened && offset < dialogOpenedThreshold) {
      path.lineTo(0, size.height);
    } else {
      path.quadraticBezierTo(
        size.width / 2 - (offset / 8),
        size.height,
        (size.width / 2) + (buttonSize / 2) - _bendSize,
        size.height - offset - bottomPadding - (buttonSize / 2),
      );

      path.arcToPoint(
        Offset(
          size.width / 2,
          size.height - offset - bottomPadding - buttonSize + _bendSize,
        ),
        radius: const Radius.circular(16),
        clockwise: false,
      );

      path.arcToPoint(
        Offset(
          (size.width / 2) - (buttonSize / 2) + _bendSize,
          size.height - offset - bottomPadding - (buttonSize / 2),
        ),
        radius: const Radius.circular(16),
        clockwise: false,
      );

      path.quadraticBezierTo(
        size.width / 2 + (offset / 8),
        size.height,
        0,
        size.height,
      );
    }
    path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  double _getOpacity(Size size) {
    final temp = (offset / (size.height / 5) * 100) * 0.01;
    return isDialogOpened || temp > 1.0 ? 1 : temp;
  }
}

class FloatingDialogItem {
  final String label;
  final VoidCallback onTap;

  const FloatingDialogItem({
    required this.label,
    required this.onTap,
  });
}

class FloatingDialogButton extends StatefulWidget {
  final List<FloatingDialogItem> dialogItems;

  const FloatingDialogButton({
    super.key,
    required this.dialogItems,
  });

  @override
  State<FloatingDialogButton> createState() => _FloatingDialogButtonState();
}
