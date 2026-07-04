# Beauty Textile — Image Upload & Management Guide

> Keep this file. Follow it every time you need to add, replace, or upload images.

---

## 1. Two Types of Images in This Project

| Type | What it is | Stored where | Served from |
|------|-----------|--------------|-------------|
| **Category images** | Illustrations for each category tile (Sarees, Shirts, etc.) | `frontend/public/images/categories/` | `http://localhost:4200/images/categories/…` |
| **Product images** | Photos of individual products uploaded by admin | `uploads/products/` (local) or cloud storage | Backend API path `/images/filename.jpg` |

---

## 2. Category Images — Add / Replace

### Folder structure (already created)
```
frontend/public/
└── images/
    └── categories/
        ├── women.svg
        ├── saree/
        │   ├── saree.svg
        │   ├── daily-wear.svg
        │   ├── cotton.svg
        │   ├── party-wear.svg
        │   ├── kanjivaram.svg
        │   └── pattu-silk.svg
        ├── kurthi/
        │   ├── kurthi.svg
        │   ├── tops.svg
        │   ├── set.svg
        │   └── gown.svg
        ├── mens/
        │   ├── mens.svg
        │   ├── shirt.svg
        │   ├── pant.svg
        │   └── ethnic-wear.svg
        └── kids/
            ├── kids.svg
            ├── boys.svg
            └── girls.svg
```

### To replace a category image with a real photo

1. Place your `.jpg` / `.png` / `.webp` file in the correct subfolder, e.g.:
   ```
   frontend/public/images/categories/saree/saree.jpg
   ```
2. Open [database/schema.sql](../database/schema.sql) and update the `image_path` in the seed row:
   ```sql
   -- Before
   ('/images/categories/saree/saree.svg')
   -- After
   ('/images/categories/saree/saree.jpg')
   ```
3. In [DataInitializer.java](../backend/src/main/java/com/beautytextile/config/DataInitializer.java), update the matching `saveIfAbsent` call:
   ```java
   // Before
   Category sarees = saveIfAbsent("Sarees", women, "/images/categories/saree/saree.svg");
   // After
   Category sarees = saveIfAbsent("Sarees", women, "/images/categories/saree/saree.jpg");
   ```
4. If the database already has existing data, run this SQL to update it:
   ```sql
   UPDATE categories SET image_path = '/images/categories/saree/saree.jpg' WHERE name = 'Sarees';
   ```

### Image size recommendation
| Use | Size | Format |
|-----|------|--------|
| Category tiles (home page) | 400×400 px | JPG / WebP |
| Category banner | 800×300 px | JPG / WebP |
| SVG illustrations (current) | Scalable | SVG |

---

## 3. Product Images — Upload via Admin Panel

### Step-by-step (UI)
1. Log in at `http://localhost:4200/admin/login` → username `admin`, password `admin123`
2. Go to **Products** in the sidebar
3. Click **+ Add Product** (or **Edit** on an existing product)
4. In the form, scroll to **Product Image**
5. Click the upload zone → select your image file (JPG/PNG/WebP, max 5 MB)
6. The image uploads immediately and a preview appears
7. Click **Save** / **Update Product** to save the product

### How it works behind the scenes
```
Browser → POST /api/products/upload-image (multipart/form-data)
        → Backend saves file to  uploads/products/<uuid>.jpg
        → Returns { imageUrl: "/images/<uuid>.jpg" }
        → Angular stores imageUrl in the form
        → POST /api/products → saves product with imageUrl
```

### Upload folder
- **Dev:** `uploads/products/` (next to the `backend/` folder)
- **Production (Render):** `/tmp/uploads/products/` (see application-prod.yml)

---

## 4. Product Images — Via API (Postman / curl)

### Upload image first
```bash
curl -X POST http://localhost:8080/api/products/upload-image \
  -H "Authorization: Bearer <your-jwt-token>" \
  -F "file=@/path/to/your/image.jpg"
```
Response:
```json
{ "imageUrl": "/images/abc123.jpg" }
```

### Create product with uploaded image
```bash
curl -X POST http://localhost:8080/api/products \
  -H "Authorization: Bearer <your-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Kanjivaram Silk Saree",
    "description": "...",
    "category": "Kanjivaram Sarees",
    "price": 2999.00,
    "stock": 10,
    "imageUrl": "/images/abc123.jpg"
  }'
```

### Get JWT token first
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```
Copy the `token` from the response.

---

## 5. Database — MySQL Setup (local dev)

```bash
# Start MySQL and create database
mysql -u root -p
CREATE DATABASE beauty_textile;
USE beauty_textile;
SOURCE path/to/database/schema.sql;
```

Backend auto-connects when started with profile `dev`:
```bash
cd backend
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

---

## 6. Database — PostgreSQL Setup

### Local
```bash
# Create database
psql -U postgres -c "CREATE DATABASE beauty_textile;"
psql -U postgres -d beauty_textile -f database/schema_postgresql.sql
```

Start backend with PostgreSQL profile:
```bash
cd backend
SPRING_PROFILES_ACTIVE=postgresql ./mvnw spring-boot:run
```

### Railway (cloud PostgreSQL)
1. Go to [railway.app](https://railway.app) → New Project → Add Database → PostgreSQL
2. Click your PostgreSQL service → **Connect** tab → copy the **DATABASE_URL**
3. Set environment variables in Render (your backend service):
   ```
   SPRING_PROFILES_ACTIVE=postgresql
   DATABASE_URL=jdbc:postgresql://containers-us-west-XXX.railway.app:7890/railway
   DB_USERNAME=postgres
   DB_PASSWORD=<from railway>
   ```
4. In the Railway **Query** tab, paste and run `schema_postgresql.sql`

### Neon (serverless PostgreSQL — free tier)
1. Sign up at [neon.tech](https://neon.tech) → New Project
2. Copy the connection string (format: `postgresql://user:pass@ep-xxx.neon.tech/neondb?sslmode=require`)
3. Convert to JDBC format:
   ```
   jdbc:postgresql://ep-xxx.neon.tech/neondb?sslmode=require
   ```
4. Set in Render environment variables as above

---

## 7. Cloud Storage for Product Images (Production)

In production, `/tmp/uploads/` gets wiped on every Render deploy. Use cloud storage instead.

### Option A — Cloudinary (recommended, free 25GB)
1. Sign up at [cloudinary.com](https://cloudinary.com)
2. Get your `Cloud Name`, `API Key`, `API Secret`
3. Add to `pom.xml`:
   ```xml
   <dependency>
     <groupId>com.cloudinary</groupId>
     <artifactId>cloudinary-http44</artifactId>
     <version>1.37.0</version>
   </dependency>
   ```
4. Create `CloudinaryImageStorageService.java` implementing `ImageStorageService`:
   ```java
   @Service
   @ConditionalOnProperty(name="app.storage.provider", havingValue="cloudinary")
   public class CloudinaryImageStorageService implements ImageStorageService {
       // Cloudinary.upload() → returns secure_url
   }
   ```
5. Set env vars in Render:
   ```
   CLOUDINARY_URL=cloudinary://api_key:api_secret@cloud_name
   APP_STORAGE_PROVIDER=cloudinary
   ```
6. Image URLs will be like: `https://res.cloudinary.com/yourcloud/image/upload/v123/filename.jpg`

### Option B — Firebase Storage (free 5GB)
1. Firebase Console → Storage → Get started
2. Set CORS rules to allow your domain
3. Use Firebase Admin SDK in Spring Boot to upload
4. Image URLs: `https://firebasestorage.googleapis.com/...`

### Option C — AWS S3 / MinIO
1. Create S3 bucket, set ACL to public-read
2. Add `spring-cloud-aws-starter-s3` to pom.xml
3. Set `AWS_ACCESS_KEY`, `AWS_SECRET_KEY`, `S3_BUCKET`, `AWS_REGION` env vars

---

## 8. Category Image path stored in DB

```
categories table
-----------------
id  | name              | parent_id | image_path
----|-------------------|-----------|----------------------------------------------
1   | Women             | NULL      | /images/categories/women.svg
6   | Sarees            | 1         | /images/categories/saree/saree.svg
9   | Daily Wear Sarees | 6         | /images/categories/saree/daily-wear.svg
...
```

The Angular frontend reads `category.imagePath` and displays it as:
```html
<img [src]="category.imagePath || 'assets/placeholder.jpg'" />
```

---

## 9. Quick Reference: Where Each Image Lives

| Image | Location | URL |
|-------|----------|-----|
| Saree category tile | `public/images/categories/saree/saree.svg` | `/images/categories/saree/saree.svg` |
| Product photo (local) | `uploads/products/abc123.jpg` | `/images/abc123.jpg` |
| Product photo (Cloudinary) | Cloudinary CDN | `https://res.cloudinary.com/…` |
| Placeholder | `public/assets/placeholder.jpg` | `assets/placeholder.jpg` |

---

## 10. Recommended Image Sizes for Best Performance

| Image type | Recommended size | Max file size |
|-----------|-----------------|---------------|
| Category SVG illustration | N/A (vector, scalable) | < 10 KB |
| Category JPG (replace SVG) | 400×400 px | < 50 KB |
| Product photo | 600×800 px (portrait) | < 500 KB |
| Product thumbnail | 200×260 px | < 50 KB |

Use [Squoosh](https://squoosh.app) (free, browser-based) to compress images before uploading.
