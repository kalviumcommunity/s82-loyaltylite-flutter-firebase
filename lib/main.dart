import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/utils/result.dart';
import 'data/repositories_impl/auth_repository_impl.dart';
import 'data/repositories_impl/loyalty_repository_impl.dart';
import 'data/services/firebase_auth_service.dart';
import 'data/services/firestore_service.dart';
import 'data/services/notification_service.dart';
import 'domain/usecases/analytics/get_analytics.dart';
import 'domain/usecases/auth/auth_state_changes.dart';
import 'domain/usecases/auth/get_current_user.dart';
import 'domain/usecases/auth/sign_in.dart';
import 'domain/usecases/auth/sign_out.dart';
import 'domain/usecases/auth/sign_up.dart';
import 'domain/usecases/customers/create_customer.dart';
import 'domain/usecases/customers/delete_customer.dart';
import 'domain/usecases/customers/stream_customers.dart';
import 'domain/usecases/customers/update_customer_points.dart';
import 'firebase_options.dart';
import 'presentation/providers/analytics_provider.dart';
import 'presentation/providers/auth_provider.dart' as app;
import 'presentation/providers/customer_provider.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(LoyaltyLiteApp());
}

class LoyaltyLiteApp extends StatelessWidget {
  factory LoyaltyLiteApp() {
    final authService = FirebaseAuthService(FirebaseAuth.instance);
    final firestoreService = FirestoreService(FirebaseFirestore.instance);
    final notificationService = NotificationService();

    final authRepository = AuthRepositoryImpl(authService, firestoreService);
    final loyaltyRepository =
        LoyaltyRepositoryImpl(authService, firestoreService, notificationService);

    return LoyaltyLiteApp._(
      signInUseCase: SignInUseCase(authRepository),
      signUpUseCase: SignUpUseCase(authRepository),
      signOutUseCase: SignOutUseCase(authRepository),
      authStateChangesUseCase: AuthStateChangesUseCase(authRepository),
      getCurrentUserUseCase: GetCurrentUserUseCase(authRepository),
      createCustomerUseCase: CreateCustomerUseCase(loyaltyRepository),
      updateCustomerPointsUseCase: UpdateCustomerPointsUseCase(loyaltyRepository),
      deleteCustomerUseCase: DeleteCustomerUseCase(loyaltyRepository),
      streamCustomersUseCase: StreamCustomersUseCase(loyaltyRepository),
      getAnalyticsUseCase: GetAnalyticsUseCase(loyaltyRepository),
    );
  }

  const LoyaltyLiteApp._({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
    required AuthStateChangesUseCase authStateChangesUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required CreateCustomerUseCase createCustomerUseCase,
    required UpdateCustomerPointsUseCase updateCustomerPointsUseCase,
    required DeleteCustomerUseCase deleteCustomerUseCase,
    required StreamCustomersUseCase streamCustomersUseCase,
    required GetAnalyticsUseCase getAnalyticsUseCase,
    })  : _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _signOutUseCase = signOutUseCase,
        _authStateChangesUseCase = authStateChangesUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _createCustomerUseCase = createCustomerUseCase,
        _updatePointsUseCase = updateCustomerPointsUseCase,
        _deleteCustomerUseCase = deleteCustomerUseCase,
        _streamCustomersUseCase = streamCustomersUseCase,
        _getAnalyticsUseCase = getAnalyticsUseCase,
        super(key: const Key('LoyaltyLiteApp'));

  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final AuthStateChangesUseCase _authStateChangesUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final CreateCustomerUseCase _createCustomerUseCase;
  final UpdateCustomerPointsUseCase _updatePointsUseCase;
  final DeleteCustomerUseCase _deleteCustomerUseCase;
  final StreamCustomersUseCase _streamCustomersUseCase;
  final GetAnalyticsUseCase _getAnalyticsUseCase;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<app.AuthProvider>(
          create: (_) => app.AuthProvider(
            signIn: _signInUseCase,
            signUp: _signUpUseCase,
            signOut: _signOutUseCase,
            authStateChanges: _authStateChangesUseCase,
            getCurrentUser: _getCurrentUserUseCase,
          ),
        ),
        ChangeNotifierProvider<CustomerProvider>(
          create: (_) => CustomerProvider(
            createCustomer: _createCustomerUseCase,
            updatePoints: _updatePointsUseCase,
            deleteCustomer: _deleteCustomerUseCase,
            streamCustomers: _streamCustomersUseCase,
          ),
        ),
        ChangeNotifierProvider<AnalyticsProvider>(
          create: (_) => AnalyticsProvider(_getAnalyticsUseCase),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: Consumer<app.AuthProvider>(
          builder: (context, auth, _) {
            switch (auth.status) {
              case app.AuthStatus.unknown:
              case app.AuthStatus.loading:
                return const SplashScreen();
              case app.AuthStatus.authenticated:
                return const DashboardScreen();
              case app.AuthStatus.unauthenticated:
                return const LoginScreen();
              case app.AuthStatus.error:
                final message = auth.error?.message ?? 'Authentication error';
                return ErrorScaffold(message: message);
            }
          },
        ),
      ),
    );
  }
}

class ErrorScaffold extends StatelessWidget {
  const ErrorScaffold({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<app.AuthProvider>().signOut(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}