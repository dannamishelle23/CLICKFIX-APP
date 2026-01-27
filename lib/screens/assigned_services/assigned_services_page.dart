import 'package:flutter/material.dart';
import '../service_detail_technician/service_detail_technician_page.dart';

class AssignedServicesPage extends StatefulWidget {
  const AssignedServicesPage({super.key});

  @override
  State<AssignedServicesPage> createState() => _AssignedServicesPageState();
}

class _AssignedServicesPageState extends State<AssignedServicesPage>
    with TickerProviderStateMixin {
  // ========================================================================
  // VARIABLES DE ESTADO
  // ========================================================================

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late List<Map<String, dynamic>> _services;
  String _selectedFilter = 'todos';

  @override
  void initState() {
    super.initState();

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

    _initializeSampleData();
  }

  void _initializeSampleData() {
    // TODO: Obtener de Supabase - servicios asignados al tecnico
    _services = [
      {
        'id': '1',
        'descripcion': 'Fuga de agua en el bano principal',
        'cliente_nombre': 'Maria Garcia',
        'cliente_foto': 'https://via.placeholder.com/150/555879/FFFFFF?text=MG',
        'cliente_telefono': '+57 300 1234567',
        'direccion': 'Calle 45 #12-34, Bogota',
        'monto': 150000,
        'fecha_asignacion': DateTime.now().subtract(const Duration(hours: 2)),
        'fecha_programada': DateTime.now().add(const Duration(days: 1)),
        'estado': 'pendiente',
      },
      {
        'id': '2',
        'descripcion': 'Reparacion de puerta de madera',
        'cliente_nombre': 'Ana Rodriguez',
        'cliente_foto': 'https://via.placeholder.com/150/98A1BC/FFFFFF?text=AR',
        'cliente_telefono': '+57 310 9876543',
        'direccion': 'Avenida 68 #23-45, Bogota',
        'monto': 200000,
        'fecha_asignacion': DateTime.now().subtract(const Duration(days: 1)),
        'fecha_programada': DateTime.now(),
        'estado': 'en_progreso',
      },
      {
        'id': '3',
        'descripcion': 'Instalacion de tomacorrientes',
        'cliente_nombre': 'Juan Perez',
        'cliente_foto': 'https://via.placeholder.com/150/DED3C4/555879?text=JP',
        'cliente_telefono': '+57 320 5555555',
        'direccion': 'Carrera 15 #78-90, Bogota',
        'monto': 80000,
        'fecha_asignacion': DateTime.now().subtract(const Duration(days: 3)),
        'fecha_programada': DateTime.now().subtract(const Duration(days: 2)),
        'estado': 'completado',
      },
    ];
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // ========================================================================
  // METODOS AUXILIARES
  // ========================================================================

  String _formatDate(DateTime date) {
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatMoney(int amount) {
    return '\$${amount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}';
  }

  Color _getStateColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return const Color(0xFFF39C12);
      case 'en_progreso':
        return const Color(0xFF3498DB);
      case 'completado':
        return const Color(0xFF27AE60);
      default:
        return const Color(0xFF95A5A6);
    }
  }

  String _getStateLabel(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_progreso':
        return 'En Progreso';
      case 'completado':
        return 'Completado';
      default:
        return estado;
    }
  }

  IconData _getStateIcon(String estado) {
    switch (estado) {
      case 'pendiente':
        return Icons.schedule;
      case 'en_progreso':
        return Icons.build;
      case 'completado':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  List<Map<String, dynamic>> get _filteredServices {
    if (_selectedFilter == 'todos') return _services;
    return _services.where((s) => s['estado'] == _selectedFilter).toList();
  }

  void _viewServiceDetail(Map<String, dynamic> service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailTechnicianPage(service: service),
      ),
    );
  }

  // ========================================================================
  // CONSTRUIR INTERFAZ
  // ========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EBD3),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              _buildFilterChips(),
              Expanded(
                child: _filteredServices.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _filteredServices.length,
                        itemBuilder: (context, index) {
                          return _buildServiceCard(_filteredServices[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Servicios Asignados',
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      backgroundColor: const Color(0xFF555879),
      elevation: 4,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['todos', 'pendiente', 'en_progreso', 'completado'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  filter == 'todos' ? 'Todos' : _getStateLabel(filter),
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF555879),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                backgroundColor: Colors.white,
                selectedColor: const Color(0xFF555879),
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color: isSelected ? const Color(0xFF555879) : const Color(0xFF98A1BC),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment,
            size: 80,
            color: const Color(0xFF98A1BC).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay servicios asignados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555879),
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los servicios que te asignen apareceran aqui',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF98A1BC).withOpacity(0.7),
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final stateColor = _getStateColor(service['estado']);
    final stateLabel = _getStateLabel(service['estado']);
    final stateIcon = _getStateIcon(service['estado']);

    return GestureDetector(
      onTap: () => _viewServiceDetail(service),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: stateColor.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF555879).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con estado
            Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF555879), width: 2),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      service['cliente_foto'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person, color: Color(0xFF555879));
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['cliente_nombre'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF555879),
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 12, color: const Color(0xFF98A1BC)),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(service['fecha_programada']),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF98A1BC),
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: stateColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: stateColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(stateIcon, size: 14, color: stateColor),
                      const SizedBox(width: 4),
                      Text(
                        stateLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: stateColor,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Descripcion
            Text(
              service['descripcion'],
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF555879),
                fontFamily: 'Montserrat',
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            // Direccion
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Color(0xFF98A1BC)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    service['direccion'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF98A1BC),
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: const Color(0xFFDED3C4)),
            const SizedBox(height: 12),
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatMoney(service['monto']),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF555879),
                    fontFamily: 'Montserrat',
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      'Ver detalle',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF555879),
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF555879)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
