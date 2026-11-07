# Trawün Mapu

Juego de estrategia en la Patagonia · El Gallo McFlay. © 2026 Facundo. Todos los derechos reservados.

## Instalar (Windows 10 u 11, 64 bits)

1. Bajá **[Instalar Trawun Mapu.exe](https://raw.githubusercontent.com/facundoavila306-spec/trawun-mapu/main/Instalar%20Trawun%20Mapu.exe)** (6 MB).
2. Abrilo. Si Windows dice "protegió su PC": **Más información → Ejecutar de todas formas**.
3. Apretá Enter: baja el juego con la música (unos 125 MB) desde acá mismo, lo instala en tu carpeta de usuario (no pide administrador) y te deja el acceso directo en el escritorio.

(Si el .exe no te deja, está la misma cosa como [Instalar-Trawun-Mapu.zip](https://raw.githubusercontent.com/facundoavila306-spec/trawun-mapu/main/Instalar-Trawun-Mapu.zip): adentro hay un `.cmd` que hace lo mismo.)

Las actualizaciones después se bajan desde adentro del juego: **Menú → Buscar actualizaciones**.

## Qué hay en este repositorio

- `trawun.json` y `juego/<versión>/index.html`: lo que lee el actualizador de adentro del juego.
- `instalar/instalar.json` y `instalar/<versión>/`: el paquete completo (Electron + juego) que baja el instalador, en partes de 45 MB.
