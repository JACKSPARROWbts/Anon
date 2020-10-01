import 'dart:io';
import 'dart:math';
import 'package:Anon/Chat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_apns/apns.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    hide Message;
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
 //keytool -genkey -v -keystore c:\key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
var random = new Random();
var random1 = new Random();
String name = "";
var values = random.nextInt(100);
var arrays = ['men', 'women'];
var values1 = random1.nextInt(2);
var images = arrays[values1];
void showLocalNotification(Message message, ChannelModel channel) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final initializationSettingsAndroid =
      AndroidInitializationSettings('launch_background');
  final initializationSettingsIOS = IOSInitializationSettings();
  final initializationSettings = InitializationSettings(
    initializationSettingsAndroid,
    initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await flutterLocalNotificationsPlugin.show(
    message.id.hashCode,
    '${message.user.name} @ ${channel.name}',
    message.text,
    NotificationDetails(
      AndroidNotificationDetails(
        'message channel',
        'Message channel',
        'Channel used for showing messages',
        priority: Priority.High,
        importance: Importance.High,
      ),
      IOSNotificationDetails(),
    ),
  );
}

Future backgroundHandler(Map<String, dynamic> notification) async {
  final messageId = notification['data']['message_id'];

  final notificationData =
      await NotificationService.getAndStoreMessage(messageId);

  showLocalNotification(
    notificationData.message,
    notificationData.channel,
  );
}

void _initNotifications(Client client) {
  final connector = createPushConnector();
  connector.configure(
    onBackgroundMessage: backgroundHandler,
  );

  connector.requestNotificationPermissions();
  connector.token.addListener(() {
    if (connector.token.value != null) {
      client.addDevice(
        connector.token.value,
        Platform.isAndroid ? 'apn' : 'firebase',
      );
    }
  });
}

void main() async {
  final client = Client(
    's2dxdhpxd94g',
    logLevel: Level.INFO,
    showLocalNotification: Platform.isAndroid ? showLocalNotification : null,
    persistenceEnabled: true,
  );

  await client.setUser(
    User(id: 'loviedovie', extraData: {
      'name': '$name',
      'image': 'https://randomuser.me/api/portraits/$images/$values.jpg'
    }),
    'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoic3VwZXItYmFuZC05In0.0L6lGoeLwkz0aZRUcpZKsvaXtNEDHBcezVTZ0oPq40A',
  );

  _initNotifications(client);

  runApp(MyApp(client));
}

class MyApp extends StatelessWidget {
  final Client client;

  MyApp(this.client);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      builder: (context, widget) {
        return StreamChat(
          child: widget,
          client: client,
        );
      },
      home: FrontPage(),
    );
  }
}

class FrontPage extends StatefulWidget {
  @override
  _FrontPageState createState() => _FrontPageState();
}

class _FrontPageState extends State<FrontPage> {
  final key = GlobalKey<FormState>();
  var textvalue = "";
  TextEditingController controller = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
              child: Container(
          // decoration: BoxDecoration(
          //   color: Colors.red[400]
          // ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0, left: 30, right: 30),
              child: Form(
                  key: key,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 50, right: 50),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage(
                            'lib/images/batman.jpeg',
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 70,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: "your name "),
                        validator: (value) {
                          setState(() {
                            textvalue = value;
                          });
                          if (value.isEmpty) {
                            return "Enter Your Name";
                          }
                        },
                        controller: controller,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                          padding: EdgeInsets.all(20),
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ChannelListPage()));
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(80.0)),
                            padding: const EdgeInsets.all(0.0),
                            child: Ink(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                    colors: [Colors.blue, Colors.red]),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(0.0)),
                              ),
                              child: Container(
                                constraints: const BoxConstraints(
                                    minWidth: 88.0,
                                    minHeight:
                                        36.0), // min sizes for Material buttons
                                alignment: Alignment.center,
                                child: const Text(
                                  'OK',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ))
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }
}

class ChannelListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "CHAT ANON",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
               
              icon: Icon(Icons.videocam,
              ),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => VideoChat()));
              })
        ],
      ),
      body: ChannelsBloc(
        child: ChannelListView(
          filter: {
            'members': {
              '\$in': [StreamChat.of(context).user.id],
            }
          },
          sort: [SortOption('last_message_at')],
          pagination: PaginationParams(
            limit: 20,
          ),
          channelWidget: ChannelPage(),
        ),
      ),
    );
  }
}

class ChannelPage extends StatelessWidget {
  const ChannelPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChannelHeader(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                MessageListView(
                  threadBuilder: (_, parentMessage) {
                    return ThreadPage(
                      parent: parentMessage,
                    );
                  },
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4,
                    ),
                    child: TypingIndicator(
                      alignment: Alignment.bottomRight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          MessageInput(),
        ],
      ),
    );
  }
}

class ThreadPage extends StatelessWidget {
  final Message parent;

  ThreadPage({
    Key key,
    this.parent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThreadHeader(
        parent: parent,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: MessageListView(
              parentMessage: parent,
            ),
          ),
          if (parent.type != 'deleted')
            MessageInput(
              parentMessage: parent,
            ),
        ],
      ),
    );
  }
}

// import 'dart:io';
// import 'dart:math';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_apns/apns.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart'
//     hide Message;
// import 'package:stream_chat_flutter/stream_chat_flutter.dart';

// var random = new Random();
// var random1 = new Random();
// var values = random.nextInt(22);
// var arrays = ['men', 'women'];
// var values1 = random1.nextInt(2);
// var images = arrays[values1];
// var name = [
//   'LovieDovie',
//   'Harsha',
//   'Spartan',
//   'Livle-glitter',
//   'Cap Sparrw',
//   'Soul Mortal',
//   'Death Stealer',
//   'Heart Stealer',
//   'Comedian',
//   'Trity-squad',
//   'Amen-Man',
//   'Lover-ducky','Spider-Man','kiddo','Mr-Robot','Lovely-Hero',
//   'Remo-star','He-Man','Get-World','One-Punch-Man','World-Famous-Lover',
//   'Good-One'
// ];
// var namevalues = name[values];
// void main() async {
//   final client = Client(
//     '9yydd5sxr8t8',
//     logLevel: Level.INFO,
//     showLocalNotification: Platform.isAndroid ? showLocalNotification : null,
//     persistenceEnabled: true,
//   );
//   await client.setUser(
//       User(id: 'lively-glitter-5', extraData: {
//         'name': '$namevalues',
//         'image': 'https://randomuser.me/api/portraits/$images/$values.jpg'
//       }),
//       'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoibGl2ZWx5LWdsaXR0ZXItNSJ9.EQgZ34HP8bOZPqAnNLmxXM9CeWukHeoiOUm2Et0BBZ0');

//   _initNotifications(client);

//   runApp(MyApp(client));
// }

// class MyApp extends StatelessWidget {
//   final Client client;
//   MyApp(this.client);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.light(),
//       darkTheme: ThemeData.dark(),
//       themeMode: ThemeMode.system,
//       builder: (context, widget) {
//         return StreamChat(
//           child: widget,
//           client: client,
//         );
//       },
//       home: ChannelListPage(),
//     );
//   }
// }

// class ChannelListPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ChannelsBloc(
//         child: ChannelListView(
//           filter: {
//             'members': {
//               '\$in': [StreamChat.of(context).user.id],
//             }
//           },
//           sort: [SortOption('last_message_at')],
//           pagination: PaginationParams(
//             limit: 20,
//           ),
//           channelWidget: ChannelPage(),
//         ),
//       ),
//     );
//   }
// }

// class ChannelPage extends StatelessWidget {
//   const ChannelPage({
//     Key key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: ChannelHeader(),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: Stack(
//               children: <Widget>[
//                 MessageListView(
//                   threadBuilder: (_, parentMessage) {
//                     return ThreadPage(
//                       parent: parentMessage,
//                     );
//                   },
//                 ),
//                 Positioned.fill(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8.0,
//                       vertical: 4,
//                     ),
//                     child: TypingIndicator(
//                       alignment: Alignment.bottomRight,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           MessageInput(),
//         ],
//       ),
//     );
//   }
// }

// class ThreadPage extends StatelessWidget {
//   final Message parent;

//   ThreadPage({
//     Key key,
//     this.parent,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: ThreadHeader(
//         parent: parent,
//       ),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: MessageListView(
//               parentMessage: parent,
//             ),
//           ),
//           if (parent.type != 'deleted')
//             MessageInput(
//               parentMessage: parent,
//             ),
//         ],
//       ),
//     );
//   }
// }

// void showLocalNotification(Message message, ChannelModel channel) async {
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   final initializationSettingsAndroid =
//       AndroidInitializationSettings('launch_background');
//   final initializationSettingsIOS = IOSInitializationSettings();
//   final initializationSettings = InitializationSettings(
//     initializationSettingsAndroid,
//     initializationSettingsIOS,
//   );
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   await flutterLocalNotificationsPlugin.show(
//     message.id.hashCode,
//     '${message.user.name} @ ${channel.name}',
//     message.text,
//     NotificationDetails(
//       AndroidNotificationDetails(
//         'message channel',
//         'Message channel',
//         'Channel used for showing messages',
//         priority: Priority.High,
//         importance: Importance.High,
//       ),
//       IOSNotificationDetails(),
//     ),
//   );
// }

// Future backgroundHandler(Map<String, dynamic> notification) async {
//   final messageId = notification['data']['message_id'];

//   final notificationData =
//       await NotificationService.getAndStoreMessage(messageId);

//   showLocalNotification(
//     notificationData.message,
//     notificationData.channel,
//   );
// }

// void _initNotifications(Client client) {
//   final connector = createPushConnector();
//   connector.configure(
//     onBackgroundMessage: backgroundHandler,
//   );

//   connector.requestNotificationPermissions();
//   connector.token.addListener(() {
//     if (connector.token.value != null) {
//       client.addDevice(
//         connector.token.value,
//         Platform.isAndroid ? 'apn' : 'firebase',
//       );
//     }
//   });
// }
// import 'package:flutter/material.dart';

// void main() {
//   runApp(Anon());
// }

// class Anon extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key, this.title}) : super(key: key);
//   final String title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(new Duration(seconds: 4), () {
//       Navigator.push(context, MaterialPageRoute(builder: (context) => main()));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Container(
//           child: CircularProgressIndicator(),
//         ),
//       ),
//     );
//   }
// }
