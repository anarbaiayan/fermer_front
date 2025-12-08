import 'package:frontend/core/screens/not_found_screen.dart';
import 'package:frontend/features/auth/presentation/login_screen.dart';
import 'package:frontend/features/auth/presentation/widgets/register_flow_models.dart';
import 'package:frontend/features/auth/presentation/widgets/register_password_screen.dart';
import 'package:frontend/features/auth/presentation/register_screen.dart';
import 'package:frontend/features/herd/domain/entities/cattle.dart';
import 'package:frontend/features/herd/domain/entities/cattle_create_data.dart';
import 'package:frontend/features/herd/domain/entities/cattle_edit_data.dart';
import 'package:frontend/features/herd/presentation/herd_add_animal_details_screen.dart';
import 'package:frontend/features/herd/presentation/herd_add_animal_screen.dart';
import 'package:frontend/features/herd/presentation/herd_animal_screen.dart';
import 'package:frontend/features/herd/presentation/herd_edit_animal_details_screen.dart';
import 'package:frontend/features/herd/presentation/herd_edit_animal_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/splash/presentation/splash_screen.dart';
import 'package:frontend/features/home/presentation/home_screen.dart';
import 'package:frontend/features/herd/presentation/herd_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  errorBuilder: (context, state) => const NotFoundScreen(),
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register-step1',
      builder: (context, state) => const RegisterStep1Screen(),
    ),
    GoRoute(
      path: '/register-step2',
      builder: (context, state) {
        final data = state.extra as RegisterInfo;
        return RegisterStep2Screen(initialData: data);
      },
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/herd', builder: (context, state) => const HerdScreen()),

    // сначала add
    GoRoute(
      path: '/herd/add',
      builder: (context, state) => const HerdAddAnimalScreen(),
    ),
    GoRoute(
      path: '/herd/add/details',
      builder: (context, state) {
        final draft = state.extra as CattleCreateData;
        return HerdAddAnimalDetailsScreen(draft: draft);
      },
    ),

    // потом edit
    GoRoute(
      path: '/herd/edit',
      builder: (context, state) {
        final cattle = state.extra as Cattle;
        return HerdEditAnimalScreen(cattle: cattle);
      },
    ),
    GoRoute(
      path: '/herd/edit/details',
      builder: (context, state) {
        final draft = state.extra as CattleEditData;
        return HerdEditAnimalDetailsScreen(draft: draft);
      },
    ),

    // и только в самом конце - динамический :id
    GoRoute(
      path: '/herd/:id',
      builder: (context, state) {
        final idStr = state.pathParameters['id'];
        if (idStr == null) {
          throw Exception('Route /herd/:id без параметра id');
        }

        final id = int.parse(idStr); // тут уже точно число
        return HerdAnimalScreen(id: id);
      },
    ),
  ],
);
