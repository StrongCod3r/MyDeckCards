import 'package:flutter/material.dart';
import '../../../models/flashcard.dart';

class ReviewCardWidget extends StatelessWidget {
  final Flashcard card;
  final bool showBack;
  final double dragOffset;
  final bool isAnimating;
  final Animation<double> cardAnimation;
  final double animationDirection;
  final VoidCallback onTap;
  final ValueChanged<double> onDragUpdate;
  final VoidCallback onDragEnd;

  const ReviewCardWidget({
    super.key,
    required this.card,
    required this.showBack,
    required this.dragOffset,
    required this.isAnimating,
    required this.cardAnimation,
    required this.animationDirection,
    required this.onTap,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onHorizontalDragUpdate: (details) {
        onDragUpdate(details.delta.dx);
      },
      onHorizontalDragEnd: (details) {
        onDragEnd();
      },
      child: AnimatedBuilder(
        animation: cardAnimation,
        builder: (context, child) {
          final slideOffset = isAnimating
              ? cardAnimation.value * 500 * animationDirection
              : dragOffset;

          return Transform.translate(
            offset: Offset(slideOffset, 0),
            child: Transform.rotate(angle: slideOffset * 0.001, child: child),
          );
        },
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      card.front,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: Center(
                    child: showBack
                        ? Text(
                            card.back,
                            style: TextStyle(
                              fontSize: 24,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          )
                        : Icon(
                            Icons.help_outline,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
