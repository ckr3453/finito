import 'package:home_widget/home_widget.dart';

void handleWidgetDeepLink({required void Function(Uri) onUri}) {
  HomeWidget.initiallyLaunchedFromHomeWidget().then((uri) {
    if (uri != null) onUri(uri);
  });

  HomeWidget.widgetClicked.listen((uri) {
    if (uri != null) onUri(uri);
  });
}
