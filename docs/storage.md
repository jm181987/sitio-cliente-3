# Storage de imágenes y assets

El sitio está preparado para usar un proveedor S3-compatible, por ejemplo MinIO en Coolify, Cloudflare R2, AWS S3 u otro compatible.

## Buckets

- `public-assets`: imágenes, logos, banners, PDFs y recursos públicos del sitio.
- `private-assets`: archivos privados que deben entregarse mediante URLs firmadas.

Los nombres pueden cambiarse con `STORAGE_PUBLIC_BUCKET` y `STORAGE_PRIVATE_BUCKET`.

## Inicialización

Con las variables de storage configuradas, `GET /api/storage/health` comprueba la conexión y crea ambos buckets si todavía no existen.

## Subidas

`POST /api/assets/upload` recibe `multipart/form-data` con:

- `file`: archivo a subir.
- `folder`: carpeta lógica opcional, por ejemplo `images`, `logos`, `hero` o `documents`.

El endpoint acepta JPEG, PNG, WebP, AVIF, GIF, SVG y PDF hasta 10 MB. Al subir un archivo también registra sus metadatos en PostgreSQL en la tabla `assets`.

## Base de datos

Ejecutar `npm run db:migrate` en el entorno de despliegue para crear la tabla `assets` y registrar las migraciones aplicadas.

## Seguridad

Las credenciales reales de PostgreSQL y object storage deben existir únicamente como variables de entorno del servidor. Nunca deben guardarse en GitHub.

El acceso público al bucket `public-assets` o su CDN/dominio público depende del proveedor seleccionado. `STORAGE_PUBLIC_BASE_URL` debe apuntar a la URL pública correspondiente.
