import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/export_service.dart';

class ExportReportScreen extends StatefulWidget {
  const ExportReportScreen({super.key});

  @override
  State<ExportReportScreen> createState() => _ExportReportScreenState();
}

class _ExportReportScreenState extends State<ExportReportScreen> {
  final _exportService = ExportService();
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();
  bool _loading = false;

  Future<void> _pickDate({required bool start}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: start ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date == null) return;
    setState(() {
      if (start) {
        _startDate = date;
      } else {
        _endDate = date;
      }
    });
  }

  Future<void> _share(String format) async {
    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final content = format == 'CSV'
          ? await _exportService.exportToCSV(
              startDate: _startDate,
              endDate: DateTime(
                _endDate.year,
                _endDate.month,
                _endDate.day,
                23,
                59,
                59,
              ),
            )
          : await _exportService.exportToJSON(
              startDate: _startDate,
              endDate: DateTime(
                _endDate.year,
                _endDate.month,
                _endDate.day,
                23,
                59,
                59,
              ),
            );
      if (content == 'No transactions to export.') {
        throw StateError(content);
      }
      await Share.share(
        content,
        subject:
            'NeoSpend $format report ${DateFormat('yyyy-MM-dd').format(_startDate)}',
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $error')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    return Scaffold(
      appBar: AppBar(title: const Text('Export Report')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Choose a date range and share your transaction report.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ListTile(
            title: const Text('Start date'),
            subtitle: Text(dateFormat.format(_startDate)),
            trailing: const Icon(Icons.calendar_month),
            onTap: () => _pickDate(start: true),
          ),
          ListTile(
            title: const Text('End date'),
            subtitle: Text(dateFormat.format(_endDate)),
            trailing: const Icon(Icons.calendar_month),
            onTap: () => _pickDate(start: false),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _loading ? null : () => _share('CSV'),
            icon: const Icon(Icons.table_chart_outlined),
            label: Text(_loading ? 'Preparing...' : 'Share CSV'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _loading ? null : () => _share('JSON'),
            icon: const Icon(Icons.data_object),
            label: const Text('Share JSON'),
          ),
        ],
      ),
    );
  }
}
