import 'package:flutter/material.dart';
import '../models/panel_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'ticket_screen.dart';

class PanelDetailScreen extends StatefulWidget {
  final String panelId;

  const PanelDetailScreen({super.key, required this.panelId});

  @override
  _PanelDetailScreenState createState() => _PanelDetailScreenState();
}

class _PanelDetailScreenState extends State<PanelDetailScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  Panel? _panel;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPanelData();
  }

  Future<void> _loadPanelData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final panel = await _apiService.fetchPanelDetails(widget.panelId);
      setState(() {
        _panel = panel;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSignIn() async {
    // Currently bypasses MSAL and sets authenticated = true
    final success = await _authService.login();
    if (success) {
      _loadPanelData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(_errorMessage!, 
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadPanelData,
                  child: const Text("Try Again"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_panel == null) return const Scaffold(body: Center(child: Text("No Data")));

    return Scaffold(
      appBar: AppBar(
        title: Text(_panel!.projectName ?? "Panel Details"),
        actions: [
          if (_authService.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await _authService.logout();
                _loadPanelData();
              },
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPublicSection(),
            if (_authService.isAuthenticated) _buildInternalSection(),
            const SizedBox(height: 20),
            if (!_authService.isAuthenticated)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _handleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.lock_open),
                  label: const Text("Unlock Traceability Data", style: TextStyle(fontSize: 16)),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TicketScreen(panelId: widget.panelId),
                    ),
                  );
                },
                icon: const Icon(Icons.report_problem),
                label: const Text("Raise Complaint Ticket", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublicSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Basic Information", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
            const Divider(),
            _infoRow("Company Name", "Newen Systems Pvt Ltd"),
            _infoRow("Project Name", _panel!.projectName ?? "N/A"),
            _infoRow("Panel Sr No", _panel!.panelSerial),
            _infoRow("Start Date", _panel!.startDate ?? "N/A"),
            _infoRow("Verified By", _panel!.verifiedBy ?? "N/A"),
            _infoRow("Status", _panel!.status),
          ],
        ),
      ),
    );
  }

  Widget _buildInternalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 24, bottom: 12, left: 4),
          child: Text("Full Traceability Report", 
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
        ),
        Card(
          elevation: 2,
          color: Colors.green.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow("Prepared By", _panel!.preparedBy ?? "N/A"),
                _infoRow("Remarks", _panel!.remarks ?? "N/A"),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 24, bottom: 12, left: 4),
          child: Text("Component List", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        if (_panel!.components == null || _panel!.components!.isEmpty)
          const Center(child: Text("No components found for this panel."))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _panel!.components!.length,
            itemBuilder: (context, index) {
              final comp = _panel!.components![index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.settings_input_component, size: 20)),
                  title: Text(comp.componentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Section: ${comp.sectionName}\nMake: ${comp.make}"),
                  trailing: Text("SN: ${comp.serialNumber}", 
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                  isThreeLine: true,
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          ),
          const Text(":  "),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
