import 'package:get/get.dart';
import 'package:github_repository_search/core/network/dio_clients.dart';
import 'package:github_repository_search/data/repository/repo_repository.dart';
import '../../data/local/repo_local_datasource.dart';
import '../../data/remote/repo_remote_datasource.dart';
import '../utils/connectivity_helper.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DioClient(), permanent: true);
    Get.put(ConnectivityHelper(), permanent: true);

    Get.put(
      RepoRemoteDataSource(dioClient: Get.find<DioClient>()),
      permanent: true,
    );
    Get.put(RepoLocalDataSource(), permanent: true);

    Get.put(
      RepoRepository(
        remote: Get.find<RepoRemoteDataSource>(),
        local: Get.find<RepoLocalDataSource>(),
        connectivity: Get.find<ConnectivityHelper>(),
      ),
      permanent: true,
    );
  }
}
