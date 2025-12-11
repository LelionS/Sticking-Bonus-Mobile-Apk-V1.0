import 'package:flutter/material.dart';

class MenuCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard> {
  bool _isHovered = false;

  void _setHovered(bool hovered) => setState(() => _isHovered = hovered);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _isHovered ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
        decoration: const BoxDecoration(
          color: Colors.transparent, // completely transparent
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Material(
          color: Colors.transparent, // Material for InkWell
          child: InkWell(
            onTap: widget.onTap,
            onHover: _setHovered,
            borderRadius: BorderRadius.circular(20),
            splashColor: Colors.transparent, // optional: remove ripple
            highlightColor: Colors.transparent, // optional: remove highlight
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isHovered
                          ? Colors.greenAccent.withOpacity(0.3)
                          : Colors.transparent, // subtle hover effect
                    ),
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 200),
                      scale: _isHovered ? 1.1 : 1.0,
                      child: Icon(widget.icon, size: 40, color: Colors.green[700]),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _isHovered ? Colors.green[700] : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
