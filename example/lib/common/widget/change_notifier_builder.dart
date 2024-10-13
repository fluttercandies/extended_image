import 'package:flutter/material.dart';

class ChangeNotifierBuilder extends StatefulWidget {
  /// Creates a [ValueListenableBuilder].
  ///
  /// The [valueListenable] and [builder] arguments must not be null.
  /// The [child] is optional but is good practice to use if part of the widget
  /// subtree does not depend on the value of the [valueListenable].
  const ChangeNotifierBuilder({
    Key? key,
    required this.changeNotifier,
    required this.builder,
    this.child,
    this.dispose,
  }) : super(key: key);

  /// The [ValueListenable] whose value you depend on in order to build.
  ///
  /// This widget does not ensure that the [ValueListenable]'s value is not
  /// null, therefore your [builder] may need to handle null values.
  ///
  /// This [ValueListenable] itself must not be null.
  final ChangeNotifier changeNotifier;

  /// A [ValueWidgetBuilder] which builds a widget depending on the
  /// [valueListenable]'s value.
  ///
  /// Can incorporate a [valueListenable] value-independent widget subtree
  /// from the [child] parameter into the returned widget tree.
  ///
  /// Must not be null.
  final WidgetBuilder builder;

  /// A [valueListenable]-independent widget which is passed back to the [builder].
  ///
  /// This argument is optional and can be null if the entire widget subtree
  /// the [builder] builds depends on the value of the [valueListenable]. For
  /// example, if the [valueListenable] is a [String] and the [builder] simply
  /// returns a [Text] widget with the [String] value.
  final Widget? child;
  final Function? dispose;
  @override
  State<ChangeNotifierBuilder> createState() => _ChangeNotifierBuilderState();
}

class _ChangeNotifierBuilderState extends State<ChangeNotifierBuilder> {
  @override
  void initState() {
    super.initState();
    widget.changeNotifier.addListener(_valueChanged);
  }

  @override
  void didUpdateWidget(ChangeNotifierBuilder oldWidget) {
    if (oldWidget.changeNotifier != widget.changeNotifier) {
      oldWidget.changeNotifier.removeListener(_valueChanged);
      widget.changeNotifier.addListener(_valueChanged);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.changeNotifier.removeListener(_valueChanged);
    widget.dispose?.call();
    super.dispose();
  }

  void _valueChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
