import 'package:aps_chat/models/details_page.dart';
import 'package:aps_chat/utils/get_images/get_images.dart';
import 'package:aps_chat/utils/pages_configs/pages_configs.dart';
import 'package:aps_chat/widgets/opacity_request/opacity_request.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatefulWidget {
  CustomDrawer({
    this.pages,
    this.hasLogoutButton = false,
  });

  final List<DetailsPage> pages;
  final bool hasLogoutButton;
  
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
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  var _isLoadingLogout = false;

  @override 
  Widget build(BuildContext context) {
    final pagesItems = PagesConfigs.detailsPage;

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
                      selected: CustomDrawer._selectedIndex == index,
                      leading: pagesItems[index].leading ?? Icon(
                        pagesItems[index].leadingData,
                      ),
                      title: pagesItems[index].title ?? Text(
                        pagesItems[index].name,
                        style: TextStyle(
                        ),
                      ),
                      onTap: () {
                        CustomDrawer.changePage(pagesItems[index].goToNamedRoute);
                        Navigator.of(context).pushReplacementNamed(
                          pagesItems[index].goToNamedRoute,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            if (widget.hasLogoutButton ?? false)
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _isLoadingLogout = true;
                        });
                        // Navigator.of(context).pushReplacementNamed(
                        //   Routes.homePage,
                        //   arguments: TransitionsPage(
                        //     builder: (ctx) => HomePage(false),
                        //   )
                        // );
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