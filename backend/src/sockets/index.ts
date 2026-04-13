import type { Server as HttpServer } from "node:http";

import { Server } from "socket.io";

import { registerChatSocket } from "./chat-socket";

export const registerSockets = (server: HttpServer): Server => {
	const io = new Server(server, {
		cors: {
			origin: "*",
		},
	});

	io.on("connection", (socket) => {
		registerChatSocket(io, socket);
	});

	return io;
};
