import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'config/supabase_config.dart';
import 'core/services/supabase_service.dart';
import 'screens/auth_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tierlab',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF121212),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E2E2E),
          foregroundColor: Colors.white,
        ),
      ),
      home: const MyHomePage(title: 'Tierlab'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final List<Map<String, String>> games = [

    {
      'name': 'Sonic Mania',
      'description': 'Aventura clássica em alta velocidade.',
      'image':
        'https://cdn1.epicgames.com/45e7cf3c49054f2fb20b673d9b0ae69e/offer/EGS_SonicMania_Lab42_S5-1360x765-31b5379f91e2451e57e0273339bf68b8.jpg',
    },

    {
      'name': 'Resident Evil 4',
      'description': 'Survival horror com ação intensa.',
      'image':
        'https://store-images.s-microsoft.com/image/apps.17229.14157056169306105.30ae0432-c36b-42e7-9bbb-f85189243ca3.c5486ade-9a07-47ba-a2c5-4e717b3f183a?q=90&w=336&h=200',
    },

    {
      'name': 'Hades',
      'description': 'Roguelike frenético inspirado na mitologia.',
      'image':
        'https://lojaibyte.vteximg.com.br/arquivos/ids/405817/jogo-hades-ps4.jpg',
    },

  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(
              SupabaseService().isAuthenticated ? Icons.logout : Icons.login,
            ),
            onPressed: () async {
              if (SupabaseService().isAuthenticated) {
                await SupabaseService().signOut();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuário desconectado.')),
                  );
                  setState(() {});
                }
                return;
              }

              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AuthScreen(),
                ),
              );
              if (context.mounted) {
                setState(() {});
              }
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.only(top: 30),

        child: Column(
          children: [

            CarouselSlider(

              options: CarouselOptions(
                height: 240,
                enlargeCenterPage: true,
                autoPlay: true,
                viewportFraction: 0.8,
              ),

              items: games.map<Widget>((Map<String, String> game) {

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),

                        child: AspectRatio(
                          aspectRatio: 18 / 9,

                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),

                            child: Stack(
                              children: [

                                Image.network(
                                  game['image']!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),

                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,

                                      colors: [
                                        Colors.transparent,
                                          const Color.fromRGBO(0, 0, 0, 0.7),
                                      ],
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),

                      child: Text(
                        game['name']!,

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),

                      child: Text(
                        game['description']!,

                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 11,
                        ),
                      ),
                    ),

                  ],
                );

              }).toList(),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Align(
                alignment: Alignment.centerLeft,

                child: Text(
                  'Ação',

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            if (!SupabaseService().isAuthenticated) ...[
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final loggedIn = await Navigator.of(context).push<bool?>(
                        MaterialPageRoute(
                          builder: (_) => const AuthScreen(),
                        ),
                      );
                      if (context.mounted) {
                        if (loggedIn == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Autenticação concluída.'),
                            ),
                          );
                        }
                        setState(() {});
                      }
                    },
                    child: const Text('Fazer login / registrar'),
                  ),
                ),
              ),
            ],

          ],
        ),
      ),
    );
  }
}
