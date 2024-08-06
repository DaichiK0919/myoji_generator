import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:japanese_family_name_generator/japanese_family_name_generator.dart';

// mainでMyAppを呼び出している
void main() {
  runApp(MyApp());
}

// StatelessWidgetを継承したMyAll
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // StatelessWidgetをオーバライド　詳細を記述している
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        // タイトル
        title: 'Namer App',
        // テーマ
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        // ホームとなるウィジェットを配置
        home: MyHomePage(),
      ),
    );
  }
}

// アプリの状態を管理
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var myoji = generateKanjiCombinedFamilyNameText();
  void getNext() {
    current = WordPair.random();
    myoji = generateKanjiCombinedFamilyNameText();
    notifyListeners();
  }

  // <WordPair>を入れられる配列を作成
  var favorites = <WordPair>[];
  var okini = [];

  void toggleFavorite() {
    if (okini.contains(myoji)) {
      okini.remove(myoji);
    } else {
      okini.add(myoji);
    }
    notifyListeners();
  }
}

// StatefulWidgetとは、Widget自体で状態を管理できる
// 上記のMyAppStateは別で状態を管理していた
// 上記の方法でも状態を管理できるが、全ての状態を管理すると冗長になりすぎるので
// Widgetに関連した状態はそれ自身に管理を任せる方がよい
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    var myoji = appState.myoji;

    IconData icon;
    if (appState.okini.contains(myoji)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MyojiCard(myoji: myoji),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.okini.isEmpty) {
      return Center(
        child: Text('気に入った苗字はまだありません'),
      );
    }

    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text('あなたは'
                '${appState.okini.length}個の苗字をお気に入りしました:'),
          ),
          for (var myoji in appState.okini)
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text(myoji),
            ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asSnakeCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class MyojiCard extends StatelessWidget {
  const MyojiCard({
    super.key,
    required this.myoji,
  });

  final String myoji;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayLarge!.copyWith(
      color: theme.colorScheme.onSecondary,
    );

    return Card(
      color: theme.colorScheme.secondary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          myoji,
          style: style,
        ),
      ),
    );
  }
}
