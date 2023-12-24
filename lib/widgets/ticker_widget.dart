import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class SingleTickerWidget extends StatefulWidget {
  final WidgetBuilder builder;

  const SingleTickerWidget({Key? key, required this.builder}) : super(key: key);

  @override
  State<SingleTickerWidget> createState() => SingleTickerWidgetState();
}

class SingleTickerWidgetState extends State<SingleTickerWidget>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return widget.builder.call(context);
  }
}

class TickerWidget extends StatefulWidget {
  final WidgetBuilder builder;

  const TickerWidget({Key? key, required this.builder}) : super(key: key);

  @override
  State<SingleTickerWidget> createState() => SingleTickerWidgetState();
}

class TickerWidgetState extends State<TickerWidget>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return widget.builder.call(context);
  }
}

TickerProvider findTickerProvider(BuildContext context) {
  SingleTickerWidgetState? single = context.findAncestorStateOfType();
  if (single != null) {
    return single;
  }
  TickerWidgetState? state = context.findAncestorStateOfType();
  if (state != null) {
    return state;
  }
  return SingleTickerProvider();
}

class SingleTickerProvider implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}
