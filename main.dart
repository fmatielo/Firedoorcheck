// main.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pdfLib;
import 'package:printing/printing.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FireDoorApp());
}

/* ========================= APP ========================= */

class FireDoorApp extends StatelessWidget {
  const FireDoorApp({super.key});
  @override
  Widget build(BuildContext context) {
    final seed = const Color(0xFF6C8BFF);
    return MaterialApp(
      title: 'FireDoor Check',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: seed,
        scaffoldBackgroundColor: const Color(0xFF0E1116),
        cardTheme: CardTheme(
          color: const Color(0xFF161A22),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF10151D),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const IntroPage(),
    );
  }
}

/* ========================= INTRO ========================= */

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});
  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  bool _showDisclaimer = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadFlags();
  }

  Future<void> _loadFlags() async {
    final d = await LocalStore.load();
    setState(() {
      _showDisclaimer = !(d.settings.introDisclaimerDismissed ?? false);
      _loaded = true;
    });
  }

  Future<void> _dismissDisclaimer() async {
    final d = await LocalStore.load();
    d.settings.introDisclaimerDismissed = true;
    await LocalStore.save();
    if (mounted) setState(() => _showDisclaimer = false);
  }

  void _openModal(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF12161D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(title),
        content: Text(body),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withOpacity(.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs.primary.withOpacity(.35)),
                  ),
                  child: const Icon(Icons.verified_user, size: 30),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text('FireDoor Check', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800))),
              ]),
              const SizedBox(height: 14),
              Text(
                'FireDoor Check helps landlords, property managers and residents run quick visual checks on fire doors. Flow: Property → Door → Checklist. All notes stay on your device.',
                style: TextStyle(color: cs.onSurface.withOpacity(.8)),
              ),
              const SizedBox(height: 20),

              Row(children: [
                Expanded(
                  child: _FeatureTile(
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    subtitle: 'Overview of inspections',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardPage())),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FeatureTile(
                    icon: Icons.apartment,
                    title: 'Properties',
                    subtitle: 'Organise by address or block',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PropertiesPage())),
                  ),
                ),
              ]),
              const SizedBox(height: 10),

              Row(children: [
                Expanded(
                  child: _FeatureTile(
                    icon: Icons.meeting_room_outlined,
                    title: 'Doors',
                    subtitle: 'All saved doors',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllDoorsPage())),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _FeatureTile(
                    icon: Icons.checklist_rtl,
                    title: 'Checklist',
                    subtitle: 'Saved inspections (resume or review)',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InspectionsPage())),
                  ),
                ),
              ]),

              const SizedBox(height: 14),
              if (_showDisclaimer)
                _DisclaimerBox(
                  text: 'This app is a simple guide and does not replace a professional inspection or a formal Fire Risk Assessment.',
                  onClose: _dismissDisclaimer,
                ),

              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PropertiesPage())),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Start inspection', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center, spacing: 8,
                children: [
                  TextButton(
                    onPressed: () => _openModal(
                      context,
                      'About',
                      'FireDoor Check helps landlords, property managers and residents run quick visual checks on fire doors, guiding you through Property → Door → Checklist.',
                    ),
                    child: const Text('About'),
                  ),
                  TextButton(
                    onPressed: () => _openModal(
                      context,
                      'Privacy',
                      'Your inspection data stays private on your phone and can be viewed or deleted by you at any time.',
                    ),
                    child: const Text('Privacy'),
                  ),
                  TextButton(
                    onPressed: () => _openModal(
                      context,
                      'Disclaimer',
                      'This app is a simple guide only and does not replace a professional inspection or formal Fire Risk Assessment.',
                    ),
                    child: const Text('Disclaimer'),
                  ),
                  TextButton(
                    onPressed: () => _openModal(
                      context,
                      'Safety Reminder',
                      'Keep fire doors closed, never remove door closers and report any damage or missing seals immediately.',
                    ),
                    child: const Text('Safety Reminder'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final VoidCallback? onTap;
  const _FeatureTile({required this.icon, required this.title, required this.subtitle, this.onTap});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surfaceVariant.withOpacity(.18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outlineVariant.withOpacity(.3)),
          ),
          child: Row(children: [
            Icon(icon, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: cs.onSurface.withOpacity(.7))),
              ]),
            ),
            const Icon(Icons.chevron_right),
          ]),
        ),
      ),
    );
  }
}

class _DisclaimerBox extends StatelessWidget {
  final String text; final VoidCallback? onClose;
  const _DisclaimerBox({required this.text, this.onClose});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(.35)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.info_outline),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        const SizedBox(width: 6),
        if (onClose != null)
          IconButton(
            tooltip: 'I understand',
            onPressed: onClose,
            icon: const Icon(Icons.check_circle_outline),
          ),
      ]),
    );
  }
}

/* ========================= MODELS ========================= */

enum CheckStatus { pass, attention, fail, na }

class Property {
  int id; String name; String? address;
  Property({required this.id, required this.name, this.address});
  factory Property.fromJson(Map<String, dynamic> j) => Property(id: j['id'], name: j['name'], address: j['address']);
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'address': address};
}

class Door {
  int id; int propertyId; String label;
  Door({required this.id, required this.propertyId, required this.label});
  factory Door.fromJson(Map<String, dynamic> j) => Door(id: j['id'], propertyId: j['propertyId'], label: j['label']);
  Map<String, dynamic> toJson() => {'id': id, 'propertyId': propertyId, 'label': label};
}

class StepResult {
  String stepKey;
  CheckStatus? status;
  String? notes;
  List<String> photosBase64;

  StepResult({
    required this.stepKey,
    this.status,
    this.notes,
    List<String>? photosBase64,
  }) : photosBase64 = photosBase64 ?? [];

  factory StepResult.fromJson(Map<String, dynamic> j) {
    final raw = j['status'];
    CheckStatus? parsed;
    if (raw is String) {
      parsed = CheckStatus.values.firstWhere(
            (e) => e.name == raw,
        orElse: () => CheckStatus.pass,
      );
    } else if (raw is int) {
      if (raw == 0) parsed = CheckStatus.pass;
      if (raw == 1) parsed = CheckStatus.fail;
      if (raw == 2) parsed = CheckStatus.na;
    }
    return StepResult(
      stepKey: j['stepKey'],
      status: parsed,
      notes: j['notes'],
      photosBase64: (j['photosBase64'] as List?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'stepKey': stepKey,
    'status': status?.name,
    'notes': notes,
    'photosBase64': photosBase64,
  };
}

class Inspection {
  int id;
  int propertyId;
  int doorId;
  DateTime startedAt;
  DateTime? finishedAt;
  List<StepResult> results;
  String? evaluatorName;

  Inspection({
    required this.id,
    required this.propertyId,
    required this.doorId,
    required this.startedAt,
    this.finishedAt,
    required this.results,
    this.evaluatorName,
  });

  factory Inspection.fromJson(Map<String, dynamic> j) => Inspection(
    id: j['id'],
    propertyId: j['propertyId'],
    doorId: j['doorId'],
    startedAt: DateTime.parse(j['startedAt']),
    finishedAt: j['finishedAt'] == null ? null : DateTime.parse(j['finishedAt']),
    results: (j['results'] as List).map((e) => StepResult.fromJson(e)).toList(),
    evaluatorName: j['evaluatorName'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'propertyId': propertyId,
    'doorId': doorId,
    'startedAt': startedAt.toIso8601String(),
    'finishedAt': finishedAt?.toIso8601String(),
    'results': results.map((e) => e.toJson()).toList(),
    'evaluatorName': evaluatorName,
  };
}

/* ========================= LOCAL JSON STORAGE (WITH SETTINGS) ========================= */

class Settings {
  bool? introDisclaimerDismissed; bool? checklistDisclaimerDismissed;
  Settings({this.introDisclaimerDismissed, this.checklistDisclaimerDismissed});
  factory Settings.fromJson(Map<String, dynamic>? j) => Settings(
    introDisclaimerDismissed: j?['introDisclaimerDismissed'] as bool?,
    checklistDisclaimerDismissed: j?['checklistDisclaimerDismissed'] as bool?,
  );
  Map<String, dynamic> toJson() => {
    'introDisclaimerDismissed': introDisclaimerDismissed,
    'checklistDisclaimerDismissed': checklistDisclaimerDismissed,
  };
}

class AppData {
  int _nextPropId = 1; int _nextDoorId = 1; int _nextInspId = 1;
  List<Property> properties = []; List<Door> doors = []; List<Inspection> inspections = [];
  Settings settings = Settings();
  AppData();
  factory AppData.fromJson(Map<String, dynamic> j) {
    final d = AppData();
    d._nextPropId = j['_nextPropId'] ?? 1;
    d._nextDoorId = j['_nextDoorId'] ?? 1;
    d._nextInspId = j['_nextInspId'] ?? 1;
    d.properties = (j['properties'] as List?)?.map((e) => Property.fromJson(e)).toList() ?? [];
    d.doors = (j['doors'] as List?)?.map((e) => Door.fromJson(e)).toList() ?? [];
    d.inspections = (j['inspections'] as List?)?.map((e) => Inspection.fromJson(e)).toList() ?? [];
    d.settings = Settings.fromJson(j['settings'] as Map<String, dynamic>?);
    return d;
  }
  Map<String, dynamic> toJson() => {
    '_nextPropId': _nextPropId, '_nextDoorId': _nextDoorId, '_nextInspId': _nextInspId,
    'properties': properties.map((e) => e.toJson()).toList(),
    'doors': doors.map((e) => e.toJson()).toList(),
    'inspections': inspections.map((e) => e.toJson()).toList(),
    'settings': settings.toJson(),
  };
  int nextPropId() => _nextPropId++; int nextDoorId() => _nextDoorId++; int nextInspId() => _nextInspId++;
}

class LocalStore {
  static File? _file; static AppData _cache = AppData();
  static Future<File> _getFile() async {
    if (_file != null) return _file!;
    final dir = await getApplicationDocumentsDirectory();
    _file = File('${dir.path}/app_data.json');
    if (!await _file!.exists()) await _file!.writeAsString(jsonEncode(_cache.toJson()));
    return _file!;
  }
  static Future<AppData> load() async {
    final f = await _getFile();
    try { final txt = await f.readAsString(); _cache = AppData.fromJson(jsonDecode(txt)); }
    catch (_) { _cache = AppData(); }
    return _cache;
  }
  static Future<void> save() async { final f = await _getFile(); await f.writeAsString(jsonEncode(_cache.toJson())); }

  static Future<Property> addProperty(String name, {String? address}) async {
    final d = await load(); final p = Property(id: d.nextPropId(), name: name, address: address);
    d.properties.add(p); await save(); return p;
  }
  static Future<void> deleteProperty(int propertyId) async {
    final d = await load();
    final doorIds = d.doors.where((x) => x.propertyId == propertyId).map((e) => e.id).toSet();
    d.inspections.removeWhere((i) => i.propertyId == propertyId || doorIds.contains(i.doorId));
    d.doors.removeWhere((door) => door.propertyId == propertyId);
    d.properties.removeWhere((p) => p.id == propertyId);
    await save();
  }

  static Future<Door> addDoor(int propertyId, String label) async {
    final d = await load(); final door = Door(id: d.nextDoorId(), propertyId: propertyId, label: label);
    d.doors.add(door); await save(); return door;
  }
  static Future<void> deleteDoor(int doorId) async {
    final d = await load();
    d.inspections.removeWhere((i) => i.doorId == doorId);
    d.doors.removeWhere((door) => door.id == doorId);
    await save();
  }

  static Future<Inspection> startInspection(int propertyId, int doorId, {String? evaluatorName}) async {
    final d = await load();
    final insp = Inspection(
      id: d.nextInspId(), propertyId: propertyId, doorId: doorId, startedAt: DateTime.now(),
      results: _defaultChecklist(),
      evaluatorName: evaluatorName,
    );
    d.inspections.add(insp); await save(); return insp;
  }
  static Future<void> deleteInspection(int inspectionId) async {
    final d = await load();
    d.inspections.removeWhere((i) => i.id == inspectionId);
    await save();
  }

  static List<Inspection> inspectionsForDoor(int doorId) => _cache.inspections.where((i) => i.doorId == doorId).toList();

  static List<StepResult> _defaultChecklist() => [
    StepResult(stepKey: 'auto_closing'),
    StepResult(stepKey: 'frame_gap_edges'),
    StepResult(stepKey: 'floor_gap'),
    StepResult(stepKey: 'drop_seal_presence'),
    StepResult(stepKey: 'seals'),
    StepResult(stepKey: 'hinges_screws'),
    StepResult(stepKey: 'glazing'),
    StepResult(stepKey: 'cert_label'),
    StepResult(stepKey: 'surface_condition'),
  ];
}

/* ========================= PAGES ========================= */

class PropertiesPage extends StatefulWidget {
  const PropertiesPage({super.key});
  @override State<PropertiesPage> createState() => _PropertiesPageState();
}
class _PropertiesPageState extends State<PropertiesPage> {
  AppData? data;
  @override void initState() { super.initState(); LocalStore.load().then((d) => setState(() => data = d)); }

  Future<void> _addProperty() async {
    final nameCtrl = TextEditingController(); final addrCtrl = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF12161D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text('New property'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
        const SizedBox(height: 8),
        TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'Address (optional)')),
      ]),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(context,false), child: const Text('Cancel')),
        FilledButton(onPressed: ()=>Navigator.pop(context,true), child: const Text('Save')),
      ],
    ));
    if (ok != true) return;
    await LocalStore.addProperty(nameCtrl.text.trim(), address: addrCtrl.text.trim().isEmpty ? null : addrCtrl.text.trim());
    final d = await LocalStore.load(); setState(() => data = d);
  }

  Future<void> _confirmDeleteProperty(Property p) async {
    final sure = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF12161D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text('Delete property?'),
      content: const Text('This will also delete its doors and inspections.'),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(context,false), child: const Text('Cancel')),
        FilledButton(onPressed: ()=>Navigator.pop(context,true), child: const Text('Delete')),
      ],
    ));
    if (sure == true) {
      await LocalStore.deleteProperty(p.id);
      final d = await LocalStore.load(); setState(() => data = d);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = data; if (d == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: ()=>Navigator.pop(context)),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _addProperty, child: const Icon(Icons.add)),
      body: d.properties.isEmpty
          ? const _EmptyState(icon: Icons.apartment, title: 'No properties yet', subtitle: 'Tap + to add your first property.')
          : ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: d.properties.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final p = d.properties[i];
            final doorsCount = d.doors.where((e) => e.propertyId == p.id).length;
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: p.address == null || p.address!.isEmpty ? Text('$doorsCount doors') : Text('${p.address!} • $doorsCount doors'),
                leading: const Icon(Icons.apartment),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: () => _confirmDeleteProperty(p),
                    icon: const Icon(Icons.delete_outline),
                  ),
                  const Icon(Icons.chevron_right),
                ]),
                // Optimize: tapping property opens DoorsPage (all doors of the property)
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoorsPage(property: p))).then((_) async {
                  final re = await LocalStore.load(); setState(() => data = re);
                }),
              ),
            );
          }),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon; final String title; final String subtitle;
  const _EmptyState({required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 48, color: cs.primary),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant)),
      ]),
    ));
  }
}

class DoorsPage extends StatefulWidget {
  final Property property;
  const DoorsPage({super.key, required this.property});
  @override State<DoorsPage> createState() => _DoorsPageState();
}
class _DoorsPageState extends State<DoorsPage> {
  List<Door> _doors = [];
  AppData? _data;

  @override
  void initState() {
    super.initState();
    _loadDoors();
  }

  Future<void> _loadDoors() async {
    final d = await LocalStore.load();
    setState(() {
      _data = d;
      _doors = d.doors.where((e) => e.propertyId == widget.property.id).toList();
    });
  }

  Future<void> _addDoor() async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF12161D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text('New door'),
      content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Label (e.g., Flat 2 — Front Door)'), textInputAction: TextInputAction.done, onSubmitted: (_)=>FocusScope.of(context).unfocus()),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(context,false), child: const Text('Cancel')),
        FilledButton(onPressed: ()=>Navigator.pop(context,true), child: const Text('Save')),
      ],
    ));
    if (ok != true) return;
    await LocalStore.addDoor(widget.property.id, ctrl.text.trim());
    await _loadDoors();
  }

  Future<void> _deleteDoor(Door door) async {
    final sure = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF12161D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text('Delete door?'),
      content: const Text('This will also delete its inspections.'),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(context,false), child: const Text('Cancel')),
        FilledButton(onPressed: ()=>Navigator.pop(context,true), child: const Text('Delete')),
      ],
    ));
    if (sure == true) {
      await LocalStore.deleteDoor(door.id);
      await _loadDoors();
    }
  }

  Future<void> _startInspection(Door d) async {
    final insp = await LocalStore.startInspection(widget.property.id, d.id);
    if (!mounted) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => StepWizardPage(door: d, inspectionId: insp.id)));
    await _loadDoors();
  }

  // New behavior: tapping a door opens the latest inspection summary if exists else starts inspection
  Future<void> _onDoorTap(Door d) async {
    final all = await LocalStore.load();
    final inspections = all.inspections.where((i) => i.doorId == d.id).toList();
    if (inspections.isEmpty) {
      // Start a new inspection if none exists
      final insp = await LocalStore.startInspection(widget.property.id, d.id);
      if (!mounted) return;
      await Navigator.push(context, MaterialPageRoute(builder: (_) => StepWizardPage(door: d, inspectionId: insp.id)));
    } else {
      // Show latest inspection summary
      inspections.sort((a, b) => (b.finishedAt ?? b.startedAt).compareTo(a.finishedAt ?? a.startedAt));
      final latest = inspections.first;
      if (!mounted) return;
      await Navigator.push(context, MaterialPageRoute(builder: (_) =>
          InspectionSummaryPage(
            inspection: latest,
            door: d,
            property: widget.property,
          ),
      ));
    }
    await _loadDoors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Doors — ${widget.property.name}')),
      floatingActionButton: FloatingActionButton(onPressed: _addDoor, child: const Icon(Icons.add)),
      body: _doors.isEmpty
          ? const _EmptyState(icon: Icons.meeting_room_outlined, title: 'No doors yet', subtitle: 'Tap + to add a door for this property.')
          : ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: _doors.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final d = _doors[i];
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                leading: const Icon(Icons.meeting_room_outlined),
                title: Text(d.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                trailing: Wrap(spacing: 4, children: [
                  IconButton(
                    tooltip: 'Delete door',
                    onPressed: () => _deleteDoor(d),
                    icon: const Icon(Icons.delete_outline),
                  ),
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.playlist_add_check_circle_outlined),
                    onPressed: () => _startInspection(d),
                    label: const Text('Start'),
                  ),
                ]),
                onTap: () => _onDoorTap(d),
              ),
            );
          }),
    );
  }
}

class AllDoorsPage extends StatefulWidget {
  const AllDoorsPage({super.key});
  @override State<AllDoorsPage> createState() => _AllDoorsPageState();
}
class _AllDoorsPageState extends State<AllDoorsPage> {
  AppData? data;
  @override void initState() { super.initState(); LocalStore.load().then((d) => setState(() => data = d)); }

  String _propNameFor(int propId) {
    final p = data!.properties.where((e) => e.id == propId);
    return p.isEmpty ? 'Unknown property' : p.first.name;
  }

  @override
  Widget build(BuildContext context) {
    final d = data; if (d == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('All doors')),
      body: d.doors.isEmpty
          ? const _EmptyState(icon: Icons.meeting_room_outlined, title: 'No doors', subtitle: 'Create doors inside a property.')
          : ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: d.doors.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final door = d.doors[i];
            final propName = _propNameFor(door.propertyId);
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                title: Text(door.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(propName),
                trailing: FilledButton.tonalIcon(
                  icon: const Icon(Icons.playlist_add_check_circle_outlined),
                  onPressed: () async {
                    final insp = await LocalStore.startInspection(door.propertyId, door.id);
                    if (!mounted) return;
                    await Navigator.push(context, MaterialPageRoute(builder: (_)=> StepWizardPage(door: door, inspectionId: insp.id)));
                    final re = await LocalStore.load(); setState(() => data = re);
                  },
                  label: const Text('Start'),
                ),
                onTap: () async {
                  // Open latest inspection summary if present
                  final all = await LocalStore.load();
                  final insps = all.inspections.where((i) => i.doorId == door.id).toList();
                  if (insps.isEmpty) {
                    final insp = await LocalStore.startInspection(door.propertyId, door.id);
                    if (!mounted) return;
                    await Navigator.push(context, MaterialPageRoute(builder: (_)=> StepWizardPage(door: door, inspectionId: insp.id)));
                  } else {
                    insps.sort((a,b) => (b.finishedAt ?? b.startedAt).compareTo(a.finishedAt ?? a.startedAt));
                    final latest = insps.first;
                    final prop = all.properties.firstWhere((p) => p.id == latest.propertyId, orElse: ()=>Property(id:0,name:'Unknown'));
                    if (!mounted) return;
                    await Navigator.push(context, MaterialPageRoute(builder: (_)=> InspectionSummaryPage(inspection: latest, door: door, property: prop)));
                  }
                  final re = await LocalStore.load(); setState(() => data = re);
                },
              ),
            );
          }),
    );
  }
}

class InspectionsPage extends StatefulWidget {
  const InspectionsPage({super.key});
  @override State<InspectionsPage> createState() => _InspectionsPageState();
}

class _InspectionsPageState extends State<InspectionsPage> {
  AppData? data;

  @override
  void initState() {
    super.initState();
    LocalStore.load().then((d) => setState(() => data = d));
  }

  String _propNameFor(int id) {
    final p = data!.properties.where((e) => e.id == id);
    return p.isEmpty ? 'Unknown property' : p.first.name;
  }

  Door? _doorFor(int id) {
    final ds = data!.doors.where((e) => e.id == id);
    return ds.isEmpty ? null : ds.first;
  }

  String _summary(Inspection i) {
    int pass = 0, attention = 0, fail = 0, na = 0, pend = 0;
    for (final r in i.results) {
      final s = r.status;
      if (s == null) {
        pend++;
      } else if (s == CheckStatus.pass) {
        pass++;
      } else if (s == CheckStatus.attention) {
        attention++;
      } else if (s == CheckStatus.fail) {
        fail++;
      } else {
        na++;
      }
    }
    return 'Pass $pass • Attention $attention • Fail $fail • N/A $na • Pending $pend';
  }

  String _outcome(Inspection i) {
    final hasFail = i.results.any((r) => r.status == CheckStatus.fail);
    final hasAttention = i.results.any((r) => r.status == CheckStatus.attention);
    final allNull = i.results.every((r) => r.status == null);
    if (allNull) return 'Pending';
    if (hasFail) return 'Failed';
    if (hasAttention) return 'Attention';
    return 'Passed';
  }

  Color _outcomeColor(String outcome) {
    switch (outcome) {
      case 'Passed':
        return Colors.green;
      case 'Attention':
        return Colors.amber;
      case 'Failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  int _firstIncompleteIndex(Inspection i) {
    final idx = i.results.indexWhere((r) => r.status == null);
    if (idx < 0) return 0;
    return (idx >= i.results.length) ? 0 : idx;
  }

  String _fmtDateTime(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$d ${months[dt.month-1]} ${dt.year}, $h:$m';
  }

  Future<void> _deleteInspection(Inspection insp) async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF12161D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete inspection?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (sure == true) {
      await LocalStore.deleteInspection(insp.id);
      final re = await LocalStore.load();
      setState(() => data = re);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = data;
    if (d == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Inspections')),
      body: d.inspections.isEmpty
          ? const _EmptyState(icon: Icons.checklist_rtl, title: 'No inspections', subtitle: 'Start one from a door.')
          : ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: d.inspections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final insp = d.inspections[i];
          final prop = _propNameFor(insp.propertyId);
          final door = _doorFor(insp.doorId);
          final done = insp.results.every((r) => r.status != null);
          final when = insp.finishedAt ?? insp.startedAt;
          final whenStr = _fmtDateTime(when);
          final outcome = _outcome(insp);
          final color = _outcomeColor(outcome);

          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              visualDensity: VisualDensity.compact,
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: color.withOpacity(.18),
                child: Icon(
                  outcome == 'Passed'
                      ? Icons.check_circle
                      : outcome == 'Failed'
                      ? Icons.cancel
                      : outcome == 'Attention'
                      ? Icons.error_outline
                      : Icons.hourglass_bottom,
                  color: color,
                ),
              ),
              title: Text(
                door?.label ?? 'Door #${insp.doorId}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(prop, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    whenStr,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color),
                    ),
                    child: Text(
                      outcome,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Delete inspection',
                        onPressed: () => _deleteInspection(insp),
                        icon: const Icon(Icons.delete_outline),
                      ),
                      IconButton(
                        tooltip: done ? 'Review' : 'Resume',
                        onPressed: () async {
                          if (door == null) return;
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InspectionSummaryPage(
                                inspection: insp,
                                door: door,
                                property: d.properties.firstWhere(
                                      (p) => p.id == insp.propertyId,
                                  orElse: () => Property(id: 0, name: 'Unknown'),
                                ),
                              ),
                            ),
                          );
                          final re = await LocalStore.load();
                          setState(() => data = re);
                        },
                        icon: Icon(done ? Icons.visibility_outlined : Icons.play_arrow_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/* ========================= INSPECTION SUMMARY PAGE (with PDF export) ========================= */

class InspectionSummaryPage extends StatelessWidget {
  final Inspection inspection;
  final Door? door;
  final Property? property;

  const InspectionSummaryPage({
    super.key,
    required this.inspection,
    required this.door,
    required this.property,
  });

  String _overall(Inspection i) {
    final hasFail = i.results.any((r) => r.status == CheckStatus.fail);
    final hasAttention = i.results.any((r) => r.status == CheckStatus.attention);
    final allNull = i.results.every((r) => r.status == null);
    if (allNull) return 'Not inspected';
    if (hasFail) return 'Failed';
    if (hasAttention) return 'Attention';
    return 'Passed';
  }

  String _fmtDateTime(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$d ${months[dt.month-1]} ${dt.year}, $h:$m';
  }

  Future<void> _exportPdf(BuildContext context) async {
    final doc = pw.Document();
    final when = inspection.finishedAt ?? inspection.startedAt;

    doc.addPage(
      pw.MultiPage(
        pageFormat: pdfLib.PdfPageFormat.a4,
        build: (pw.Context ctx) {
          return [
            pw.Header(level: 0, child: pw.Text('Inspection Summary', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))),
            pw.Text('Property: ${property?.name ?? 'Unknown'}'),
            if (property?.address != null && property!.address!.isNotEmpty) pw.Text('Address: ${property!.address!}'),
            pw.Text('Door: ${door?.label ?? 'Unknown'}'),
            pw.Text('Evaluator: ${inspection.evaluatorName ?? '—'}'),
            pw.Text('Date: ${_fmtDateTime(when)}'),
            pw.SizedBox(height: 10),
            pw.Text('Overall: ${_overall(inspection)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('Detailed results:', style: pw.TextStyle(decoration: pw.TextDecoration.underline)),
            pw.SizedBox(height: 6),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: inspection.results.map((r) {
                final s = r.status?.name ?? 'Pending';
                final notes = r.notes ?? '';
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('- ${r.stepKey}: $s', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    if (notes.isNotEmpty) pw.Text('  Notes: $notes'),
                    if (r.photosBase64.isNotEmpty) pw.Text('  Photos: ${r.photosBase64.length}'),
                    pw.SizedBox(height: 6),
                  ],
                );
              }).toList(),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Photos (embedded):', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Wrap(
              spacing: 8,
              runSpacing: 8,
              children: inspection.results.expand((r) => r.photosBase64).take(6).map((b64) {
                try {
                  final bytes = base64Decode(b64);
                  final image = pw.MemoryImage(bytes);
                  return pw.Container(width: 150, height: 100, child: pw.Image(image, fit: pw.BoxFit.cover));
                } catch (_) {
                  return pw.Container(width: 150, height: 100, child: pw.Center(child: pw.Text('Invalid image')));
                }
              }).toList(),
            ),
          ];
        },
      ),
    );

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/inspection_${inspection.id}.pdf');
      final bytes = await doc.save();
      await file.writeAsBytes(bytes);
      await Printing.sharePdf(bytes: bytes, filename: 'inspection_${inspection.id}.pdf');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF exported: ${file.path}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF export failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final i = inspection;

    int pass = 0, att = 0, fail = 0, na = 0, pending = 0;
    for (final r in i.results) {
      switch (r.status) {
        case CheckStatus.pass: pass++; break;
        case CheckStatus.attention: att++; break;
        case CheckStatus.fail: fail++; break;
        case CheckStatus.na: na++; break;
        default: pending++;
      }
    }

    final overall = _overall(i);
    final color = overall == 'Passed'
        ? Colors.green
        : overall == 'Attention'
        ? Colors.amber
        : overall == 'Failed'
        ? Colors.red
        : Colors.grey;

    final when = i.finishedAt ?? i.startedAt;
    final whenStr = _fmtDateTime(when);

    return Scaffold(
      appBar: AppBar(title: const Text('Inspection Summary')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(property?.name ?? 'Unknown property', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  if (property?.address != null && (property!.address!.isNotEmpty))
                    Text(property!.address!, style: TextStyle(color: cs.onSurface.withOpacity(.7))),
                  const SizedBox(height: 8),
                  Text('Door: ${door?.label ?? 'Unknown door'}'),
                  const SizedBox(height: 6),
                  Text('Date: $whenStr', style: TextStyle(color: cs.onSurface.withOpacity(.9))),
                  const SizedBox(height: 6),
                  Text('Evaluator: ${i.evaluatorName ?? '—'}', style: TextStyle(color: cs.onSurface.withOpacity(.9))),
                  const SizedBox(height: 10),
                  Row(children: [
                    Icon(Icons.circle, color: color, size: 14),
                    const SizedBox(width: 8),
                    Text(overall, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Results Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _statRow('Passed', pass, Colors.green),
            _statRow('Attention', att, Colors.amber),
            _statRow('Failed', fail, Colors.red),
            _statRow('N/A', na, Colors.grey),
            _statRow('Pending', pending, Colors.blueGrey),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: i.results.map((r) {
                  return Card(
                    child: ListTile(
                      title: Text(r.stepKey, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: ${r.status?.name ?? 'Pending'}'),
                          if (r.notes != null) Text('Notes: ${r.notes}'),
                          if (r.photosBase64.isNotEmpty) Text('Photos: ${r.photosBase64.length}'),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Back')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _exportPdf(context),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Export PDF')),
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Widget _statRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Icon(Icons.circle, color: color, size: 12),
        const SizedBox(width: 10),
        Expanded(child: Text(label)),
        Text('$value', style: const TextStyle(fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

/* ========================= STEP WIZARD (WITH PHOTOS & evaluator prompt) ========================= */

class StepWizardPage extends StatefulWidget {
  final Door door; final int inspectionId; final int? startIndex;
  const StepWizardPage({super.key, required this.door, required this.inspectionId, this.startIndex});
  @override State<StepWizardPage> createState() => _StepWizardPageState();
}

class _StepContent {
  final String title;
  final String question;
  final String instructions;
  final List<String> guidelines;
  final String? extraNote;
  const _StepContent({
    required this.title,
    required this.question,
    required this.instructions,
    required this.guidelines,
    this.extraNote,
  });
}

class _StepWizardPageState extends State<StepWizardPage> {
  Inspection? _insp;
  int _index = 0;
  bool _showDisclaimer = true;
  late final Map<String, TextEditingController> _controllers;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controllers = {};
    _load();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) { c.dispose(); }
    super.dispose();
  }

  Future<void> _load() async {
    final d = await LocalStore.load();
    final insp = d.inspections.firstWhere((e) => e.id == widget.inspectionId);
    final start = (widget.startIndex ?? 0);
    setState(() {
      _insp = insp;
      _index = (start < 0 || start >= insp.results.length) ? 0 : start;
      _showDisclaimer = !(d.settings.checklistDisclaimerDismissed ?? false);
    });
  }

  Future<void> _dismissChecklistDisclaimer() async {
    final d = await LocalStore.load();
    d.settings.checklistDisclaimerDismissed = true;
    await LocalStore.save();
    if (mounted) setState(() => _showDisclaimer = false);
  }

  StepResult get _current => _insp!.results[_index];
  int get _total => _insp!.results.length;

  TextEditingController _controllerFor(StepResult r) {
    return _controllers.putIfAbsent(r.stepKey, () => TextEditingController(text: r.notes ?? ''));
  }

  Future<void> _setStatus(CheckStatus s) async {
    _current.status = s;
    await LocalStore.save();
    if (mounted) setState(() {});
  }

  Future<void> _setNotes(String? t) async {
    _current.notes = (t != null && t.trim().isNotEmpty) ? t.trim() : null;
    await LocalStore.save();
  }

  void _goPrev() {
    FocusScope.of(context).unfocus();
    if (_index > 0) setState(() => _index--);
  }

  void _goNext() {
    FocusScope.of(context).unfocus();
    final s = _current.status;
    final noteEmpty = (_current.notes == null || _current.notes!.trim().isEmpty);

    if (s == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select Pass, Attention, Fail or N/A to continue')));
      return;
    }
    if (s == CheckStatus.attention && noteEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add a note for “Attention” before continuing')));
      return;
    }

    if (_index < _total - 1) setState(() => _index++);
    else _finish();
  }

  Future<void> _finish() async {
    FocusScope.of(context).unfocus();

    // Prompt for evaluator name if not set
    if ((_insp?.evaluatorName ?? '').trim().isEmpty) {
      final ctrl = TextEditingController();
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF12161D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Evaluator name'),
          content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Enter evaluator name (optional)')),
          actions: [
            TextButton(onPressed: ()=>Navigator.pop(context,false), child: const Text('Skip')),
            FilledButton(onPressed: ()=>Navigator.pop(context,true), child: const Text('Save')),
          ],
        ),
      );

      if (ok == true) {
        _insp!.evaluatorName = ctrl.text.trim().isEmpty ? null : ctrl.text.trim();
      }
    }

    _insp!.finishedAt = DateTime.now();
    await LocalStore.save();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inspection saved')));

    // Load property before navigating to summary (avoid await inside builder)
    final all = await LocalStore.load();
    final prop = all.properties.firstWhere((p)=>p.id==_insp!.propertyId, orElse: ()=>Property(id:0,name:'Unknown'));
    if (!mounted) return;
    await Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => InspectionSummaryPage(inspection: _insp!, door: widget.door, property: prop)));
  }

  // Photos
  Future<void> _addPhotoFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 72);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() => _current.photosBase64.add(base64Encode(bytes)));
    await LocalStore.save();
  }

  Future<void> _addPhotoFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 72);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() => _current.photosBase64.add(base64Encode(bytes)));
    await LocalStore.save();
  }

  void _deletePhoto(int index) async {
    setState(() => _current.photosBase64.removeAt(index));
    await LocalStore.save();
  }

  void _previewPhoto(Uint8List bytes) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF0E1116),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InteractiveViewer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(bytes, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  _StepContent _fallback(String key) => _StepContent(
    title: 'Step: $key',
    question: 'Provide an assessment for "$key".',
    instructions: 'Mark Pass / Attention / Fail / N/A and add notes if needed.',
    guidelines: const ['Use consistent judgment.', 'Add notes for any Attention/Fail.'],
  );

  final Map<String, _StepContent> content = {
    'auto_closing': _StepContent(
      title: 'Automatic Closing',
      question: 'Does the door close on its own without resistance?',
      instructions: 'Open the door fully and release it. It should close smoothly and completely by itself without sticking or requiring force.',
      guidelines: [
        'The door should close from any angle.',
        'Listen for any unusual sounds during closing.',
        'Check the door closer is not damaged or leaking oil.',
      ],
    ),
    'frame_gap_edges': _StepContent(
      title: 'Frame Gap Test (Sides & Top)',
      question: 'Are the gaps between door and frame correct (3–4 mm)?',
      instructions: 'Use £1 coins to measure the gap around the door edges (sides and top). Stack coins to check consistency.',
      guidelines: [
        '£1 coin = 3 mm thick (perfect reference).',
        'Gap should be 3–4 mm around edges.',
        'Consistent all around.',
      ],
    ),
    'floor_gap': _StepContent(
      title: 'Floor Gap Test (Bottom)',
      question: 'Is the gap under the door within acceptable limits?',
      instructions: 'Measure the gap; requirements change if a drop seal is fitted.',
      guidelines: [
        'No drop seal: ≤10 mm (≈ 3 £1 coins).',
        'With drop seal: up to ~25 mm when open.',
        'Seal must activate on closing.',
      ],
      extraNote: '⚠ Without drop seal: max 10 mm.',
    ),
    'drop_seal_presence': _StepContent(
      title: 'Automatic drop/smoke seal',
      question: 'Is a drop seal fitted and working?',
      instructions: 'Confirm presence and that it deploys on closing.',
      guidelines: ['Visible at threshold', 'Full contact with floor', 'No damage or missing sections'],
    ),
    'seals': _StepContent(
      title: 'Intumescent & Smoke Seals',
      question: 'Are seals intact and correctly fitted?',
      instructions: 'Check strips around the frame/edges.',
      guidelines: ['Not painted over', 'No loose or missing sections', 'Often combined intumescent + smoke'],
    ),
    'hinges_screws': _StepContent(
      title: 'Hinges & Screws',
      question: 'Are hinges firm with correct screws and no paint on moving parts?',
      instructions: 'Tight screws (≥35 mm), no paint on knuckles.',
      guidelines: ['At least 3 hinges (FD60 may need 4)', 'All screws present and tight'],
    ),
    'glazing': _StepContent(
      title: 'Fire-Rated Glass (if present)',
      question: 'If glazed, is it certified fire-rated?',
      instructions: 'Look for visible markings; regular glass is not acceptable.',
      guidelines: ['Mark N/A if no glass', 'Check markings on glass/edge'],
    ),
    'cert_label': _StepContent(
      title: 'Certification Label',
      question: 'Is there a visible FD30/FD60/FD90 label?',
      instructions: 'Look on the top or hinge side.',
      guidelines: ['States FD rating', 'Missing label = cannot verify'],
    ),
    'surface_condition': _StepContent(
      title: 'Overall Surface Condition',
      question: 'Free from damage, cracks, warping, or holes?',
      instructions: 'Inspect both sides completely.',
      guidelines: ['Cracks/holes/splits', 'Warping/swelling', 'Around letter boxes/handles'],
    ),
  };

  String _fmtDateTime(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$d ${months[dt.month-1]} ${dt.year}, $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final i = _insp; final cs = Theme.of(context).colorScheme;
    if (i == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    if (_index < 0 || _index >= _total) _index = 0;
    final r = _current;
    final c = content[r.stepKey] ?? _fallback(r.stepKey);
    final progress = '${_index + 1}/$_total';
    final dt = i.finishedAt ?? i.startedAt;
    final controller = _controllerFor(r);

    // Prevent bottom overflow by allowing the scaffold to resize and using scroll where needed.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text('Step $progress — ${widget.door.label} • ${_fmtDateTime(dt)}'),
          leading: IconButton(icon: const Icon(Icons.close), tooltip: 'Exit', onPressed: ()=>Navigator.pop(context)),
          actions: [
            IconButton(
              tooltip: 'Back',
              onPressed: _index == 0 ? null : _goPrev,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            IconButton(
              tooltip: _index == _total - 1 ? 'Finish & Save' : 'Next',
              onPressed: _goNext,
              icon: Icon(_index == _total - 1 ? Icons.check_circle_outline : Icons.arrow_forward_ios_rounded),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (_showDisclaimer)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _DisclaimerBox(
                    text: 'Note: This app is a simple guide and does not replace a professional inspection.',
                    onClose: _dismissChecklistDisclaimer,
                  ),
                ),

              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.task_alt, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(c.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: cs.surfaceVariant.withOpacity(.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: cs.outlineVariant.withOpacity(.35)),
                        ),
                        child: Text(progress, style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ]),

                    const SizedBox(height: 8),
                    Text(c.question, style: TextStyle(fontSize: 15, color: cs.onSurface.withOpacity(.95))),
                    const SizedBox(height: 10),

                    _SectionHeader(icon: Icons.lightbulb_outline, label: 'Instructions'),
                    Text('💡 ${c.instructions}', style: TextStyle(color: cs.onSurface.withOpacity(.9))),
                    const SizedBox(height: 10),

                    _SectionHeader(icon: Icons.menu_book_outlined, label: 'Guidelines'),
                    ...c.guidelines.map((g) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('•  '),
                          Expanded(child: Text(g)),
                        ],
                      ),
                    )),
                    if (c.extraNote != null) ...[
                      const SizedBox(height: 10),
                      Text(c.extraNote!, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],

                    const SizedBox(height: 14),
                    Wrap(spacing: 8, children: [
                      _StatusPill(text: 'Pass', selected: r.status == CheckStatus.pass, selectedColor: Colors.green, onTap: () => _setStatus(CheckStatus.pass)),
                      _StatusPill(text: 'Attention', selected: r.status == CheckStatus.attention, selectedColor: Colors.amber, onTap: () => _setStatus(CheckStatus.attention)),
                      _StatusPill(text: 'Fail', selected: r.status == CheckStatus.fail, selectedColor: Colors.red, onTap: () => _setStatus(CheckStatus.fail)),
                      _StatusPill(text: 'N/A', selected: r.status == CheckStatus.na, selectedColor: Colors.grey, onTap: () => _setStatus(CheckStatus.na)),
                    ]),

                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      minLines: 3, maxLines: 5,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: () => FocusScope.of(context).unfocus(),
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      onChanged: (t) => _setNotes(t),
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional — required for Attention)',
                        hintText: 'Add key details, location, measurements…',
                      ),
                    ),

                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Photos', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        Row(children: [
                          IconButton(tooltip: 'Add from gallery', onPressed: _addPhotoFromGallery, icon: const Icon(Icons.photo_library_outlined)),
                          IconButton(tooltip: 'Take photo', onPressed: _addPhotoFromCamera, icon: const Icon(Icons.add_a_photo_outlined)),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (r.photosBase64.isEmpty)
                      Text('No photos yet', style: TextStyle(color: cs.onSurfaceVariant))
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: r.photosBase64.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final bytes = base64Decode(entry.value);
                          return Stack(
                            alignment: Alignment.topRight,
                            children: [
                              GestureDetector(
                                onTap: () => _previewPhoto(bytes),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(bytes, width: 90, height: 90, fit: BoxFit.cover),
                                ),
                              ),
                              Positioned(
                                top: -8, right: -8,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 22),
                                  onPressed: () => _deletePhoto(idx),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                  ]),
                ),
              ),

              const SizedBox(height: 16),

              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _index == 0 ? null : _goPrev,
                    icon: const Icon(Icons.arrow_back),
                    label: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Back')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _goNext,
                    icon: Icon(_index == _total - 1 ? Icons.check : Icons.arrow_forward),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(_index == _total - 1 ? 'Finish & Save' : 'Next'),
                    ),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

/* ========================= SMALL UI HELPERS ========================= */

class _StatusPill extends StatelessWidget {
  final String text;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;
  const _StatusPill({required this.text, required this.selected, required this.selectedColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color border = selected ? selectedColor : cs.outlineVariant.withOpacity(.35);
    final Color bg = selected ? selectedColor.withOpacity(.18) : cs.surfaceVariant.withOpacity(.18);
    final Color fg = selected ? selectedColor : cs.onSurface;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: border),
        ),
        child: Text(text, style: TextStyle(fontWeight: FontWeight.w700, color: fg)),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon; final String label;
  const _SectionHeader({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

/* ========================= DASHBOARD PAGE ========================= */

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  AppData? data;

  @override
  void initState() {
    super.initState();
    LocalStore.load().then((d) => setState(() => data = d));
  }

  String _outcome(Inspection i) {
    final hasFail = i.results.any((r) => r.status == CheckStatus.fail);
    final hasAttention = i.results.any((r) => r.status == CheckStatus.attention);
    final allNull = i.results.every((r) => r.status == null);
    if (allNull) return 'Not inspected';
    if (hasFail) return 'Failed';
    if (hasAttention) return 'Attention';
    return 'Passed';
  }

  String _fmtDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final d = dt.day.toString().padLeft(2, '0');
    return '$d ${months[dt.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final d = data;
    final cs = Theme.of(context).colorScheme;
    if (d == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final totalProps = d.properties.length;
    final totalDoors = d.doors.length;
    final totalInsp = d.inspections.length;

    int passed = 0, attention = 0, failed = 0, notInspected = 0;
    for (final i in d.inspections) {
      final o = _outcome(i);
      if (o == 'Passed') passed++;
      else if (o == 'Attention') attention++;
      else if (o == 'Failed') failed++;
      else notInspected++;
    }
    final passRate = totalInsp == 0 ? 0 : ((passed * 100) / totalInsp).round();

    final recentProps = d.properties.reversed.take(3).toList();
    final recentInsps = d.inspections.toList()
      ..sort((a, b) => (b.finishedAt ?? b.startedAt).compareTo(a.finishedAt ?? a.startedAt));
    final lastInsps = recentInsps.take(8).toList();

    Door? _door(int id) {
      final ds = d.doors.where((e) => e.id == id);
      return ds.isEmpty ? null : ds.first;
    }
    Property? _prop(int id) {
      final ps = d.properties.where((e) => e.id == id);
      return ps.isEmpty ? null : ps.first;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Track the status of all your fire doors', style: TextStyle(color: cs.onSurface.withOpacity(.8))),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.35,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _dashStatCard(Icons.apartment, 'Total Properties', '$totalProps'),
              _dashStatCard(Icons.meeting_room_outlined, 'Total Doors', '$totalDoors'),
              _dashStatCard(Icons.check_circle_outline, 'Inspections Completed', '$totalInsp'),
              _dashStatCard(Icons.percent, 'Pass Rate', '$passRate%'),
            ],
          ),

          const SizedBox(height: 24),
          const Text('Overall Door Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          _dashStatusRow('Passed', passed, Colors.green),
          _dashStatusRow('Attention', attention, Colors.amber),
          _dashStatusRow('Failed', failed, Colors.red),
          _dashStatusRow('Not inspected', notInspected, Colors.grey),

          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Properties', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PropertiesPage())),
                child: const Text('View all →'),
              ),
            ],
          ),
          if (recentProps.isEmpty)
            const Text('No properties yet')
          else
            ...recentProps.map((p) {
              final doors = d.doors.where((e) => e.propertyId == p.id).length;
              return Card(
                child: ListTile(
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(p.address ?? '—'),
                  trailing: Text('$doors doors', style: TextStyle(color: cs.onSurfaceVariant)),
                ),
              );
            }),

          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Inspections', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InspectionsPage())),
                child: const Text('View history →'),
              ),
            ],
          ),
          if (lastInsps.isEmpty)
            const Text('No inspections yet')
          else
            ...lastInsps.map((i) {
              final door = _door(i.doorId);
              final prop = _prop(i.propertyId);
              final status = _outcome(i);
              final color = status == 'Passed'
                  ? Colors.green
                  : status == 'Attention'
                  ? Colors.amber
                  : status == 'Failed'
                  ? Colors.red
                  : Colors.grey;
              final date = _fmtDate(i.finishedAt ?? i.startedAt);
              return Card(
                child: ListTile(
                  leading: Icon(Icons.meeting_room_outlined, color: color),
                  title: Text(door?.label ?? 'Door #${i.doorId}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${prop?.name ?? 'Unknown property'} • $status • $date'),
                ),
              );
            }),
        ]),
      ),
    );
  }

  Widget _dashStatCard(IconData icon, String title, String value) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 26),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
      ]),
    ),
  );

  Widget _dashStatusRow(String label, int count, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Icon(Icons.circle, size: 14, color: color),
      const SizedBox(width: 10),
      Expanded(child: Text(label)),
      Text('$count', style: const TextStyle(fontWeight: FontWeight.w700)),
    ]),
  );
}