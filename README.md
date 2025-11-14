# 🌾 Sistema de Gestão de Cana-de-Açúcar

Sistema completo para gestão de fazendas de cana-de-açúcar desenvolvido em Flutter.

## 👤 Desenvolvedor

**Rafael Henrique Vernici**
- 📧 Email: afcrc.olimpia@gmail.com
- 🐙 GitHub: [@afcrcolimpia-cloud](https://github.com/afcrcolimpia-cloud)
- 📍 Localização: Olímpia, São Paulo, Brasil

## 📱 Funcionalidades

- ✅ Cadastro de Proprietários
- ✅ Cadastro de Propriedades
- ✅ Cadastro de Talhões
- ✅ Dashboard com Estatísticas em Tempo Real
- ✅ Gráficos Interativos (Pizza, Barras, Progresso)
- ✅ Controle de Variedades de Cana
- ✅ Registro de Colheitas
- ✅ Controle de Aplicações (Defensivos/Fertilizantes)
- ✅ Registro de Precipitação
- ✅ Pull-to-Refresh para atualização de dados
- ✅ Interface responsiva e moderna

## 🚀 Tecnologias Utilizadas

- **Flutter 3.x** - Framework principal
- **Dart** - Linguagem de programação
- **Supabase** - Backend as a Service
- **PostgreSQL** - Banco de dados
- **fl_chart** - Gráficos interativos

## 🔧 Instalação e Configuração

### Pré-requisitos

- Flutter SDK 3.0 ou superior
- Dart SDK 3.0 ou superior
- Conta no Supabase (gratuita)

### 1. Clonar o Repositório
```bash
git clone https://github.com/afcrcolimpia-cloud/gestao-cana-app.git
cd gestao-cana-app
```

### 2. Instalar Dependências
```bash
flutter pub get
```

### 3. Configurar Banco de Dados

1. Crie uma conta em [Supabase](https://supabase.com)
2. Crie um novo projeto
3. No SQL Editor, execute o script de criação das tabelas
4. Copie as credenciais de API

### 4. Configurar Credenciais

1. Copie `lib/config/database_config.example.dart`
2. Renomeie para `database_config.dart`
3. Adicione suas credenciais do Supabase

### 5. Executar o Aplicativo
```bash
flutter run
```

## 📦 Build para Produção

### Android (APK)
```bash
flutter build apk --release
```

O APK estará em: `build/app/outputs/flutter-apk/app-release.apk`

### iOS (apenas macOS)
```bash
flutter build ios --release
```

## 📊 Estrutura do Banco de Dados

O sistema utiliza 7 tabelas principais:

- `proprietarios` - Dados dos proprietários
- `propriedades` - Informações das fazendas
- `talhoes` - Detalhes dos talhões de plantio
- `variedades` - Catálogo de variedades de cana
- `colheitas` - Registros de colheita
- `aplicacoes` - Controle de aplicações agrícolas
- `precipitacao` - Dados pluviométricos

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues e pull requests.

## 📄 Licença

Este projeto é privado e de uso exclusivo.

## 📞 Contato

Rafael Henrique Vernici
- 📧 Email: afcrc.olimpia@gmail.com
- 🐙 GitHub: [@afcrcolimpia-cloud](https://github.com/afcrcolimpia-cloud)

---

Desenvolvido com ❤️ em Olímpia/SP por Rafael Henrique Vernici