import { Router } from "express";

import { requireAuth } from "@/middlewares/auth.js";
import { validate } from "@/middlewares/validate.js";
import { writeRateLimit } from "@/middlewares/rate-limit.js";
import { addWishlistItemSchema, wishlistItemIdSchema } from "@/models/wishlist-model.js";
import {
	addWishlistItem,
	clearWishlist,
	getWishlist,
	removeWishlistItem,
} from "@/controllers/wishlist-controller.js";

export const wishlistRouter = Router();

/**
 * @swagger
 * /wishlist:
 *   get:
 *     summary: Get current user's wishlist
 *     tags: [Wishlist]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Wishlist with items
 */
wishlistRouter.get("/", writeRateLimit, requireAuth, getWishlist);

/**
 * @swagger
 * /wishlist/items:
 *   post:
 *     summary: Add listing to wishlist
 *     tags: [Wishlist]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/AddWishlistItemInput'
 *     responses:
 *       201:
 *         description: Wishlist item created
 */
wishlistRouter.post(
	"/items",
	writeRateLimit,
	requireAuth,
	validate(addWishlistItemSchema),
	addWishlistItem
);

/**
 * @swagger
 * /wishlist/items/{listingId}:
 *   delete:
 *     summary: Remove listing from wishlist
 *     tags: [Wishlist]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: listingId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       204:
 *         description: Removed
 */
wishlistRouter.delete(
	"/items/:listingId",
	writeRateLimit,
	requireAuth,
	validate(wishlistItemIdSchema, "params"),
	removeWishlistItem
);

/**
 * @swagger
 * /wishlist/clear:
 *   delete:
 *     summary: Clear wishlist
 *     tags: [Wishlist]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       204:
 *         description: Cleared
 */
wishlistRouter.delete("/clear", writeRateLimit, requireAuth, clearWishlist);
