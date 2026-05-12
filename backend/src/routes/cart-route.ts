import { Router } from "express";

import { requireAuth } from "@/middlewares/auth.js";
import { validate } from "@/middlewares/validate.js";
import { writeRateLimit } from "@/middlewares/rate-limit.js";
import { addCartItemSchema, cartItemIdSchema } from "@/models/cart-model.js";
import { addCartItem, clearCart, getCart, removeCartItem } from "@/controllers/cart-controller.js";

export const cartRouter = Router();

/**
 * @swagger
 * /cart:
 *   get:
 *     summary: Get current user's cart
 *     tags: [Cart]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Cart with items
 */
cartRouter.get("/", writeRateLimit, requireAuth, getCart);

/**
 * @swagger
 * /cart/items:
 *   post:
 *     summary: Add listing to cart
 *     tags: [Cart]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/AddCartItemInput'
 *     responses:
 *       201:
 *         description: Cart item created
 */
cartRouter.post("/items", writeRateLimit, requireAuth, validate(addCartItemSchema), addCartItem);

/**
 * @swagger
 * /cart/items/{listingId}:
 *   delete:
 *     summary: Remove listing from cart
 *     tags: [Cart]
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
cartRouter.delete(
	"/items/:listingId",
	writeRateLimit,
	requireAuth,
	validate(cartItemIdSchema, "params"),
	removeCartItem
);

/**
 * @swagger
 * /cart/clear:
 *   delete:
 *     summary: Clear cart
 *     tags: [Cart]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       204:
 *         description: Cleared
 */
cartRouter.delete("/clear", writeRateLimit, requireAuth, clearCart);
