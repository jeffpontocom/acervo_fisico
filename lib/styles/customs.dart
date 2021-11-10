import 'dart:math';
import 'package:flutter/material.dart';

/// AppBarDelegate customizado para atender requisitos de tamanho minimo e máximo
class MySliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  /// Widget para servir como cabecalho para Slivers
  MySliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(MySliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

/// Classe de textos customizados
class MyGreyText extends Text {
  /// Widget de Texto com padrão de cor Cinza
  MyGreyText(String data)
      : super(
          data,
          style: TextStyle(color: Colors.grey),
        );
}
