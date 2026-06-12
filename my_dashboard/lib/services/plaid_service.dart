import 'dart:async';

import 'package:plaid_flutter/plaid_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Drives the Plaid Link flow.
///
/// Sequence:
///  1. `create-link-token` edge function -> link_token (Plaid secret stays
///     server-side).
///  2. Open the native Plaid Link UI.
///  3. On success, send the public_token to `exchange-public-token`, which
///     stores the access token and runs the first holdings sync.
class PlaidService {
  PlaidService._();
  static final PlaidService instance = PlaidService._();

  StreamSubscription<LinkSuccess>? _successSub;
  StreamSubscription<LinkExit>? _exitSub;

  SupabaseClient get _db => Supabase.instance.client;

  /// Opens Plaid Link. [onLinked] fires after the new institution's holdings
  /// have been synced; [onError] receives a user-displayable message.
  Future<void> connect({
    required Future<void> Function(String institutionName) onLinked,
    required void Function(String message) onError,
  }) async {
    String linkToken;
    try {
      final response = await _db.functions.invoke('create-link-token');
      final data = response.data as Map<String, dynamic>?;
      final token = data?['link_token'] as String?;
      if (token == null) {
        onError('Backend did not return a link token.');
        return;
      }
      linkToken = token;
    } catch (e) {
      onError('Could not start Plaid Link: $e');
      return;
    }

    await _successSub?.cancel();
    await _exitSub?.cancel();

    _successSub = PlaidLink.onSuccess.listen((event) async {
      final institution = event.metadata.institution?.name ?? 'Institution';
      try {
        await _db.functions.invoke('exchange-public-token', body: {
          'public_token': event.publicToken,
          'institution_id': event.metadata.institution?.id,
          'institution_name': institution,
        });
        await onLinked(institution);
      } catch (e) {
        onError('Linked $institution, but saving it failed: $e');
      }
    });

    _exitSub = PlaidLink.onExit.listen((event) {
      final error = event.error;
      if (error != null) {
        onError(error.displayMessage ?? error.message);
      }
    });

    await PlaidLink.create(
      configuration: LinkTokenConfiguration(token: linkToken),
    );
    await PlaidLink.open();
  }
}
