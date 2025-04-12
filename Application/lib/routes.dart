import 'package:flutter/material.dart';

import 'presentation/screens/blog/blog_explorer.dart';

import 'presentation/screens/search/club_search.dart';

import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/home_screen.dart';

import 'presentation/screens/club/club_detail_screen.dart';
import 'presentation/screens/club/club_form_screen.dart';
import 'presentation/screens/member/member_list_screen.dart';
import 'presentation/screens/member/member_detail_screen.dart';
import 'presentation/screens/member/member_form_screen.dart';
import 'presentation/screens/event/event_explorer_screen.dart';
import 'presentation/screens/event/event_detail_screen.dart';

import 'presentation/screens/profile/join_request.dart';
import 'presentation/screens/profile/HistoryEvent.dart';
import 'presentation/screens/profile/JoinClb.dart';
import 'presentation/screens/profile/profile.dart';
import 'presentation/screens/auth/forgot_password_screen.dart';
import 'presentation/screens/Notification/Notification.dart';
import 'presentation/screens/blog/blog_detail_screen.dart';
import 'presentation/screens/main_screen.dart';

class AppRoutes {
  // Tên các route
  static const String joinRequest = '/join-request';
  static const String historyEvent = '/history-event';
  static const String joinClb = '/join-clb';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String clubSearch = '/club-search';
  static const String clubDetail = '/club-detail';
  static const String clubForm = '/club-form';
  static const String memberList = '/member-list';
  static const String memberDetail = '/member-detail';
  static const String memberForm = '/member-form';
  static const String eventList = '/event-list';
  static const String eventDetail = '/event-detail';
  static const String eventForm = '/event-form';
  static const String eventManager = '/event-manager';
  static const String clubManager = '/club-manager';
  static const String blogManager = '/blog-manager';
  static const String memberManager = '/member-manager';
  static const String homeManager = '/home-manager';
  static const String information = '/infomation';
  static const String profile = '/profile';

  static const String resetmail = '/reset-mail';
  static const String blog = '/blog';

  static const String notification = '/notification';
  static const String main = '/main';
  // Hàm để tạo các route
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case joinRequest:
        return MaterialPageRoute(builder: (_) => JoinRequestListScreen());
      case historyEvent:
        return MaterialPageRoute(builder: (_) => JoinedEventsScreen());
      case joinClb:
        return MaterialPageRoute(builder: (_) => JoinedClubsScreen());
      case notification:
        return MaterialPageRoute(builder: (_) => NotificationScreen());

      case resetmail:
        return MaterialPageRoute(builder: (_) => PasswordRecoveryScreen());
      case blog:
        return MaterialPageRoute(builder: (_) => BlogExplorer());
      case profile:
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());

      case clubSearch:
        return MaterialPageRoute(builder: (_) => ClubSearch());

      case clubDetail:
        final clubId = settings.arguments as String;
        return MaterialPageRoute(
            builder: (_) => ClubDetailScreen(clubId: clubId));
      case clubForm:
        return MaterialPageRoute(builder: (_) => ClubFormScreen());
      case memberList:
        return MaterialPageRoute(builder: (_) => MemberListScreen());
      case memberDetail:
        final memberId = settings.arguments as String;
        return MaterialPageRoute(
            builder: (_) => MemberDetailScreen(memberId: memberId));
      case memberForm:
        return MaterialPageRoute(builder: (_) => MemberFormScreen());
      case eventList:
        return MaterialPageRoute(builder: (_) => EventExplorerScreen());
      case eventDetail:
        final eventId = settings.arguments as String;
        return MaterialPageRoute(
            builder: (_) => EventDetailScreen(eventId: eventId));
      case '/blog_explorer':
        return MaterialPageRoute(builder: (_) => BlogExplorer());
      case '/blog/:id':
        final args = settings.arguments;
        if (args is String) {
          return MaterialPageRoute(
              builder: (_) => BlogDetailScreen(blogId: args));
        }
        return MaterialPageRoute(builder: (_) => BlogExplorer());
      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const MainScreen(),
        );
    }
  }
}
