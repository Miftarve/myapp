import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:myapp/results_screen.dart';

class PartitaScreen extends StatefulWidget {
  final Map homeTeam;
  final Map awayTeam;
  final List allTeams; // Aggiungi questo parametro per passare tutte le squadre

  PartitaScreen(this.homeTeam, this.awayTeam, {required this.allTeams});

  @override
  _PartitaScreenState createState() => _PartitaScreenState();
}

class _PartitaScreenState extends State<PartitaScreen> {
  int homeScore = 0;
  int awayScore = 0;
  int currentMinute = 0;
  bool isMatchStarted = false;
  bool isMatchEnded = false;
  List<GameEvent> events = [];
  Timer? gameTimer;
  final Random random = Random();

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  void startMatch() {
    setState(() {
      isMatchStarted = true;
      events.add(
        GameEvent(
          minute: 0,
          eventType: EventType.kickOff,
          teamName: widget.homeTeam['team']['name'],
        ),
      );
    });

    // Timer che aggiorna il tempo di gioco e genera eventi
    gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (currentMinute >= 90) {
        endMatch();
        return;
      }

      setState(() {
        currentMinute += 1;
      });

      // Possibilità di generare eventi durante la partita
      if (random.nextInt(10) < 2) {
        // 20% chance per minute
        generateRandomEvent();
      }
    });
  }

  void endMatch() {
    gameTimer?.cancel();
    setState(() {
      isMatchEnded = true;
      events.add(
        GameEvent(minute: 90, eventType: EventType.finalWhistle, teamName: ""),
      );
    });
  }

  void generateRandomEvent() {
    // Decide quale squadra genera l'evento (50/50)
    bool isHomeTeam = random.nextBool();
    String teamName =
        isHomeTeam
            ? widget.homeTeam['team']['name']
            : widget.awayTeam['team']['name'];

    // Possibili eventi
    int eventChance = random.nextInt(100);

    if (eventChance < 10) {
      // Gol (10% degli eventi)
      setState(() {
        if (isHomeTeam) {
          homeScore += 1;
        } else {
          awayScore += 1;
        }
        events.add(
          GameEvent(
            minute: currentMinute,
            eventType: EventType.goal,
            teamName: teamName,
          ),
        );
      });
    } else if (eventChance < 25) {
      // Tiro in porta (15% degli eventi)
      setState(() {
        events.add(
          GameEvent(
            minute: currentMinute,
            eventType: EventType.shot,
            teamName: teamName,
          ),
        );
      });
    } else if (eventChance < 45) {
      // Calcio d'angolo (20% degli eventi)
      setState(() {
        events.add(
          GameEvent(
            minute: currentMinute,
            eventType: EventType.corner,
            teamName: teamName,
          ),
        );
      });
    } else if (eventChance < 75) {
      // Fallo (30% degli eventi)
      setState(() {
        events.add(
          GameEvent(
            minute: currentMinute,
            eventType: EventType.foul,
            teamName: teamName,
          ),
        );
      });
    } else if (eventChance < 85) {
      // Cartellino giallo (10% degli eventi)
      setState(() {
        events.add(
          GameEvent(
            minute: currentMinute,
            eventType: EventType.yellowCard,
            teamName: teamName,
          ),
        );
      });
    } else if (eventChance < 88) {
      // Cartellino rosso (3% degli eventi)
      setState(() {
        events.add(
          GameEvent(
            minute: currentMinute,
            eventType: EventType.redCard,
            teamName: teamName,
          ),
        );
      });
    } else {
      // Fuorigioco (12% degli eventi)
      setState(() {
        events.add(
          GameEvent(
            minute: currentMinute,
            eventType: EventType.offside,
            teamName: teamName,
          ),
        );
      });
    }
  }

  void viewLeagueResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => RisultatiCampionatoScreen(
              teams: widget.allTeams,
              homeTeam: widget.homeTeam,
              awayTeam: widget.awayTeam,
              homeScore: homeScore,
              awayScore: awayScore,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Partita"), centerTitle: true),
      body: Column(
        children: [
          // Scoreboard
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.blue.shade800,
            child: Column(
              children: [
                Text(
                  isMatchEnded
                      ? "PARTITA TERMINATA"
                      : isMatchStarted
                      ? "$currentMinute'"
                      : "PRONTO",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Image.network(
                          widget.homeTeam['team']['logo'],
                          width: 60,
                          height: 60,
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.homeTeam['team']['name'],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "$homeScore - $awayScore",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                    Column(
                      children: [
                        Image.network(
                          widget.awayTeam['team']['logo'],
                          width: 60,
                          height: 60,
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.awayTeam['team']['name'],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Match controls
          if (!isMatchStarted && !isMatchEnded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                child: Text("Inizia Partita"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                onPressed: startMatch,
              ),
            ),

          // Match events feed
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: ListView.builder(
                padding: EdgeInsets.all(8.0),
                itemCount: events.length,
                reverse: true, // Most recent events at the top
                itemBuilder: (context, index) {
                  final event = events[events.length - 1 - index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          "${event.minute}'",
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(_getEventDescription(event)),
                      trailing: _getEventIcon(event.eventType),
                    ),
                  );
                },
              ),
            ),
          ),

          // Match statistics (can be expanded in a future update)
          if (isMatchEnded)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey.shade200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Risultato finale: " +
                        (homeScore > awayScore
                            ? "Vittoria ${widget.homeTeam['team']['name']}"
                            : homeScore < awayScore
                            ? "Vittoria ${widget.awayTeam['team']['name']}"
                            : "Pareggio"),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        child: Text("Torna alla selezione"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      ElevatedButton(
                        child: Text("Visualizza Risultati Campionato"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: viewLeagueResults,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Icon _getEventIcon(EventType type) {
    switch (type) {
      case EventType.goal:
        return Icon(Icons.sports_soccer, color: Colors.green);
      case EventType.shot:
        return Icon(Icons.sports, color: Colors.orange);
      case EventType.corner:
        return Icon(Icons.flag, color: Colors.blue);
      case EventType.foul:
        return Icon(Icons.warning, color: Colors.orange);
      case EventType.yellowCard:
        return Icon(Icons.credit_card, color: Colors.amber);
      case EventType.redCard:
        return Icon(Icons.credit_card, color: Colors.red);
      case EventType.offside:
        return Icon(Icons.flag_outlined, color: Colors.red);
      case EventType.kickOff:
        return Icon(Icons.sports_soccer_outlined);
      case EventType.finalWhistle:
        return Icon(Icons.sports_score);
      // ignore: unreachable_switch_default
      default:
        return Icon(Icons.sports);
    }
  }

  String _getEventDescription(GameEvent event) {
    switch (event.eventType) {
      case EventType.goal:
        return "GOL! ${event.teamName} segna!";
      case EventType.shot:
        return "Tiro in porta di ${event.teamName}";
      case EventType.corner:
        return "Calcio d'angolo per ${event.teamName}";
      case EventType.foul:
        return "Fallo commesso da ${event.teamName}";
      case EventType.yellowCard:
        return "Cartellino giallo per ${event.teamName}";
      case EventType.redCard:
        return "Cartellino rosso per ${event.teamName}!";
      case EventType.offside:
        return "Fuorigioco segnalato a ${event.teamName}";
      case EventType.kickOff:
        return "Inizio partita!";
      case EventType.finalWhistle:
        return "Fischio finale! Partita terminata.";
      // ignore: unreachable_switch_default
      default:
        return "Evento di gioco";
    }
  }
}

// Enumerazione per i tipi di eventi di gioco
enum EventType {
  goal,
  shot,
  corner,
  foul,
  yellowCard,
  redCard,
  offside,
  kickOff,
  finalWhistle,
}

// Classe per rappresentare un evento di gioco
class GameEvent {
  final int minute;
  final EventType eventType;
  final String teamName;

  GameEvent({
    required this.minute,
    required this.eventType,
    required this.teamName,
  });
}
