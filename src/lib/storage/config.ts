export const STORAGE_BUCKETS = {
  publicAssets: process.env.STORAGE_PUBLIC_BUCKET ?? "public-assets",
  privateAssets: process.env.STORAGE_PRIVATE_BUCKET ?? "private-assets",
} as const;

export const STORAGE_CONFIG = {
  endpoint: process.env.STORAGE_ENDPOINT,
  region: process.env.STORAGE_REGION ?? "auto",
  accessKeyId: process.env.STORAGE_ACCESS_KEY_ID,
  secretAccessKey: process.env.STORAGE_SECRET_ACCESS_KEY,
  publicBaseUrl: process.env.STORAGE_PUBLIC_BASE_URL,
  forcePathStyle: process.env.STORAGE_FORCE_PATH_STYLE !== "false",
};

export function assertStorageConfigured() {
  const missing = [
    ["STORAGE_ENDPOINT", STORAGE_CONFIG.endpoint],
    ["STORAGE_ACCESS_KEY_ID", STORAGE_CONFIG.accessKeyId],
    ["STORAGE_SECRET_ACCESS_KEY", STORAGE_CONFIG.secretAccessKey],
  ]
    .filter(([, value]) => !value)
    .map(([key]) => key);

  if (missing.length) {
    throw new Error(`Storage is not configured. Missing: ${missing.join(", ")}`);
  }
}
