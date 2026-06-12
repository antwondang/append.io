// Exchanges a Plaid public_token (from a successful Link) for an
// access_token, stores the new item, and runs the first holdings sync.

import {
  adminClient,
  json,
  plaidRequest,
  requireUser,
  syncItem,
} from "../_shared/plaid.ts";

Deno.serve(async (req) => {
  try {
    const user = await requireUser(req);
    const body = await req.json();
    const publicToken = body.public_token as string | undefined;
    if (!publicToken) return json({ error: "public_token required" }, 400);

    const exchange = await plaidRequest("/item/public_token/exchange", {
      public_token: publicToken,
    });

    const db = adminClient();
    const { data: item, error } = await db
      .from("plaid_items")
      .upsert(
        {
          user_id: user.id,
          item_id: exchange.item_id as string,
          access_token: exchange.access_token as string,
          institution_id: body.institution_id ?? null,
          institution_name: body.institution_name ?? null,
        },
        { onConflict: "item_id" },
      )
      .select("id, user_id, access_token, institution_name")
      .single();
    if (error) throw error;

    await syncItem(db, item);

    return json({ ok: true, item_id: item.id });
  } catch (e) {
    const message = e instanceof Error ? e.message : String(e);
    return json({ error: message }, message === "Unauthorized" ? 401 : 500);
  }
});
