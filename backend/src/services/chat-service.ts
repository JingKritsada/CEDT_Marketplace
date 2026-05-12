import { prisma } from "@/config/prisma.js";
import { ApiError } from "@/utils/api-error.js";
import type { CreateChatRoomInput, SendChatMessageInput } from "@/models/chat-model.js";

export const chatService = {
	async listRooms(userId: string) {
		return prisma.chatRoom.findMany({
			where: {
				OR: [{ buyerId: userId }, { sellerId: userId }],
			},
			include: {
				listing: {
					select: {
						id: true,
						title: true,
						images: true,
						status: true,
						price: true,
						isFree: true,
					},
				},
				buyer: {
					select: {
						id: true,
						displayName: true,
						avatarUrl: true,
					},
				},
				seller: {
					select: {
						id: true,
						displayName: true,
						avatarUrl: true,
					},
				},
				messages: {
					orderBy: { createdAt: "desc" },
					take: 1,
				},
			},
			orderBy: {
				updatedAt: "desc",
			},
		});
	},

	async createRoom(userId: string, payload: CreateChatRoomInput) {
		const listing = await prisma.listing.findUnique({
			where: { id: payload.listingId },
			select: { id: true, sellerId: true },
		});

		if (!listing) {
			throw new ApiError("Listing not found", 404);
		}

		if (listing.sellerId === userId) {
			throw new ApiError("Sellers cannot create a room as a buyer", 400);
		}

		return prisma.chatRoom.upsert({
			where: {
				listingId_buyerId: {
					listingId: listing.id,
					buyerId: userId,
				},
			},
			update: {},
			create: {
				listingId: listing.id,
				buyerId: userId,
				sellerId: listing.sellerId,
			},
			include: {
				listing: true,
			},
		});
	},

	async getMessages(userId: string, roomId: string) {
		const room = await prisma.chatRoom.findUnique({
			where: { id: roomId },
			select: { buyerId: true, sellerId: true },
		});

		if (!room) {
			throw new ApiError("Chat room not found", 404);
		}

		if (room.buyerId !== userId && room.sellerId !== userId) {
			throw new ApiError("Forbidden", 403);
		}

		return prisma.message.findMany({
			where: { chatRoomId: roomId },
			orderBy: { createdAt: "asc" },
		});
	},

	async sendMessage(userId: string, roomId: string, payload: SendChatMessageInput) {
		const room = await prisma.chatRoom.findUnique({
			where: { id: roomId },
			select: { buyerId: true, sellerId: true },
		});

		if (!room) {
			throw new ApiError("Chat room not found", 404);
		}

		if (room.buyerId !== userId && room.sellerId !== userId) {
			throw new ApiError("Forbidden", 403);
		}

		return prisma.message.create({
			data: {
				chatRoomId: roomId,
				senderId: userId,
				content: payload.content,
			},
		});
	},
};
