import 'package:bloc_test/bloc_test.dart';
import 'package:eldcare/pharmacy/blocs/category/category_bloc.dart';
import 'package:eldcare/pharmacy/model/category.dart';
import 'package:eldcare/pharmacy/presentation/inventory/add_categery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryBloc extends MockBloc<CategoryEvent, CategoryState>
    implements CategoryBloc {}

class MockAddCategoryEvent extends Fake implements CategoryEvent {}

void main() {
  late MockCategoryBloc mockCategoryBloc;

  setUpAll(() {
    print('🚀 Starting AddCategoryPage tests');
    registerFallbackValue(MockAddCategoryEvent());
  });

  setUp(() {
    mockCategoryBloc = MockCategoryBloc();
    when(() => mockCategoryBloc.state).thenReturn(
      CategoryLoaded([
        Category(id: '1', name: 'Tablets', shopId: 'shop1'),
        Category(id: '2', name: 'Syrups', shopId: 'shop1'),
      ]),
    );
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<CategoryBloc>.value(
        value: mockCategoryBloc,
        child: const AddCategoryPage(shopId: 'shop1'),
      ),
    );
  }

  group('AddCategoryPage', () {
    testWidgets('renders AppBar correctly', (WidgetTester tester) async {
      print('\n🧪 Testing AppBar...');
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Manage Categories'), findsOneWidget);
      print('✅ AppBar verified');
    });

    testWidgets('displays add category button', (WidgetTester tester) async {
      print('\n🧪 Testing Add Category button...');
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Add Category'), findsOneWidget);
      print('✅ Add Category button verified');
    });

    testWidgets('shows search field', (WidgetTester tester) async {
      print('\n🧪 Testing search field...');
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      print('✅ Search field verified');
    });

    testWidgets('displays category list', (WidgetTester tester) async {
      print('\n🧪 Testing category list...');
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Tablets'), findsOneWidget);
      expect(find.text('Syrups'), findsOneWidget);
      print('✅ Category list verified');
    });

    testWidgets('shows edit and delete icons', (WidgetTester tester) async {
      print('\n🧪 Testing category actions...');
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.edit), findsNWidgets(2));
      expect(find.byIcon(Icons.delete), findsNWidgets(2));
      print('✅ Category actions verified');
    });
  });

  tearDownAll(() {
    print('\n🏁 Tests completed successfully');
  });
}
