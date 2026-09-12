import { GetObjectCommand, PutObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { randomUUID } from "crypto";
import { getStorageClient } from "./client";
import { STORAGE_BUCKETS, STORAGE_CONFIG } from "./config";

function sanitizeFilename(name: string) {
  return name.toLowerCase().replace(/[^a-z0-9._-]+/g, "-");
}

export function createAssetKey(filename: string, folder = "uploads") {
  const cleanFolder = folder.replace(/[^a-zA-Z0-9/_-]+/g, "-");
  return `${cleanFolder}/${new Date().toISOString().slice(0, 10)}/${randomUUID()}-${sanitizeFilename(filename)}`;
}

export function getPublicAssetUrl(key: string) {
  if (!STORAGE_CONFIG.publicBaseUrl) return null;
  return `${STORAGE_CONFIG.publicBaseUrl.replace(/\/$/, "")}/${key}`;
}

export async function uploadPublicAsset(input: {
  key: string;
  body: Uint8Array;
  contentType: string;
}) {
  await getStorageClient().send(
    new PutObjectCommand({
      Bucket: STORAGE_BUCKETS.publicAssets,
      Key: input.key,
      Body: input.body,
      ContentType: input.contentType,
      CacheControl: "public, max-age=31536000, immutable",
    }),
  );

  return {
    bucket: STORAGE_BUCKETS.publicAssets,
    key: input.key,
    url: getPublicAssetUrl(input.key),
  };
}

export async function createPrivateDownloadUrl(key: string, expiresIn = 900) {
  return getSignedUrl(
    getStorageClient(),
    new GetObjectCommand({ Bucket: STORAGE_BUCKETS.privateAssets, Key: key }),
    { expiresIn },
  );
}
