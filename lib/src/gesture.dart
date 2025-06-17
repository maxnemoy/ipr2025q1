import 'package:flutter/material.dart';

class Gesture extends StatelessWidget {
  const Gesture({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [_Single(), _Draggable()]));
  }
}

/// простой тап
class _Single extends StatelessWidget {
  const _Single();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint('Tap!');
      },
      child: SizedBox(
        width: 200,
        height: 200,
        child: ColoredBox(
          color: Colors.blue,
          child: Center(child: Text('Tap me')),
        ),
      ),
    );
  }
}

// отслеживание перемещения
class _Draggable extends StatelessWidget {
  final ValueNotifier<Offset> _offset = ValueNotifier(Offset.zero);

  _Draggable();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: _offset,
            builder: (context, value, _) {
              return Positioned(
                top: value.dy,
                left: value.dx,
                child: GestureDetector(
                  onTap: () => _offset.value = Offset.zero,
                  onPanUpdate: (details) {
                    _offset.value += details.delta;
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    color: Colors.purple,
                    child: Center(child: Text('Drag')),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class GestureDragAutoScrollDemo extends StatefulWidget {
  const GestureDragAutoScrollDemo({super.key});

  @override
  State<GestureDragAutoScrollDemo> createState() => _GestureDragAutoScrollDemoState();
}

class _GestureDragAutoScrollDemoState extends State<GestureDragAutoScrollDemo> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _listKey = GlobalKey();
  Offset? _dragOffset;
  int? _draggingIndex;
  double? _dragOffsetFromTop;

  final _items = List.generate(40, (i) => i);

  void _maybeAutoScroll(Offset localPosition, double height) {
    const edge = 60.0;
    const scrollStep = 12.0;
    if (localPosition.dy < edge) {
      _scrollController.jumpTo(
        (_scrollController.offset - scrollStep).clamp(0.0, _scrollController.position.maxScrollExtent),
      );
    }
    if (localPosition.dy > height - edge) {
      _scrollController.jumpTo(
        (_scrollController.offset + scrollStep).clamp(0.0, _scrollController.position.maxScrollExtent),
      );
    }
  }

  int _findTargetIndex(Offset globalPosition) {
    final RenderBox listBox = _listKey.currentContext!.findRenderObject() as RenderBox;
    final listOffset = listBox.globalToLocal(globalPosition).dy + _scrollController.offset;
    final itemHeight = 60.0;
    int targetIndex = (listOffset ~/ itemHeight).clamp(0, _items.length - 1);
    return targetIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ReorderedList')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Listener(
            onPointerMove: (event) {
              // отслеживаем жесты
              if (_draggingIndex != null) {
                final local = (context.findRenderObject() as RenderBox).globalToLocal(event.position);
                // если близко к краям, делаем подскролл
                _maybeAutoScroll(local, constraints.maxHeight);
                
                setState(() {
                  _dragOffset = event.position;
                });
              }
            },
            onPointerUp: (event) {
              // отслеживаем отпускание жеста
              if (_draggingIndex != null) {
                if (_dragOffset != null && _dragOffsetFromTop != null) {
                  // если все ок, перемещаем элемент внутри списка
                  final targetIndex = _findTargetIndex(_dragOffset! - Offset(0, _dragOffsetFromTop!));
                  if (targetIndex != _draggingIndex && targetIndex >= 0 && targetIndex < _items.length) {
                    setState(() {
                      final item = _items.removeAt(_draggingIndex!);
                      _items.insert(targetIndex, item);
                      _draggingIndex = null;
                      _dragOffset = null;
                      _dragOffsetFromTop = null;
                    });
                    return;
                  }
                }
                // обнуляем стейт
                setState(() {
                  _draggingIndex = null;
                  _dragOffset = null;
                  _dragOffsetFromTop = null;
                });
              }
            },
            child: Stack(
              children: [
                ListView.builder(
                  key: _listKey,
                  controller: _scrollController,
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    // Если сейчас этот элемент перетаскивается — пустота
                    return _draggingIndex == index && _dragOffset != null
                        ? const SizedBox(height: 60)
                        : _DraggableListItem(
                            value: _items[index],
                            onDragStart: (details) {
                              setState(() {
                                _draggingIndex = index; // сохраняем индекс, не значение!
                                _dragOffset = details.globalPosition;
                                _dragOffsetFromTop = details.localPosition.dy;
                              });
                            },
                            onDragUpdate: (details) {
                              setState(() {
                                _dragOffset = details.globalPosition;
                              });
                            },
                            onDragEnd: () {
                              if (_dragOffset != null && _draggingIndex != null && _dragOffsetFromTop != null) {
                                final targetIndex = _findTargetIndex(_dragOffset! - Offset(0, _dragOffsetFromTop!));
                                // Если реально сместили и не выходим за границы
                                if (targetIndex != _draggingIndex && targetIndex >= 0 && targetIndex < _items.length) {
                                  setState(() {
                                    final item = _items.removeAt(_draggingIndex!);
                                    _items.insert(targetIndex, item);
                                    _draggingIndex = null;
                                    _dragOffset = null;
                                    _dragOffsetFromTop = null;
                                  });
                                  return;
                                }
                              }
                              setState(() {
                                _draggingIndex = null;
                                _dragOffset = null;
                                _dragOffsetFromTop = null;
                              });
                            },
                          );
                  },
                ),
                // Сам перетаскиваемый элемент поверх
                if (_dragOffset != null && _draggingIndex != null && _dragOffsetFromTop != null)
                  Positioned(
                    top: (context.findRenderObject() as RenderBox).globalToLocal(_dragOffset!).dy - _dragOffsetFromTop!,
                    left: 0, right: 0,
                    child: Opacity(opacity: 0.85, child: _DraggetItem(value:_items[_draggingIndex!])),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DraggetItem extends StatelessWidget {
  final int value;

  const _DraggetItem({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: MediaQuery.sizeOf(context).width,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.blue,
      child: Center(
        child: Text(
          'Item $value',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _DraggableListItem extends StatelessWidget {
  final int value;
  final void Function(DragStartDetails) onDragStart;
  final void Function(DragUpdateDetails) onDragUpdate;
  final VoidCallback onDragEnd;

  const _DraggableListItem({
    required this.value,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: onDragStart,
      onVerticalDragUpdate: onDragUpdate,
      onVerticalDragEnd: (_) {
        onDragEnd();
      },
      child: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        color: Colors.grey[(value % 2 == 0) ? 300 : 200],
        child: Center(child: Text('Item $value')),
      ),
    );
  }
}
