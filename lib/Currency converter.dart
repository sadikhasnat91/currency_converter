import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(CurrencyConverterApp());
}

class CurrencyConverterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: CurrencyConverterHome(),
    );
  }
}

class CurrencyConverterHome extends StatefulWidget {
  @override
  _CurrencyConverterHomeState createState() => _CurrencyConverterHomeState();
}

class _CurrencyConverterHomeState extends State<CurrencyConverterHome> {
  List<String> currencies = [];
  String fromCurrency = 'USD';
  String toCurrency = 'INR';
  TextEditingController amountController = TextEditingController();
  String result = '';

  @override
  void initState() {
    super.initState();
    fetchCurrencies();
  }

  Future<void> fetchCurrencies() async {
    final url = Uri.parse('https://open.er-api.com/v6/latest/USD');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final keys = (data['rates'] as Map<String, dynamic>).keys.toList();
      setState(() {
        currencies = keys..sort();
      });
    } else {
      throw Exception('Failed to load currencies');
    }
  }

  Future<void> convert() async {
    final url = Uri.parse('https://open.er-api.com/v6/latest/$fromCurrency');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final rates = data['rates'];
      double amount = double.tryParse(amountController.text) ?? 0.0;
      double rate = rates[toCurrency];

      setState(() {
        double converted = amount * rate;
        String symbol = getCurrencySymbol(toCurrency);
        result = '$symbol ${converted.toStringAsFixed(2)}';
      });
    } else {
      throw Exception('Failed to convert currency');
    }
  }

  String getCurrencySymbol(String code) {
    switch (code) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'INR':
        return '₹';
      case 'PKR':
        return '₨';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CNY':
        return '¥';
      case 'AUD':
        return 'A\$';
      case 'CAD':
        return 'C\$';
      default:
        return code; // fallback to currency code if symbol not found
    }
  }

  Widget buildDropdown(String value, bool isFrom) {
    return DropdownButtonFormField<String>(
      value: value,
      items: currencies
          .map((e) => DropdownMenuItem(
        child: Text(e),
        value: e,
      ))
          .toList(),
      onChanged: (val) {
        setState(() {
          if (isFrom) {
            fromCurrency = val!;
          } else {
            toCurrency = val!;
          }
        });
      },
      decoration: InputDecoration(
        labelText: isFrom ? 'From' : 'To',
        border: OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: currencies.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: buildDropdown(fromCurrency, true)),
                const SizedBox(width: 10),
                Icon(Icons.compare_arrows),
                const SizedBox(width: 10),
                Expanded(child: buildDropdown(toCurrency, false)),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: convert,
              child: Text('Convert'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding:
                EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              result.isEmpty ? 'Conversion Result' : result,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
