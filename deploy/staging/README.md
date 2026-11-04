# Staging bajo demanda (Coolify)

Servicio Docker Compose en Coolify con la imagen `ghcr.io/alien-creativo/crm-aliencreativo:staging`. Normalmente está **parado**.

## Arranque
1. Comprobar memoria libre (`free -m`): se necesitan ≥ 2 GB disponibles.
2. Coolify arranca solo Postgres y Redis (`APP_REPLICAS=0`, `WORKER_REPLICAS=0`, `TUNNEL_REPLICAS=0`).
3. Restaurar un backup (`pg_restore --no-owner --no-acl`) y **sanitizar con Sidekiq parado**: vaciar credenciales de canales, borrar webhooks e integraciones, anular URLs de agent bots, desactivar campañas y reglas de automatización, y borrar configuraciones con secretos. El script de sanitización es privado y no vive en el repo.
4. Lanzar un `cloudflared` Quick Tunnel **fuera de Coolify** en la red del servicio, para que la URL no cambie con cada redeploy: `docker run -d --name stg-tunnel-<uuid> --network <uuid> cloudflare/cloudflared tunnel --no-autoupdate --url http://chatwoot:3000`.
5. Fijar `STAGING_FRONTEND_URL` con esa URL y poner `APP_REPLICAS=1` y `WORKER_REPLICAS=1`.

## Cierre
Borrar el contenedor del túnel y parar el servicio en Coolify. Nunca dejarlo encendido: la copia contiene usuarios reales.
