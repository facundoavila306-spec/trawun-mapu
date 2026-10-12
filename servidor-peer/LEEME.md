# Servidor de señalización de Trawün Mapu

Sirve sólo para que dos jugadores se encuentren por internet; la partida va directa entre ellos (WebRTC).

## Render (gratis)
New → Web Service → este repo → Root Directory `servidor-peer` → Build `npm install` → Start `npm start` → plan Free.
Al abrir la dirección tiene que responder un JSON "PeerJS Server". El plan gratis se duerme a los 15 min: un monitor HTTP (UptimeRobot) cada 5 min lo mantiene despierto.

## TURN (Metered.ca, gratis 50 GB/mes)
Crear app, generar credencial. Hosts `global.relay.metered.ca`, puertos 80 y 443 (UDP y TCP; `turns:` en 443 TCP).

## En el juego (`juego/src/00_html_y_motor_mev.js`, módulo Red)
- `PEER_PROPIO.host` = dirección de Render sin `https://`.
- `TURN_PROPIO` = lista con `urls`, `username`, `credential` de Metered.
Si `PEER_PROPIO.host` está vacío se usa el PeerJS público de siempre.
