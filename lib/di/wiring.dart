import 'package:http/http.dart' as http;

import '../core/http_client.dart';
import '../core/env.dart';

import '../data/db/db.dart';
import '../data/services/osu_auth_service.dart';
import '../data/datasources/osu_remote_ds.dart';
import '../data/datasources/binding_local_ds.dart';
import '../data/repositories/osu_repository_impl.dart';
import '../data/repositories/binding_repository_impl.dart';

import '../domain/repositories/osu_repository.dart';
import '../domain/repositories/binding_repository.dart';

import '../domain/usecases/register_binding.dart';
import '../domain/usecases/unregister_binding.dart';
import '../domain/usecases/get_binding.dart';
import '../domain/usecases/fetch_profile.dart';
import '../domain/usecases/fetch_top_scores.dart';
import '../domain/usecases/fetch_recent_scores.dart';
import '../domain/usecases/fetch_user_map_scores.dart';

class AppDeps {
  AppDeps({
    required this.http,
    required this.auth,
    required this.remote,
    required this.osuRepo,
    required this.bindingLocal,
    required this.bindingRepo,
    required this.registerBinding,
    required this.unregisterBinding,
    required this.getBinding,
    required this.fetchProfile,
    required this.fetchTopScores,
    required this.fetchRecentScores,
    required this.fetchUserMapScores,
  });

  final IHttpClient http;
  final OsuAuthService auth;
  final OsuRemoteDs remote;
  final IOsuRepository osuRepo;
  final BindingLocalDs bindingLocal;
  final IBindingRepository bindingRepo;
  final RegisterBinding registerBinding;
  final UnregisterBinding unregisterBinding;
  final GetBinding getBinding;
  final FetchProfile fetchProfile;
  final FetchTopScores fetchTopScores;
  final FetchRecentScores fetchRecentScores;
  final FetchUserMapScores fetchUserMapScores;
}

Future<AppDeps> buildDeps(Env env, AppDatabase db) async {
  final httpClient = HttpClientImpl(http.Client());

  final auth = OsuAuthService(
    http: httpClient,
    clientId: env.osuClientId,
    clientSecret: env.osuClientSecret,
  );

  final remote = OsuRemoteDs(http: httpClient, tokenProvider: auth.getToken);

  final osuRepo = OsuRepositoryImpl(remote);

  final bindingLocal = BindingLocalDs(db);
  final bindingRepo = BindingRepositoryImpl(bindingLocal);

  return AppDeps(
    http: httpClient,
    auth: auth,
    remote: remote,
    osuRepo: osuRepo,
    bindingLocal: bindingLocal,
    bindingRepo: bindingRepo,
    registerBinding: RegisterBinding(bindingRepo, osuRepo),
    unregisterBinding: UnregisterBinding(bindingRepo),
    getBinding: GetBinding(bindingRepo),
    fetchProfile: FetchProfile(osuRepo),
    fetchTopScores: FetchTopScores(osuRepo),
    fetchRecentScores: FetchRecentScores(osuRepo),
    fetchUserMapScores: FetchUserMapScores(osuRepo),
  );
}
