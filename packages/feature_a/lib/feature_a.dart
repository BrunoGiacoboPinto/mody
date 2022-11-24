library feature_a;

import 'package:base/base.dart';
import 'package:flutter/material.dart';

class FeatureAModule extends Module {
  FeatureAModule(super.container);

  @override
  Future<void> install() async {
    if (!container.containsDependency('StupidValue')) {
      container.add(
        Dependency(
          name: 'StupidValue',
          creationFactory: () => const StupidValue(42),
        ),
      );
    }
  }

  @override
  Map<String, WidgetBuilder>? buildRoutes() {
    return {
      MyWidget.routeName: (context) => MyWidget(data: container.get()),
    };
  }
}

class StupidValue {
  const StupidValue(this.value);

  final int value;
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key, required this.data});

  final StupidValue data;

  static const String routeName = '/path';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(data.value.toString()),
      ),
    );
  }
}
