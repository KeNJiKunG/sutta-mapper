import 'package:sutta/models/book.dart';
import 'package:sutta/repositories/repository.dart';

class BookRepository extends Repository {
  BookRepository() : super("Books");

  Future<Iterable<Book>> getBooks() async {
    var connection = await getConnection();

    var books = await connection.select("""SELECT bookId, name, namePL, ordering FROM Books ORDER BY ordering""");

    return _parseBooks(books);
  }

  Future<Book> getBook(int bookId) async {
    var connection = await getConnection();

    var books = await connection.select("""SELECT bookId, name, namePL, ordering FROM Books WHERE bookId = ?""", [bookId]);

    return _parseBooks(books).first;
  }

  static Iterable<Book> _parseBooks(Iterable<Map<String, Object?>> books) {
    return books.map((b) => _parseBook(b));
  }

  static Book _parseBook(Map<String, Object?> book) {
    return Book(
      bookId: book["bookId"] as int,
      name: book["name"] as String,
      namePL: book["namePL"] as String,
      ordering: book["ordering"] as int,
    );
  }
}
