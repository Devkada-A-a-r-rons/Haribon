import 'package:flutter/material.dart';

class DraggableFab extends StatefulWidget {
  final Widget child;
  final Size initSize;

  const DraggableFab({
    super.key,
    required this.child,
    this.initSize = const Size(56, 56), // Standard FAB size
  });

  @override
  State<DraggableFab> createState() => _DraggableFabState();
}

class _DraggableFabState extends State<DraggableFab> {
  Offset _offset = Offset.zero;
  bool _isInit = false;
  bool _isDragging = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final size = MediaQuery.of(context).size;
      // Position at bottom right (standard FAB position)
      _offset = Offset(size.width - widget.initSize.width - 16, size.height - widget.initSize.height - 100);
      _isInit = true;
    }
  }

  void _snapToEdge(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    
    final safeTop = padding.top + kToolbarHeight + 16.0;
    final safeBottom = size.height - padding.bottom - 80.0 - widget.initSize.height;
    final safeLeft = 16.0;
    final safeRight = size.width - widget.initSize.width - 16.0;

    final dLeft = (_offset.dx - safeLeft).abs();
    final dRight = (_offset.dx - safeRight).abs();
    final dTop = (_offset.dy - safeTop).abs();
    final dBottom = (_offset.dy - safeBottom).abs();

    final minD = [dLeft, dRight, dTop, dBottom].reduce((a, b) => a < b ? a : b);

    double newX = _offset.dx.clamp(safeLeft, safeRight);
    double newY = _offset.dy.clamp(safeTop, safeBottom);

    if (minD == dLeft) {
      newX = safeLeft;
    } else if (minD == dRight) {
      newX = safeRight;
    } else if (minD == dTop) {
      newY = safeTop;
    } else if (minD == dBottom) {
      newY = safeBottom;
    }

    setState(() {
      _offset = Offset(newX, newY);
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    final safeTop = padding.top + kToolbarHeight + 16.0;
    final safeBottom = size.height - padding.bottom - 80.0 - widget.initSize.height;
    final safeLeft = 16.0;
    final safeRight = size.width - widget.initSize.width - 16.0;

    return AnimatedPositioned(
      duration: Duration(milliseconds: _isDragging ? 0 : 300),
      curve: Curves.easeOutCubic,
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _offset += details.delta;
            // Clamp to safe bounds
            _offset = Offset(
              _offset.dx.clamp(safeLeft, safeRight),
              _offset.dy.clamp(safeTop, safeBottom),
            );
          });
        },
        onPanEnd: (details) {
          _snapToEdge(context);
        },
        child: widget.child,
      ),
    );
  }
}
