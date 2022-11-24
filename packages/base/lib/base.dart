library base;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

abstract class Module {
  Module(this.container);

  final DependencyContainer container;

  Future<void> install();

  Map<String, WidgetBuilder>? buildRoutes();
}

class Feature {
  const Feature({
    required this.name,
    this.isEnabled = false,
  });

  final String name;
  final bool isEnabled;
}

class FeatureToggle {
  FeatureToggle({
    this.features = const {},
  });

  final Map<String, Feature> features;

  void addFeature(String name) {
    features[name] = Feature(name: name);
  }

  bool hasFeature(String name) => features.containsKey(name);

  bool isFeatureEnabled(String name) => features[name]?.isEnabled ?? false;
}

class Dependency<T extends Object> {
  Dependency({
    required this.name,
    required this.creationFactory,
    this.creationFactoryAsync,
    this.isAsyncInitialized = false,
    this.isSingleton = false,
    this.dispose,
  });

  Future<Object> Function(T)? dispose;
  final Future<T> Function()? creationFactoryAsync;
  final T Function() creationFactory;
  final bool isAsyncInitialized;
  final bool isSingleton;
  final String name;

  Future<T> resolveAsync() async {
    if (creationFactoryAsync != null) {
      return await creationFactoryAsync!.call();
    } else {
      return Future.value(creationFactory());
    }
  }

  T resolve() => creationFactory();
}

class DependencyContainer {
  DependencyContainer(this.toggle);

  static final injector = GetIt.instance;

  // resolver com toggle dps
  final FeatureToggle toggle;

  bool containsDependency(String dependency) => injector.isRegistered(instanceName: dependency);

  DependencyContainer add<T extends Object>(
    Dependency<T> dependency, {
    Dependency<T> Function()? onToggleEnabled,
  }) {
    if (dependency.isAsyncInitialized) {
      if (dependency.isSingleton) {
        injector.registerLazySingletonAsync<T>(
          dependency.resolveAsync,
          instanceName: dependency.name,
          dispose: dependency.dispose,
        );
      } else {
        injector.registerFactoryAsync(
          dependency.resolveAsync,
          instanceName: dependency.name,
        );
      }
    } else {
      if (dependency.isSingleton) {
        injector.registerLazySingleton<T>(
          dependency.resolve,
          instanceName: dependency.name,
          dispose: dependency.dispose,
        );
      } else {
        injector.registerFactory(
          dependency.resolve,
          instanceName: dependency.name,
        );
      }
    }

    return this;
  }

  T get<T extends Object>() => injector.get<T>();
}
