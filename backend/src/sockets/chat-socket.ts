import type { Server, Socket } from "socket.io";

import { z } from "zod";

const joinRoomSchema = z.object({
	roomId: z.string().trim().min(1).max(128),
});

const sendMessageSchema = z.object({
	roomId: z.string().trim().min(1).max(128),
	message: z.string().trim().min(1).max(2000),
});

const typingSchema = z.object({
	roomId: z.string().trim().min(1).max(128),
	isTyping: z.boolean(),
});

const parseJoinPayload = (payload: unknown): { roomId: string } | null => {
	if (typeof payload === "string") {
		return joinRoomSchema.safeParse({ roomId: payload }).success
			? { roomId: payload.trim() }
			: null;
	}

	const result = joinRoomSchema.safeParse(payload);

	return result.success ? result.data : null;
};

export const registerChatSocket = (io: Server, socket: Socket): void => {
	socket.on("join_room", (payload: unknown) => {
		const parsedPayload = parseJoinPayload(payload);

		if (!parsedPayload) {
			return;
		}

		socket.join(parsedPayload.roomId);
	});

	socket.on("send_message", (payload: unknown) => {
		const parsedPayload = sendMessageSchema.safeParse(payload);

		if (!parsedPayload.success || !socket.rooms.has(parsedPayload.data.roomId)) {
			return;
		}

		io.to(parsedPayload.data.roomId).emit("receive_message", {
			senderId: socket.id,
			message: parsedPayload.data.message,
			createdAt: new Date().toISOString(),
		});
	});

	socket.on("typing", (payload: unknown) => {
		const parsedPayload = typingSchema.safeParse(payload);

		if (!parsedPayload.success || !socket.rooms.has(parsedPayload.data.roomId)) {
			return;
		}

		socket.to(parsedPayload.data.roomId).emit("typing", {
			senderId: socket.id,
			isTyping: parsedPayload.data.isTyping,
		});
	});
};
