// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_webview_pro/webview_flutter.dart';
// import 'package:webview_flutter/webview_flutter.dart';


// class AdminWebview extends StatefulWidget {
//   final String url;
//   const AdminWebview({Key? key, required this.url}) : super(key: key);


//   @override
//   _AdminWebviewState createState() => _AdminWebviewState();
// }


// class _AdminWebviewState extends State<AdminWebview> {
//   final Completer<WebViewController> _controller =
//       Completer<WebViewController>();
//   bool isLoading = false;


//   @override
//   void initState() {
//     super.initState();
//     if (Platform.isAndroid) {
//       WebView.platform = SurfaceAndroidWebView();
//     }
//   }


//   Future<bool> _onWillPop() async {
//     final WebViewController controller = await _controller.future;
//     if (await controller.canGoBack()) {
//       await controller.goBack();
//       return false;
//     } else {
//       return await showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text('Are you sure?'),
//               content: const Text(
//                   'Do you want to leave this page and go back to the Login page?'),
//               actions: <Widget>[
//                 TextButton(
//                   child: const Text('No'),
//                   onPressed: () => Navigator.of(context).pop(false),
//                 ),
//                 TextButton(
//                   child: const Text('Yes'),
//                   onPressed: () {
//                     Navigator.of(context).pop(true);
//                   },
//                 ),
//               ],
//             ),
//           ) ??
//           false;
//     }
//   }


//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Administration'),
//           actions: <Widget>[
//             NavigationControls(_controller.future),
//           ],
//         ),
//         body: Stack(
//           children: [
//             WebView(
//               initialUrl: widget.url,
//               javascriptMode: JavascriptMode.unrestricted,
//               onWebViewCreated: (WebViewController webViewController) {
//                 _controller.complete(webViewController);
//               },
//               onPageStarted: (String url) {
//                 setState(() {
//                   isLoading = true;
//                 });
//               },
//               onPageFinished: (String url) {
//                 setState(() {
//                   isLoading = false;
//                 });
//               },
//               gestureNavigationEnabled: true,
//               zoomEnabled: true,
//               navigationDelegate: (NavigationRequest request) {
//                 if (request.url.endsWith(".pdf") ||
//                     request.url.endsWith(".doc") ||
//                     request.url.endsWith(".jpg") ||
//                     request.url.contains("download")) {
//                   _launchInBrowser(request.url);
//                   return NavigationDecision.prevent;
//                 }
//                 return NavigationDecision.navigate;
//               },
//             ),
//             if (isLoading)
//               const LinearProgressIndicator(
//                 backgroundColor: Colors.white,
//               ),
//           ],
//         ),
//       ),
//     );
//   }


//   Future<void> _launchInBrowser(String url) async {
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Could not launch $url')),
//       );
//     }
//   }
// }


// class NavigationControls extends StatelessWidget {
//   const NavigationControls(this._webViewControllerFuture, {Key? key})
//       : super(key: key);


//   final Future<WebViewController> _webViewControllerFuture;


//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<WebViewController>(
//       future: _webViewControllerFuture,
//       builder: (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
//         final bool webViewReady = snapshot.connectionState == ConnectionState.done;
//         final WebViewController? controller = snapshot.data;
//         return Row(
//           children: <Widget>[
//             IconButton(
//               icon: const Icon(Icons.arrow_back_ios),
//               onPressed: !webViewReady
//                   ? null
//                   : () async {
//                       if (await controller!.canGoBack()) {
//                         await controller.goBack();
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('No back history item')),
//                         );
//                       }
//                     },
//             ),
//             IconButton(
//               icon: const Icon(Icons.arrow_forward_ios),
//               onPressed: !webViewReady
//                   ? null
//                   : () async {
//                       if (await controller!.canGoForward()) {
//                         await controller.goForward();
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                               content: Text('No forward history item')),
//                         );
//                       }
//                     },
//             ),
//             IconButton(
//               icon: const Icon(Icons.replay),
//               onPressed: !webViewReady
//                   ? null
//                   : () {
//                       controller!.reload();
//                     },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }





