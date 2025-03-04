import 'dart:io';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    printHelp();
    return;
  }

  final command = arguments[0];

  switch (command) {
    case 'create':
      if (arguments.length < 3) {
        print('❌ Erro: Nome do projeto ou template não informado.');
        return;
      }
      createFlutterProject(arguments[1], arguments[2]);
      break;

    case 'add':
      if (arguments.length < 3 || arguments[1] != 'feature') {
        print('❌ Erro: Comando inválido. Use: flugen add feature <nome>');
        return;
      }
      addFeature(arguments[2]);
      break;

    default:
      print('❌ Comando desconhecido: $command');
      printHelp();
  }
}

void printHelp() {
  print('''
  🎯 FluGen - Flutter Project Generator
  ------------------------------------
  Comandos disponíveis:

  - flugen create <nome_projeto> <template>  → Cria um novo projeto Flutter
    Templates disponíveis: login
  - flugen add feature <nome>                → Adiciona um módulo/feature ao projeto

  Exemplo:
  flugen create my_app login
  flugen add feature home
  ''');
}

Future<void> createFlutterProject(String projectName, String template) async {
  print('🚀 Criando projeto Flutter: $projectName...');
  await Process.runSync('flutter', ['create', projectName]);
  final projectPath = Directory('$projectName/lib');

  await installDependencies(projectName);

  switch (template) {
    case 'login':
      createLoginTemplate(projectPath.path);
      break;
    default:
      print('❌ Template desconhecido: $template');
      return;
  }

  print('🔧 Gerando arquivos...');
  Process.runSync('dart', ['run', 'build_runner', 'build'],
      workingDirectory: projectName);
  Process.runSync('dart', ['run', 'routefly'], workingDirectory: projectName);

  print('✅ Projeto criado com sucesso!');
}

void createLoginTemplate(String projectPath) {
  final directories = [
    'config',
    'core/localization/l10n',
    'core/routing',
    'core/themes',
    'data/exceptions',
    'data/repositories/auth',
    'data/services/auth',
    'domain/models',
    'domain/dtos',
    'domain/entities',
    'domain/validators',
    'ui/auth/viewmodels',
    'utils/exceptions',
    'utils/validation',
    'widgets',
  ];

  for (var dir in directories) {
    Directory('$projectPath/$dir').createSync(recursive: true);
  }

  createMainFile(projectPath);
  createAssets(projectPath);
  createCoreLocalizationEN(projectPath);
  createCoreLocalizationPT(projectPath);
  createThemeColors(projectPath);
  createThemeDimens(projectPath);
  createTheme(projectPath);
  createDependencies(projectPath);
  createDataExceptions(projectPath);
  createRepositoriesAuth(projectPath);
  createRepositoriesAuthRemote(projectPath);
  createDataServiceAuthClient(projectPath);
  createDataServiceAuthLocal(projectPath);
  createCoreClientHttp(projectPath);
  createCoreLocalStorage(projectPath);
  createDomainDtos(projectPath);
  createDomainEntities(projectPath);
  createDomainValidators(projectPath);
  createUiAuthViewmodel(projectPath);
  createDomainValidatorsCredentialsValidator(projectPath);
  createUtilsExceptions(projectPath);
  createUiAuthLoginPage(projectPath);
  createUtilsValidationLucidValidatorExtension(projectPath);
}

void addFeature(String featureName) {
  print('🛠 Adicionando feature: $featureName...');
  final dir = Directory('lib/features/$featureName');
  dir.createSync(recursive: true);

  File('${dir.path}/$featureName.dart').writeAsStringSync('''
  class ${featureName[0].toUpperCase()}${featureName.substring(1)}Feature {
    void execute() {
      print('🚀 Feature $featureName adicionada!');
    }
  }
  ''');

  print('✅ Feature "$featureName" criada em lib/features/$featureName/');
}

Future<void> installDependencies(String projectPath) async {
  print('📦 Instalando pacotes essenciais...');

  Process.runSync(
      'flutter',
      [
        'pub',
        'add',
        'freezed_annotation',
        'json_annotation',
        'lucid_validation',
        'result_dart',
        'dio',
        'auto_injector',
        'routefly',
      ],
      workingDirectory: projectPath);

  print('📦 Instalando pacotes de desenvolvimento...');

  Process.runSync(
      'flutter',
      [
        'pub',
        'add',
        '--dev',
        'build_runner',
        'json_serializable',
        'freezed',
      ],
      workingDirectory: projectPath);

  print('✅ Pacotes instalados com sucesso!');
}

void createMainFile(String path) {
  final file = File('$path/main.dart');
  file.writeAsStringSync('''
import 'package:app_architecture_flutter/config/dependencies.dart';
import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';

import 'main.route.dart';

part 'main.g.dart';

void main() {
  setupDependencies();

  runApp(const MainApp());
}

@Main('lib/ui')
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: Routefly.routerConfig(
        routes: routes,
        initialPath: routePaths.auth.login,
      ),
    );
  }
}
  ''');
}

void createAssets(String path) {
  final file = File('$path/config/assets.dart');
  file.writeAsStringSync('''
abstract final class Assets {}
  ''');
}

void createCoreLocalizationEN(String path) {
  final file = File('$path/core/localization/l10n/intl_en.arb');
  file.writeAsStringSync('''
{
    "homeTitle": "Home",
    "@homeTitle": {
        "description": "Home screen title"
    },
    "pushedTheButton": "You have pushed the button this many times:",
    "@pushedTheButton": {
        "description": "A text that indicates how many times the user pushed the button"
    }
}
  ''');
}

void createCoreLocalizationPT(String path) {
  final file = File('$path/core/localization/l10n/intl_pt.arb');
  file.writeAsStringSync('''
{
    "helloWorld": "Home",
    "pushedTheButton": "Você apertou o botão tantas vezes:"
}
  ''');
}

void createThemeColors(String path) {
  final file = File('$path/core/themes/colors.dart');
  file.writeAsStringSync('''
import 'package:flutter/material.dart';

abstract final class AppColors {
  static const black1 = Color(0xFF101010);
  static const white1 = Color(0xFFFFF7FA);
  static const grey1 = Color(0xFFF2F2F2);
  static const grey2 = Color(0xFF4D4D4D);
  static const grey3 = Color(0xFFA4A4A4);
  static const whiteTransparent = Color(0x4DFFFFFF); 
  static const blackTransparent = Color(0x4D000000);
  static const red1 = Color(0xFFE74C3C);

  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.black1,
    onPrimary: AppColors.white1,
    secondary: AppColors.black1,
    onSecondary: AppColors.white1,
    surface: Colors.white,
    onSurface: AppColors.black1,
    error: Colors.white,
    onError: Colors.red,
  );

  static const darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.white1,
    onPrimary: AppColors.black1,
    secondary: AppColors.white1,
    onSecondary: AppColors.black1,
    surface: AppColors.black1,
    onSurface: Colors.white,
    error: Colors.black,
    onError: AppColors.red1,
  );
}
  ''');
}

void createThemeDimens(String path) {
  final file = File('$path/core/themes/dimens.dart');
  file.writeAsStringSync('''
import 'package:flutter/material.dart';

abstract final class Dimens {
  const Dimens();

  static const paddingHorizontal = 20.0;
  static const paddingVertical = 24.0;

  double get paddingScreenHorizontal;
  double get paddingScreenVertical;

  double get profilePictureSize;

  EdgeInsets get edgeInsetsScreenHorizontal =>
      EdgeInsets.symmetric(horizontal: paddingScreenHorizontal);

  EdgeInsets get edgeInsetsScreenSymmetric => EdgeInsets.symmetric(
      horizontal: paddingScreenHorizontal, vertical: paddingScreenVertical);

  static const Dimens desktop = _DimensDesktop();
  static const Dimens mobile = _DimensMobile();

  factory Dimens.of(BuildContext context) =>
      switch (MediaQuery.sizeOf(context).width) {
        > 600 => desktop,
        _ => mobile,
      };
}

final class _DimensMobile extends Dimens {
  @override
  final double paddingScreenHorizontal = Dimens.paddingHorizontal;

  @override
  final double paddingScreenVertical = Dimens.paddingVertical;

  @override
  final double profilePictureSize = 64.0;

  const _DimensMobile();
}

final class _DimensDesktop extends Dimens {
  @override
  final double paddingScreenHorizontal = 100.0;

  @override
  final double paddingScreenVertical = 64.0;

  @override
  final double profilePictureSize = 128.0;

  const _DimensDesktop();
}
  ''');
}

void createTheme(String path) {
  final file = File('$path/core/themes/theme.dart');
  file.writeAsStringSync('''
import 'package:flutter/material.dart';

import 'colors.dart';

abstract final class AppTheme {
  static const _textTheme = TextTheme(
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
    headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.grey3,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.grey3,
    ),
    labelLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: AppColors.grey3,
    ),
  );

  static const _inputDecorationTheme = InputDecorationTheme(
    hintStyle: TextStyle(
      color: AppColors.grey3,
      fontSize: 18.0,
      fontWeight: FontWeight.w400,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: AppColors.lightColorScheme,
    textTheme: _textTheme,
    inputDecorationTheme: _inputDecorationTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: AppColors.darkColorScheme,
    textTheme: _textTheme,
    inputDecorationTheme: _inputDecorationTheme,
  );
}
  ''');
}

void createDependencies(String path) {
  final file = File('$path/config/dependencies.dart');
  file.writeAsStringSync('''
import 'package:app_architecture_flutter/data/repositories/auth/auth_repository.dart';
import 'package:app_architecture_flutter/data/repositories/auth/remote_auth_repository.dart';
import 'package:app_architecture_flutter/data/services/auth/auth_client_http.dart';
import 'package:app_architecture_flutter/data/services/auth/auth_local_storage.dart';
import 'package:app_architecture_flutter/data/services/client_http.dart';
import 'package:app_architecture_flutter/data/services/local_storage.dart';
import 'package:auto_injector/auto_injector.dart';

final injector = AutoInjector();

void setupDependencies(){
  injector.addSingleton<AuthRepository>(RemoteAuthRepository.new);
  injector.addSingleton(ClientHttp.new);
  injector.addSingleton(LocalStorage.new);
  injector.addSingleton(AuthClientHttp.new);
  injector.addSingleton(AuthLocalStorage.new);
}
  ''');
}

void createDataExceptions(String path) {
  final file = File('$path/data/exceptions/exceptions.dart');
  file.writeAsStringSync('''
import 'package:app_architecture_flutter/utils/exceptions/exceptions.dart';

class LocalStorageException extends AppExceptions {
  LocalStorageException(super.message, [super.stackTrace]);
}
  ''');
}

void createRepositoriesAuth(String path) {
  final file = File('$path/data/repositories/auth/auth_repository.dart');
  file.writeAsStringSync('''
import 'package:app_architecture_flutter/domain/dtos/credentials.dart';
import 'package:app_architecture_flutter/domain/entities/user_entity.dart';
import 'package:result_dart/result_dart.dart';

abstract interface class AuthRepository {
  AsyncResult<LoggedUser> login(Credentials credentials);
  AsyncResult<Unit> logout();
  AsyncResult<LoggedUser> getUser();
  Stream<User> userObserver();
  void dispose();
}

  ''');
}

void createRepositoriesAuthRemote(String path) {
  final file = File('$path/data/repositories/auth/remote_auth_repository.dart');
  file.writeAsStringSync('''
import 'dart:async';

import 'package:app_architecture_flutter/data/services/auth/auth_client_http.dart';
import 'package:app_architecture_flutter/domain/dtos/credentials.dart';
import 'package:app_architecture_flutter/domain/validators/credentials_validator.dart';
import 'package:app_architecture_flutter/utils/validation/lucid_validator_extension.dart';
import 'package:result_dart/result_dart.dart';

import 'package:app_architecture_flutter/data/repositories/auth/auth_repository.dart';
import 'package:app_architecture_flutter/data/services/auth/auth_local_storage.dart';
import 'package:app_architecture_flutter/domain/entities/user_entity.dart';

class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository(this._authLocalStorage, this._authClientHttp);
  final _streamController = StreamController<User>.broadcast();

  final AuthLocalStorage _authLocalStorage;
  final AuthClientHttp _authClientHttp;

  @override
  AsyncResult<LoggedUser> getUser() {
    return _authLocalStorage.getUser();
  }

  @override
  AsyncResult<LoggedUser> login(Credentials credentials) async {
    final validator = CredentialsValidator();

    return validator 
        .validateResult(credentials)
        .flatMap(_authClientHttp.login)
        .flatMap(_authLocalStorage.saveUser)
        .onSuccess(_streamController.add);
  }

  @override
  AsyncResult<Unit> logout() {
    return _authLocalStorage
        .removeUser()
        .onSuccess((_) => _streamController.add(const NotLoggedUser()));
  }

  @override
  Stream<User> userObserver() {
    return _streamController.stream;
  }

  @override
  void dispose() {
    _streamController.close();
  }
}
  ''');
}

void createDataServiceAuthClient(String path) {
  final file = File('$path/data/services/auth/auth_client_http.dart');
  file.writeAsStringSync('''
import 'package:app_architecture_flutter/core/client_http/client_http.dart';
import 'package:app_architecture_flutter/domain/dtos/credentials.dart';
import 'package:app_architecture_flutter/domain/entities/user_entity.dart';
import 'package:result_dart/result_dart.dart';

class AuthClientHttp {
  final ClientHttp _clientHttp;

  AuthClientHttp(this._clientHttp);

  AsyncResult<LoggedUser> login(Credentials credentials) async {
    final response = await _clientHttp.post('/login', {
      'email': credentials.email,
      'password': credentials.password,
    });

    return response.map((response) {
      return LoggedUser.fromJson(response.data);
    });
  }
}
  ''');
}

void createDataServiceAuthLocal(String path) {
  final file = File('$path/data/services/auth/auth_local_storage.dart');
  file.writeAsStringSync('''
import 'dart:convert';

import 'package:app_architecture_flutter/core/local_storage/local_storage.dart';
import 'package:app_architecture_flutter/domain/entities/user_entity.dart';
import 'package:result_dart/result_dart.dart';

const _userKey = 'user';

class AuthLocalStorage {
  final LocalStorage _localStorage;

  AuthLocalStorage(this._localStorage);

  AsyncResult<LoggedUser> getUser() {
    return _localStorage
        .getData(_userKey)
        .map((json) => LoggedUser.fromJson(jsonDecode(json)));
  }

  AsyncResult<LoggedUser> saveUser(LoggedUser user) {
    return _localStorage
        .saveData(_userKey, jsonEncode(user.toJson()))
        .pure(user);
  }

  AsyncResult<Unit> removeUser() {
    return _localStorage.removeData(_userKey);
  }
}
  ''');
}

void createCoreClientHttp(String path) {
  final file = File('$path/core/client_http/client_http.dart');
  file.writeAsStringSync('''
import 'package:dio/dio.dart';
import 'package:result_dart/result_dart.dart';

class ClientHttp {
  final Dio _dio;

  ClientHttp(this._dio);

  AsyncResult<Response> get(String url) async {
    try {
      final response = await _dio.get(url);
      return Success(response);
    } on DioException catch (e) {
      return Failure(e);
    }
  }

  AsyncResult<Response> post(String url, dynamic data) async {
    try {
      final response = await _dio.post(url, data: data);
      return Success(response);
    } on DioException catch (e) {
      return Failure(e);
    }
  }

  AsyncResult<Response> delete(String url) async {
    try {
      final response = await _dio.delete(url);
      return Success(response);
    } on DioException catch (e) {
      return Failure(e);
    }
  }

  AsyncResult<Response> patch(String url, dynamic data) async {
    try {
      final response = await _dio.patch(url, data: data);
      return Success(response);
    } on DioException catch (e) {
      return Failure(e);
    }
  }
}
  ''');
}

void createCoreLocalStorage(String path) {
  final file = File('$path/core/local_storage/local_storage.dart');
  file.writeAsStringSync('''
import 'package:app_architecture_flutter/data/exceptions/exceptions.dart';
import 'package:result_dart/result_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  AsyncResult<String> saveData(String key, String value) async {
    try {
      final shared = await SharedPreferences.getInstance();
      shared.setString(key, value);
      return Success(value);
    } catch (e, s) {
      return Failure(LocalStorageException(e.toString(), s));
    }
  }

  AsyncResult<String> getData(String key) async {
    try {
      final shared = await SharedPreferences.getInstance();
      final value = shared.getString(key);
      return value != null
          ? Success(value)
          : Failure(LocalStorageException('No data found'));
    } catch (e, s) {
      return Failure(LocalStorageException(e.toString(), s));
    }
  }

  AsyncResult<Unit> removeData(String key) async {
    try {
      final shared = await SharedPreferences.getInstance();
      shared.remove(key);
      return const Success(unit);          
    } catch (e, s) {
      return Failure(LocalStorageException(e.toString(), s));
    }
  }
}
  ''');
}

void createDomainDtos(String path) {
  final file = File('$path/domain/dtos/credentials.dart');
  file.writeAsStringSync('''
class Credentials {
  String email;
  String password;

  Credentials({
    this.email = '',
    this.password = '',
  });
}
  ''');
}

void createDomainEntities(String path) {
  final file = File('$path/domain/entities/user_entity.dart');
  file.writeAsStringSync(r'''
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';
part 'user_entity.g.dart';

@freezed
sealed class User with _$User {
  const factory User({
    required int id,
    required String name,
    required String email,
  }) = _User;

  const factory User.notLogged() = NotLoggedUser;

  const factory User.logged({
    required int id,
    required String name,
    required String email,
    required String token,
    required String refreshToken,
  }) = LoggedUser;

  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);
}
  ''');
}

void createDomainValidators(String path) {
  final file = File('$path/domain/validators/credentials_validator.dart');
  file.writeAsStringSync('''
import 'package:app_architecture_flutter/domain/dtos/credentials.dart';
import 'package:lucid_validation/lucid_validation.dart';

class CredentialsValidator extends LucidValidator<Credentials> {
  CredentialsValidator() {
    ruleFor((c) => c.email, key: 'email').notEmpty().validEmail();
    
    ruleFor((c) => c.password, key: 'password')
        .notEmpty()
        .minLength(6)
        .mustHaveLowercase()
        .mustHaveUppercase()
        .mustHaveNumber()
        .mustHaveSpecialCharacter();
  }
}
  ''');
}

void createUiAuthViewmodel(String path) {
  final file = File('$path/ui/auth/viewmodels/login_viewmodels.dart');
  file.writeAsStringSync('''
import 'package:app_architecture_flutter/data/repositories/auth/auth_repository.dart';
import 'package:app_architecture_flutter/domain/dtos/credentials.dart';
import 'package:flutter/foundation.dart';

class LoginViewmodels extends ChangeNotifier {
  final AuthRepository _authRepository;

  LoginViewmodels(this._authRepository);

  Future<void> login(Credentials credentials) async {
    await _authRepository.login(credentials);
  }
}
  ''');
}

void createDomainValidatorsCredentialsValidator(String path) {
  final file = File('$path/domain/validators/credentials_validator.dart');
  file.writeAsStringSync('''
import 'package:app_architecture_flutter/domain/dtos/credentials.dart';
import 'package:lucid_validation/lucid_validation.dart';

class CredentialsValidator extends LucidValidator<Credentials> {
  CredentialsValidator() {
    ruleFor((c) => c.email, key: 'email').notEmpty().validEmail();
    
    ruleFor((c) => c.password, key: 'password')
        .notEmpty()
        .minLength(6)
        .mustHaveLowercase()
        .mustHaveUppercase()
        .mustHaveNumber()
        .mustHaveSpecialCharacter();
  }
}

  ''');
}

void createUtilsExceptions(String path) {
  final file = File('$path/utils/exceptions/exceptions.dart');
  file.writeAsStringSync(r'''
class AppExceptions implements Exception {
  final String message;
  final StackTrace? stackTrace;

  AppExceptions(this.message, [this.stackTrace]);

  @override
  String toString() {
    if (stackTrace != null) {
      return '$runtimeType: $message\n$stackTrace';
    }

    return '$runtimeType: $message';
  }
}
  ''');
}

void createUiAuthLoginPage(String path) {
  final file = File('$path/ui/auth/login_page.dart');
  file.writeAsStringSync('''
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login page'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Login page'),
          ],
        ),
      ),
    );
  }
}
  ''');
}

void createUtilsValidationLucidValidatorExtension(String path) {
  final file = File('$path/utils/validation/lucid_validator_extension.dart');
  file.writeAsStringSync('''
import 'package:lucid_validation/lucid_validation.dart';
import 'package:result_dart/result_dart.dart';

extension LucidValidatorExtension<T extends Object> on LucidValidator<T> {
  AsyncResult<T> validateResult(T value) async {
    final result = validate(value);
    if (result.isValid) {
      return Success(value);
    }
    return Failure(Exception(result.exceptions.first));
  }
}
  ''');
}
