/// [BackupModel] - Modelo de dados representando um backup corporativo.
///
/// Esta classe encapsula todos os dados relacionados a um backup no sistema Keeply,
/// incluindo informações como ID, nome, status, tamanho, data de criação e usuário responsável.
///
/// O modelo segue o padrão imutável (todos os campos são final), garantindo
/// que os dados não sejam alterados acidentalmente após a criação.
///
/// Uso típico:
/// ```dart
/// final backup = BackupModel(
///   id: '1',
///   name: 'Backup Banco de Dados',
///   status: 'success',
///   sizeInBytes: 1048576,
///   createdAt: DateTime.now(),
///   userName: 'João Silva',
/// );
/// ```
class BackupModel {
  /// Identificador único do backup (UUID ou ID do banco de dados)
  final String id;

  /// Nome descritivo do backup
  final String name;

  /// Status do backup: 'success', 'warning', 'error', 'pending'
  final String status;

  /// Tamanho do backup em bytes
  final int sizeInBytes;

  /// Data e hora em que o backup foi criado
  final DateTime createdAt;

  /// Nome do usuário que realizou o backup
  final String userName;

  /// Descrição opcional do backup
  final String? description;

  /// Caminho ou local onde o backup está armazenado
  final String? storageLocation;

  /// Cria uma nova instância de [BackupModel] com todos os parâmetros necessários.
  ///
  /// Parâmetros:
  /// - [id]: Identificador único (obrigatório)
  /// - [name]: Nome do backup (obrigatório)
  /// - [status]: Status atual (obrigatório)
  /// - [sizeInBytes]: Tamanho em bytes (obrigatório)
  /// - [createdAt]: Data de criação (obrigatório)
  /// - [userName]: Nome do usuário (obrigatório)
  /// - [description]: Descrição opcional
  /// - [storageLocation]: Localização de armazenamento opcional
  const BackupModel({
    required this.id,
    required this.name,
    required this.status,
    required this.sizeInBytes,
    required this.createdAt,
    required this.userName,
    this.description,
    this.storageLocation,
  });

  /// Cria uma instância de [BackupModel] a partir de um mapa JSON.
  ///
  /// Este método é útil para desserializar dados recebidos de APIs ou bancos de dados.
  ///
  /// Exemplo:
  /// ```dart
  /// final json = {
  ///   'id': '123',
  ///   'name': 'Backup DB',
  ///   'status': 'success',
  ///   'size': 1024,
  ///   'created_at': '2026-04-13T10:30:00',
  ///   'user_name': 'João',
  /// };
  /// final backup = BackupModel.fromJson(json);
  /// ```
  factory BackupModel.fromJson(Map<String, dynamic> json) {
    return BackupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      sizeInBytes: json['size'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: json['user_name'] as String,
      description: json['description'] as String?,
      storageLocation: json['storage_location'] as String?,
    );
  }

  /// Converte a instância atual em um mapa JSON.
  ///
  /// Este método é útil para serializar dados antes de enviar para APIs ou salvar em banco de dados.
  ///
  /// Retorna um [Map<String, dynamic>] com todos os campos do backup.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'size': sizeInBytes,
      'created_at': createdAt.toIso8601String(),
      'user_name': userName,
      'description': description,
      'storage_location': storageLocation,
    };
  }

  /// Cria uma cópia do backup com campos modificados.
  ///
  /// Método útil para atualizações imutáveis, permitindo criar uma nova
  /// instância com alguns campos alterados sem modificar o original.
  ///
  /// Exemplo:
  /// ```dart
  /// final updatedBackup = backup.copyWith(status: 'success');
  /// ```
  BackupModel copyWith({
    String? id,
    String? name,
    String? status,
    int? sizeInBytes,
    DateTime? createdAt,
    String? userName,
    String? description,
    String? storageLocation,
  }) {
    return BackupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      description: description ?? this.description,
      storageLocation: storageLocation ?? this.storageLocation,
    );
  }

  /// Retorna uma representação em string do backup para debug.
  @override
  String toString() {
    return 'BackupModel(id: $id, name: $name, status: $status, size: $sizeInBytes, createdAt: $createdAt, userName: $userName)';
  }

  /// Verifica se dois backups são iguais comparando todos os campos.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BackupModel &&
        other.id == id &&
        other.name == name &&
        other.status == status &&
        other.sizeInBytes == sizeInBytes &&
        other.createdAt == createdAt &&
        other.userName == userName;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, status, sizeInBytes, createdAt, userName);
  }
}
