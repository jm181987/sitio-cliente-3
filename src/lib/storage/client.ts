import {
  CreateBucketCommand,
  HeadBucketCommand,
  PutBucketCorsCommand,
  S3Client,
} from "@aws-sdk/client-s3";
import { STORAGE_BUCKETS, STORAGE_CONFIG, assertStorageConfigured } from "./config";

let client: S3Client | null = null;

export function getStorageClient() {
  assertStorageConfigured();

  if (!client) {
    client = new S3Client({
      endpoint: STORAGE_CONFIG.endpoint,
      region: STORAGE_CONFIG.region,
      forcePathStyle: STORAGE_CONFIG.forcePathStyle,
      credentials: {
        accessKeyId: STORAGE_CONFIG.accessKeyId!,
        secretAccessKey: STORAGE_CONFIG.secretAccessKey!,
      },
    });
  }

  return client;
}

async function ensureBucket(bucket: string) {
  const s3 = getStorageClient();

  try {
    await s3.send(new HeadBucketCommand({ Bucket: bucket }));
  } catch {
    await s3.send(new CreateBucketCommand({ Bucket: bucket }));
  }
}

export async function ensureStorageBuckets() {
  const s3 = getStorageClient();

  await ensureBucket(STORAGE_BUCKETS.publicAssets);
  await ensureBucket(STORAGE_BUCKETS.privateAssets);

  await s3.send(
    new PutBucketCorsCommand({
      Bucket: STORAGE_BUCKETS.publicAssets,
      CORSConfiguration: {
        CORSRules: [
          {
            AllowedMethods: ["GET", "HEAD", "PUT"],
            AllowedOrigins: [process.env.NEXT_PUBLIC_SITE_URL ?? "*"],
            AllowedHeaders: ["*"],
            ExposeHeaders: ["ETag"],
          },
        ],
      },
    }),
  );

  return STORAGE_BUCKETS;
}
