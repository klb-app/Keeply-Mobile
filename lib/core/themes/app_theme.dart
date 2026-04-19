import 'package:flutter/material.dart';

/// [AppTheme] - Classe responsável por centralizar todas as configurações de tema do aplicativo.
/// 
/// Esta classe fornece métodos estáticos para criar e configurar o tema do Material Design,
/// garantindo consistência visual em toda a aplicação Keeply Mobile.
/// 
/// Uso:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   home: ...
/// )
/// ```
class AppTheme {
  /// Cor primária do Keeply - Azul corporativo que transmite confiança e segurança
  static const Color primaryColor = Color(0xFF1976D2);
  
  /// Cor secundária - Complementa a primária para ações e destaques
  static const Color secondaryColor = Color(0xFF42A5F5);
  
  /// Cor de destaque para ações positivas (backups bem-sucedidos)
  static const Color successColor = Color(0xFF4CAF50);
  
  /// Cor de alerta para ações que requerem atenção (backups pendentes)
  static const Color warningColor = Color(0xFFFF9800);
  
  /// Cor de erro para ações críticas (backups falhados)
  static const Color errorColor = Color(0xFFF44336);
  
  /// Cor de fundo clara para cards e superfícies
  static const Color surfaceLight = Color(0xFFFAFAFA);
  
  /// Cria o tema claro do aplicativo com todas as configurações de design
  /// 
  /// Retorna um [ThemeData] configurado com:
  /// - Esquema de cores baseado na cor primária
  /// - Tipografia Material 3
  /// - Configurações de AppBar, ElevatedButton e outros widgets
  static ThemeData lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceLight,
        error: errorColor,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
