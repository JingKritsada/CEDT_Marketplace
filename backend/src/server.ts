import { createServer } from "node:http";

import { env } from "./config/env";
import { app } from "./app";
import { registerSockets } from "./sockets";

const server = createServer(app);

registerSockets(server);

server.listen(env.PORT);
