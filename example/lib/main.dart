import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:new_version_plus/new_version_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String release = "";
  @override
  void initState() {
    super.initState();

    // Instantiate NewVersion manager object (Using GCP Console app as example)
    final newVersion = NewVersionPlus(
      iOSId: 'com.disney.disneyplus', androidId: 'com.disney.disneyplus',
      androidPlayStoreCountry: "es_ES", androidHtmlReleaseNotes: true, //support country code
    );
    //for basic status check
    basicStatusCheck(newVersion);

    //for advanced status check
    // Uncomment the following line to use advanced status check
    // advancedStatusCheck(newVersion);
  }

  basicStatusCheck(NewVersionPlus newVersion) async {
    final version = await newVersion.getVersionStatus();
    if (version != null) {
      release = version.releaseNotes ?? "";
      setState(() {});
    }
    newVersion.showAlertIfNecessary(
      context: context,
      launchModeVersion: LaunchModeVersion.external,
    );
  }

  advancedStatusCheck(NewVersionPlus newVersion) async {
    final status = await newVersion.getVersionStatus();
    if (status != null) {
      debugPrint(status.releaseNotes);
      debugPrint(status.appStoreLink);
      debugPrint(status.localVersion);
      debugPrint(status.storeVersion);
      debugPrint(status.canUpdate.toString());
      newVersion.showUpdateDialog(
        context: context,
        versionStatus: status,
        dialogTitle: 'Custom Title',
        dialogText: 'Custom Text',
        launchModeVersion: LaunchModeVersion.external,
        allowDismissal: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Example App"),
      ),
      body: SafeArea(
        child: Center(
          child: Html(data: release),
        ),
      ),
    );
  }
}
