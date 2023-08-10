import 'package:flutter/material.dart';
import 'package:lets_meet/src/model/place.dart';

class FavouritesList extends StatefulWidget {
  final List<CachableGooglePlace> favouritesList;
  final Function(CachableGooglePlace) onTap;
  final Function() onRemove;


  const FavouritesList({super.key, required this.favouritesList, required this.onTap, required this.onRemove});

  @override
  _FavouritesListState createState() => _FavouritesListState();
}

class _FavouritesListState extends State<FavouritesList> {
  late List<CachableGooglePlace> favouritesList = widget.favouritesList;

  void removeFromFavourites(String placeID) {
    //##Tutaj powinna być logika usuwania miejsca z ulubionych w back-nedzie
    //_apiClient.removeFromFavourites();
    favouritesList.removeWhere((row) => row.googlePlaceID == placeID);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,

      children: <Widget>[
        if (favouritesList.isNotEmpty)
          ListView.builder(
              shrinkWrap: true,
              itemCount: favouritesList.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    widget.onTap(favouritesList[index]);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child:
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(
                                favouritesList[index].ownIconUrl),
                          ),
                          title: Text(favouritesList[index].ownName),
                        ),
                      ),
                      ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.grey)),
                          onPressed: () {
                            setState(() {
                              widget.onRemove();
                              removeFromFavourites(favouritesList[index].googlePlaceID);
                            });
                          },
                          child: const Text('Remove',
                              style: TextStyle(fontSize: 10))
                      ),
                      const SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                );
              }
          ),
        if (favouritesList.isEmpty)
          const Text(
              'You don\'t have any favourite places. Click on the map on a place and add it to favourites to show it here.',
              style: TextStyle(color: Colors.grey, height: 2),
              textAlign: TextAlign.center,
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 20),
            Expanded(
              child:
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                      'Back', style: TextStyle(fontSize: 10))
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ],
    );
  }
}
