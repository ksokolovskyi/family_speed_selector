import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_svg/svg.dart';

enum TransactionSpeed {
  normal,
  fast,
  urgent;

  TransactionSpeed get _next {
    final index = values.indexOf(this);
    return values[(index + 1) % values.length];
  }
}

class FamilySpeedSelector extends StatelessWidget {
  const FamilySpeedSelector({
    required this.speed,
    required this.onChanged,
    super.key,
  });

  final TransactionSpeed speed;

  final ValueChanged<TransactionSpeed> onChanged;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(
        fontFamily: 'Quicksand',
        color: Colors.black,
        height: 1,
        overflow: TextOverflow.clip,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onChanged(speed._next),
          child: RepaintBoundary(
            child: ColoredBox(
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _Title(speed: speed),
                        const SizedBox(height: 14),
                        _Subtitle(
                          speed: speed,
                          duration: switch (speed) {
                            TransactionSpeed.normal => 60,
                            TransactionSpeed.fast => 30,
                            TransactionSpeed.urgent => 15,
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  _Icons(speed: speed),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.speed,
  });

  final TransactionSpeed speed;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 550),
      reverseDuration: const Duration(milliseconds: 150),
      transitionBuilder: (child, animation) {
        final isNewSpeed = child.key == ValueKey(speed);

        if (isNewSpeed) {
          final position = TweenSequence<Offset>([
            TweenSequenceItem(
              tween: ConstantTween(const Offset(0, -0.5)),
              weight: 20,
            ),
            TweenSequenceItem(
              tween: Tween(
                begin: const Offset(0, -0.5),
                end: Offset.zero,
              ).chain(
                CurveTween(curve: _CustomSpringCurve()),
              ),
              weight: 50,
            ),
          ]).animate(animation);

          final opacity = TweenSequence<double>([
            TweenSequenceItem(
              tween: ConstantTween(0),
              weight: 20,
            ),
            TweenSequenceItem(
              tween: Tween<double>(begin: 0, end: 1).chain(
                CurveTween(curve: Curves.easeOut),
              ),
              weight: 50,
            ),
          ]).animate(animation);

          return FadeTransition(
            opacity: opacity,
            child: SlideTransition(
              position: position,
              child: child,
            ),
          );
        }

        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeOut).animate(animation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOut)).animate(animation),
            child: child,
          ),
        );
      },
      layoutBuilder: (
        Widget? currentChild,
        List<Widget> previousChildren,
      ) {
        return Stack(
          alignment: Alignment.centerRight,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: Text(
        switch (speed) {
          TransactionSpeed.normal => 'Normal',
          TransactionSpeed.fast => 'Fast',
          TransactionSpeed.urgent => 'Urgent',
        },
        key: ValueKey(speed),
        textAlign: TextAlign.end,
        maxLines: 1,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: Color(0xFF212121),
        ),
      ),
    );
  }
}

class _Subtitle extends StatefulWidget {
  const _Subtitle({
    required this.speed,
    required this.duration,
  });

  final TransactionSpeed speed;

  final int duration;

  @override
  State<_Subtitle> createState() => _SubtitleState();
}

class _SubtitleState extends State<_Subtitle>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late final _durationTween = IntTween(
    begin: widget.duration,
    end: widget.duration,
  );

  @override
  void didUpdateWidget(covariant _Subtitle oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.duration != widget.duration) {
      _durationTween
        ..begin = oldWidget.duration
        ..end = widget.duration;

      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 20,
      height: 1,
      color: Color(0xFF989898),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          '~',
          style: style,
        ),
        SizedBox(
          width: 30,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final duration = _durationTween.evaluate(_controller);

              return Text(
                '$duration',
                textAlign: TextAlign.center,
                style: style,
              );
            },
          ),
        ),
        const Text(
          'Secs',
          style: style,
        ),
      ],
    );
  }
}

class _Icons extends StatelessWidget {
  const _Icons({
    required this.speed,
  });

  final TransactionSpeed speed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFEFEFEF),
              width: 1.5,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(100)),
          ),
          child: const SizedBox(
            width: 35,
            height: 65,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Icon(
              shape: switch (speed) {
                TransactionSpeed.normal => _IconShape.glyph,
                TransactionSpeed.fast => _IconShape.circle,
                TransactionSpeed.urgent => _IconShape.smallCircle,
              },
              asset: 'assets/icons/clock.svg',
              color: const Color(0xFF4DAFFF),
            ),
            if (speed == TransactionSpeed.urgent)
              const SizedBox(height: 8)
            else
              const SizedBox(height: 6),
            _Icon(
              shape: switch (speed) {
                TransactionSpeed.fast => _IconShape.glyph,
                TransactionSpeed.normal ||
                TransactionSpeed.urgent =>
                  _IconShape.circle,
              },
              asset: 'assets/icons/lightning.svg',
              color: const Color(0xFFFEBE44),
            ),
            if (speed == TransactionSpeed.normal)
              const SizedBox(height: 8)
            else
              const SizedBox(height: 6),
            _Icon(
              shape: switch (speed) {
                TransactionSpeed.normal => _IconShape.smallCircle,
                TransactionSpeed.fast => _IconShape.circle,
                TransactionSpeed.urgent => _IconShape.glyph,
              },
              asset: 'assets/icons/fire.svg',
              color: const Color(0xFFF94C16),
            ),
          ],
        ),
      ],
    );
  }
}

enum _IconShape {
  smallCircle,
  circle,
  glyph;

  bool get isGlyph => this == glyph;
}

class _Icon extends StatefulWidget {
  const _Icon({
    required this.shape,
    required this.asset,
    required this.color,
  });

  final _IconShape shape;

  final String asset;

  final Color color;

  @override
  State<_Icon> createState() => _IconState();
}

class _IconState extends State<_Icon> with TickerProviderStateMixin {
  late final AnimationController _sizeController;
  late final Tween<double> _sizeTween = Tween(begin: _size, end: _size);
  late final Animation<double> _sizeAnimation = _sizeTween
      .chain(CurveTween(curve: Curves.elasticOut))
      .animate(_sizeController);

  late final AnimationController _opacityController;
  late final Animation<double> _opacityAnimation = _opacityController.drive(
    CurveTween(curve: Curves.easeInOut),
  );

  double get _size => switch (widget.shape) {
        _IconShape.smallCircle => 4.0,
        _IconShape.circle => 8.0,
        _IconShape.glyph => 16.0,
      };

  @override
  void initState() {
    super.initState();

    _sizeController = AnimationController(
      value: 1,
      duration: const Duration(milliseconds: 850),
      vsync: this,
    );

    _opacityController = AnimationController(
      value: widget.shape.isGlyph ? 1 : 0,
      duration: const Duration(milliseconds: 75),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(covariant _Icon oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.shape != widget.shape) {
      _sizeTween
        ..begin = _sizeTween.end
        ..end = _size;

      _sizeController
        ..reset()
        ..forward();

      if (widget.shape.isGlyph) {
        _opacityController.forward();
      } else {
        _opacityController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _sizeController.dispose();
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
        [_sizeAnimation, _opacityAnimation],
      ),
      builder: (context, _) {
        final size = _sizeAnimation.value;
        final opacity = _opacityAnimation.value;

        return SizedBox.square(
          dimension: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.color.withOpacity(1 - opacity),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              widget.asset,
              fit: BoxFit.fitHeight,
              colorFilter: ui.ColorFilter.mode(
                widget.color.withOpacity(opacity),
                ui.BlendMode.srcIn,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CustomSpringCurve extends Curve {
  _CustomSpringCurve()
      : _simulation = SpringSimulation(
          const SpringDescription(damping: 12, mass: 1, stiffness: 170),
          0,
          1,
          0,
        );

  final SpringSimulation _simulation;

  @override
  double transform(double t) {
    return t * (1 - _simulation.x(1)) + _simulation.x(t);
  }
}
