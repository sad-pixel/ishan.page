---
title: How to Generate Presigned URLs for R2 When Using Cloudflare Workers (And Make Sure They Actually Work)
slug: cloudflare-r2-workers-presigned
date: 2026-01-14
tags:
  - cloudflare
  - r2
  - workers
  - presigned-urls
  - aws
  - s3
  - cors
---

So you want to let users upload files directly to Cloudflare R2 from their browser? Great idea! Presigned URLs are the way to do it. 

You follow the documentation, you generate a presigned URL, and... **403 Forbidden**.

Let me show you how to fix all of this.

## Step 1: Use the Right Library

**Don't use** the official AWS SDK. It doesn't work in Cloudflare Workers because it needs Node.js APIs that Workers don't have.

**Do use** `aws4fetch` - it's built specifically for Workers and uses the Web APIs that Workers actually support.

```bash
npm install aws4fetch
```

## Step 2: Generate the Presigned URL

Here's the code that actually works:

```typescript
import { AwsClient } from 'aws4fetch';

async function generatePresignedUrl(
  key: string,           // e.g., "uploads/myfile.mp3"
  expiresIn: number      // seconds, e.g., 3600 = 1 hour
) {
  // Create the client
  const client = new AwsClient({
    accessKeyId: env.R2_ACCESS_KEY_ID,
    secretAccessKey: env.R2_SECRET_ACCESS_KEY,
    service: 's3',
    region: 'auto',  // R2 uses 'auto'
  });

  // Build the URL
  const r2Url = `https://${env.R2_ACCOUNT_ID}.r2.cloudflarestorage.com`;
  const objectUrl = `${r2Url}/my-bucket/${key}?X-Amz-Expires=${expiresIn}`;

  // Sign it - this is the magic part
  const signedRequest = await client.sign(
    new Request(objectUrl, {
      method: 'PUT',
      // DON'T include Content-Type here - more on this below
    }),
    {
      aws: { signQuery: true },
    }
  );

  return signedRequest.url.toString();
}
```

## Step 3: The Content-Type Trap (This One Got Me)

Here's something that drove me crazy debugging: if you include `Content-Type` in the signed headers, the browser upload will fail even though curl works fine.

Why? Because when you use `signQuery: true` with aws4fetch, it only signs the `host` header. If you try to send other headers from the browser, R2 sees unsigned headers and rejects the request.

Don't sign Content-Type. Don't send it manually from the browser either. Just let the browser handle it automatically:

```javascript
// In your frontend code
const xhr = new XMLHttpRequest();
xhr.open("PUT", presignedUrl);
// Don't do this: xhr.setRequestHeader("Content-Type", file.type);
xhr.send(file);  // Just send the file - browser adds headers automatically
```

R2 will still store the file with the correct content type. It just won't validate it against the signature.

## Step 4: Configure CORS (The Most Important Part)

This is probably why your upload isn't working. Even with a perfect presigned URL, **R2 blocks browser requests unless you configure CORS**.

You need to tell R2 "yes, browsers can upload files here." Here's how:

```bash
# Create a CORS policy file
cat > cors-policy.json << 'EOF'
{
  "CORSRules": [
    {
      "AllowedOrigins": ["https://your-domain.com"],
      "AllowedMethods": ["GET", "PUT"],
      "AllowedHeaders": ["*"],
      "ExposeHeaders": ["ETag"],
      "MaxAgeSeconds": 3600
    }
  ]
}
EOF

# Apply it to your bucket
aws s3api put-bucket-cors \
  --bucket your-bucket-name \
  --cors-configuration file://cors-policy.json \
  --endpoint-url "https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com"
```

During development, you can use `"AllowedOrigins": ["*"]` to allow all origins. Just remember to lock it down in production!

## Step 5: Set Up Your Environment Variables

You need these secrets in your Cloudflare Worker:

```bash
# Get these from Cloudflare Dashboard → R2 → Manage R2 API Tokens
npx wrangler secret put R2_ACCESS_KEY_ID
npx wrangler secret put R2_SECRET_ACCESS_KEY
npx wrangler secret put R2_ACCOUNT_ID
```

Your Worker needs all three to generate presigned URLs.

## The Complete Flow

Here's how it all works together:

**Backend (Cloudflare Worker):**
```typescript
// Generate presigned URL when requested
export default {
  async fetch(request, env) {
    const key = `uploads/${crypto.randomUUID()}.mp3`;
    const presignedUrl = await generatePresignedUrl(key, 3600);
    
    return new Response(JSON.stringify({
      uploadUrl: presignedUrl,
      publicUrl: `https://your-domain.com/${key}`
    }));
  }
};
```

**Frontend (Browser):**
```javascript
// 1. Get presigned URL from your API
const response = await fetch('/api/generate-upload-url');
const { uploadUrl, publicUrl } = await response.json();

// 2. Upload file directly to R2
await fetch(uploadUrl, {
  method: 'PUT',
  body: file,
});

// 3. File is now in R2! Use publicUrl to reference it
console.log('File uploaded:', publicUrl);
```

## Testing Your Implementation

Here's a quick test to see if everything works:

```javascript
// In browser console on your site
const testFile = new Blob(['test content'], { type: 'text/plain' });

// Get presigned URL from your API
const response = await fetch('/api/generate-upload-url');
const { uploadUrl } = await response.json();

// Try to upload
const uploadResponse = await fetch(uploadUrl, {
  method: 'PUT',
  body: testFile,
});

console.log('Upload result:', uploadResponse.status);
// Should see: 200 (success!)
```

If you get 200, congrats! If not, check the browser console for CORS errors or network tab for the actual error response.

## The Full Picture

Here's what I ended up with in my production app:

**worker/r2-utils.ts:**
```typescript
import { AwsClient } from 'aws4fetch';

export async function generateR2PresignedUrl(
  key: string,
  contentType: string,
  expiresIn: number,
  credentials: {
    R2_ACCESS_KEY_ID: string;
    R2_SECRET_ACCESS_KEY: string;
    R2_ACCOUNT_ID: string;
    R2_BUCKET?: string;
  }
): Promise<string> {
  const client = new AwsClient({
    accessKeyId: credentials.R2_ACCESS_KEY_ID,
    secretAccessKey: credentials.R2_SECRET_ACCESS_KEY,
    service: 's3',
    region: 'auto',
  });

  const bucketName = credentials.R2_BUCKET || 'my-bucket';
  const r2Url = `https://${credentials.R2_ACCOUNT_ID}.r2.cloudflarestorage.com`;
  const objectUrl = `${r2Url}/${bucketName}/${key}?X-Amz-Expires=${expiresIn}`;

  const signedRequest = await client.sign(
    new Request(objectUrl, { method: 'PUT' }),
    { aws: { signQuery: true } }
  );

  return signedRequest.url.toString();
}
```

**Frontend upload component:**
```typescript
async function uploadFile(file: File) {
  // 1. Get presigned URL
  const { presignedUrl, publicUrl } = await generatePresignedUrl({
    filename: file.name,
    contentType: file.type,
  });

  // 2. Upload to R2
  const xhr = new XMLHttpRequest();
  xhr.open("PUT", presignedUrl);
  
  // Track progress
  xhr.upload.onprogress = (e) => {
    if (e.lengthComputable) {
      const percent = (e.loaded / e.total) * 100;
      console.log(`Upload progress: ${percent}%`);
    }
  };

  // Send the file
  xhr.send(file);

  // 3. Wait for completion
  await new Promise((resolve, reject) => {
    xhr.onload = () => xhr.status === 200 ? resolve() : reject();
    xhr.onerror = reject;
  });

  return publicUrl;
}
```

## Final Thoughts

Getting presigned URLs working with Cloudflare Workers was way harder than it should have been. The AWS documentation doesn't help because Workers aren't Node.js. Most examples online use the AWS SDK which doesn't work. Even Cloudflare themselves doesn't have a document anywhere (that I could find at least!) telling us that we can't use the AWS SDK (or documenting these gotchas).

But once you know the tricks:
1. Use `aws4fetch`
2. Don't sign Content-Type
3. Configure CORS
4. Let the browser handle headers

...it actually works great! And your users can upload files directly to R2 without killing your Worker.

Hope this saves you the hours of debugging I went through. If you're still stuck, the issue is probably CORS. It's almost always CORS.

Good luck!
