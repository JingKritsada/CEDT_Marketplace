import { z } from "zod";

/**
 * @swagger
 * components:
 *   schemas:
 *     CreateChatRoomInput:
 *       type: object
 *       required:
 *         - listingId
 *       properties:
 *         listingId:
 *           type: string
 *     SendChatMessageInput:
 *       type: object
 *       required:
 *         - content
 *       properties:
 *         content:
 *           type: string
 */

export const createChatRoomSchema = z.object({
	listingId: z.string().trim().min(1),
});

export const chatRoomIdSchema = z.object({
	id: z.string().trim().min(1),
});

export const sendChatMessageSchema = z.object({
	content: z.string().trim().min(1).max(2000),
});

export type CreateChatRoomInput = z.infer<typeof createChatRoomSchema>;
export type SendChatMessageInput = z.infer<typeof sendChatMessageSchema>;
