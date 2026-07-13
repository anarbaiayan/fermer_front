import 'package:frontend/core/screens/not_found_screen.dart';
import 'package:frontend/features/auth/presentation/forgot_password_code_screen.dart';
import 'package:frontend/features/auth/presentation/forgot_password_new_password_screen.dart';
import 'package:frontend/features/auth/presentation/forgot_password_phone_screen.dart';
import 'package:frontend/features/auth/presentation/login_screen.dart';
import 'package:frontend/features/auth/presentation/restore_account_screen.dart';
import 'package:frontend/features/auth/presentation/widgets/register_flow_models.dart';
import 'package:frontend/features/auth/presentation/widgets/register_password_screen.dart';
import 'package:frontend/features/auth/presentation/register_screen.dart';
import 'package:frontend/features/cattle_events/presentation/pages/add_bulk_cattle_event_screen.dart';
import 'package:frontend/features/cattle_events/presentation/pages/add_cattle_event_screen.dart';
import 'package:frontend/features/cattle_events/presentation/pages/events_screen.dart';
import 'package:frontend/features/herd/domain/entities/cattle.dart';
import 'package:frontend/features/herd/domain/entities/cattle_edit_data.dart';
import 'package:frontend/features/herd/domain/entities/herd_filter.dart';
import 'package:frontend/features/herd/presentation/pages/herd_add_animal_details_screen.dart';
import 'package:frontend/features/herd/presentation/pages/herd_add_animal_screen.dart';
import 'package:frontend/features/herd/presentation/pages/herd_animal_screen.dart';
import 'package:frontend/features/herd/presentation/pages/herd_edit_animal_details_screen.dart';
import 'package:frontend/features/herd/presentation/pages/herd_edit_animal_screen.dart';
import 'package:frontend/features/lactation/presentation/pages/add_bulk_lactation_screen.dart';
import 'package:frontend/features/lactation/presentation/pages/add_lactation_screen.dart';
import 'package:frontend/features/lactation/presentation/pages/lactation_screen.dart';
import 'package:frontend/features/more/presentation/pages/more_screen.dart';
import 'package:frontend/features/notifications/presentation/pages/archived_notifications_screen.dart';
import 'package:frontend/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:frontend/features/pharmacy/data/models/drug_group_dto.dart';
import 'package:frontend/features/pharmacy/presentation/pages/drug_group_details_screen.dart';
import 'package:frontend/features/pharmacy/presentation/pages/pharmacy_requests_screen.dart';
import 'package:frontend/features/pharmacy/presentation/pages/pharmacy_screen.dart';
import 'package:frontend/features/profile/presentation/pages/profile_screen.dart';
import 'package:frontend/features/profile/presentation/pages/settings_screen.dart';
import 'package:frontend/features/profile/presentation/pages/support_screen.dart';
import 'package:frontend/features/rations/presentation/pages/add_user_rations_screen.dart';
import 'package:frontend/features/rations/presentation/pages/inventory_screen.dart';
import 'package:frontend/features/rations/presentation/pages/ration_template_details_screen.dart';
import 'package:frontend/features/rations/presentation/pages/rations_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/splash/presentation/splash_screen.dart';
import 'package:frontend/features/home/presentation/home_screen.dart';
import 'package:frontend/features/herd/presentation/pages/herd_screen.dart';

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
    GoRoute(path: '/more', builder: (context, state) => const MoreScreen()),
    GoRoute(
      path: '/herd',
      builder: (context, state) {
        final filter = state.extra as HerdFilterType?;
        return HerdScreen(filter: filter);
      },
    ),

    // сначала add
    GoRoute(
      path: '/herd/add',
      builder: (context, state) => const HerdAddAnimalScreen(),
    ),
    GoRoute(
      path: '/herd/add/details',
      builder: (context, state) {
        final cattleId = state.extra! as int;
        return HerdAddAnimalDetailsScreen(cattleId: cattleId);
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

    GoRoute(
      path: '/herd/:id/events/add',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return AddCattleEventScreen(cattleId: id);
      },
    ),

    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPhoneScreen(),
    ),
    GoRoute(
      path: '/forgot-password/code',
      builder: (context, state) {
        final phone = state.extra as String?; // можно null
        return ForgotPasswordCodeScreen(phoneNumber: phone);
      },
    ),
    GoRoute(
      path: '/forgot-password/new',
      builder: (context, state) {
        final extra = state.extra;

        if (extra is Map) {
          final phone = extra['phone'] as String?;
          final code = extra['code'] as String?;
          return ForgotPasswordNewPasswordScreen(
            phoneNumber: phone,
            code: code,
          );
        }

        // fallback если вдруг пришли без extra
        return const ForgotPasswordNewPasswordScreen();
      },
    ),
    GoRoute(
      path: '/restore-account',
      builder: (context, state) => const RestoreAccountScreen(),
    ),

    GoRoute(
      path: '/lactation',
      builder: (context, state) => const LactationScreen(),
    ),

    GoRoute(
      path: '/herd/:id/lactation/add',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final extra = state.extra;
        final tag = (extra is Map && extra['cattleTagNumber'] is String)
            ? extra['cattleTagNumber'] as String
            : '';
        return AddLactationScreen(cattleId: id, cattleTagNumber: tag);
      },
    ),

    GoRoute(
      path: '/lactation/bulk/add',
      builder: (context, state) => const AddBulkLactationScreen(),
    ),

    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/support',
      builder: (context, state) => const SupportScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/notifications/archived',
      builder: (context, state) => const ArchivedNotificationsScreen(),
    ),

    GoRoute(path: '/events', builder: (context, state) => const EventsScreen()),
    GoRoute(
      path: '/events/bulk/add',
      builder: (context, state) => const AddBulkCattleEventScreen(),
    ),
    GoRoute(
      path: '/rations',
      builder: (context, state) {
        final extra = state.extra;
        int? cattleId;

        if (extra is Map<String, dynamic>) {
          final v = extra['cattleId'];
          if (v is int) cattleId = v;
          if (v is String) cattleId = int.tryParse(v);
        }

        return RationsScreen(cattleId: cattleId);
      },
    ),
    GoRoute(
      path: '/rations/cattle/:cattleId',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['cattleId']!);
        return CattleRationDetailsScreen(cattleId: id);
      },
    ),
    GoRoute(
      path: '/rations/stocks/add',
      builder: (context, state) => const AddUserRationsScreen(),
    ),
    GoRoute(
      path: '/rations/stocks',
      builder: (context, state) => const UserRationsStocksScreen(),
    ),
    GoRoute(
      path: '/rations/stocks/:type',
      builder: (context, state) {
        final type = state.pathParameters['type'];
        return UserRationsStocksScreen(filterType: type);
      },
    ),

    GoRoute(
      path: '/pharmacy',
      builder: (context, state) => const PharmacyScreen(),
    ),
    GoRoute(
      path: '/pharmacy/requests',
      builder: (context, state) => const PharmacyRequestsScreen(),
    ),
    GoRoute(
      path: '/pharmacy/group',
      builder: (context, state) {
        final group = state.extra as DrugGroupDto;
        return DrugGroupDetailsScreen(group: group);
      },
    ),
  ],
);
