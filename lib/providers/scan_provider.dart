import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/receipt_analysis_service.dart';

final receiptAnalysisServiceProvider =
    Provider<ReceiptAnalysisService>((ref) => ReceiptAnalysisService());

class ScanState {
  final Uint8List? imageBytes;
  final String? fileName;
  final bool isAnalyzing;
  final ReceiptAnalysisResult? result;
  final String? error;

  ScanState({
    this.imageBytes,
    this.fileName,
    this.isAnalyzing = false,
    this.result,
    this.error,
  });

  ScanState copyWith({
    Uint8List? imageBytes,
    String? fileName,
    bool? isAnalyzing,
    ReceiptAnalysisResult? result,
    String? error,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return ScanState(
      imageBytes: imageBytes ?? this.imageBytes,
      fileName: fileName ?? this.fileName,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      result: clearResult ? null : (result ?? this.result),
      error: clearError ? null : (error ?? this.error),
    );
  }

  ScanState reset() {
    return ScanState();
  }
}

class ScanNotifier extends Notifier<ScanState> {
  @override
  ScanState build() => ScanState();

  ReceiptAnalysisService get _service =>
      ref.read(receiptAnalysisServiceProvider);

  void setImage(Uint8List bytes, String fileName) {
    state = state.copyWith(
      imageBytes: bytes,
      fileName: fileName,
      clearResult: true,
      clearError: true,
    );
  }

  Future<void> analyzeReceipt() async {
    if (state.imageBytes == null || state.fileName == null) return;

    state = state.copyWith(isAnalyzing: true, clearError: true);

    try {
      final result = await _service.analyzeReceipt(
        state.imageBytes!,
        state.fileName!,
      );
      state = state.copyWith(isAnalyzing: false, result: result);
    } catch (e) {
      state = state.copyWith(isAnalyzing: false, error: e.toString());
    }
  }

  void reset() {
    state = state.reset();
  }
}

final scanNotifierProvider =
    NotifierProvider<ScanNotifier, ScanState>(ScanNotifier.new);
