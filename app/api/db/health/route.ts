import { NextResponse } from "next/server";
import { query } from "@/src/lib/db";

export const dynamic = "force-dynamic";

export async function GET() {
  try {
    const startedAt = Date.now();
    await query("SELECT 1");

    return NextResponse.json({
      ok: true,
      database: "connected",
      latencyMs: Date.now() - startedAt,
    });
  } catch (error) {
    console.error("Database health check failed", error);

    return NextResponse.json(
      {
        ok: false,
        database: "unavailable",
      },
      { status: 503 },
    );
  }
}
