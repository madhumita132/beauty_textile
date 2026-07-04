# Beauty Textile — Full‑Stack Shop & POS

Production-ready scaffold for an online textile store **and** in-shop billing (POS) system.

- **Frontend:** Angular (standalone components) — customer storefront + admin panel
- **Backend:** Spring Boot (Java 17) — REST APIs, JWT auth, barcode, file uploads
- **Database:** MySQL
- **Integrations (mock-ready):** Razorpay payments, WhatsApp bill sharing, Code‑128 barcode, thermal (58mm) printing

> Integrations run in **MOCK mode** until you add real API keys in
> `backend/src/main/resources/application.yml`. The app compiles and runs without them.

---

## Project layout

```
beauty-textile/
├─ backend/                 # Spring Boot API (Maven, includes mvnw wrapper)
│  ├─ src/main/java/com/beautytextile/...
│  └─ src/main/resources/
│     ├─ application.yml
│     └─ db/schema.sql
├─ frontend/                # Angular app (customer + admin)
│  └─ src/app/...
├─ database/
│  └─ schema.sql            # Standalone MySQL script (DDL + seed)
└─ uploads/products/        # Uploaded product images (served by backend)
```

---

## Prerequisites

| Tool | Status on this machine |
|------|------------------------|
| Java 17 | ✅ installed |
| Maven | ⛔ use the included `mvnw` wrapper |
| Node + npm | ✅ installed |
| Angular CLI | ✅ installed |
| MySQL 8 | ⛔ install & start before running backend |

---

## 1) Database

```sql
-- in MySQL:
SOURCE database/schema.sql;
```
This creates the `beauty_textile` schema, all tables, seed categories
(Women, Men, Kids, Girls, Boys, Kurthi) and a default admin user.

Default admin login: **admin / admin123** (change in production).

## 2) Backend

```powershell
cd backend
# set DB credentials in src/main/resources/application.yml first
./mvnw spring-boot:run
```
API runs at `http://localhost:8080`.

## 3) Frontend

```powershell
cd frontend
npm install
npm start
```
App runs at `http://localhost:4200`.

---

## Default credentials & shop info

- Shop: **Beauty Textile**
- Email: beautytextile.shop@gmail.com
- Phone: 8344515186
- Admin login: `admin` / `admin123`

---

## Key flows

**Customer:** Home → Category/Product list → Product detail → Add to cart → Checkout → Razorpay (mock) → Order saved → stock reduced.

**Admin POS:** Login → Billing → scan barcode / search → add items → adjust qty → Save bill → Print 58mm receipt → Send WhatsApp (mock) → stock reduced.

**Reports:** Daily / Monthly / Product-wise / Category-wise, combining online orders + shop billing.

See `database/schema.sql` and inline code comments for full details.
