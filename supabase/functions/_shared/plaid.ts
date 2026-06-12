// Shared Plaid helpers for edge functions.
// Required function secrets (set with `supabase secrets set`):
//   PLAID_CLIENT_ID, PLAID_SECRET, PLAID_ENV (sandbox | development | production)

import { createClient, SupabaseClient } from "jsr:@supabase/supabase-js@2";

const PLAID_BASE: Record<string, string> = {
  sandbox: "https://sandbox.plaid.com",
  development: "https://development.plaid.com",
  production: "https://production.plaid.com",
};

export function plaidUrl(path: string): string {
  const env = Deno.env.get("PLAID_ENV") ?? "sandbox";
  return `${PLAID_BASE[env] ?? PLAID_BASE.sandbox}${path}`;
}

export async function plaidRequest(
  path: string,
  body: Record<string, unknown>,
): Promise<Record<string, unknown>> {
  const response = await fetch(plaidUrl(path), {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      client_id: Deno.env.get("PLAID_CLIENT_ID"),
      secret: Deno.env.get("PLAID_SECRET"),
      ...body,
    }),
  });
  const data = await response.json();
  if (!response.ok) {
    throw new Error(
      `Plaid ${path} failed: ${data.error_code ?? response.status} ${
        data.error_message ?? ""
      }`,
    );
  }
  return data;
}

/** Service-role client — bypasses RLS; only ever used inside functions. */
export function adminClient(): SupabaseClient {
  return createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
}

/** Resolves the calling user from the request's Authorization header. */
export async function requireUser(req: Request) {
  const authClient = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: req.headers.get("Authorization")! } } },
  );
  const { data, error } = await authClient.auth.getUser();
  if (error || !data.user) throw new Error("Unauthorized");
  return data.user;
}

export function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

interface PlaidItemRow {
  id: string;
  user_id: string;
  access_token: string;
  institution_name: string | null;
}

/** Pulls accounts + holdings for one item from Plaid and upserts them. */
export async function syncItem(
  db: SupabaseClient,
  item: PlaidItemRow,
): Promise<void> {
  const data = await plaidRequest("/investments/holdings/get", {
    access_token: item.access_token,
  });

  const accounts = (data.accounts ?? []) as Array<Record<string, any>>;
  const securities = (data.securities ?? []) as Array<Record<string, any>>;
  const holdings = (data.holdings ?? []) as Array<Record<string, any>>;

  const securityById = new Map(securities.map((s) => [s.security_id, s]));

  // Upsert accounts, remembering plaid_account_id -> row uuid.
  const accountIdMap = new Map<string, string>();
  for (const account of accounts) {
    const { data: row, error } = await db
      .from("accounts")
      .upsert(
        {
          user_id: item.user_id,
          item_id: item.id,
          plaid_account_id: account.account_id,
          name: account.name ?? account.official_name ?? "Account",
          institution_name: item.institution_name,
          type: account.type,
          subtype: account.subtype,
          mask: account.mask,
          balance: account.balances?.current ?? 0,
          updated_at: new Date().toISOString(),
        },
        { onConflict: "plaid_account_id" },
      )
      .select("id")
      .single();
    if (error) throw error;
    accountIdMap.set(account.account_id, row.id);
  }

  for (const holding of holdings) {
    const accountUuid = accountIdMap.get(holding.account_id);
    if (!accountUuid) continue;
    const security = securityById.get(holding.security_id);
    const { error } = await db.from("holdings").upsert(
      {
        user_id: item.user_id,
        account_id: accountUuid,
        plaid_security_id: holding.security_id,
        ticker: security?.ticker_symbol ?? null,
        name: security?.name ?? "Unknown security",
        quantity: holding.quantity ?? 0,
        price: holding.institution_price ?? 0,
        value: holding.institution_value ?? 0,
        cost_basis: holding.cost_basis,
        updated_at: new Date().toISOString(),
      },
      { onConflict: "account_id,plaid_security_id" },
    );
    if (error) throw error;
  }
}
