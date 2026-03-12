// (apenas imports acima, nenhum bloco solto)

import 'package:flutter/material.dart';
import '../models/models.dart';

class MonitoramentoPragasScreen extends StatefulWidget {
	final ContextoPropriedade contexto;
	const MonitoramentoPragasScreen({Key? key, required this.contexto}) : super(key: key);

	@override
	State<MonitoramentoPragasScreen> createState() => _MonitoramentoPragasScreenState();
}

class _MonitoramentoPragasScreenState extends State<MonitoramentoPragasScreen> {
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Monitoramento de Pragas')),
			body: const Center(child: Text('Em desenvolvimento')),
		);
	}
}
