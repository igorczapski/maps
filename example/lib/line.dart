// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import 'main.dart';
import 'page.dart';

class LinePage extends ExamplePage {
  LinePage() : super(const Icon(Icons.share), 'Line');

  @override
  Widget build(BuildContext context) {
    return const LineBody();
  }
}

class LineBody extends StatefulWidget {
  const LineBody();

  @override
  State<StatefulWidget> createState() => LineBodyState();
}

class LineBodyState extends State<LineBody> {
  LineBodyState();

  static final LatLng center = const LatLng(-33.86711, 151.1947171);

  MapboxMapController? controller;
  LineManager? lineManager;
  int lineId = 0;

  int _lineCount = 0;
  Line? _selectedLine;

  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  _onLineTapped(Line line) async {
    setState(() {
      _selectedLine = line;
    });
    await _updateSelectedLine(
      LineOptions(lineColor: "#ff0000"),
    );
  }

  Future<void> _updateSelectedLine(LineOptions changes) {
    _selectedLine = _selectedLine!
        .copyWith(options: _selectedLine!.options.copyWith(changes));
    return lineManager!.set(_selectedLine!);
  }

  void _add() {
    lineManager!.add(Line(
      lineId.toString(),
      LineOptions(
          geometry: [
            LatLng(-33.86711, 151.1947171),
            LatLng(-33.86711, 151.1947171),
            LatLng(-32.86711, 151.1947171),
            LatLng(-33.86711, 152.1947171),
          ],
          lineColor: "#ff0000",
          lineWidth: 30.0,
          lineOpacity: 0.5,
          draggable: true),
    ));

    setState(() {
      lineId++;
      _lineCount += 1;
    });
  }

  _move() async {
    final currentStart = _selectedLine!.options.geometry![0];
    final currentEnd = _selectedLine!.options.geometry![1];
    final end =
        LatLng(currentEnd.latitude + 0.001, currentEnd.longitude + 0.001);
    final start =
        LatLng(currentStart.latitude - 0.001, currentStart.longitude - 0.001);
    await controller!
        .updateLine(_selectedLine!, LineOptions(geometry: [start, end]));
  }

  void _remove() {
    lineManager!.remove(_selectedLine!);
    setState(() {
      _selectedLine = null;
      _lineCount -= 1;
    });
  }

  Future<void> _changeAlpha() async {
    double? current = _selectedLine!.options.lineOpacity;
    if (current == null) {
      // default value
      current = 1.0;
    }

    await _updateSelectedLine(
      LineOptions(lineOpacity: current < 0.1 ? 1.0 : current * 0.75),
    );
  }

  Future<void> _toggleVisible() async {
    double? current = _selectedLine!.options.lineOpacity;
    if (current == null) {
      // default value
      current = 1.0;
    }
    await _updateSelectedLine(
      LineOptions(lineOpacity: current == 0.0 ? 1.0 : 0.0),
    );
  }

  void onStyleLoadedCallback() {
    lineManager = LineManager(controller!, onTap: _onLineTapped);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: SizedBox(
            height: 400.0,
            child: MapboxMap(
              accessToken: MapsDemo.ACCESS_TOKEN,
              onMapCreated: _onMapCreated,
              onStyleLoadedCallback: onStyleLoadedCallback,
              initialCameraPosition: const CameraPosition(
                target: LatLng(-33.852, 151.211),
                zoom: 11.0,
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        TextButton(
                          child: const Text('add'),
                          onPressed: (_lineCount == 12) ? null : _add,
                        ),
                        TextButton(
                          child: const Text('remove'),
                          onPressed: (_selectedLine == null) ? null : _remove,
                        ),
                        TextButton(
                          child: const Text('move'),
                          onPressed: (_selectedLine == null)
                              ? null
                              : () async {
                                  await _move();
                                },
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        TextButton(
                          child: const Text('change alpha'),
                          onPressed:
                              (_selectedLine == null) ? null : _changeAlpha,
                        ),
                        TextButton(
                          child: const Text('toggle visible'),
                          onPressed:
                              (_selectedLine == null) ? null : _toggleVisible,
                        ),
                        TextButton(
                          child: const Text('print current LatLng'),
                          onPressed: (_selectedLine == null)
                              ? null
                              : () async {
                                  var current =
                                      lineManager!.byId(_selectedLine!.id)!;
                                  for (var latLng
                                      in current.options.geometry!) {
                                    print(latLng.toString());
                                  }
                                },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
