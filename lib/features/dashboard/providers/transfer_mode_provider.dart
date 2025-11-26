import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/card.dart' as card_model;

/// Represents the state when in transfer mode
class TransferModeState {
  final card_model.Card sourceCard;
  final String accountId;

  const TransferModeState({required this.sourceCard, required this.accountId});
}

/// Provider to manage transfer mode state
/// When not null, the user is in transfer mode and needs to select a destination
class TransferModeNotifier extends StateNotifier<TransferModeState?> {
  TransferModeNotifier() : super(null);

  /// Enter transfer mode with the selected source card
  void enterTransferMode(card_model.Card sourceCard, String accountId) {
    state = TransferModeState(sourceCard: sourceCard, accountId: accountId);
  }

  /// Exit transfer mode
  void exitTransferMode() {
    state = null;
  }

  /// Check if we're in transfer mode
  bool get isInTransferMode => state != null;
}

final transferModeProvider =
    StateNotifierProvider<TransferModeNotifier, TransferModeState?>((ref) {
      return TransferModeNotifier();
    });
