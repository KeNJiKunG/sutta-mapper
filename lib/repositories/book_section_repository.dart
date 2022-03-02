import 'package:sutta/models/book.dart';
import 'package:sutta/models/book_section.dart';
import 'package:sutta/repositories/repository.dart';

class BookSectionRepository extends Repository {

  BookSectionRepository() : super("BookSections");

  Future<Iterable<BookSection>> getBookSections() async {
    var connection = await getConnection();

    var bookSections = await connection.select("""SELECT bookId, name, ordering FROM Books ORDER BY ordering""");

    return _parseBookSections(bookSections);
  }

  Future<BookSection> getBookSection(int bookSectionId) async {
    var connection = await getConnection();

    var bookSections = await connection.select("""SELECT bookId, name, ordering FROM Books WHERE bookId = ?""", [bookSectionId]);

    return _parseBookSections(bookSections).first;
  }

  static Iterable<BookSection> _parseBookSections(Iterable<Map<String, Object?>> books) {
    return books.map((b) => _parseBookSection(b));
  }

  static BookSection _parseBookSection(Map<String, Object?> bookSection) {
    return BookSection(
      bookSectionId: bookSection["bookId"] as int,
      bookId: bookSection["bookId"] as int,
      name: bookSection["name"] as String,
    );
  }
}
