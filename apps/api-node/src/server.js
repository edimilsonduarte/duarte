import http from 'node:http';

const PORT = process.env.PORT || 3000;

const routes = {
  '/health': () => ({ status: 'ok', service: 'api-node' }),
  '/': () => ({ message: 'API Node.js no ar! Adicione suas rotas em apps/api-node/src/server.js' }),
};

const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);
  const handler = routes[url.pathname];

  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  res.setHeader('Access-Control-Allow-Origin', '*');

  if (!handler) {
    res.statusCode = 404;
    res.end(JSON.stringify({ error: 'Rota não encontrada' }));
    return;
  }

  res.end(JSON.stringify(handler(req)));
});

server.listen(PORT, () => {
  console.log(`api-node ouvindo na porta ${PORT}`);
});
