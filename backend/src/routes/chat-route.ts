import { Router } from "express";

import { requireAuth } from "@/middlewares/auth.js";
import { validate } from "@/middlewares/validate.js";
import { writeRateLimit } from "@/middlewares/rate-limit.js";
import {
	chatRoomIdSchema,
	createChatRoomSchema,
	sendChatMessageSchema,
} from "@/models/chat-model.js";
import {
	createChatRoom,
	getChatMessages,
	getChatRooms,
	sendChatMessage,
} from "@/controllers/chat-controller.js";

export const chatRouter = Router();

/**
 * @swagger
 * /chat/rooms:
 *   get:
 *     summary: Get chat rooms for current user
 *     tags: [Chat]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Chat rooms
 */
chatRouter.get("/rooms", writeRateLimit, requireAuth, getChatRooms);

/**
 * @swagger
 * /chat/rooms:
 *   post:
 *     summary: Create or fetch a chat room for a listing
 *     tags: [Chat]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreateChatRoomInput'
 *     responses:
 *       201:
 *         description: Chat room created
 */
chatRouter.post(
	"/rooms",
	writeRateLimit,
	requireAuth,
	validate(createChatRoomSchema),
	createChatRoom
);

/**
 * @swagger
 * /chat/rooms/{id}/messages:
 *   get:
 *     summary: Get messages in a chat room
 *     tags: [Chat]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Chat messages
 */
chatRouter.get(
	"/rooms/:id/messages",
	writeRateLimit,
	requireAuth,
	validate(chatRoomIdSchema, "params"),
	getChatMessages
);

/**
 * @swagger
 * /chat/rooms/{id}/messages:
 *   post:
 *     summary: Send a message in a chat room
 *     tags: [Chat]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/SendChatMessageInput'
 *     responses:
 *       201:
 *         description: Message sent
 */
chatRouter.post(
	"/rooms/:id/messages",
	writeRateLimit,
	requireAuth,
	validate(chatRoomIdSchema, "params"),
	validate(sendChatMessageSchema),
	sendChatMessage
);
