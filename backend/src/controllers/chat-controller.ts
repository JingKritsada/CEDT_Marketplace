import type { Request, Response } from "express";

import { asyncHandler } from "@/utils/async-handler.js";
import { chatService } from "@/services/chat-service.js";

const getParamValue = (value: string | string[]): string => {
	return Array.isArray(value) ? value[0] : value;
};

export const getChatRooms = asyncHandler(async (req: Request, res: Response) => {
	const rooms = await chatService.listRooms(req.auth!.userId);

	res.status(200).json(rooms);
});

export const createChatRoom = asyncHandler(async (req: Request, res: Response) => {
	const room = await chatService.createRoom(req.auth!.userId, req.body);

	res.status(201).json(room);
});

export const getChatMessages = asyncHandler(async (req: Request, res: Response) => {
	const messages = await chatService.getMessages(req.auth!.userId, getParamValue(req.params.id));

	res.status(200).json(messages);
});

export const sendChatMessage = asyncHandler(async (req: Request, res: Response) => {
	const message = await chatService.sendMessage(
		req.auth!.userId,
		getParamValue(req.params.id),
		req.body
	);

	res.status(201).json(message);
});
