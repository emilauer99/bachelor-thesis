
abstract class ICustomerRepository {
  Future<dynamic> getAll();
  Future<dynamic> create(String name, String imagePath);
  Future<void> delete(int id);
}
