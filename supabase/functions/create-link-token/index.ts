// Creates a Plaid link_token for the authenticated user.
// The Flutter app calls this before opening Plaid Link.

import { json, plaidRequest, requireUser } from "../_shared/plaid.ts";

Deno.serve(async (req) => {
  try {
    const user = await requireUser(req);

    const data = await plaidRequest("/link/token/create", {
      client_name: "append.io",
      language: "en",
      country_codes: ["US"],
      products: ["investments"],
      user: { client_user_id: user.id },
    });

    return json({ link_token: data.link_token });
  } catch (e) {
    const message = e instanceof Error ? e.message : String(e);
    return json({ error: message }, message === "Unauthorized" ? 401 : 500);
  }
});
