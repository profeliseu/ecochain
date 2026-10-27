import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const EcoChainApp());
}

class AdministradorCredenciais {
  static Future<String> obterSenha() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection('configuracoes')
          .doc('admin')
          .get();
      if (doc.exists && doc.data() != null && doc.data()!['senha'] != null) {
        return doc.data()!['senha'];
      }
    } catch (e) {
      // Usa a senha padrão se falhar
    }
    return '1234';
  }

  static Future<void> salvarSenha(String novaSenha) async {
    await FirebaseFirestore.instance
        .collection('configuracoes')
        .doc('admin')
        .set({'senha': novaSenha}, SetOptions(merge: true));
  }
}

class Familia {
  String idDoc;
  String nomeFamilia;
  String moradores;
  String estudantePadrinho;
  String turmaEstudante;
  String cidade;
  String login;
  String senha;
  double pontos;
  double co2Evitado;

  Familia({
    required this.idDoc,
    required this.nomeFamilia,
    required this.moradores,
    required this.estudantePadrinho,
    required this.turmaEstudante,
    required this.cidade,
    required this.login,
    required this.senha,
    this.pontos = 0.0,
    this.co2Evitado = 0.0,
  });
}

Familia? familiaLogada;

class EcoChainApp extends StatelessWidget {
  const EcoChainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoChain',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF4F9F4),
      ),
      home: const HomeScreen(),
      routes: {
        '/cadastro': (context) => const CadastroScreen(),
        '/login': (context) => const LoginScreen(),
        '/ranking': (context) => const RankingScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/admin-login': (context) => const AdminLoginScreen(),
        '/admin-panel': (context) => const AdminScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoChain 🌱', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        centerTitle: true,
        backgroundColor: Colors.green[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Acesso do Administrador',
            onPressed: () => Navigator.pushNamed(context, '/admin-login'),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[800]!, Colors.green[50]!],
            stops: const [0.0, 0.3],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(Icons.eco, size: 64, color: Colors.green[700]),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Bem-vindo ao EcoChain',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Conectando famílias por um futuro sustentável 🌍',
                  style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 15, 15, 15)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        _buildMenuButton(
                          context,
                          title: 'Cadastro da Família',
                          subtitle: 'Registre sua casa e participe',
                          icon: Icons.person_add_alt_1_rounded,
                          color: Colors.green[700]!,
                          route: '/cadastro',
                        ),
                        const SizedBox(height: 16),
                        _buildMenuButton(
                          context,
                          title: 'Login',
                          subtitle: 'Acesse suas ações e pegada',
                          icon: Icons.login_rounded,
                          color: Colors.green[800]!,
                          route: '/login',
                        ),
                        const SizedBox(height: 16),
                        _buildMenuButton(
                          context,
                          title: 'Ranking Geral',
                          subtitle: 'Veja a pontuação e CO2 evitado',
                          icon: Icons.leaderboard_rounded,
                          color: Colors.teal[700]!,
                          route: '/ranking',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[850],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[650]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({Key? key}) : super(key: key);

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeFamiliaController = TextEditingController();
  final TextEditingController _moradoresController = TextEditingController();
  final TextEditingController _estudanteController = TextEditingController();
  final TextEditingController _turmaController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro da Família'), backgroundColor: Colors.green[700]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _nomeFamiliaController, decoration: const InputDecoration(labelText: 'Nome da Família *'), validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              TextFormField(controller: _moradoresController, decoration: const InputDecoration(labelText: 'Quantidade de Moradores *'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              TextFormField(controller: _estudanteController, decoration: const InputDecoration(labelText: 'Estudante Padrinho *'), validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              TextFormField(controller: _turmaController, decoration: const InputDecoration(labelText: 'Turma do Estudante *'), validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              TextFormField(controller: _cidadeController, decoration: const InputDecoration(labelText: 'Cidade onde mora *'), validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              TextFormField(controller: _loginController, decoration: const InputDecoration(labelText: 'Login (Usuário) *'), validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              TextFormField(controller: _senhaController, decoration: const InputDecoration(labelText: 'Senha *'), obscureText: true, validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], padding: const EdgeInsets.all(14)),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    String nomeFam = _nomeFamiliaController.text.trim();
                    try {
                      await FirebaseFirestore.instance.collection('familias').doc(nomeFam).set({
                        'nomeFamilia': nomeFam,
                        'moradores': _moradoresController.text.trim(),
                        'estudantePadrinho': _estudanteController.text.trim(),
                        'turmaEstudante': _turmaController.text.trim(),
                        'cidade': _cidadeController.text.trim(),
                        'login': _loginController.text.trim(),
                        'senha': _senhaController.text.trim(),
                        'pontos': 0.0,
                        'co2Evitado': 0.0,
                      });

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Família cadastrada com sucesso na nuvem! Faça o login.')));
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao cadastrar: $e')));
                    }
                  }
                },
                child: const Text('Finalizar Cadastro', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  void _fazerLogin() async {
    String usuarioDigitado = _loginController.text.trim();
    String senhaDigitada = _senhaController.text.trim();

    try {
      var query = await FirebaseFirestore.instance
          .collection('familias')
          .where('login', isEqualTo: usuarioDigitado)
          .get();

      if (query.docs.isEmpty) {
        throw 'Família não encontrada';
      }

      var doc = query.docs.first;
      var famData = doc.data();
      String senhaCadastrada = famData['senha'] ?? '';

      if (senhaCadastrada == senhaDigitada) {
        familiaLogada = Familia(
          idDoc: doc.id,
          nomeFamilia: famData['nomeFamilia'] ?? '',
          moradores: famData['moradores'] ?? '',
          estudantePadrinho: famData['estudantePadrinho'] ?? '',
          turmaEstudante: famData['turmaEstudante'] ?? '',
          cidade: famData['cidade'] ?? '',
          login: famData['login'] ?? '',
          senha: famData['senha'] ?? '',
          pontos: (famData['pontos'] ?? 0.0).toDouble(),
          co2Evitado: (famData['co2Evitado'] ?? 0.0).toDouble(),
        );

        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        throw 'Senha incorreta';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login ou senha incorretos, ou família não cadastrada!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login EcoChain'), backgroundColor: Colors.green[700]),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _loginController, decoration: const InputDecoration(labelText: 'Login')),
            TextField(controller: _senhaController, decoration: const InputDecoration(labelText: 'Senha'), obscureText: true),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], minimumSize: const Size(double.infinity, 50)),
              onPressed: _fazerLogin,
              child: const Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _adminUserCont = TextEditingController();
  final TextEditingController _adminPassCont = TextEditingController();

  void _logarAdmin() async {
    String senhaSalva = await AdministradorCredenciais.obterSenha();
    String usuarioDigitado = _adminUserCont.text.trim();
    String senhaDigitada = _adminPassCont.text.trim();

    if (usuarioDigitado == 'admin' && senhaDigitada == senhaSalva) {
      Navigator.pushReplacementNamed(context, '/admin-panel');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Acesso negado! Credenciais de Administrador inválidas.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Administrador 🛡️'), backgroundColor: Colors.brown[700]),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Área Restrita ao Administrador',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(controller: _adminUserCont, decoration: const InputDecoration(labelText: 'Usuário Admin')),
            TextField(controller: _adminPassCont, decoration: const InputDecoration(labelText: 'Senha Admin'), obscureText: true),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.brown[700], minimumSize: const Size(double.infinity, 50)),
              onPressed: _logarAdmin,
              child: const Text('Entrar no Painel Admin'),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _tirarFotoEEnviar(String acaoNome, double pontos, double co2Conversao) async {
    if (familiaLogada == null) return;
    try {
      final XFile? foto = await _picker.pickImage(
        source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 30,
        maxWidth: 500,
        maxHeight: 500,
      );
      
      if (foto != null) {
        String dataHoraAtual = DateTime.now().toString().substring(0, 16);
        
        File arquivoFoto = File(foto.path);
        Uint8List imageBytes = await arquivoFoto.readAsBytes();
        String base64Image = base64Encode(imageBytes);

        await FirebaseFirestore.instance.collection('acoes_pendentes').add({
          'nomeFamilia': familiaLogada!.nomeFamilia,
          'titulo': acaoNome,
          'pontos': pontos,
          'co2Conversao': co2Conversao,
          'imageBase64': base64Image,
          'dataHora': dataHoraAtual,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto enviada com sucesso para o Administrador!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar foto: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String nomeFam = familiaLogada?.nomeFamilia ?? 'Família';
    double pontosFam = familiaLogada?.pontos ?? 0.0;
    double co2Fam = familiaLogada?.co2Evitado ?? 0.0;
    return Scaffold(
      appBar: AppBar(title: Text('Dicas Ecológicas - $nomeFam'), backgroundColor: Colors.green[700]),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text('Olá, $nomeFam! Registre suas ações:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildActionCard('Entrega de Tampinha', '0,5 pontos (0,2 kg CO2)', 0.5, 0.2, Icons.recycling),
          _buildActionCard('Uso de Lâmpada LED', '1 ponto (1,5 kg CO2)', 1.0, 1.5, Icons.lightbulb),
          _buildActionCard('Reciclagem Geral', '1 ponto (2,0 kg CO2)', 1.0, 2.0, Icons.autorenew),
          _buildActionCard('Transporte Sustentável', '2 pontos (3,5 kg CO2)', 2.0, 3.5, Icons.directions_bike),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[700], minimumSize: const Size(double.infinity, 50)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sua Pegada Ecológica & CO₂'),
                  content: Text('Família: $nomeFam\nPontuação Aprovada: $pontosFam pts\nRedução de CO₂: ${co2Fam.toStringAsFixed(1)} kg\n\n(Ações enviadas aguardam validação do admin).'),
                  actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar'))],
                ),
              );
            },
            icon: const Icon(Icons.analytics),
            label: const Text('Calcular Pegada Ecológica', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, double pontos, double co2Conversao, IconData icon) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.green[700], size: 36),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.camera_alt, color: Colors.green),
        onTap: () => _tirarFotoEEnviar(title, pontos, co2Conversao),
      ),
    );
  }
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  void _mostrarFotoInteira(BuildContext context, Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.memory(imageBytes),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _alterarSenhaAdmin(BuildContext context) {
    final TextEditingController novaSenhaAdminController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alterar Senha do Administrador'),
        content: TextField(
          controller: novaSenhaAdminController,
          decoration: const InputDecoration(labelText: 'Nova Senha do Admin'),
          obscureText: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown[700]),
            onPressed: () async {
              String novaSenha = novaSenhaAdminController.text.trim();
              if (novaSenha.isNotEmpty) {
                await AdministradorCredenciais.salvarSenha(novaSenha);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Senha do Administrador alterada e sincronizada!')),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  // Função para zerar o ranking de todas as famílias
  void _zerarRanking(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ Zerar Ranking Geral?'),
        content: const Text('Isso vai zerar os pontos e o CO₂ de TODAS as famílias cadastradas. Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                var querySnapshot = await FirebaseFirestore.instance.collection('familias').get();
                for (var doc in querySnapshot.docs) {
                  await doc.reference.update({
                    'pontos': 0.0,
                    'co2Evitado': 0.0,
                  });
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ranking zerado com sucesso!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao zerar ranking: $e')),
                );
              }
            },
            child: const Text('Zerar Tudo'),
          ),
        ],
      ),
    );
  }

  void _gerenciarFamilias(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gerenciar Famílias Cadastradas'),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('familias').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Nenhuma família cadastrada na nuvem.'));
              }
              final docs = snapshot.data!.docs;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var doc = docs[index];
                  var famData = doc.data() as Map<String, dynamic>;
                  String docId = doc.id;
                  
                  Familia famObj = Familia(
                    idDoc: docId,
                    nomeFamilia: famData['nomeFamilia'] ?? '',
                    moradores: famData['moradores'] ?? '',
                    estudantePadrinho: famData['estudantePadrinho'] ?? '',
                    turmaEstudante: famData['turmaEstudante'] ?? '',
                    cidade: famData['cidade'] ?? '',
                    login: famData['login'] ?? '',
                    senha: famData['senha'] ?? '',
                    pontos: (famData['pontos'] ?? 0.0).toDouble(),
                    co2Evitado: (famData['co2Evitado'] ?? 0.0).toDouble(),
                  );

                  return Card(
                    child: ListTile(
                      title: Text(famObj.nomeFamilia, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Login: ${famObj.login} | Cidade: ${famObj.cidade}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility, color: Colors.blue),
                            tooltip: 'Ver Cadastro',
                            onPressed: () {
                              Navigator.pop(ctx);
                              _mostrarCadastroCompleto(context, famObj);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.lock_reset, color: Colors.brown),
                            tooltip: 'Alterar Senha',
                            onPressed: () {
                              Navigator.pop(ctx);
                              _dialogAlterarSenha(context, famObj);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Deletar',
                            onPressed: () async {
                              await FirebaseFirestore.instance.collection('familias').doc(docId).delete();
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Família deletada da nuvem!')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar')),
        ],
      ),
    );
  }

  void _mostrarCadastroCompleto(BuildContext context, Familia fam) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cadastro: ${fam.nomeFamilia}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Nome da Família: ${fam.nomeFamilia}'),
            Text('• Qtd. de Moradores: ${fam.moradores}'),
            Text('• Estudante Padrinho: ${fam.estudantePadrinho}'),
            Text('• Turma do Estudante: ${fam.turmaEstudante}'),
            Text('• Cidade: ${fam.cidade}'),
            Text('• Login de Acesso: ${fam.login}'),
            Text('• Senha: ${fam.senha}'),
            Text('• Pontuação Total: ${fam.pontos} pts'),
            Text('• CO₂ Evitado: ${fam.co2Evitado.toStringAsFixed(1)} kg'),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _dialogAlterarSenha(BuildContext context, Familia familia) {
    final TextEditingController novaSenhaController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Alterar Senha: ${familia.nomeFamilia}'),
        content: TextField(
          controller: novaSenhaController,
          decoration: const InputDecoration(labelText: 'Nova Senha'),
          obscureText: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown[700]),
            onPressed: () async {
              String novaSenha = novaSenhaController.text.trim();
              if (novaSenha.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('familias')
                    .doc(familia.idDoc)
                    .update({'senha': novaSenha});
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Senha da ${familia.nomeFamilia} alterada na nuvem!')),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _dialogAprovarComEdicao(BuildContext context, String docId, String nomeFam, double pontosSugeridos, double co2Sugerido) {
    final TextEditingController pontosController = TextEditingController(text: pontosSugeridos.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Aprovar Ação - ${nomeFam}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ajuste os pontos (o CO₂ será calculado automaticamente):'),
            const SizedBox(height: 12),
            TextField(
              controller: pontosController,
              decoration: const InputDecoration(labelText: 'Pontos a somar'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              double? novosPontos = double.tryParse(pontosController.text.trim().replaceAll(',', '.'));

              if (novosPontos != null) {
                try {
                  double proporcao = pontosSugeridos > 0 ? (novosPontos / pontosSugeridos) : 1.0;
                  double novoCo2Calculado = co2Sugerido * proporcao;

                  var famQuery = await FirebaseFirestore.instance
                      .collection('familias')
                      .where('nomeFamilia', isEqualTo: nomeFam)
                      .get();

                  if (famQuery.docs.isNotEmpty) {
                    var famDoc = famQuery.docs.first;
                    var famData = famDoc.data();
                    double pontosAtuais = (famData['pontos'] ?? 0.0).toDouble();
                    double co2Atual = (famData['co2Evitado'] ?? 0.0).toDouble();

                    await FirebaseFirestore.instance
                        .collection('familias')
                        .doc(famDoc.id)
                        .update({
                      'pontos': pontosAtuais + novosPontos,
                      'co2Evitado': co2Atual + novoCo2Calculado,
                    });
                  }

                  await FirebaseFirestore.instance.collection('acoes_pendentes').doc(docId).delete();
                  Navigator.pop(ctx);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ação aprovada, pontos e CO₂ somados com sucesso!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao aprovar: $e')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Insira um valor numérico válido para os pontos.')),
                );
              }
            },
            child: const Text('Confirmar Aprovação'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de Validação (Admin) 🛡️'),
        backgroundColor: Colors.brown[700],
        actions: [
          // Botão para Zerar o Ranking
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Zerar Ranking Geral',
            onPressed: () => _zerarRanking(context),
          ),
          IconButton(
            icon: const Icon(Icons.vpn_key),
            tooltip: 'Alterar Senha do Admin',
            onPressed: () => _alterarSenhaAdmin(context),
          ),
          IconButton(
            icon: const Icon(Icons.manage_accounts),
            tooltip: 'Gerenciar Famílias',
            onPressed: () => _gerenciarFamilias(context),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('acoes_pendentes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhuma foto pendente de validação na nuvem.', style: TextStyle(fontSize: 16, color: Colors.grey)));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              var data = doc.data() as Map<String, dynamic>;
              String docId = doc.id;

              String nomeFam = data['nomeFamilia'] ?? '';
              String tituloAcao = data['titulo'] ?? '';
              double pontosAcao = (data['pontos'] ?? 0.0).toDouble();
              double co2Conv = (data['co2Conversao'] ?? 0.0).toDouble();
              String dataHora = data['dataHora'] ?? '';
              String base64Image = data['imageBase64'] ?? '';

              Uint8List? imageBytes;
              try {
                if (base64Image.isNotEmpty) {
                  imageBytes = base64Decode(base64Image);
                }
              } catch (e) {
                imageBytes = null;
              }

              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Família: $nomeFam', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                          Text('$pontosAcao pts', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Ação: $tituloAcao', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('Data e Horário: $dataHora', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      
                      if (imageBytes != null) ...[
                        GestureDetector(
                          onTap: () => _mostrarFotoInteira(context, imageBytes!),
                          child: Container(
                            color: Colors.black12,
                            height: 220,
                            width: double.infinity,
                            child: Image.memory(imageBytes, fit: BoxFit.contain),
                          ),
                        ),
                        const Center(child: Text('Toque na imagem para ampliar', style: TextStyle(fontSize: 12, color: Colors.grey))),
                        const SizedBox(height: 10),
                      ] else ...[
                        const Text('Nenhuma foto anexada.', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 10),
                      ],

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () async {
                              await FirebaseFirestore.instance.collection('acoes_pendentes').doc(docId).delete();
                            },
                            icon: const Icon(Icons.close),
                            label: const Text('Rejeitar'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            onPressed: () => _dialogAprovarComEdicao(context, docId, nomeFam, pontosAcao, co2Conv),
                            icon: const Icon(Icons.check),
                            label: const Text('Aprovar e Somar'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class RankingScreen extends StatelessWidget {
  const RankingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ranking de Famílias 🏆'), backgroundColor: Colors.green[700]),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('familias')
            .orderBy('pontos', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhuma família cadastrada na nuvem ainda.', style: TextStyle(fontSize: 16, color: Colors.grey)));
          }
          final familiasDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: familiasDocs.length,
            itemBuilder: (context, index) {
              final famData = familiasDocs[index].data() as Map<String, dynamic>;
              
              final nome = famData['nomeFamilia'] ?? 'Família';
              final estudante = famData['estudantePadrinho'] ?? '';
              final turma = famData['turmaEstudante'] ?? '';
              final cidade = famData['cidade'] ?? '';
              final pontos = famData['pontos'] ?? 0;
              final co2 = (famData['co2Evitado'] ?? 0.0).toDouble();

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: index == 0 ? Colors.amber : Colors.green[200],
                  child: Text('${index + 1}º', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                ),
                title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Estudante: $estudante ($turma) - $cidade\n🌱 CO₂ Evitado: ${co2.toStringAsFixed(1)} kg'),
                isThreeLine: true,
                trailing: Text('$pontos pts', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
              );
            },
          );
        },
      ),
    );
  }
}