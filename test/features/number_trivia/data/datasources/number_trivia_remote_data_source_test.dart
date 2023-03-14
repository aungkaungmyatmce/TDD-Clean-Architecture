import 'dart:convert';
import 'package:tdd_clean_architecture/core/error/exception.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../fixtures/fixture_reader.dart';
import 'package:http/http.dart' as http;

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late NumberTriviaRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  void setMockHttpClientSuccess200() {
    registerFallbackValue(Uri.parse(''));

    when(() => mockHttpClient
            .get(any(), headers: {'Content-Type': 'application/json'}))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setMockHttpClientFailure404() {
    registerFallbackValue(Uri.parse(''));
    when(() => mockHttpClient
            .get(any(), headers: {'Content-Type': 'application/json'}))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 404));
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test('''should perform a GET request on a URL with number
        being the endpoint and with application/json header''', () async {
      setMockHttpClientSuccess200();
      dataSource.getConcreteNumberTrivia(tNumber);
      verify(() => mockHttpClient.get(
          Uri.parse('https://numbersapi.com/$tNumber'),
          headers: {'Content-Type': 'application/json'}));
    });

    test('should return NumberTrivia when the response code is 200 (success)',
        () async {
      setMockHttpClientSuccess200();
      final result = await dataSource.getConcreteNumberTrivia(tNumber);
      expect(result, tNumberTriviaModel);
    });

    test('should trow a SeverException when the response code is 404 or other',
        () async {
      setMockHttpClientFailure404();
      final call = dataSource.getConcreteNumberTrivia;
      expect(call(tNumber), throwsA(TypeMatcher<SeverException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test('''should perform a GET request on a URL with number
        being the endpoint and with application/json header''', () async {
      setMockHttpClientSuccess200();
      dataSource.getRandomNumberTrivia();
      verify(() => mockHttpClient.get(
          Uri.parse('https://numbersapi.com/random'),
          headers: {'Content-Type': 'application/json'}));
    });

    test('should return NumberTrivia when the response code is 200 (success)',
        () async {
      setMockHttpClientSuccess200();
      final result = await dataSource.getRandomNumberTrivia();
      expect(result, tNumberTriviaModel);
    });

    test('should trow a SeverException when the response code is 404 or other',
        () async {
      setMockHttpClientFailure404();
      final call = dataSource.getRandomNumberTrivia;
      expect(call(), throwsA(TypeMatcher<SeverException>()));
    });
  });
}
