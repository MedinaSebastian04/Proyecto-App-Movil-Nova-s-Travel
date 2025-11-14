import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/data_service.dart';
import '../models/usuario.dart';
import 'login_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final DataService _dataService = DataService();
  final _formKey = GlobalKey<FormState>();
  
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _dniController = TextEditingController();

  bool _cargando = true;
  bool _editando = false;
  Usuario? _usuario;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _dniController.dispose();
    super.dispose();
  }

  Future<void> _cargarUsuario() async {
    setState(() {
      _cargando = true;
    });

    final usuario = await _dataService.obtenerUsuario();
    
    if (usuario != null) {
      setState(() {
        _usuario = usuario;
        _nombreController.text = usuario.nombre;
        _apellidoController.text = usuario.apellido;
        _emailController.text = usuario.email;
        _telefonoController.text = usuario.telefono;
        _dniController.text = usuario.dni;
      });
    }

    setState(() {
      _cargando = false;
    });
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final usuarioActualizado = Usuario(
      id: _usuario!.id,
      nombre: _nombreController.text,
      apellido: _apellidoController.text,
      email: _emailController.text,
      telefono: _telefonoController.text,
      dni: _dniController.text,
    );

    await _dataService.guardarUsuario(usuarioActualizado);

    setState(() {
      _usuario = usuarioActualizado;
      _editando = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  //Cerrar sesión
  Future<void> _cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        elevation: 0,
        actions: [
          if (!_editando && !_cargando)
            IconButton(
              tooltip: 'Editar perfil',
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _editando = true;
                });
              },
            ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            child: Text(
                              _usuario != null
                                  ? '${_usuario!.nombre[0]}${_usuario!.apellido[0]}'
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _usuario != null
                              ? '${_usuario!.nombre} ${_usuario!.apellido}'
                              : 'Usuario',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _usuario?.email ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildTextField(
                            controller: _nombreController,
                            label: 'Nombre',
                            icon: Icons.person,
                            enabled: _editando,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _apellidoController,
                            label: 'Apellido',
                            icon: Icons.person_outline,
                            enabled: _editando,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email,
                            enabled: _editando,
                            type: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _telefonoController,
                            label: 'Teléfono',
                            icon: Icons.phone,
                            enabled: _editando,
                            type: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _dniController,
                            label: 'DNI',
                            icon: Icons.badge,
                            enabled: _editando,
                            type: TextInputType.number,
                            maxLength: 8,
                          ),

                          if (_editando) ...[
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _editando = false;
                                        _cargarUsuario();
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('CANCELAR'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _guardarCambios,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('GUARDAR'),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 32),

                          //Botón inferior de cerrar sesión
                          ElevatedButton.icon(
                            onPressed: _cerrarSesion,
                            icon: const Icon(Icons.logout),
                            label: const Text('Cerrar sesión'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType type = TextInputType.text,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      enabled: enabled,
      keyboardType: type,
      maxLength: maxLength,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu $label';
        }
        return null;
      },
    );
  }
}
