import 'package:flutter/material.dart';
import 'package:foods/components/drawer.dart';
import 'package:foods/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foods/models/measurement.dart';

class ManageMeasurementUnits extends StatefulWidget {
  const ManageMeasurementUnits({super.key});

  @override
  State<ManageMeasurementUnits> createState() => _ManageMeasurementUnitsState();
}

class _ManageMeasurementUnitsState extends State<ManageMeasurementUnits> {
  bool isEditing = false;
  int editIndex = -1;
  List<Measurement> _measurements = [];
  String name = '';

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    var measurements = await ingredientService.getAllMeasurements();
    setState(() {
      _measurements = measurements;
    });
  }

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        handlePop(didPop, context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(localization!.manageMeasurements),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          actions: [
            isEditing
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        isEditing = false;
                        editIndex = -1;
                        name = '';
                      });
                    },
                    icon: const Icon(Icons.done_all))
                : const Text(""),
          ],
        ),
        drawer: FoodDrawer(screenIndex: getScreenIndex("ManageMeasurements")),
        drawerEdgeDragWidth: MediaQuery.of(context).size.width,
        body: Center(
          child: _measurements.isNotEmpty
              ? ListView.builder(
                  itemCount: _measurements.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.5, horizontal: 12),
                      child: Card.filled(
                        clipBehavior: Clip.hardEdge,
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: InkWell(
                          onLongPress: () {
                            setState(() {
                              name = _measurements[index].name;
                              editIndex = index;
                              isEditing = true;
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: editIndex == index ? 4 : 12),
                            child: ListTile(
                              title: isEditing && index == editIndex
                                  ? TextFormField(
                                      initialValue: _measurements[index].name,
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        labelText: localization.unit,
                                        hintText: localization.unit,
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          name = value;
                                        });
                                      },
                                    )
                                  : Text(_measurements[index].name),
                              trailing: isEditing && editIndex == index
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () async {
                                            if (name == "") {
                                              return;
                                            } else {
                                              await ingredientService
                                                  .editMeasurement(
                                                _measurements[index].key,
                                                Measurement(name: name),
                                              );
                                              setState(() {
                                                editIndex = -1;
                                                name = '';
                                              });
                                              _fetch();
                                            }
                                          },
                                          icon: const Icon(Icons.check),
                                        ),
                                        IconButton(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                          icon: const Icon(Icons.delete),
                                          onPressed: () async {
                                            await ingredientService
                                                .deleteMeasurement(
                                              _measurements[index].key,
                                            );
                                            setState(() {
                                              editIndex = -1;
                                            });
                                            _fetch();
                                          },
                                        ),
                                      ],
                                    )
                                  : (isEditing)
                                      ? IconButton(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                          icon: const Icon(Icons.delete),
                                          onPressed: () async {
                                            await ingredientService
                                                .deleteMeasurement(
                                              _measurements[index].key,
                                            );
                                            setState(() {
                                              editIndex = -1;
                                            });
                                            _fetch();
                                          },
                                        )
                                      : const Text(''),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                )
              : const CircularProgressIndicator(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await ingredientService.addMeasurement(Measurement(name: "unit"));
            await _fetch();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
