import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

// La classe NewsPage ora include un bottone per tornare alla home
class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Applico un tema complessivo alle system UI
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFDCE4F0),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: const Color(0xFF5E17EB).withOpacity(0.1),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF5E17EB)),
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            ),
          ),
        ),
        title: Text(
          'Il nostro percorso',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF5E17EB),
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // Body now directly shows the single page
      body: const YearsListPage(),
    );
  }
}

class YearsListPage extends StatelessWidget {
  const YearsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Use the gradient background similar to the example code
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDCE4F0), Color(0xFFB8C7DB)], // Gradient background
        ),
      ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Anni Scolastici',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5E17EB),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Esplora i ricordi e gli eventi dei nostri 5 anni al Paleocapa',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((
                BuildContext context,
                int index,
              ) {
                if (index < schoolYears.length) {
                  return Hero(
                    tag: 'year_card_$index',
                    child: SchoolYearCard(
                      year: schoolYears[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    YearEventsPage(year: schoolYears[index]),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                }
                return null;
              }, childCount: schoolYears.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class SchoolYearCard extends StatelessWidget {
  final SchoolYear year;
  final VoidCallback onTap;

  const SchoolYearCard({super.key, required this.year, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                _getGradientStartColor(year.yearNumber),
                _getGradientEndColor(year.yearNumber),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _getYearColor(year.yearNumber).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative pattern/icon in background
              Positioned(
                right: -30,
                bottom: -30,
                child: Icon(
                  _getYearIcon(year.yearNumber),
                  size: 150,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),

              // Content overlay
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            year.academicYear,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          year.title,
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.1,
                            shadows: [
                              Shadow(
                                blurRadius: 3.0,
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(1.0, 1.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<int>(
                              future: EventStorage.getTotalEventCount(
                                year.yearNumber,
                                year.events.length,
                              ),
                              builder: (context, snapshot) {
                                final baseCount = year.events.length;
                                final totalCount = snapshot.data ?? baseCount;

                                return Text(
                                  '$totalCount eventi',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 5),
                            Text(
                              year.shortDescription,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.85),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: _getYearColor(year.yearNumber),
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get an icon based on the year number
  IconData _getYearIcon(int yearNumber) {
    switch (yearNumber) {
      case 1:
        return FontAwesomeIcons.school;
      case 2:
        return FontAwesomeIcons.bookOpen;
      case 3:
        return FontAwesomeIcons.graduationCap;
      case 4:
        return FontAwesomeIcons.laptop;
      case 5:
        return FontAwesomeIcons.trophy;
      case 6:
        return FontAwesomeIcons.rocket;
      default:
        return FontAwesomeIcons.calendarAlt;
    }
  }

  Color _getYearColor(int yearNumber) {
    switch (yearNumber) {
      case 1:
        return const Color(0xFF4776E6); // Blue
      case 2:
        return const Color(0xFF00897B); // Teal
      case 3:
        return const Color(0xFF8E54E9); // Purple
      case 4:
        return const Color(0xFFFF416C); // Pink
      case 5:
        return const Color(0xFF56AB2F); // Green
      case 6:
        return const Color(0xFFFF9966); // Orange
      default:
        return const Color(0xFF4776E6);
    }
  }

  Color _getGradientStartColor(int yearNumber) {
    switch (yearNumber) {
      case 1:
        return const Color(0xFF4776E6); // Blue
      case 2:
        return const Color(0xFF00897B); // Teal
      case 3:
        return const Color(0xFF8E54E9); // Purple
      case 4:
        return const Color(0xFFFF416C); // Pink
      case 5:
        return const Color(0xFF56AB2F); // Green
      case 6:
        return const Color(0xFFFF9966); // Orange
      default:
        return const Color(0xFF4776E6);
    }
  }

  Color _getGradientEndColor(int yearNumber) {
    switch (yearNumber) {
      case 1:
        return const Color(0xFF8E54E9); // Purple
      case 2:
        return const Color(0xFF26A69A); // Lighter Teal
      case 3:
        return const Color(0xFF4776E6); // Blue
      case 4:
        return const Color(0xFFFF4B2B); // Orange-Red
      case 5:
        return const Color(0xFFA8E063); // Light Green
      case 6:
        return const Color(0xFFFF5E62); // Red
      default:
        return const Color(0xFF8E54E9);
    }
  }
}

class YearEventsPage extends StatefulWidget {
  final SchoolYear year;

  const YearEventsPage({super.key, required this.year});

  @override
  State<YearEventsPage> createState() => _YearEventsPageState();
}

class _YearEventsPageState extends State<YearEventsPage> {
  late List<SchoolEvent> events;
  late List<SchoolEvent> customEvents = [];
  bool _isLoading = true;

  // Controller per l'animazione dello scroll
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Carica gli eventi predefiniti
    events = List.from(widget.year.events);
    // Carica gli eventi personalizzati salvati
    _loadCustomEvents();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomEvents() async {
    setState(() {
      _isLoading = true;
    });
    // Use EventStorage class
    customEvents = await EventStorage.loadCustomEvents(widget.year.yearNumber);
    setState(() {
      events = [...widget.year.events, ...customEvents];
      _isLoading = false;
    });
  }

  Future<void> _saveCustomEvents() async {
    // Use EventStorage class
    await EventStorage.saveCustomEvents(widget.year.yearNumber, customEvents);
  }

  void _addNewEvent(SchoolEvent newEvent) {
    setState(() {
      customEvents.add(newEvent);
      events = [...widget.year.events, ...customEvents];
    });

    // Salva l'evento aggiunto nel local storage
    _saveCustomEvents();

    // Scorri verso il basso per mostrare il nuovo evento
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100, // Add some offset
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final yearColor = _getYearColor(widget.year.yearNumber);
    final gradientStart = _getGradientStartColor(widget.year.yearNumber);
    final gradientEnd = _getGradientEndColor(widget.year.yearNumber);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEventDialog(context);
        },
        backgroundColor: yearColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFDCE4F0),
              Color(0xFFB8C7DB),
            ], // Gradient background
          ),
        ),
        child:
            _isLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: yearColor,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Caricamento eventi...",
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
                : CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 240.0,
                      pinned: true,
                      stretch: true,
                      backgroundColor: yearColor,
                      elevation: 0,
                      leading: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.8),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black87,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                      actions: [
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                          onSelected: (value) {
                            if (value == 'filter') {
                              // Implementa filtro
                            } else if (value == 'sort') {
                              // Implementa ordinamento
                            }
                          },
                          itemBuilder:
                              (context) => [
                                PopupMenuItem(
                                  value: 'filter',
                                  child: Row(
                                    children: [
                                      Icon(Icons.filter_list, color: yearColor),
                                      const SizedBox(width: 10),
                                      const Text('Filtra eventi'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'sort',
                                  child: Row(
                                    children: [
                                      Icon(Icons.sort, color: yearColor),
                                      const SizedBox(width: 10),
                                      const Text('Ordina eventi'),
                                    ],
                                  ),
                                ),
                              ],
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        titlePadding: const EdgeInsets.only(
                          left: 20,
                          bottom: 16,
                          right: 20,
                        ),
                        title: Text(
                          widget.year.title,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            letterSpacing: -0.5,
                          ),
                        ),
                        background: Hero(
                          // Adjust tag if needed, ensure it's unique and matches
                          tag: 'year_card_${widget.year.yearNumber - 1}',
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [gradientStart, gradientEnd],
                                  ),
                                ),
                              ),
                              // Decorative pattern
                              Positioned(
                                right: -30,
                                bottom: -30,
                                child: Icon(
                                  _getYearIcon(widget.year.yearNumber),
                                  size: 150,
                                  color: Colors.white.withOpacity(0.15),
                                ),
                              ),
                              // Overlay gradient
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      yearColor.withOpacity(0.8),
                                      yearColor,
                                    ],
                                    stops: const [0.5, 0.8, 1.0],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 60,
                                left: 20,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    widget.year.academicYear,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.year.description,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey.shade800,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: yearColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.event_note,
                                    color: yearColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Eventi',
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: yearColor,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () {
                                    _showAddEventDialog(context);
                                  },
                                  icon: Icon(
                                    Icons.add_circle,
                                    color: yearColor,
                                    size: 20,
                                  ),
                                  label: Text(
                                    'Aggiungi',
                                    style: GoogleFonts.poppins(
                                      color: yearColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    backgroundColor: yearColor.withOpacity(
                                      0.08,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                    // Griglia a 3 card per riga con spaziatura ottimizzata
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // Manteniamo 3 colonne
                              childAspectRatio:
                                  0.8, // Rapporto d'aspetto per card senza spazio bianco
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          if (index < events.length) {
                            return GridEventCard(
                              event: events[index],
                              yearColor: yearColor,
                              index: index,
                              isCustom: index >= widget.year.events.length,
                              onDelete:
                                  index >= widget.year.events.length
                                      ? () => _deleteCustomEvent(
                                        index - widget.year.events.length,
                                      )
                                      : null,
                            );
                          }
                          return null; // Should not happen
                        }, childCount: events.length),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100), // Spazio extra in fondo
                    ),
                  ],
                ),
      ),
    );
  }

  void _deleteCustomEvent(int customIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Conferma eliminazione",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: _getYearColor(widget.year.yearNumber),
            ),
          ),
          content: Text(
            "Sei sicuro di voler eliminare questo evento?",
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              child: Text(
                "Annulla",
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              child: Text(
                "Elimina",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              onPressed: () async {
                // Make async
                // Use EventStorage class for deletion logic
                await EventStorage.deleteCustomEvent(
                  widget.year.yearNumber,
                  customIndex,
                  customEvents, // Pass the list of custom events
                );
                // Reload events after deletion
                await _loadCustomEvents();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String title = '';
    String date = '';
    String description = '';
    String additionalContent = '';
    List<Anecdote> anecdotes = [];
    final yearColor = _getYearColor(widget.year.yearNumber);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            // Use setStateDialog for dialog state
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Aggiungi un nuovo evento',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: yearColor,
                  fontSize: 20,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Titolo',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: yearColor,
                                width: 2,
                              ),
                            ),
                            prefixIcon: Icon(Icons.title, color: yearColor),
                            labelStyle: GoogleFonts.poppins(
                              color: Colors.grey.shade700,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                          ),
                          style: GoogleFonts.poppins(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Inserisci un titolo';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            title = value ?? '';
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Data (es. 12 maggio 2023)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: yearColor,
                                width: 2,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.calendar_today,
                              color: yearColor,
                            ),
                            labelStyle: GoogleFonts.poppins(
                              color: Colors.grey.shade700,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                          ),
                          style: GoogleFonts.poppins(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Inserisci una data';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            date = value ?? '';
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Descrizione',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: yearColor,
                                width: 2,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.description,
                              color: yearColor,
                            ),
                            labelStyle: GoogleFonts.poppins(
                              color: Colors.grey.shade700,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
                            alignLabelWithHint: true,
                          ),
                          style: GoogleFonts.poppins(),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Inserisci una descrizione';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            description = value ?? '';
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Contenuto aggiuntivo (opzionale)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: yearColor,
                                width: 2,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.more_horiz,
                              color: yearColor,
                            ),
                            labelStyle: GoogleFonts.poppins(
                              color: Colors.grey.shade700,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
                            alignLabelWithHint: true,
                          ),
                          style: GoogleFonts.poppins(),
                          maxLines: 2,
                          onSaved: (value) {
                            additionalContent = value ?? '';
                          },
                        ),
                        const SizedBox(height: 24),

                        // Display existing anecdotes
                        if (anecdotes.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: yearColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: yearColor.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Aneddoti aggiunti:',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: yearColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...anecdotes.asMap().entries.map((entry) {
                                  int idx = entry.key;
                                  Anecdote anecdote = entry.value;
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        anecdote.title,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Text(
                                        anecdote.description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red.shade400,
                                        ),
                                        onPressed: () {
                                          // Use setStateDialog to update the dialog UI
                                          setStateDialog(() {
                                            anecdotes.removeAt(idx);
                                          });
                                        },
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 4,
                                          ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: yearColor.withOpacity(0.1),
                            foregroundColor: yearColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: yearColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.add),
                          label: Text(
                            'Aggiungi aneddoto',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          onPressed:
                              () => _showAddAnecdoteDialog(context, (
                                title,
                                description,
                              ) {
                                // Use setStateDialog to update the dialog UI
                                setStateDialog(() {
                                  anecdotes.add(
                                    Anecdote(
                                      title: title,
                                      description: description,
                                    ),
                                  );
                                });
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Annulla',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yearColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Salva',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();

                      // Crea nuovo evento
                      final newEvent = SchoolEvent(
                        title: title,
                        date: date,
                        description: description,
                        imageUrl:
                            'https://picsum.photos/id/${100 + events.length}/1000/600', // URL di immagine casuale
                        additionalContent: additionalContent,
                        anecdotes: anecdotes,
                      );

                      // Aggiungi l'evento e chiudi il dialog
                      _addNewEvent(newEvent);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddAnecdoteDialog(
    BuildContext context,
    Function(String, String) onAdd,
  ) {
    final yearColor = _getYearColor(widget.year.yearNumber);
    final formKey = GlobalKey<FormState>();
    String title = '';
    String description = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Aggiungi un aneddoto',
            style: GoogleFonts.poppins(
              color: yearColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Titolo aneddoto',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: yearColor, width: 2),
                    ),
                    prefixIcon: Icon(
                      FontAwesomeIcons.quoteLeft,
                      size: 16,
                      color: yearColor,
                    ),
                    labelStyle: GoogleFonts.poppins(
                      color: Colors.grey.shade700,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                  ),
                  style: GoogleFonts.poppins(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci un titolo';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    title = value ?? '';
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Descrizione aneddoto',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: yearColor, width: 2),
                    ),
                    prefixIcon: Icon(Icons.description, color: yearColor),
                    labelStyle: GoogleFonts.poppins(
                      color: Colors.grey.shade700,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    alignLabelWithHint: true,
                  ),
                  style: GoogleFonts.poppins(),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci una descrizione';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    description = value ?? '';
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Annulla',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: yearColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Aggiungi',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  onAdd(title, description);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Color _getYearColor(int yearNumber) {
    switch (yearNumber) {
      case 1:
        return const Color(0xFF4776E6); // Blue
      case 2:
        return const Color(0xFF00897B); // Teal
      case 3:
        return const Color(0xFF8E54E9); // Purple
      case 4:
        return const Color(0xFFFF416C); // Pink
      case 5:
        return const Color(0xFF56AB2F); // Green
      case 6: // Periodo dopo la scuola
        return const Color(0xFFFF9966); // Orange
      default:
        return const Color(0xFF4776E6);
    }
  }

  Color _getGradientStartColor(int yearNumber) {
    switch (yearNumber) {
      case 1:
        return const Color(0xFF4776E6); // Blue
      case 2:
        return const Color(0xFF00897B); // Teal
      case 3:
        return const Color(0xFF8E54E9); // Purple
      case 4:
        return const Color(0xFFFF416C); // Pink
      case 5:
        return const Color(0xFF56AB2F); // Green
      case 6:
        return const Color(0xFFFF9966); // Orange
      default:
        return const Color(0xFF4776E6);
    }
  }

  Color _getGradientEndColor(int yearNumber) {
    switch (yearNumber) {
      case 1:
        return const Color(0xFF8E54E9); // Purple
      case 2:
        return const Color(0xFF26A69A); // Lighter Teal
      case 3:
        return const Color(0xFF4776E6); // Blue
      case 4:
        return const Color(0xFFFF4B2B); // Orange-Red
      case 5:
        return const Color(0xFFA8E063); // Light Green
      case 6:
        return const Color(0xFFFF5E62); // Red
      default:
        return const Color(0xFF8E54E9);
    }
  }

  IconData _getYearIcon(int yearNumber) {
    switch (yearNumber) {
      case 1:
        return FontAwesomeIcons.school;
      case 2:
        return FontAwesomeIcons.bookOpen;
      case 3:
        return FontAwesomeIcons.graduationCap;
      case 4:
        return FontAwesomeIcons.laptop;
      case 5:
        return FontAwesomeIcons.trophy;
      case 6:
        return FontAwesomeIcons.rocket;
      default:
        return FontAwesomeIcons.calendarAlt;
    }
  }
}

// Widget ottimizzato per le card nella griglia
class GridEventCard extends StatelessWidget {
  final SchoolEvent event;
  final Color yearColor;
  final int index;
  final bool isCustom;
  final Function? onDelete;

  const GridEventCard({
    super.key,
    required this.event,
    required this.yearColor,
    required this.index,
    this.isCustom = false,
    this.onDelete,
  });

  IconData _getEventIcon() {
    if (event.title == 'Primo giorno di scuola') return FontAwesomeIcons.school;
    if (event.title.contains('DAD')) return FontAwesomeIcons.laptopHouse;

    return isCustom ? FontAwesomeIcons.solidStar : FontAwesomeIcons.calendarDay;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showEventDetails(context),
        child: Stack(
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [yearColor.withOpacity(0.7), yearColor],
                ),
              ),
            ),

            // Decorative pattern in background
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                _getEventIcon(),
                size: 60,
                color: Colors.white.withOpacity(0.15),
              ),
            ),

            // Immagine di sfondo a pieno formato
            AspectRatio(
              aspectRatio: 0.8, // Controlla il rapporto d'aspetto della card
              child: Image.network(
                event.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: yearColor.withOpacity(0.1),
                    child: Center(
                      child: Icon(
                        _getEventIcon(),
                        color: yearColor.withOpacity(0.5),
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Overlay sfumato sulla parte inferiore per il testo
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.6, 0.8, 1.0],
                  ),
                ),
              ),
            ),

            // Icona in alto a destra
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getEventIcon(), color: Colors.white, size: 12),
              ),
            ),

            // Badge per eventi personalizzati
            if (isCustom)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.edit, size: 8, color: yearColor),
                ),
              ),

            // Badge aneddoti
            if (event.anecdotes.isNotEmpty)
              Positioned(
                bottom: 30,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FontAwesomeIcons.quoteLeft,
                        size: 6,
                        color: yearColor,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${event.anecdotes.length}',
                        style: GoogleFonts.poppins(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: yearColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Testo sovrapposto all'immagine nella parte inferiore
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Titolo
                    Text(
                      event.title,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: [
                          const Shadow(color: Colors.black, blurRadius: 2),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Data
                    Text(
                      event.date,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: Colors.white.withOpacity(0.9),
                        shadows: [
                          const Shadow(color: Colors.black, blurRadius: 2),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Pulsante elimina
            if (isCustom && onDelete != null)
              Positioned(
                right: 0,
                top: 0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onDelete!(),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      topRight: Radius.circular(16), // Match card radius
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.7),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          topRight: Radius.circular(16), // Match card radius
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showEventDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -5),
                  spreadRadius: 0.1,
                ),
              ],
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header con icona e titolo
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: yearColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Icon(
                                      _getEventIcon(),
                                      color: yearColor,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                event.title,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.3,
                                                  letterSpacing: -0.3,
                                                ),
                                              ),
                                            ),
                                            if (isCustom)
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  left: 8,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: yearColor.withOpacity(
                                                    0.1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                child: Text(
                                                  'Creato da me',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color: yearColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          event.date,
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey.shade600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 28),

                              // Immagine con effetto shadow
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    event.imageUrl,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 200,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: yearColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.image_not_supported,
                                              size: 50,
                                              color: yearColor.withOpacity(0.3),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              "Immagine non disponibile",
                                              style: GoogleFonts.poppins(
                                                color: yearColor.withOpacity(
                                                  0.7,
                                                ),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Descrizione completa con titolo
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: yearColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.description_outlined,
                                      color: yearColor,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Descrizione',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: yearColor,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  event.description,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: Colors.grey.shade800,
                                    height: 1.6,
                                  ),
                                ),
                              ),

                              // Contenuto aggiuntivo
                              if (event.additionalContent.isNotEmpty) ...[
                                const SizedBox(height: 28),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: yearColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.article_outlined,
                                        color: yearColor,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Note aggiuntive',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: yearColor,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: yearColor.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: yearColor.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    event.additionalContent,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color: Colors.grey.shade800,
                                      height: 1.6,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],

                              // Aneddoti
                              if (event.anecdotes.isNotEmpty) ...[
                                const SizedBox(height: 28),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: yearColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        FontAwesomeIcons.quoteLeft,
                                        color: yearColor,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Aneddoti',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: yearColor,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: yearColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${event.anecdotes.length}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: yearColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...event.anecdotes.map((anecdote) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 14),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white,
                                          Colors.grey.shade50,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: yearColor.withOpacity(0.08),
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(16),
                                                  topRight: Radius.circular(16),
                                                ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                FontAwesomeIcons.quoteLeft,
                                                size: 14,
                                                color: yearColor,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  anecdote.title,
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: yearColor
                                                        .withOpacity(0.9),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Text(
                                            anecdote.description,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: Colors.grey.shade700,
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],

                              // Galleria
                              if (event.additionalImages.isNotEmpty) ...[
                                const SizedBox(height: 28),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: yearColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.photo_library_outlined,
                                        color: yearColor,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Galleria',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: yearColor,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: yearColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${event.additionalImages.length}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: yearColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 1,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                  itemCount: event.additionalImages.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        _showFullScreenImage(
                                          context,
                                          event.additionalImages[index],
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.08,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              yearColor.withOpacity(0.7),
                                              yearColor,
                                            ],
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.network(
                                            event.additionalImages[index],
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Container(
                                                color: yearColor.withOpacity(
                                                  0.1,
                                                ),
                                                child: Icon(
                                                  Icons.broken_image,
                                                  color: yearColor.withOpacity(
                                                    0.3,
                                                  ),
                                                  size: 30,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],

                              // Pulsante elimina per eventi personalizzati
                              if (isCustom && onDelete != null) ...[
                                const SizedBox(height: 36),
                                Center(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.delete_outline),
                                    label: const Text('Elimina evento'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade600,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      textStyle: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(
                                        context,
                                      ); // Close bottom sheet first
                                      onDelete!(); // Call the delete function
                                    },
                                  ),
                                ),
                              ],

                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: 200,
                      color: Colors.black12,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.white60,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Immagine non disponibile",
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Implementazione delle classi di modello per la persistenza dei dati
class SchoolYear {
  final int yearNumber;
  final String title;
  final String academicYear;
  final String shortDescription;
  final String description;
  final String coverImageUrl;
  final List<SchoolEvent> events;

  SchoolYear({
    required this.yearNumber,
    required this.title,
    required this.academicYear,
    required this.shortDescription,
    required this.description,
    required this.coverImageUrl,
    required this.events,
  });
}

class SchoolEvent {
  final String title;
  final String date;
  final String description;
  final String imageUrl;
  final String additionalContent;
  final List<String> additionalImages;
  final List<Anecdote> anecdotes;

  SchoolEvent({
    required this.title,
    required this.date,
    required this.description,
    required this.imageUrl,
    this.additionalContent = '',
    this.additionalImages = const [],
    this.anecdotes = const [],
  });

  // Conversione da e verso JSON per la persistenza
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
      'description': description,
      'imageUrl': imageUrl,
      'additionalContent': additionalContent,
      'additionalImages': additionalImages,
      'anecdotes': anecdotes.map((a) => a.toJson()).toList(),
    };
  }

  factory SchoolEvent.fromJson(Map<String, dynamic> json) {
    return SchoolEvent(
      title: json['title'],
      date: json['date'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      additionalContent: json['additionalContent'] ?? '',
      additionalImages: List<String>.from(json['additionalImages'] ?? []),
      anecdotes:
          (json['anecdotes'] as List?)
              ?.map((a) => Anecdote.fromJson(a))
              .toList() ??
          [],
    );
  }
}

class Anecdote {
  final String title;
  final String description;

  Anecdote({required this.title, required this.description});

  // Conversione da e verso JSON per la persistenza
  Map<String, dynamic> toJson() {
    return {'title': title, 'description': description};
  }

  factory Anecdote.fromJson(Map<String, dynamic> json) {
    return Anecdote(title: json['title'], description: json['description']);
  }
}

// Classe di utilità per gestire la persistenza degli eventi
class EventStorage {
  static const String _keyPrefix = 'custom_events_';

  // Salva gli eventi personalizzati per un determinato anno
  static Future<void> saveCustomEvents(
    int yearNumber,
    List<SchoolEvent> events,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<String> encodedEvents =
        events.map((event) {
          return jsonEncode(event.toJson());
        }).toList();

    await prefs.setStringList('$_keyPrefix$yearNumber', encodedEvents);
  }

  // Carica gli eventi personalizzati per un determinato anno
  static Future<List<SchoolEvent>> loadCustomEvents(int yearNumber) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? savedEvents = prefs.getStringList(
      '$_keyPrefix$yearNumber',
    );

    if (savedEvents == null || savedEvents.isEmpty) {
      return [];
    }

    try {
      return savedEvents.map((eventJson) {
        final Map<String, dynamic> eventMap = jsonDecode(eventJson);
        return SchoolEvent.fromJson(eventMap);
      }).toList();
    } catch (e) {
      return []; // Return empty list on error
    }
  }

  // Elimina un evento personalizzato specifico
  static Future<void> deleteCustomEvent(
    int yearNumber,
    int customEventIndex, // Index within the customEvents list
    List<SchoolEvent> currentCustomEvents, // Pass the list to modify
  ) async {
    if (customEventIndex < 0 ||
        customEventIndex >= currentCustomEvents.length) {
      return;
    }

    currentCustomEvents.removeAt(
      customEventIndex,
    ); // Remove from the passed list

    // Save the modified list back to SharedPreferences
    await saveCustomEvents(yearNumber, currentCustomEvents);
  }

  // Ottieni il numero totale di eventi (predefiniti + personalizzati)
  static Future<int> getTotalEventCount(int yearNumber, int baseCount) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? customEvents = prefs.getStringList(
      '$_keyPrefix$yearNumber',
    );
    return (customEvents?.length ?? 0) + baseCount;
  }

  // Ripristina tutti gli eventi personalizzati (elimina tutto)
  static Future<void> clearAllCustomEvents() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Ottieni tutte le chiavi che iniziano con il prefisso degli eventi personalizzati
    final keys = prefs.getKeys().where((key) => key.startsWith(_keyPrefix));

    // Elimina tutte le chiavi trovate
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}

// Sample data for the school years - inserisci qui l'array schoolYears aggiornato
final List<SchoolYear> schoolYears = [
  SchoolYear(
    yearNumber: 1,
    title: 'Primo Anno',
    academicYear: '2019-2020',
    shortDescription: 'L\'inizio del nostro percorso insieme',
    description:
        'Il primo anno è stato un momento fondamentale per la nostra classe. Abbiamo acquisito le competenze base dell\'informatica e stabilito relazioni interpersonali significative, costruendo le fondamenta per un percorso formativo condiviso. L\'anno scolastico è stato caratterizzato dall\'imprevista emergenza sanitaria che ha portato all\'implementazione della didattica a distanza.',
    coverImageUrl: 'Immagini/1giorno.png',
    events: [
      SchoolEvent(
        title: 'Primo giorno di scuola',
        date: '12 settembre 2019',
        description:
            'Ci siamo ritrovati all\'ingresso dell\'istituto alla ricerca della nostra aula assegnata. Dopo un periodo di orientamento iniziale, una docente ci ha guidato verso la nostra classe. Sono seguiti i momenti di presentazione reciproca e l\'incontro con il corpo docente che ci avrebbe accompagnato nel percorso formativo.',
        imageUrl: 'Immagini/1giorno.png',
        additionalContent:
            'L\'impatto con il nuovo ambiente scolastico ha rappresentato un momento di transizione significativo, caratterizzato da un misto di aspettative e incertezze tipiche dell\'inizio di un nuovo ciclo di studi.',
        anecdotes: [
          Anecdote(
            title: 'La ricerca dell\'aula',
            description:
                'Alcuni studenti hanno avuto difficoltà a localizzare l\'aula corretta, confondendo il secondo piano con il terzo e trovandosi momentaneamente in aree non destinate agli alunni.',
          ),
          Anecdote(
            title: 'Il primo intervallo',
            description:
                'Durante la prima pausa didattica, il gruppo classe si è riunito nei corridoi, seguendo gli studenti degli anni superiori per familiarizzare con gli spazi comuni dell\'istituto.',
          ),
        ],
      ),
      SchoolEvent(
        title: 'La DAD (COVID-19)',
        date: '9 marzo 2020',
        description:
            'La transizione alla didattica a distanza ha rappresentato un cambiamento significativo nelle modalità di apprendimento. Nonostante le iniziali difficoltà, la classe ha dimostrato capacità di adattamento, sviluppando nuove competenze digitali e strategie di apprendimento autonomo.',
        imageUrl: 'Immagini/DAD.png',
        additionalContent:
            'L\'implementazione della didattica a distanza ha richiesto un processo di adattamento sia per gli studenti che per i docenti, comportando l\'utilizzo di nuove piattaforme digitali e metodologie didattiche innovative.',
        anecdotes: [
          Anecdote(
            title: 'Supporto in presenza',
            description:
                'Gli studenti con disturbi specifici dell\'apprendimento hanno continuato a frequentare l\'istituto in presenza, mentre il resto della classe seguiva le lezioni da remoto, creando un\'esperienza educativa ibrida.',
          ),
        ],
      ),
      SchoolEvent(
        title: 'Ritorno a scuola',
        date: '14 settembre 2020',
        description:
            'Il rientro in aula è stato caratterizzato da grande entusiasmo, nonostante l\'obbligo di indossare dispositivi di protezione individuale. Il ritorno all\'esperienza scolastica in presenza ha rivitalizzato l\'ambiente di apprendimento e le dinamiche relazionali tra studenti.',
        imageUrl: 'Immagini/ritorno.png',
        additionalContent:
            'La ripresa delle attività in presenza ha comportato l\'adozione di nuovi protocolli di sicurezza che hanno modificato le consuete modalità di interazione, pur permettendo un graduale ritorno alla normalità didattica.',
        anecdotes: [
          Anecdote(
            title: 'Protocolli di sicurezza',
            description:
                'Durante le lezioni di laboratorio di chimica, il rispetto dei protocolli di sicurezza relativi all\'uso delle mascherine era particolarmente rigoroso, generando occasionali tensioni con i docenti in caso di non conformità.',
          ),
        ],
      ),
      SchoolEvent(
        title: 'Microfoni e videocamere',
        date: '20 novembre 2020',
        description:
            'La gestione degli strumenti di comunicazione digitale ha rappresentato una sfida quotidiana durante la didattica a distanza. Problematiche tecniche relative a microfoni e videocamere hanno influenzato la qualità dell\'interazione didattica, richiedendo adattamenti continui da parte di docenti e studenti.',
        imageUrl: 'Immagini/dadcaos.png',
        additionalContent:
            'La richiesta di mantenere attive le videocamere è diventata una costante nelle comunicazioni dei docenti, mentre gli studenti hanno dovuto confrontarsi con varie difficoltà tecniche, reali o talvolta addotte come giustificazione.',
        anecdotes: [
          Anecdote(
            title: 'Distrazioni digitali',
            description:
                'La disattivazione dei dispositivi audiovisivi ha talvolta permesso agli studenti di dedicarsi ad attività ricreative durante le lezioni, compromettendo l\'efficacia del processo di apprendimento.',
          ),
          Anecdote(
            title: 'Simulazione di problemi tecnici',
            description:
                'L\'attivazione e disattivazione rapida dei microfoni veniva talvolta utilizzata per simulare problemi di connessione, specialmente in prossimità di verifiche orali non programmate.',
          ),
        ],
      ),
      SchoolEvent(
        title: 'Verifiche online',
        date: '15 dicembre 2020',
        description:
            'Le valutazioni a distanza hanno rappresentato una sfida metodologica significativa. I docenti hanno implementato diverse strategie di controllo e modalità di verifica, adattando gli strumenti valutativi al contesto digitale.',
        imageUrl: 'Immagini/verifiche].png',
        additionalContent:
            'Le metodologie di valutazione hanno subito una necessaria evoluzione, con l\'introduzione di tempistiche ridotte, domande casualizzate e requisiti specifici per il posizionamento dei dispositivi di ripresa durante le prove.',
        anecdotes: [
          Anecdote(
            title: 'Valutazioni in chimica',
            description:
                'Nonostante il contesto di apprendimento modificato, le verifiche di chimica hanno mantenuto un elevato livello di complessità, risultando in valutazioni insufficienti per diversi studenti.',
          ),
        ],
      ),
      SchoolEvent(
        title: 'Prima cogestione',
        date: '22 gennaio 2020',
        description:
            'La prima esperienza di cogestione, sebbene non particolarmente memorabile, ha rappresentato un\'importante novità nel percorso formativo, offrendo l\'opportunità di sperimentare modalità di apprendimento alternative rispetto alla didattica tradizionale.',
        imageUrl: 'Immagini/Cogestione.png',
        additionalContent:
            'L\'evento ha permesso l\'esplorazione di interessi e tematiche non incluse nel curriculum standard, favorendo lo sviluppo di competenze trasversali e l\'espressione di talenti individuali in contesti non convenzionali.',
        anecdotes: [
          Anecdote(
            title: 'Pause durante il dj set',
            description:
                'Mi ricordo ancora gli studenti che uscivano a prendere aria durante il dj set, creando un continuo via vai che ha caratterizzato questo primo evento di cogestione.',
          ),
        ],
      ),
    ],
  ),
  SchoolYear(
    yearNumber: 2,
    title: 'Secondo Anno',
    academicYear: '2020-2021',
    shortDescription: 'Approfondimento e nuove sfide',
    description:
        'Il secondo anno è stato segnato dalla didattica a distanza, ma nonostante questo abbiamo continuato a crescere e imparare insieme, affrontando nuove sfide e approfondendo le nostre conoscenze nel campo dell\'informatica. Nuove amicizie si sono formate e abbiamo vissuto esperienze indimenticabili nonostante il periodo difficile.',
    coverImageUrl: 'Immagini/dsaSong.png',
    events: [
      SchoolEvent(
        title: 'Primo giorno di seconda',
        date: '14 settembre 2020',
        description:
            'Il primo giorno di seconda ha portato con sé molte novità: nuovi compagni di classe, nuovi insegnanti e nuove materie. Dopo un\'estate di restrizioni, tornavamo a scuola con grandi aspettative ma anche con le dovute precauzioni sanitarie.',
        imageUrl: 'Immagini/dad1.png',
        additionalContent:
            'Quel giorno abbiamo conosciuto alcuni nuovi compagni che si sono uniti alla nostra classe. Il mix di facce familiari e nuove ha creato un\'atmosfera di curiosità e di nuove opportunità. Nonostante le mascherine e il distanziamento, si percepiva l\'entusiasmo di iniziare un nuovo anno insieme.',
        anecdotes: [
          Anecdote(
            title: 'L\'impatto con i nuovi',
            description:
                'I nuovi compagni sembravano un po\' intimiditi all\'inizio, ma dopo una settimana era come se fossero sempre stati con noi. In particolare uno di loro ha subito fatto amicizia con tutti raccontando le sue disavventure nella scuola precedente.',
          ),
        ],
      ),
      SchoolEvent(
        title: 'Cibo gratis dalle macchinette',
        date: 'Ottobre 2020',
        description:
            'Il secondo anno è stato folle. Si sono diffuse le chiavette craccate, quindi le macchinette erano assaltate da tutti...specialmente da PLebani.',
        imageUrl: 'Immagini/macchinette1.png',
        additionalContent:
            'I tecnici delle macchinette sono arrivati solo nel pomeriggio, dopo che ormai erano state quasi completamente svuotate. Il giorno dopo sono state introdotte nuove regole per l\'utilizzo delle macchinette, ma nessuno è stato ritenuto responsabile per l\'accaduto.',
        anecdotes: [
          Anecdote(
            title: 'Il Giovedì sacro',
            description:
                'Il Giovedì era il giorno del refill delle chiavette alle macchinette, quindi bisognava andare a prenderle per craccarle. Un vero e proprio business.',
          ),
          Anecdote(
            title: 'Plebani e le macchinette',
            description:
                'Crazy come ogni mattine entravamo in classe e trovavamo Plebani e fare colazione con patatine, kinder maxi e coca cola.',
          ),
        ],
      ),
      SchoolEvent(
        title: 'La Canzone DSA',
        date: '3 dicembre 2020',
        description:
            'Durante un progetto di sensibilizzazione sui Disturbi Specifici dell\'Apprendimento, alcuni di noi hanno creato una canzone rap dedicata ai DSA. È diventata rapidamente un inno per la classe, evidenziando l\'importanza dell\'inclusione e della comprensione delle diverse modalità di apprendimento.',
        imageUrl: 'Immagini/dsaSong.png',
        additionalContent:
            'La canzone "DSA BIG SONG" era un progetto di matematica. È stata veramente una chicca di questa classe.',
        anecdotes: [
          Anecdote(
            title: 'Il ritornello orecchiabile',
            description:
                '"Ho la disgrafia, discalculia e dislessia, non ho fatto un mix è solo vita mia" - questo ritornello lo cantavamo spesso, diventando un modo per sdrammatizzare le difficoltà quotidiane.',
          ),
        ],
        additionalImages: ['https://picsum.photos/id/96/1000/600'],
      ),
      SchoolEvent(
        title: 'Le note disciplinari',
        date: '15 gennaio 2021',
        description:
            'Il secondo anno, con Guerini e Garbarino in classe, è stato veramente folle.',
        imageUrl: 'Immagini/garbarino.png',
        additionalContent: '',
        anecdotes: [
          Anecdote(
            title: 'La penna sul muro',
            description:
                'Avevamo una nota di classe perché Garba aveva appiccicato una penna al muro...è un mondo folle.',
          ),
          Anecdote(
            title: 'L alunno Begni pasteggia durante la lezione.',
            description:
                'Questa è la nota più crazy. La professoressa Espinosa ha messo una nota a Begni perché mangiava 5 minuti prima dell intervallo...e facevamo 7 ore quel giorno. Non cè più rispetto.',
          ),
        ],
      ),
      SchoolEvent(
        title: 'Rampinelli e la LIM magica',
        date: '3 giugno 2021',
        description: 'Rampinelli che spegne la lim con la Ciuni.',
        imageUrl: 'Immagini/rampinelliLim.png',
        additionalContent:
            'Solo verso la fine dell\'anno abbiamo scoperto che usava un\'app per controllare i dispositivi della rete scolastica.',
        anecdotes: [
          Anecdote(
            title: 'L app della epson.',
            description:
                'Aveva finto di andare a parlare comn Plebani, e aveva usato l app della Epson per spegnere la lim. Alla fine la Ciuni ha messo una nota di classe.',
          ),
        ],
      ),
    ],
  ),
  SchoolYear(
    yearNumber: 3,
    title: 'Terzo Anno',
    academicYear: '2021-2022',
    shortDescription: 'Specializzazione e crescita',
    description:
        'Il terzo anno ha segnato l\'inizio della nostra specializzazione in informatica. Abbiamo iniziato a studiare programmazione avanzata, database e reti, gettando le basi per il nostro futuro professionale. Un anno di cambiamenti, nuove sfide e anche qualche momento di tensione che ha messo alla prova la nostra coesione come gruppo classe.',
    coverImageUrl: 'Immagini/3.4.png',
    events: [
      SchoolEvent(
        title: 'Nuovi professori',
        date: '13 settembre 2021',
        description:
            'L\'inizio del terzo anno ha portato diversi cambiamenti nel corpo docente. Abbiamo conosciuto nuovi professori specializzati nelle materie di indirizzo che ci avrebbero accompagnato fino alla maturità. Il loro approccio più professionale e orientato al mondo del lavoro ci ha fatto capire che stavamo entrando nella fase più importante del nostro percorso.',
        imageUrl: 'Immagini/3.png',
        additionalContent:
            'L\'impatto con i nuovi professori è stato significativo: alcuni di loro provenivano direttamente dal mondo dell\'industria IT e portavano in classe esperienze concrete e aggiornate. Questo ha dato un taglio più pratico alle lezioni e ci ha fatto comprendere meglio le applicazioni reali di ciò che stavamo studiando.',
        anecdotes: [
          Anecdote(
            title: 'La domanda rivelatrice',
            description:
                'Durante la prima lezione, un nuovo professore ci ha chiesto chi di noi aveva scelto l\'indirizzo di informatica con la voglia di continuare su questa strada o chi aveva scelto a caso. Metà di noi avevano risposto "scelta a caso".',
          ),
        ],
      ),
      SchoolEvent(
        title: 'Panico per la polizia cinofila',
        date: '22 novembre 2021',
        description:
            'La visita a sorpresa della polizia cinofila a scuola ha creato un momento di tensione. Sebbene si trattasse di un controllo di routine, l\'arrivo degli agenti con i cani ha generato un improvviso nervosismo tra gli studenti, e non solo tra quelli con la coscienza sporca. L\'episodio ha dato vita a innumerevoli storie, alcune vere e molte inventate.',
        imageUrl: 'Immagini/3.1.png',
        additionalContent:
            'I controlli si sono svolti in modo professionale e discreto, ma l\'evento ha comunque scatenato una serie di riflessioni sul tema delle sostanze e della responsabilità personale. La scuola ha colto l\'occasione per organizzare alcuni incontri formativi sulla prevenzione.',
        anecdotes: [
          Anecdote(
            title: 'La fuga in bagno',
            description:
                'In due avevano chiesto di andare in bagno appena avevamo visto la polizia cinofila fuori dalla scuola.',
          ),
        ],
      ),
      SchoolEvent(
        title: 'Il video del prof Masserini',
        date: '15 febbraio 2022',
        description:
            'Il professor Masserini durante le lezioni metteva sempre i suoi video che aveva fatto lui dove spiegava, e durante la lezione lui stava seduto.',
        imageUrl: 'Immagini/3.2.png',
        additionalContent:
            'Il successo del video ha ispirato altri professori a sperimentare con nuovi formati didattici, portando a una generale modernizzazione degli approcci all\'insegnamento nella nostra scuola. Per noi studenti, è stato un momento di orgoglio vedere il nostro professore riconosciuto per la sua innovazione.',
        anecdotes: [
          Anecdote(
            title: 'Le lezioni interminabili',
            description:
                'Le lezioni non passavano ed erano noiose perché senza che un prof non spiega dal vivo, le lezioni diventavano noiose e metà di noi dormivano.',
          ),
        ],
        additionalImages: ['https://picsum.photos/id/250/1000/600'],
      ),
      SchoolEvent(
        title: 'Perdita dei compagni',
        date: '8 giugno 2022',
        description:
            'Alcuni compagni sono stati bocciati, segnando un cambiamento nel nostro gruppo classe.',
        imageUrl: 'Immagini/3.3.png',
        additionalContent:
            'La perdita di questi compagni ci ha fatto riflettere su quanto fossimo diventati uniti come classe nei tre anni trascorsi insieme.',
        anecdotes: [
          Anecdote(
            title: 'Guerini ci mancherà',
            description:
                'Ci mancherà per tutte le sue stronzate che ha fatto tra litigate con le prof.',
          ),
        ],
      ),
    ],
  ),
  SchoolYear(
    yearNumber: 4,
    title: 'Quarto Anno',
    academicYear: '2022-2023',
    shortDescription: 'Progetti e crescente autonomia',
    description:
        'Il quarto anno è stato caratterizzato da progetti sempre più complessi e da una crescente autonomia. È stato un anno in cui abbiamo visto i primi frutti del nostro studio, ma anche un anno molto faticoso per la quantità di progetti, molto più impegnativi rispetto agli anni precedenti. Abbiamo iniziato a collaborare con aziende esterne e a sviluppare applicazioni reali, mettendo in pratica tutto ciò che avevamo imparato fino a quel momento. Questa esperienza ci ha permesso di crescere sia a livello tecnico che personale, preparandoci alle sfide future con maggiore consapevolezza e determinazione.',
    coverImageUrl: 'Immagini/primo.png',
    events: [
      SchoolEvent(
        title: 'Gita a Napoli',
        date: '18 ottobre 2022',
        description:
            'Il viaggio d\'istruzione a Napoli è stato uno dei momenti più attesi e memorabili dell\'anno. Abbiamo visitato siti archeologici come Pompei ed Ercolano, esplorato il centro storico di Napoli e gustato l\'autentica cucina campana. Ma soprattutto, abbiamo rafforzato i legami tra noi, creando ricordi che durano nel tempo. I momenti più divertenti della nostra classe sono nati proprio in questa esperienza: tra battute, scherzi e situazioni inaspettate, abbiamo scoperto nuovi lati dei nostri compagni e legato ancora di più come gruppo.',
        imageUrl: 'Immagini/sec.png',
        additionalContent:
            'Questa gita non è stata solo un\'opportunità per conoscere meglio la storia e la cultura del luogo, ma anche per conoscere meglio noi stessi. La gita ha combinato aspetti culturali ed educativi con momenti di divertimento e relax. I professori accompagnatori ci hanno dato più libertà rispetto alle gite precedenti, dimostrando fiducia nella nostra maturità.',
        anecdotes: [],
      ),
      SchoolEvent(
        title: 'Il progetto delle radio',
        date: '15 dicembre 2022',
        description:
            'In questo progetto abbiamo lavorato con un\'API esistente che raccoglie tutte le radio del mondo, un\'idea affascinante ma allo stesso tempo una sfida tecnica non indifferente. Non avevamo mai affrontato un\'API così complessa, e inoltre abbiamo deciso di sviluppare il progetto con Vue.js, un framework che stavamo ancora esplorando. Due studenti si sono dedicati in particolare a questo progetto, portando i nostri siti a un livello molto più avanzato.',
        imageUrl: 'Immagini/terz.png',
        additionalContent:
            'Questa esperienza ci ha permesso di migliorare la nostra capacità di interagire con dati esterni, gestire richieste API in modo efficiente e ottimizzare il funzionamento dei nostri siti web. Dopo molte ore di lavoro, debugging e prove, siamo riusciti a ottenere un risultato solido che ha migliorato il nostro livello di sviluppo. Il successo di questo progetto ha ispirato molti di noi a pensare in modo più ambizioso ai nostri lavori.',
        anecdotes: [],
      ),
      SchoolEvent(
        title: 'Stage in azienda',
        date: '6 febbraio 2023',
        description:
            'Il periodo di stage presso aziende informatiche locali è stato fondamentale per applicare in un contesto reale le competenze acquisite a scuola. Ognuno di noi è stato assegnato a un\'azienda diversa, dalle startup innovative alle realtà più consolidate, permettendoci di esplorare diversi ambienti lavorativi e culture aziendali.',
        imageUrl: 'Immagini/quart.png',
        additionalContent:
            'Questa esperienza non solo ci ha permesso di conoscerci meglio e capire come funziona davvero il mondo del lavoro, ma ci ha anche dato un primo assaggio di quello che vogliamo fare nella nostra vita. Abbiamo iniziato a riflettere su quali percorsi universitari o professionali potrebbero essere più adatti a noi. Sicuramente la strada da percorrere è ancora lunga, ma questo è stato un primo passo fondamentale per capirlo. Un\'esperienza unica che nessuno di noi aveva mai vissuto prima.',
        anecdotes: [],
      ),
      SchoolEvent(
        title: 'Progetto del drone',
        date: '18 marzo 2023',
        description:
            'Il progetto interdisciplinare del drone ha coinvolto diverse materie tecniche e ha rappresentato la sfida più complessa affrontata fino a quel momento. Abbiamo progettato, costruito e programmato un drone in grado di eseguire missioni di monitoraggio ambientale, integrando conoscenze di elettronica, informatica e fisica.',
        imageUrl: 'Immagini/quin.png',
        additionalContent:
            'Questo è stato un vero lavoro di squadra, dove ognuno ha dato il proprio contributo con competenze specifiche. Il progetto ha poi partecipato a un evento organizzato da un\'azienda chiamata Sorint, ottenendo ottimi risultati. Anche il resto della classe, pur non essendo direttamente coinvolto, ha supportato il team, facendo il tifo affinché il progetto vincesse.',
        anecdotes: [],
      ),
      SchoolEvent(
        title: 'Incidente Rampinelli',
        date: '20 maggio 2023',
        description:
            'L\'incidente che ha coinvolto il nostro compagno Rampinelli è stato un vero shock per tutti. All\'inizio nessuno riusciva a crederci, ma poi la notizia si è diffusa rapidamente. È stata la prima volta che vedevamo qualcosa del genere finire sulle pagine del giornale locale L\'Eco di Bergamo: la prima notizia riportava che Rampinelli era stato ricoverato in terapia intensiva.',
        imageUrl: 'Immagini/sei.png',
        additionalContent:
            'Eravamo estremamente preoccupati per la sua situazione, tanto che i professori hanno deciso di contattare i genitori per darci aggiornamenti sul suo stato di salute. È stato un momento di grande ansia e paura, ma anche un episodio che ha rafforzato il senso di comunità tra di noi.',
        anecdotes: [],
      ),
      SchoolEvent(
        title: 'Il progetto su Eulero della 4IC',
        date: 'Aprile 2024',
        description:
            'Un’attività didattica creativa organizzata dalla classe 4IC per far conoscere la vita e le teorie del matematico Leonhard Euler. Ogni gruppo ha realizzato mini-giochi e quiz ispirati alla sua storia e alle sue scoperte. Al termine di ogni prova, gli studenti ospiti ricevevano una lettera per formare una parola segreta.',
        imageUrl: 'Immagini/eu.png',
        additionalContent:
            'L’intero progetto si è svolto con entusiasmo e grande spirito di collaborazione. Abbiamo guidato le altre classi tra giochi, enigmi matematici e racconti storici, rendendo l’apprendimento coinvolgente e interattivo. Ogni gruppo ospite aveva una parola diversa da scoprire e doveva completare tutte le prove per riuscirci. È stata un’esperienza di successo, che ha mostrato la nostra creatività e il nostro impegno.',
        anecdotes: [
          Anecdote(
            title: 'La sfida delle parole segrete',
            description:
                'Durante le attività, alcuni gruppi cercavano di indovinare la parola finale con poche lettere, ma ogni tappa era fondamentale. Questo ha reso il gioco ancora più divertente e competitivo.',
          ),
        ],
        additionalImages: [
          'Immagini/eu1.',
          'Immagini/eu2.jpg',
          'Immagini/eu3.jpg',
          'Immagini/eu4.jpg',
          'Immagini/eu5.png',
        ],
      ),
    ],
  ),
  SchoolYear(
    yearNumber: 5,
    title: 'Quinto Anno',
    academicYear: '2024-2025',
    shortDescription: 'La consapevolezza di doverci salutare',
    description:
        'Il quinto anno è stato incentrato sulla preparazione all\'esame e sulla definizione del nostro futuro. Abbiamo messo a frutto tutto ciò che abbiamo imparato nei quattro anni precedenti. Un anno di riflessioni, scelte importanti e momenti di svago per alleggerire la pressione degli esami imminenti.',
    coverImageUrl: 'Immagini/img1.png',
    events: [
      SchoolEvent(
        title: 'Ricordi dei caduti',
        date: '2024/2024',
        description:
            'Durante tutto l\' anno non sono mancati cenni ai ricordi dei nostri vecchi compagni, che purtroppo non ce l\' hanno fatta e non sono qui con noi a celebrare la fine del nostro percorso insieme.',
        imageUrl: 'Immagini/img1.png',
        additionalContent:
            'Molti di noi perirono, ma il loro onore vivrà sempre nei nostri cuori.',
        anecdotes: [],
      ),
      SchoolEvent(
        title: 'Terrorismo psicologico per l\'esame',
        date: '2024/2025',
        description:
            'Il clima è stato chill fino a fine Marzo, periodo in cui ci hanno sommerso di verifiche e interrogazioni...sembrava tutto troppo facile',
        imageUrl: 'Immagini/img2.png',
        additionalContent:
            'Bomboklat tutti i professori ci continuano a dire che non siamo per niente preparati, ma siamo i maestri con l\'arte dell\'arrangiarsi: ce la faremo come sempre!',
      ),
      SchoolEvent(
        title: 'Macchinette vuote',
        date: 'Febbraio 2025',
        description:
            'Qualcuno ha sofferto di questa mancanza, qualcun altro, invece, ne ha approfittato per darci dentro con la dieta...forse rischiando di svenire',
        imageUrl: 'Immagini/quintaanno5.png',
        additionalContent:
            'C\'è chi ha contato ogni snack mancante come una tragedia, e chi ha visto nell\'emergenza una scusa perfetta per iniziare la “vita sana”... anche se qualcuno ha rischiato il crollo tra una lezione e l\'altra!',
        anecdotes: [],
      ),
      SchoolEvent(
        title: 'Discoteca a Barcellona',
        date: '27 Febbraio 2025',
        description:
            'Che sfaso il Pacha: 5 di noi sono sgattaiolati fuori dall\'hotel a mezzanotte durante la gita a Barcellona per andare al Pacha: eh niente alla fine sono stati beccati malissimo...anche se non sia sa precisamente come.',
        imageUrl: 'Immagini/img4.png',
        additionalContent:
            'La situa sembrava seria: furtivi come non so cosa (tranne Edo che ha svegliato mezza Barcellona per chiamare il Rampi), pali potentissimi di Rimpi e Rampi, il ritorno in Uber, e il biliardo post-disco. Poi il rischio della sospensione, e infine i sabati pomeriggio a spostare bottiglie di plastica. Follia.',
        anecdotes: [
          Anecdote(
            title: 'Sotto controllo come dei carcerati',
            description:
                'Avevamo l\'ingresso gratis fino all\' 1.30, però non potevamo uscire perché le professoresse pattugliavano il corridoio come dei pali...è stato crazy',
          ),
        ],
      ),
      SchoolEvent(
        title: 'CHATONEEEEEE',
        date: '2024-2025',
        description:
            'Chattone fa miracoli: è diventato lo slogan del 2025, anno in cui abbiamo deciso di cedere il grosso del nostro lavoro a lui. Una Ferrari va domata, e a noi toccherà essere i piloti di questo strumento...ecco svelato perché lo usiamo così tanto in verifica.',
        imageUrl: 'Immagini/img5.png',
        anecdotes: [
          Anecdote(
            title: 'MIFTAR e Chattone',
            description:
                'Best coppia dell\' anno all\' Esperia è stata quella di Miftar e Chattone: oggi ha cucinato dice sempre il Miftar, roba che il Galli gli sniffa i piedi',
          ),
        ],
      ),
      SchoolEvent(
        title: 'MIFTAR',
        date: '2022-2025',
        description:
            'Eh niente, lui è Miftar. È noto per la scintilla con la bidella, però costa 6 di elisi quindi è balzato tutto. Gli è andata bene con la relazione con chattone invece, che probabilmente andrà in pensione appena Miftar si sarà diplomato.',
        imageUrl: 'Immagini/img6.png',
        additionalContent:
            'Povero Miftar, 2 settimane affianco a Rampi durate il Ramadan...questa è una dimostrazione di grande determinazione e devozione per Allah.',
        additionalImages: ['https://picsum.photos/id/122/1000/600'],
      ),
    ],
  ),
  SchoolYear(
    yearNumber: 6,
    title: '100 giorni dopo la scuola',
    academicYear: '2024',
    shortDescription: 'Nuovi inizi e nostalgia',
    description:
        'Cento giorni dopo la fine del Paleocapa. Cento giorni in cui abbiamo iniziato a scrivere nuove pagine lontani dai banchi, ma con gli stessi sogni e battiti nel cuore. C’è chi è finito tra i libri universitari e chi tra le righe di un contratto di lavoro, ma tutti abbiamo capito una cosa: eravamo più pronti di quanto pensassimo. La scuola è finita, ma non il legame. E infatti… eccoci di nuovo insieme, come se il tempo si fosse fermato solo per noi. Playlist nostalgiche, abbracci veri, e qualche prof che spunta a sorpresa: è stato tutto magico. Forse non torneremo più a scuola, ma una cosa è certa — ci porteremo sempre dentro la classe più pazza, affiatata e rumorosa del Paleocapa.',
    coverImageUrl: 'Immagini/6.png',
    events: [
      SchoolEvent(
        title: 'Risultati dell\'esame di maturità',
        date: '15 luglio 2024',
        description:
            'La notifica è arrivata alle prime luci del mattino: cuori a mille, dita tremanti e occhi sgranati. I risultati dell’esame di maturità ci hanno colpito come un’onda di emozioni miste: gioia, orgoglio, lacrime di sollievo e messaggi vocali da cinque minuti. Ce l’abbiamo fatta. Per davvero. Il Paleocapa è ufficialmente parte del nostro passato... e di noi.',

        imageUrl: 'Immagini/risultati.png',
      ),
      SchoolEvent(
        title: 'Festa di diploma',
        date: '20 luglio 2024',
        description:
            'Ci siamo vestiti bene, ma dentro eravamo gli stessi di sempre. La festa di diploma è stata un uragano di emozioni, selfie, brindisi e balli un po’ goffi ma pieni di cuore. Abbiamo ballato sul nostro passato e brindato al nostro futuro. Una serata che non dimenticheremo mai, dove il Paleocapa non era solo una scuola… ma una famiglia.',

        imageUrl: 'Immagini/diplom.png',
      ),
      SchoolEvent(
        title: 'Iscrizioni universitarie',
        date: '10 settembre 2024',
        description:
            'Zaini nuovi, città nuove, ansie nuove… ma sempre con lo stesso spirito. Le iscrizioni universitarie sono state un altro salto nel buio, ma ormai sappiamo come si fa. Tra chi ha scelto informatica, medicina o lingue, c’è stato un solo pensiero comune: "Sarò all’altezza?". La risposta, ce la siamo data da soli: certo che sì.',

        imageUrl: 'Immagini/Iscrizioni.png',
      ),
      SchoolEvent(
        title: 'Primo lavoro',
        date: '15 settembre 2024',
        description:
            'Dalla teoria alla pratica, dal banco alla scrivania. Il primo lavoro è arrivato per alcuni come una sorpresa, per altri come un sogno realizzato. È iniziato tutto con un badge, un monitor e un caffè d’ufficio. Ma dietro, c’eravamo noi: con la voglia di imparare e di lasciare il segno. È ufficiale: siamo entrati nel mondo dei grandi.',

        imageUrl: 'Immagini/Primolavoro.png',
        additionalContent:
            'Caffè, codice e tante prime volte: la prima mail seria, il primo errore da correggere, il primo collega che ti chiama "giovane". Abbiamo capito che non è più un gioco… ma anche che siamo pronti a farlo sul serio.',

        anecdotes: [
          Anecdote(
            title: 'Bug da panico',
            description:
                'Uno di noi ha cancellato per sbaglio metà database al primo giorno. Per fortuna c’era il backup... e un team paziente!',
          ),
        ],
      ),

      SchoolEvent(
        title: 'Reunion',
        date: '10 ottobre 2024',
        description:
            'Cento giorni dopo l’esame, ci siamo guardati negli occhi e ci siamo riconosciuti. La reunion è stata come tornare in aula, ma senza campanella. Tra battute, “ti ricordi quando...?” e playlist di classe, abbiamo capito che il tempo passa, ma certe connessioni no. Eravamo diversi, ma ancora perfettamente noi.',

        imageUrl: 'Immagini/Reunion.png',
        additionalContent:
            'Tra battute, abbracci e "ti ricordi quando...?", abbiamo sentito che qualcosa è cambiato... ma il legame tra noi è rimasto intatto.',

        anecdotes: [
          Anecdote(
            title: 'La playlist del Paleocapa',
            description:
                'Qualcuno ha messo su una playlist con tutte le canzoni che ascoltavamo in classe. Impossibile non cantare a squarciagola.',
          ),
          Anecdote(
            title: 'La prof in incognito',
            description:
                'Una nostra prof ci ha raggiunto a sorpresa per un saluto. È rimasta a cena con noi: serata assurda!',
          ),
        ],
      ),
    ],
  ),
];
