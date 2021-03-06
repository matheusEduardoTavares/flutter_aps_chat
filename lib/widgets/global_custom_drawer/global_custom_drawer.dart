import 'package:aps_chat/models/details_page.dart';
import 'package:aps_chat/utils/asset_images/asset_images.dart';
import 'package:aps_chat/utils/details_pages/details_pages.dart';
import 'package:aps_chat/widgets/opacity_request/opacity_request.dart';
import 'package:flutter/material.dart';

class GlobalCustomDrawer extends StatefulWidget {  
  static int _selectedIndex = 0;

  static void changePage(String newPage, [List<DetailsPage> pages]) {
    final filterInPages = DetailsPages.detailsPage;

    var index = filterInPages.
      indexWhere((page) => page.goToNamedRoute == newPage);

    if (index != -1) {
      _selectedIndex = index;
    }
  }

  @override
  _GlobalCustomDrawerState createState() => _GlobalCustomDrawerState();
}

class _GlobalCustomDrawerState extends State<GlobalCustomDrawer> {
  var _isLoadingLogout = false;

  @override 
  Widget build(BuildContext context) {
    final pagesItems = DetailsPages.detailsPage;

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
                      selected: GlobalCustomDrawer._selectedIndex == index,
                      leading: pagesItems[index].leading ?? Icon(
                        pagesItems[index].leadingData,
                      ),
                      title: pagesItems[index].title ?? Text(
                        pagesItems[index].name,
                        style: TextStyle(
                        ),
                      ),
                      onTap: () {
                        GlobalCustomDrawer.changePage(pagesItems[index].goToNamedRoute);
                        Navigator.of(context).pushReplacementNamed(
                          pagesItems[index].goToNamedRoute,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}