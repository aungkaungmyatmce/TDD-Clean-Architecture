import 'dart:convert';
import 'package:tdd_clean_architecture/core/error/exception.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late NumberTriviaLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(
        sharedPreferences: mockSharedPreferences);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));
    test(
        'should return numberTrivia from SharedPreferences when three is one in the cache',
        () async {
      when(() => mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA))
          .thenReturn(fixture('trivia_cached.json'));
      final result = await dataSource.getLastNumberTrivia();
      verify(() => mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw a CacheException  when there is not a cached value',
        () async {
      when(() => mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA))
          .thenReturn(null);
      final call = dataSource.getLastNumberTrivia;

      expect(() => call(), throwsA(TypeMatcher<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel(text: 'Test', number: 1);

    test('should call SharedPreferences fo cache the data', () async {
      when(() => mockSharedPreferences.setString(
              CACHED_NUMBER_TRIVIA, json.encode(tNumberTriviaModel.toJson())))
          .thenAnswer((_) async => true);
      dataSource.cacheNumberTrivia(tNumberTriviaModel);
      final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
      verify(() => mockSharedPreferences.setString(
          CACHED_NUMBER_TRIVIA, expectedJsonString));
    });
  });
}
