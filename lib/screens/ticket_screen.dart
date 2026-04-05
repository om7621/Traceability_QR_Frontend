import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TicketScreen extends StatefulWidget {
  final String panelId;

  const TicketScreen({super.key, required this.panelId});

  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isSubmitting = false;

  Future<void> _submitTicket() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      
      final success = await _apiService.raiseTicket(
        widget.panelId,
        _descriptionController.text,
        _contactController.text,
      );

      setState(() => _isSubmitting = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ticket raised successfully!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to raise ticket. Please try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Raise Complaint Ticket")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Panel Serial Number: ${widget.panelId}", 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description of issue",
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) => value!.isEmpty ? "Please enter description" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: "Contact Email/Phone",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Please enter contact info" : null,
              ),
              const SizedBox(height: 24),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitTicket,
                        child: const Text("Submit Ticket"),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
