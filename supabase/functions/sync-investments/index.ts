// Re-syncs accounts and holdings from Plaid for every item the calling
// user has linked. Invoked by pull-to-refresh / "Sync now" in the app.

import { adminClient, json, requireUser, syncItem } from "../_shared/plaid.ts";

Deno.serve(async (req) => {
  try {
    const user = await requireUser(req);
    const db = adminClient();

    const { data: items, error } = await db
      .from("plaid_items")
      .select("id, user_id, access_token, institution_name")
      .eq("user_id", user.id);
    if (error) throw error;

    const results: Array<{ item: string; ok: boolean; error?: string }> = [];
    for (const item of items ?? []) {
      try {
        await syncItem(db, item);
        results.push({ item: item.id, ok: true });
      } catch (e) {
        results.push({
          item: item.id,
          ok: false,
          error: e instanceof Error ? e.message : String(e),
        });
      }
    }

    return json({ synced: results });
  } catch (e) {
    const message = e instanceof Error ? e.message : String(e);
    return json({ error: message }, message === "Unauthorized" ? 401 : 500);
  }
});
