import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';

String fmtNum(num? n) => n == null ? '' : NumberFormat("#,##0.###").format(n);
DateFormat dFmt = DateFormat("dd/MM/yyyy HH:mm");

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } else {
    await Firebase.initializeApp();
  }
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BESOSTRI FARM',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 20),
          bodyMedium: TextStyle(fontSize: 18),
        ),
        visualDensity: VisualDensity.comfortable,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int idx = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BESOSTRI FARM'), centerTitle: true),
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => setState(() => idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.scale), label: 'Raccolti'),
          NavigationDestination(icon: Icon(Icons.local_fire_department), label: 'Essiccazione'),
          NavigationDestination(icon: Icon(Icons.view_list), label: 'Tutti i pesi'),
        ],
      ),
      body: switch (idx) {
        0 => const HarvestPage(),
        1 => const DryingPage(),
        _ => const ManagerAllHarvestsPage(),
      },
    );
  }
}

// ----------------- RACCOLTI -----------------
class HarvestPage extends StatelessWidget {
  const HarvestPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        PersonCard(person: 'OMAR'),
        SizedBox(height: 24),
        PersonCard(person: 'FABRIZIO'),
      ],
    );
  }
}

class PersonCard extends StatelessWidget {
  final String person;
  const PersonCard({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(person,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold))),
                FilledButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => HarvestDialog(person: person),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Nuovo peso'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: HarvestList(person: person),
            ),
            const SizedBox(height: 8),
            PersonTotal(person: person),
          ],
        ),
      ),
    );
  }
}

class HarvestDialog extends StatefulWidget {
  final String person;
  const HarvestDialog({super.key, required this.person});
  @override
  State<HarvestDialog> createState() => _HarvestDialogState();
}

class _HarvestDialogState extends State<HarvestDialog> {
  final nameC = TextEditingController();
  final tareC = TextEditingController();
  final grossC = TextEditingController();

  num get tare => num.tryParse(tareC.text.replaceAll(',', '.')) ?? 0;
  num get gross => num.tryParse(grossC.text.replaceAll(',', '.')) ?? 0;
  num get net => gross - tare;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Nuovo peso – ${widget.person}'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nameC,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nome campo'),
            ),
            TextField(
              controller: tareC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Tara (kg)'),
              onChanged: (_) => setState(() {}),
            ),
            TextField(
              controller: grossC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Lordo (kg)'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Text('Netto: ${fmtNum(net)} kg',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
        FilledButton(
          onPressed: () async {
            final data = {
              'person': widget.person,
              'fieldName': nameC.text.trim(),
              'tare': tare.toDouble(),
              'gross': gross.toDouble(),
              'net': net.toDouble(),
              'createdAt': FieldValue.serverTimestamp(),
            };
            await FirebaseFirestore.instance.collection('harvests').add(data);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Salva'),
        ),
      ],
    );
  }
}

class HarvestList extends StatelessWidget {
  final String person;
  const HarvestList({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    final q = FirebaseFirestore.instance
        .collection('harvests')
        .where('person', isEqualTo: person)
        .orderBy('createdAt', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: q.snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('Nessun peso inserito'));
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            return ListTile(
              title: Text('${d['fieldName'] ?? ''}  –  Netto: ${fmtNum(d['net'])} kg',
                  style: const TextStyle(fontSize: 18)),
              subtitle: Text('Tara: ${fmtNum(d['tare'])}  •  Lordo: ${fmtNum(d['gross'])}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => docs[i].reference.delete(),
              ),
            );
          },
        );
      },
    );
  }
}

class PersonTotal extends StatelessWidget {
  final String person;
  const PersonTotal({super.key, required this.person});
  @override
  Widget build(BuildContext context) {
    final q = FirebaseFirestore.instance
        .collection('harvests')
        .where('person', isEqualTo: person);
    return StreamBuilder<QuerySnapshot>(
      stream: q.snapshots(),
      builder: (_, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final total = snap.data!.docs.fold<num>(
            0, (sum, d) => sum + ((d['net'] ?? 0) as num));
        return Align(
          alignment: Alignment.centerRight,
          child: Text('Totale ${person}: ${fmtNum(total)} kg',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        );
      },
    );
  }
}

// ----------------- ESSICCAZIONE -----------------
class DryingPage extends StatefulWidget {
  const DryingPage({super.key});
  @override
  State<DryingPage> createState() => _DryingPageState();
}

class _DryingPageState extends State<DryingPage> {
  int dryer = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 1, label: Text('Essiccatoio 1')),
            ButtonSegment(value: 2, label: Text('Essiccatoio 2')),
          ],
          selected: {dryer},
          onSelectionChanged: (s) => setState(() => dryer = s.first),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => DryingDialog(dryer: dryer),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Nuova essiccazione'),
            ),
          ),
        ),
        Expanded(child: DryingList(dryer: dryer)),
      ],
    );
  }
}

class DryingDialog extends StatefulWidget {
  final int dryer;
  const DryingDialog({super.key, required this.dryer});
  @override
  State<DryingDialog> createState() => _DryingDialogState();
}

class _DryingDialogState extends State<DryingDialog> {
  DateTime? start;
  DateTime? end;
  final humidityC = TextEditingController();
  final notesC = TextEditingController();

  Future<void> pick(bool isStart) async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDate: now,
    );
    if (d == null) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t == null) return;
    final dt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    setState(() {
      if (isStart) {
        start = dt;
      } else {
        end = dt;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Nuova essiccazione – Essiccatoio ${widget.dryer}'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => pick(true),
                    child: Text(start == null ? 'Inizio' : dFmt.format(start!)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () => pick(false),
                    child: Text(end == null ? 'Fine' : dFmt.format(end!)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: humidityC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Umidità (%)'),
            ),
            TextField(
              controller: notesC,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
        FilledButton(
          onPressed: () async {
            if (start == null || end == null) return;
            await FirebaseFirestore.instance.collection('dryings').add({
              'dryer': widget.dryer,
              'start': Timestamp.fromDate(start!),
              'end': Timestamp.fromDate(end!),
              'humidity': num.tryParse(humidityC.text.replaceAll(',', '.'))?.toDouble(),
              'notes': notesC.text.trim(),
              'createdAt': FieldValue.serverTimestamp(),
            });
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Salva'),
        ),
      ],
    );
  }
}

class DryingList extends StatelessWidget {
  final int dryer;
  const DryingList({super.key, required this.dryer});
  @override
  Widget build(BuildContext context) {
    final q = FirebaseFirestore.instance
        .collection('dryings')
        .where('dryer', isEqualTo: dryer)
        .orderBy('start', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: q.snapshots(),
      builder: (_, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('Nessuna essiccazione'));
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (_, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            final s = (d['start'] as Timestamp).toDate();
            final e = (d['end'] as Timestamp).toDate();
            final hum = d['humidity'];
            return ListTile(
              title: Text('${dFmt.format(s)}  →  ${dFmt.format(e)}'),
              subtitle: Text('Umidità: ${hum ?? '-'}%  •  Note: ${d['notes'] ?? ''}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => docs[i].reference.delete(),
              ),
            );
          },
          separatorBuilder: (_, __) => const Divider(),
          itemCount: docs.length,
        );
      },
    );
  }
}

// ----------------- MANAGER: TUTTI I PESI -----------------
class ManagerAllHarvestsPage extends StatelessWidget {
  const ManagerAllHarvestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final q = FirebaseFirestore.instance
        .collection('harvests')
        .orderBy('createdAt', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: q.snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data!.docs;

        num totOmar = 0, totFabrizio = 0, totAll = 0;
        for (final d in docs) {
          final m = d.data() as Map<String, dynamic>;
          final net = (m['net'] ?? 0) as num;
          final p = (m['person'] ?? '') as String;
          totAll += net;
          if (p == 'OMAR') totOmar += net;
          if (p == 'FABRIZIO') totFabrizio += net;
        }

        return Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Totali', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Wrap(spacing: 12, runSpacing: 6, children: [
                    _TotalChip(label: 'OMAR', value: totOmar),
                    _TotalChip(label: 'FABRIZIO', value: totFabrizio),
                    _TotalChip(label: 'TOTALE', value: totAll),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                separatorBuilder: (_, __) => const Divider(),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final d = docs[i].data() as Map<String, dynamic>;
                  final created = (d['createdAt'] as Timestamp?)?.toDate();
                  return ListTile(
                    leading: _PersonBadge(person: d['person'] ?? '?'),
                    title: Text('${d['fieldName'] ?? ''}  –  Netto: ${fmtNum(d['net'])} kg',
                        style: const TextStyle(fontSize: 18)),
                    subtitle: Text(
                      'Tara: ${fmtNum(d['tare'])} • Lordo: ${fmtNum(d['gross'])}'
                      '${created != null ? ' • ${dFmt.format(created)}' : ''}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => docs[i].reference.delete(),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PersonBadge extends StatelessWidget {
  final String person;
  const _PersonBadge({required this.person});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black54),
      ),
      child: Text(person, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _TotalChip extends StatelessWidget {
  final String label;
  final num value;
  const _TotalChip({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: ${fmtNum(value)} kg',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
