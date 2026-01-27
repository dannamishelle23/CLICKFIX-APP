import 'package:flutter/material.dart';

class AdminReviewsPage extends StatefulWidget {
  const AdminReviewsPage({super.key});

  @override
  State<AdminReviewsPage> createState() => _AdminReviewsPageState();
}

class _AdminReviewsPageState extends State<AdminReviewsPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late List<Map<String, dynamic>> _reviews;
  String _selectedFilter = 'pendientes';

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _fadeController.forward();
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // TODO: Obtener de Supabase
    _reviews = [
      {
        'id': '1',
        'autor': 'Maria Garcia',
        'receptor': 'Carlos Martinez',
        'calificacion': 5,
        'comentario': 'Excelente trabajo! Muy profesional y puntual.',
        'servicio': 'Reparacion de tuberia',
        'fecha': DateTime.now().subtract(const Duration(hours: 5)),
        'estado': 'pendiente',
      },
      {
        'id': '2',
        'autor': 'Juan Perez',
        'receptor': 'Pedro Gomez',
        'calificacion': 2,
        'comentario': 'El trabajo fue malo, no lo recomiendo para nada. Muy irresponsable.',
        'servicio': 'Instalacion electrica',
        'fecha': DateTime.now().subtract(const Duration(days: 1)),
        'estado': 'pendiente',
      },
      {
        'id': '3',
        'autor': 'Ana Rodriguez',
        'receptor': 'Luis Hernandez',
        'calificacion': 4,
        'comentario': 'Buen servicio, llego a tiempo.',
        'servicio': 'Reparacion de puerta',
        'fecha': DateTime.now().subtract(const Duration(days: 2)),
        'estado': 'aprobada',
      },
      {
        'id': '4',
        'autor': 'Carlos Lopez',
        'receptor': 'Miguel Torres',
        'calificacion': 1,
        'comentario': 'Pesimo servicio, contenido inapropiado en el comentario.',
        'servicio': 'Pintura',
        'fecha': DateTime.now().subtract(const Duration(days: 3)),
        'estado': 'rechazada',
      },
    ];
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredReviews {
    if (_selectedFilter == 'todas') return _reviews;
    return _reviews.where((r) => r['estado'] == _selectedFilter).toList();
  }

  void _approveReview(Map<String, dynamic> review) {
    setState(() {
      review['estado'] = 'aprobada';
    });
    // TODO: Actualizar en Supabase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resena aprobada'),
        backgroundColor: Color(0xFF27AE60),
      ),
    );
  }

  void _rejectReview(Map<String, dynamic> review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF4EBD3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Rechazar Resena',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Color(0xFF555879)),
        ),
        content: const Text(
          'Esta resena sera ocultada y no se mostrara al publico. Deseas continuar?',
          style: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF555879)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF98A1BC))),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                review['estado'] = 'rechazada';
              });
              Navigator.pop(context);
              // TODO: Actualizar en Supabase
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Resena rechazada'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Rechazar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${date.day} ${months[date.month - 1]}';
  }

  Color _getStateColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return const Color(0xFFF39C12);
      case 'aprobada':
        return const Color(0xFF27AE60);
      case 'rechazada':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFF95A5A6);
    }
  }

  String _getStateLabel(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'aprobada':
        return 'Aprobada';
      case 'rechazada':
        return 'Rechazada';
      default:
        return estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EBD3),
      appBar: AppBar(
        title: const Text(
          'Moderacion de Resenas',
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF555879),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildStats(),
            _buildFilterChips(),
            Expanded(
              child: _filteredReviews.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredReviews.length,
                      itemBuilder: (context, index) => _buildReviewCard(_filteredReviews[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    final pendientes = _reviews.where((r) => r['estado'] == 'pendiente').length;
    final aprobadas = _reviews.where((r) => r['estado'] == 'aprobada').length;
    final rechazadas = _reviews.where((r) => r['estado'] == 'rechazada').length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF98A1BC)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Pendientes', pendientes, const Color(0xFFF39C12)),
          Container(width: 1, height: 40, color: const Color(0xFFDED3C4)),
          _buildStatItem('Aprobadas', aprobadas, const Color(0xFF27AE60)),
          Container(width: 1, height: 40, color: const Color(0xFFDED3C4)),
          _buildStatItem('Rechazadas', rechazadas, const Color(0xFFE74C3C)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'Montserrat',
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF98A1BC), fontFamily: 'Montserrat'),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = ['pendientes', 'aprobada', 'rechazada', 'todas'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                filter == 'todas' ? 'Todas' : filter == 'pendientes' ? 'Pendientes' : _getStateLabel(filter),
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF555879),
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedFilter = filter),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF555879),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review, size: 80, color: const Color(0xFF98A1BC).withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'pendientes'
                ? 'No hay resenas pendientes'
                : 'No hay resenas',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF555879),
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final stateColor = _getStateColor(review['estado']);
    final stateLabel = _getStateLabel(review['estado']);
    final isPending = review['estado'] == 'pendiente';

    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stateColor.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < (review['calificacion'] as int) ? Icons.star : Icons.star_border,
                    size: 18,
                    color: const Color(0xFFF39C12),
                  );
                }),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: stateColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: stateColor),
                ),
                child: Text(
                  stateLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: stateColor,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"${review['comentario']}"',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF555879),
              fontFamily: 'Montserrat',
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFFDED3C4)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'De: ${review['autor']}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF98A1BC)),
                    ),
                    Text(
                      'Para: ${review['receptor']}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF98A1BC)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    review['servicio'],
                    style: const TextStyle(fontSize: 11, color: Color(0xFF555879), fontWeight: FontWeight.w600),
                  ),
                  Text(
                    _formatDate(review['fecha']),
                    style: const TextStyle(fontSize: 10, color: Color(0xFF98A1BC)),
                  ),
                ],
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectReview(review),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Rechazar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveReview(review),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27AE60)),
                    icon: const Icon(Icons.check, size: 18, color: Colors.white),
                    label: const Text('Aprobar', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
