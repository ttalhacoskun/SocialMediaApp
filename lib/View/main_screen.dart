import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/View%20Model/main_screen_view_model.dart';

class MainScreen extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String userId;
  final String userProfileUrl;

  MainScreen({
    required this.firstName,
    required this.lastName,
    required this.userId,
    required this.userProfileUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MainViewModel(
        firstName: firstName,
        lastName: lastName,
        userId: userId,
        userProfileUrl: userProfileUrl,
      ),
      child: Consumer<MainViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: IndexedStack(
              index: viewModel.selectedIndex,
              children: viewModel.pages,
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: FloatingActionButton(
              onPressed: () => viewModel.navigateToCreatePostScreen(context),
              child: Icon(Icons.add),
              backgroundColor: Color.fromARGB(255, 65, 152, 223),
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Ana Sayfa',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: 'Gönderi Ekle',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
              currentIndex: viewModel.selectedIndex,
              onTap: (index) => viewModel.onItemTapped(index, context),
            ),
          );
        },
      ),
    );
  }
}
