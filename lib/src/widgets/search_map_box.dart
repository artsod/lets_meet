import 'package:flutter/material.dart';
import '../api/api_client.dart';

class SearchMapBox extends StatefulWidget {
  final String enteredKeyword;
  final String selectedPlaceType;
  final Map<String,String> labels;

  const SearchMapBox({super.key, required this.enteredKeyword, required this.selectedPlaceType, required this.labels});

  @override
  _SearchMapBoxState createState() => _SearchMapBoxState();
}

class _SearchMapBoxState extends State<SearchMapBox> {
  List<dynamic> placeTypes=[];
  late String _selectedPlaceType = widget.selectedPlaceType;
  late String _enteredKeyword = widget.enteredKeyword;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getPlaceTypes();
    _controller.text = _enteredKeyword.isEmpty ? '' : _enteredKeyword;
    _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
  }

  Future<void> _getPlaceTypes() async {
    placeTypes = await ApiClient().getPlaceTypesForSearch();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8.0, left: 8.0, right: 8.0, bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            height: 50,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.labels['keyword']!, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 30),
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        controller: _controller,
                        onChanged: (value) {
                          _enteredKeyword = value;
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: widget.labels['enterKeyword']!,
                          border: const OutlineInputBorder(),
                        ),
                        style: const TextStyle(fontSize: 12),
                        textAlignVertical: TextAlignVertical.bottom,
                      ),
                    ),
                  ]),
            ),
          ),
          SizedBox(
            height: 50,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    widget.labels['placeType']!,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedPlaceType,
                        onChanged: (newValue) {
                          setState(() {
                            if (newValue != null) {
                              _selectedPlaceType = newValue;
                            }
                          });
                        },
                        items: placeTypes.map((placeType) {
                          final String placeTypeString = placeType.toString().replaceAll('[', '').replaceAll(']', '');
                          return DropdownMenuItem<String>(
                            value: placeTypeString,
                            child: Text(
                              placeTypeString,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: widget.labels['selectPlaceType']!,
                          hintStyle: const TextStyle(fontSize: 12),
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.all(8.0),
                        ),
                      )
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                    onPressed: () async {
                        Navigator.pop(context, [_enteredKeyword, _selectedPlaceType]);
                    },
                    child: Text(widget.labels['searchPlaces']!, style: const TextStyle(fontSize: 10))
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.grey)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(widget.labels['cancel']!, style: const TextStyle(fontSize: 10))
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ],
      ),
    );
  }
}