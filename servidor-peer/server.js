const { PeerServer } = require('peer');
PeerServer({ port: process.env.PORT || 9000, path: '/', proxied: true, key: 'peerjs', corsOptions: { origin: true } });
