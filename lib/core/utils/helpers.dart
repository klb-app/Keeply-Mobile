/// [Helpers] - Classe utilitária com funções auxiliares para o aplicativo.
///
/// Esta classe contém métodos estáticos para operações comuns, como:
/// - Formatação de dados
/// - Validações
/// - Utilitários gerais
///
/// Todas as funções são puras e não possuem estado, podendo ser chamadas
/// de qualquer lugar da aplicação sem efeitos colaterais.
class Helpers {
  /// Formata uma data [DateTime] para o formato brasileiro (DD/MM/YYYY HH:mm)
  ///
  /// Parâmetros:
  /// - [date]: A data a ser formatada. Se null, retorna string vazia.
  ///
  /// Retorna:
  /// - String formatada no padrão brasileiro
  /// - String vazia se [date] for null
  ///
  /// Exemplo:
  /// ```dart
  /// final formatted = Helpers.formatDate(DateTime.now());
  /// // Saída: "13/04/2026 14:30"
  /// ```
  static String formatDate(DateTime? date) {
    if (date == null) return '';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  /// Formata um tamanho de arquivo em bytes para uma representação legível
  ///
  /// Parâmetros:
  /// - [bytes]: Tamanho em bytes. Se null ou negativo, retorna '0 B'.
  ///
  /// Retorna:
  /// - String formatada com unidade apropriada (B, KB, MB, GB, TB)
  ///
  /// Exemplo:
  /// ```dart
  /// final size = Helpers.formatFileSize(1536);
  /// // Saída: "1.5 KB"
  /// ```
  static String formatFileSize(int? bytes) {
    if (bytes == null || bytes < 0) return '0 B';

    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int unitIndex = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(size < 10 && unitIndex > 0 ? 1 : 0)} ${units[unitIndex]}';
  }

  /// Valida se uma string é um email válido
  ///
  /// Parâmetros:
  /// - [email]: String a ser validada
  ///
  /// Retorna:
  /// - true se o email tiver formato válido
  /// - false caso contrário
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Retorna o ícone apropriado baseado no status do backup
  ///
  /// Parâmetros:
  /// - [status]: Status do backup (success, warning, error)
  ///
  /// Retorna:
  /// - IconData correspondente ao status
  static IconData getIconForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'concluído':
        return Icons.check_circle_outline;
      case 'warning':
      case 'pendente':
        return Icons.warning_amber_outlined;
      case 'error':
      case 'falha':
        return Icons.error_outline;
      default:
        return Icons.help_outline;
    }
  }

  /// Retorna a cor apropriada baseada no status do backup
  ///
  /// Parâmetros:
  /// - [status]: Status do backup
  ///
  /// Retorna:
  /// - Color correspondente ao status
  static IconData getColorForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'concluído':
        return Icons.check_circle_outline;
      case 'warning':
      case 'pendente':
        return Icons.warning_amber_outlined;
      case 'error':
      case 'falha':
        return Icons.error_outline;
      default:
        return Icons.help_outline;
    }
  }
}
