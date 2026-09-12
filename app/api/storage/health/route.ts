import { NextResponse } from "next/server";
import { ensureStorageBuckets } from "@/src/lib/storage/client";

export const dynamic = "force-dynamic";

export async function GET() {
  try {
    const buckets = await ensureStorageBuckets();
    return NextResponse.json({ ok: true, storage: "connected", buckets });
  } catch (error) {
    console.error("Storage health check failed", error);
    return NextResponse.json(
      { ok: false, storage: "unavailable" },
      { status: 503 },
    );
  }
}
