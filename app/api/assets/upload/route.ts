import { NextRequest, NextResponse } from "next/server";
import { query } from "@/src/lib/db";
import { createAssetKey, uploadPublicAsset } from "@/src/lib/storage/assets";

const MAX_FILE_SIZE = 10 * 1024 * 1024;
const ALLOWED_TYPES = new Set([
  "image/jpeg",
  "image/png",
  "image/webp",
  "image/avif",
  "image/gif",
  "image/svg+xml",
  "application/pdf",
]);

export async function POST(request: NextRequest) {
  try {
    const form = await request.formData();
    const file = form.get("file");
    const folder = String(form.get("folder") ?? "uploads");

    if (!(file instanceof File)) {
      return NextResponse.json({ ok: false, error: "Missing file" }, { status: 400 });
    }

    if (file.size > MAX_FILE_SIZE) {
      return NextResponse.json({ ok: false, error: "File exceeds 10 MB" }, { status: 413 });
    }

    if (!ALLOWED_TYPES.has(file.type)) {
      return NextResponse.json({ ok: false, error: "Unsupported file type" }, { status: 415 });
    }

    const key = createAssetKey(file.name, folder);
    const uploaded = await uploadPublicAsset({
      key,
      body: new Uint8Array(await file.arrayBuffer()),
      contentType: file.type,
    });

    await query(
      `INSERT INTO assets (bucket, object_key, original_name, mime_type, size_bytes, public_url)
       VALUES ($1, $2, $3, $4, $5, $6)
       ON CONFLICT (object_key) DO NOTHING`,
      [uploaded.bucket, uploaded.key, file.name, file.type, file.size, uploaded.url],
    );

    return NextResponse.json({ ok: true, ...uploaded });
  } catch (error) {
    console.error("Asset upload failed", error);
    return NextResponse.json({ ok: false, error: "Upload failed" }, { status: 500 });
  }
}
