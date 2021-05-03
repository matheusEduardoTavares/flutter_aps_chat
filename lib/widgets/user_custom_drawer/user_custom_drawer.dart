import 'package:aps_chat/models/details_page.dart';
import 'package:aps_chat/utils/asset_images/asset_images.dart';
import 'package:aps_chat/utils/details_pages/details_pages.dart';
import 'package:aps_chat/widgets/opacity_request/opacity_request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserCustomDrawer extends StatefulWidget {
  static int _selectedIndex = 0;

  static void changePage(String newPage, [List<DetailsPage> pages]) {
    final filterInPages = DetailsPages.detailsLoggedPages;

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
    final pagesItems = DetailsPages.detailsLoggedPages;
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
                    AssetImages.chatImage,
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
                        size: 40.0,
                      ),
                      title: pagesItems[index].title ?? Text(
                        pagesItems[index].name,
                        style: TextStyle(
                        ),
                      ),
                      onTap: () {
                        UserCustomDrawer.changePage(pagesItems[index].goToNamedRoute);

                        if (pagesItems[index].isPushReplacement ?? true) {
                          Navigator.of(context).pushReplacementNamed(
                            pagesItems[index].goToNamedRoute,
                          );
                        }
                        else {
                          Navigator.of(context).pushNamed(
                            pagesItems[index].goToNamedRoute,
                            arguments: pagesItems[index].goToNamedRoute == DetailsPages.configsPage ?
                              {'isUseDrawer': false,} : null, 
                          ).then((_) {
                            UserCustomDrawer.changePage(DetailsPages.homePage);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Navigator.of(context).pop();
                            });
                          });
                        }
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
                  Container(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _isLoadingLogout = true;
                        });

                        await _auth.signOut();

                        setState(() {
                          _isLoadingLogout = false;
                        });

                        UserCustomDrawer.changePage(DetailsPages.homePage);

                        Navigator.of(context).pushReplacementNamed(
                          DetailsPages.authPage,
                        );
                      },
                      child: _isLoadingLogout ? Center(child: CircularProgressIndicator()) : const Text('Fazer Logout'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}