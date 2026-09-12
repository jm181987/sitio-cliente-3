# Sitio Cliente 3

Base inicial del sitio con Next.js + TypeScript y PostgreSQL.

## Base de datos

La aplicación usa exclusivamente la variable de entorno `DATABASE_URL` para conectarse a PostgreSQL. Las credenciales reales no se guardan en GitHub.

Variables esperadas:

```env
DATABASE_URL=postgresql://USER:PASSWORD@HOST:5432/DATABASE
DATABASE_SSL=false
```

## Comprobación de conexión

Con la aplicación desplegada y `DATABASE_URL` configurada, visita:

```text
/api/db/health
```

Una conexión correcta devuelve `ok: true` y `database: connected`.

## Desarrollo

```bash
npm install
npm run dev
```

## Estructura

- `src/lib/db.ts`: pool PostgreSQL compartido.
- `app/api/db/health/route.ts`: verificación de conectividad.
- `.env.example`: plantilla segura de variables.
- `.gitignore`: evita subir secretos y archivos locales.

A partir de esta base, las funciones que requieran persistencia deben reutilizar `query()` desde `src/lib/db.ts`.
