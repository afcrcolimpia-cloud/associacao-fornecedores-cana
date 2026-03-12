// (apenas imports acima, nenhum bloco solto)


import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/monitoramento_praga_service.dart';

class MonitoramentoPragasScreen extends StatefulWidget {
	final ContextoPropriedade contexto;
	const MonitoramentoPragasScreen({super.key, required this.contexto});

	@override
	State<MonitoramentoPragasScreen> createState() => _MonitoramentoPragasScreenState();
}

class _MonitoramentoPragasScreenState extends State<MonitoramentoPragasScreen> {
	final MonitoramentoPragaService _service = MonitoramentoPragaService();
	List<MonitoramentoPraga> _monitoramentos = [];
	bool _loading = true;

	@override
	void initState() {
		super.initState();
		_carregarMonitoramentos();
	}

	Future<void> _carregarMonitoramentos() async {
		setState(() => _loading = true);
		try {
			final lista = await _service.buscarPorPropriedade(widget.contexto.propriedade.id);
			setState(() {
				_monitoramentos = lista;
				_loading = false;
			});
		} catch (e) {
			setState(() => _loading = false);
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Monitoramento de Pragas')),
			body: _loading
					? const Center(child: CircularProgressIndicator())
					: _monitoramentos.isEmpty
							? const Center(child: Text('Nenhum monitoramento cadastrado.'))
							: ListView.builder(
									itemCount: _monitoramentos.length,
									itemBuilder: (context, index) {
										final m = _monitoramentos[index];
										return ListTile(
											title: Text(m.pragaCurta),
											subtitle: Text('Nível: ${m.nivelFormatado} | Data: ${m.dataMonitoramento.day}/${m.dataMonitoramento.month}/${m.dataMonitoramento.year}'),
											trailing: m.isCritico
													? const Icon(Icons.warning, color: Colors.red)
													: m.isAlto
															? const Icon(Icons.warning, color: Colors.orange)
															: null,
											onTap: () {
												// TODO: abrir tela de edição
											},
										);
									},
								),
			floatingActionButton: FloatingActionButton(
				onPressed: () {
					// TODO: abrir tela de cadastro
				},
				tooltip: 'Novo Monitoramento',
				child: const Icon(Icons.add),
			),
		);
	}
}
