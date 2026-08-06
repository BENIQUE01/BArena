import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  try {
    const body = await req.json();
    const callback = body?.Body?.stkCallback;

    if (!callback) {
      return new Response(JSON.stringify({ received: true }), { status: 200 });
    }

    const checkoutRequestId = callback.CheckoutRequestID;
    const resultCode = callback.ResultCode;

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    if (resultCode === 0) {
      // Payment succeeded — pull the M-Pesa receipt number out of the metadata
      const items = callback.CallbackMetadata?.Item || [];
      const receipt = items.find((i: any) => i.Name === "MpesaReceiptNumber")?.Value || null;

      await supabase
        .from("category_entries")
        .update({
          payment_status: "confirmed",
          mpesa_code: receipt,
        })
        .eq("checkout_request_id", checkoutRequestId);
    } else {
      // Payment failed or was cancelled — leave it pending so they can retry
      await supabase
        .from("category_entries")
        .update({ payment_status: "pending" })
        .eq("checkout_request_id", checkoutRequestId);
    }

    return new Response(JSON.stringify({ received: true }), { status: 200 });
  } catch (err) {
    console.error(err);
    return new Response(JSON.stringify({ received: true }), { status: 200 });
  }
});