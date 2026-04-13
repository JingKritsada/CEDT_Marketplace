import { createServer } from "node:http";

import { app } from "./app.js";
import { env } from "./config/env.js";
import { registerSockets } from "./sockets/index.js";

const server = createServer(app);

registerSockets(server);

server.listen(env.PORT);
