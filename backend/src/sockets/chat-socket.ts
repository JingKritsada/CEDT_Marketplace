import type { Server, Socket } from "socket.io";

interface SendMessagePayload {
	roomId: string;
	message: string;
}

interface TypingPayload {
	roomId: string;
	isTyping: boolean;
}

export const registerChatSocket = (io: Server, socket: Socket): void => {
	socket.on("join_room", (roomId: string) => {
		socket.join(roomId);
	});

	socket.on("send_message", (payload: SendMessagePayload) => {
		io.to(payload.roomId).emit("receive_message", {
			senderId: socket.id,
			message: payload.message,
			createdAt: new Date().toISOString(),
		});
	});

	socket.on("typing", (payload: TypingPayload) => {
		socket.to(payload.roomId).emit("typing", {
			senderId: socket.id,
			isTyping: payload.isTyping,
		});
	});
};
