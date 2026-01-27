import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class TechnicianProfilePage extends StatefulWidget {
  const TechnicianProfilePage({super.key});

  @override
  State<TechnicianProfilePage> createState() => _TechnicianProfilePageState();
}

class _TechnicianProfilePageState extends State<TechnicianProfilePage>
    with TickerProviderStateMixin {
  // ========================================================================
  // VARIABLES DE ESTADO - DATOS DEL TÉCNICO
  // ========================================================================

  // Controladores de formulario
  late TextEditingController _nombresController;
  late TextEditingController _experienciaController;
  late TextEditingController _descripcionController;
  late TextEditingController _especialidadController;

  // Estado de edición
  bool _isEditing = false;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  // Datos originales (para cancelar edición)
  late Map<String, dynamic> _originalData;
  late Map<String, dynamic> _currentData;

  // Animaciones
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ========================================================================
  // INICIALIZACIÓN
  // ========================================================================

  @override
  void initState() {
    super.initState();

    // Datos de ejemplo (serán reemplazados por datos de Supabase)
    _originalData = {
      'nombres_completos': 'Carlos Andrés Morales López',
      'años_experiencia': 8,
      'descripcion_profesional':
          'Especialista en reparación de equipos electrónicos con más de 8 años de experiencia en el sector.',
      'especialidad_nombre': 'Electrónica y Reparación',
      'rating_promedio': 4.8,
      'verificado': true,
      'verificado_por': '550e8400-e29b-41d4-a716-446655440000',
      'created_at': '2023-05-15T10:30:00Z',
    };

    _currentData = Map.from(_originalData);

    // Inicializar controladores
    _nombresController = TextEditingController(
      text: _currentData['nombres_completos'],
    );
    _experienciaController = TextEditingController(
      text: _currentData['años_experiencia'].toString(),
    );
    _descripcionController = TextEditingController(
      text: _currentData['descripcion_profesional'],
    );
    _especialidadController = TextEditingController(
      text: _currentData['especialidad_nombre'],
    );

    // Configurar animaciones
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _experienciaController.dispose();
    _descripcionController.dispose();
    _especialidadController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // ========================================================================
  // FUNCIONES DE OPERACIONES CRUD
  // ========================================================================

  /// Seleccionar imagen del dispositivo
  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  /// Tomar foto con cámara
  Future<void> _takePhoto() async {
    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
    );
    if (photo != null) {
      setState(() {
        _selectedImage = File(photo.path);
      });
    }
  }

  /// Iniciar modo edición
  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  /// Cancelar edición y restaurar datos originales
  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _selectedImage = null;
      _currentData = Map.from(_originalData);
      _nombresController.text = _currentData['nombres_completos'];
      _experienciaController.text = _currentData['años_experiencia'].toString();
      _descripcionController.text = _currentData['descripcion_profesional'];
      _especialidadController.text = _currentData['especialidad_nombre'];
    });
  }

  /// Guardar cambios (aquí se conectaría con el backend)
  void _saveChanges() {
    // Validar datos
    if (_nombresController.text.isEmpty ||
        _experienciaController.text.isEmpty ||
        _descripcionController.text.isEmpty ||
        _especialidadController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Color(0xFF555879),
        ),
      );
      return;
    }

    // Validar experiencia sea un número
    if (int.tryParse(_experienciaController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Los años de experiencia deben ser un número'),
          backgroundColor: Color(0xFF555879),
        ),
      );
      return;
    }

    // Actualizar datos
    _currentData['nombres_completos'] = _nombresController.text;
    _currentData['años_experiencia'] = int.parse(_experienciaController.text);
    _currentData['descripcion_profesional'] = _descripcionController.text;
    _currentData['especialidad_nombre'] = _especialidadController.text;

    // Guardar datos originales para próxima edición
    _originalData = Map.from(_currentData);

    // TODO: Aquí se enviarían los datos al backend mediante Supabase
    // Ejemplo:
    // await supabase
    //   .from('tecnico')
    //   .update({
    //     'nombres_completos': _nombresController.text,
    //     'años_experiencia': int.parse(_experienciaController.text),
    //     'descripcion_profesional': _descripcionController.text,
    //     'especialidad_nombre': _especialidadController.text,
    //   })
    //   .eq('id', technicianId);
    //
    // Si hay imagen, subirla a Storage:
    // if (_selectedImage != null) {
    //   await supabase.storage
    //     .from('tecnico_profiles')
    //     .upload('$technicianId/profile.jpg', _selectedImage!);
    // }

    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cambios guardados correctamente'),
        backgroundColor: Color(0xFF98A1BC),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EBD3),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: [
                    // ========== SECCIÓN: FOTO DE PERFIL ==========
                    _buildProfilePhotoSection(),
                    const SizedBox(height: 32),

                    // ========== SECCIÓN: INFORMACIÓN PERSONAL ==========
                    _buildPersonalInfoSection(),
                    const SizedBox(height: 24),

                    // ========== SECCIÓN: EXPERIENCIA ==========
                    _buildExperienceSection(),
                    const SizedBox(height: 24),

                    // ========== SECCIÓN: ESPECIALIDAD ==========
                    _buildSpecialtySection(),
                    const SizedBox(height: 24),

                    // ========== SECCIÓN: DESCRIPCIÓN PROFESIONAL ==========
                    _buildDescriptionSection(),
                    const SizedBox(height: 24),

                    // ========== SECCIÓN: ESTADO VERIFICACIÓN ==========
                    if (!_isEditing) ...[
                      _buildVerificationSection(),
                      const SizedBox(height: 24),
                    ],

                    // ========== BOTONES DE ACCIÓN ==========
                    _buildActionButtons(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ========================================================================
  // WIDGETS DE CONSTRUCCIÓN DE LA INTERFAZ
  // ========================================================================

  /// AppBar personalizado
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF555879),
      elevation: 8,
      shadowColor: const Color(0xFF555879).withOpacity(0.3),
      title: const Text(
        'Mi Perfil Técnico',
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        if (!_isEditing)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Verificado',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Sección de foto de perfil
  Widget _buildProfilePhotoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          // Foto de perfil
          GestureDetector(
            onTap: _isEditing ? null : null,
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF555879), Color(0xFF98A1BC)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF555879).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: _selectedImage != null
                      ? CircleAvatar(
                          backgroundImage: FileImage(_selectedImage!),
                        )
                      : const Center(
                          child: Text(
                            'CAM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF98A1BC),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF555879).withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: PopupMenuButton<String>(
                        onSelected: (String value) {
                          if (value == 'gallery') {
                            _pickImage();
                          } else if (value == 'camera') {
                            _takePhoto();
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'gallery',
                                child: Row(
                                  children: [
                                    Icon(Icons.photo_library),
                                    SizedBox(width: 8),
                                    Text('Galería'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'camera',
                                child: Row(
                                  children: [
                                    Icon(Icons.camera_alt),
                                    SizedBox(width: 8),
                                    Text('Cámara'),
                                  ],
                                ),
                              ),
                            ],
                        child: const Icon(
                          Icons.add_a_photo,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Nombre y especialidad
          Text(
            _currentData['nombres_completos'],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF555879),
              fontFamily: 'Montserrat',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _currentData['especialidad_nombre'],
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF98A1BC),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                child: Icon(
                  index < (_currentData['rating_promedio'] as double).toInt()
                      ? Icons.star
                      : Icons.star_border,
                  color: const Color(0xFFDED3C4),
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_currentData['rating_promedio']}/5.0',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF98A1BC),
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  /// Sección de información personal
  Widget _buildPersonalInfoSection() {
    return _buildSectionContainer(
      icon: Icons.person,
      title: 'Información Personal',
      child: Column(
        children: [
          if (_isEditing)
            _buildEditableTextField(
              controller: _nombresController,
              label: 'Nombres Completos',
              icon: Icons.person,
            )
          else
            _buildInfoField(
              label: 'Nombres Completos',
              value: _currentData['nombres_completos'],
            ),
        ],
      ),
    );
  }

  /// Sección de experiencia
  Widget _buildExperienceSection() {
    return _buildSectionContainer(
      icon: Icons.work_history,
      title: 'Experiencia',
      child: Column(
        children: [
          if (_isEditing)
            _buildEditableTextField(
              controller: _experienciaController,
              label: 'Años de Experiencia',
              icon: Icons.calendar_today,
              keyboardType: TextInputType.number,
            )
          else
            _buildInfoField(
              label: 'Años de Experiencia',
              value: '${_currentData['años_experiencia']} años',
            ),
        ],
      ),
    );
  }

  /// Sección de especialidad
  Widget _buildSpecialtySection() {
    return _buildSectionContainer(
      icon: Icons.category,
      title: 'Especialidad',
      child: Column(
        children: [
          if (_isEditing)
            _buildEditableTextField(
              controller: _especialidadController,
              label: 'Nombre de Especialidad',
              icon: Icons.build,
            )
          else
            _buildInfoField(
              label: 'Especialidad',
              value: _currentData['especialidad_nombre'],
            ),
        ],
      ),
    );
  }

  /// Sección de descripción profesional
  Widget _buildDescriptionSection() {
    return _buildSectionContainer(
      icon: Icons.description,
      title: 'Descripción Profesional',
      child: Column(
        children: [
          if (_isEditing)
            _buildEditableTextField(
              controller: _descripcionController,
              label: 'Descripción Profesional',
              icon: Icons.edit,
              maxLines: 5,
            )
          else
            _buildInfoField(
              label: 'Descripción',
              value: _currentData['descripcion_profesional'],
              isLongText: true,
            ),
        ],
      ),
    );
  }

  /// Sección de verificación
  Widget _buildVerificationSection() {
    return _buildSectionContainer(
      icon: Icons.verified_user,
      title: 'Estado de Verificación',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          border: Border.all(color: Colors.green, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Verificado',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tu perfil ha sido verificado por el equipo de ClickFix',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade700,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Botones de acción
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          if (_isEditing) ...[
            // Botón Guardar
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF555879).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF555879),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 32,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.save),
                label: const Text(
                  'Guardar Cambios',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Botón Cancelar
            ElevatedButton.icon(
              onPressed: _cancelEditing,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF98A1BC),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 32,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.close),
              label: const Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ] else ...[
            // Botón Editar
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF555879).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _startEditing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF555879),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.edit),
                  label: const Text(
                    'Editar Perfil',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ========================================================================
  // WIDGETS REUTILIZABLES
  // ========================================================================

  /// Contenedor de sección con icono y título
  Widget _buildSectionContainer({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF555879).withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de la sección
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4EBD3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: const Color(0xFF555879), size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF555879),
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Contenido
            child,
          ],
        ),
      ),
    );
  }

  /// Campo de información (solo lectura)
  Widget _buildInfoField({
    required String label,
    required String value,
    bool isLongText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF98A1BC),
            fontFamily: 'Montserrat',
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isLongText ? 14 : 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF555879),
            fontFamily: 'Montserrat',
            height: isLongText ? 1.5 : 1.2,
          ),
          maxLines: isLongText ? null : 1,
          overflow: isLongText ? null : TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Campo de texto editable
  Widget _buildEditableTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF98A1BC),
            fontFamily: 'Montserrat',
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF555879)),
          filled: true,
          fillColor: const Color(0xFFF4EBD3).withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF98A1BC), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF555879), width: 2.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          color: Color(0xFF555879),
        ),
      ),
    );
  }
}
