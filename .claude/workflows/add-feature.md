---
description: Add a new feature following project conventions
---

# Add Feature

Step-by-step guide to add a new feature following Clean Architecture.

## 1. Create Feature Directory

```
lib/src/features/{feature_name}/
├── data/
│   ├── models/
│   │   └── {feature}_model.dart
│   ├── data_sources/
│   │   └── {feature}_remote_data_source.dart
│   └── repositories/
│       └── {feature}_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── {feature}_entity.dart
│   └── repositories/
│       └── {feature}_repository.dart
└── presentation/
    ├── providers/
    │   └── {feature}_controller.dart (or .g.dart for codegen)
    ├── screens/
    │   └── {feature}_screen.dart
    └── widgets/
        └── {feature}_widget.dart
```

## 2. Define Entity

```dart
// domain/entities/{feature}_entity.dart

class Feature {
  final String id;
  final String name;
  // ... other fields
  
  const Feature({required this.id, required this.name});
}
```

## 3. Define Model (with JSON)

```dart
// data/models/{feature}_model.dart

import 'package:json_annotation/json_annotation.dart';

part '{feature}_model.g.dart';

@JsonSerializable()
class FeatureModel {
  final String id;
  final String name;
  
  const FeatureModel({required this.id, required this.name});
  
  factory FeatureModel.fromJson(Map<String, dynamic> json) 
      => _$FeatureModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$FeatureModelToJson(this);
  
  // Convert to entity
  Feature toEntity() => Feature(id: id, name: name);
}
```

## 4. Define Repository Interface

```dart
// domain/repositories/{feature}_repository.dart

abstract class FeatureRepository {
  Future<List<Feature>> getAll();
  Future<Feature?> getById(String id);
  Future<void> create(Feature feature);
  Future<void> update(Feature feature);
  Future<void> delete(String id);
  Stream<List<Feature>> watch();
}
```

## 5. Implement Repository

```dart
// data/repositories/{feature}_repository_impl.dart

class FirebaseFeatureRepository implements FeatureRepository {
  final FirebaseFirestore _firestore;
  
  FirebaseFeatureRepository(this._firestore);
  
  CollectionReference get _collection => 
      _firestore.collection('features');
  
  @override
  Future<List<Feature>> getAll() async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => FeatureModel.fromJson(doc.data()).toEntity())
        .toList();
  }
  
  // ... other methods
}
```

## 6. Create Provider

```dart
// presentation/providers/{feature}_controller.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

part '{feature}_controller.g.dart';

@riverpod
FeatureRepository featureRepository(FeatureRepositoryRef ref) {
  return FirebaseFeatureRepository(FirebaseFirestore.instance);
}

@riverpod
class FeatureController extends _$FeatureController {
  @override
  FutureOr<List<Feature>> build() async {
    return ref.read(featureRepositoryProvider).getAll();
  }
  
  Future<void> addFeature(Feature feature) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(featureRepositoryProvider).create(feature);
      return ref.read(featureRepositoryProvider).getAll();
    });
  }
}
```

## 7. Generate Code

// turbo
```bash
dart run build_runner build --delete-conflicting-outputs
```

## 8. Create Screen

```dart
// presentation/screens/{feature}_screen.dart

class FeatureScreen extends ConsumerWidget {
  const FeatureScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(featureControllerProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Features')),
      body: state.when(
        data: (features) => ListView.builder(
          itemCount: features.length,
          itemBuilder: (context, index) => FeatureWidget(
            feature: features[index],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
```

## 9. Add Route

```dart
// app/router.dart

GoRoute(
  path: '/features',
  name: 'features',
  builder: (context, state) => const FeatureScreen(),
),
```

## 10. Write Tests

```dart
// test/unit/repositories/{feature}_repository_test.dart

void main() {
  group('FeatureRepository', () {
    test('getAll returns list of features', () async {
      // ...
    });
  });
}
```

## Checklist

- [ ] Entity created
- [ ] Model with JSON serialization
- [ ] Repository interface
- [ ] Firebase implementation
- [ ] Riverpod provider
- [ ] Screen widget
- [ ] Route added
- [ ] Unit tests
- [ ] Widget tests
