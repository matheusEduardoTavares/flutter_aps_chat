import 'package:aps_chat/models/details_page.dart';
import 'package:aps_chat/utils/get_images/get_images.dart';
import 'package:aps_chat/utils/pages_configs/pages_configs.dart';
import 'package:aps_chat/widgets/opacity_request/opacity_request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserCustomDrawer extends StatefulWidget {
  static int _selectedIndex = 0;

  static void changePage(String newPage, [List<DetailsPage> pages]) {
    final filterInPages = PagesConfigs.detailsPage;

    var index = filterInPages.
      indexWhere((page) => page.goToNamedRoute == newPage);

    if (index != -1) {
      _selectedIndex = index;
    }
  }

  @override
  _UserCustomDrawerState createState() => _UserCustomDrawerState();
}

class _UserCustomDrawerState extends State<UserCustomDrawer> {
  var _isLoadingLogout = false;

  @override 
  Widget build(BuildContext context) {
    final pagesItems = PagesConfigs.detailsLoggedPages;
    final _auth = FirebaseAuth.instance;

    return OpacityRequest(
      isLoading: _isLoadingLogout,
      child: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              child: Column(
                children: [
                  Text(
                    'APS chat',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    GetImages.chatImage,
                    height: 94,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: pagesItems.length,
                  itemBuilder: (ctx, index) => Card(
                    elevation: 5.0,
                    shadowColor: Colors.grey,
                    child: ListTile(
                      selected: UserCustomDrawer._selectedIndex == index,
                      leading: pagesItems[index].leading ?? Icon(
                        pagesItems[index].leadingData,
                      ),
                      title: pagesItems[index].title ?? Text(
                        pagesItems[index].name,
                        style: TextStyle(
                        ),
                      ),
                      onTap: () {
                        UserCustomDrawer.changePage(pagesItems[index].goToNamedRoute);
                        Navigator.of(context).pushReplacementNamed(
                          pagesItems[index].goToNamedRoute,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isLoadingLogout = true;
                      });
                      await _auth.signOut();
                    },
                    child: Text('Fazer Logout'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}