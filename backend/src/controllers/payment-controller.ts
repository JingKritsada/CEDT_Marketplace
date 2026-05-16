import type { Request, Response } from "express";

import { asyncHandler } from "@/utils/async-handler.js";
import { ok } from "@/utils/api-response.js";
import { paymentService } from "@/services/payment-service.js";

const getParam = (id: string | string[]): string => (Array.isArray(id) ? id[0] : id);

export const createCheckout = asyncHandler(async (req: Request, res: Response) => {
	const result = await paymentService.checkout(req.auth!.userId, req.body.listingId);

	res.status(201).json(ok(result));
});

export const getPayment = asyncHandler(async (req: Request, res: Response) => {
	const payment = await paymentService.getById(getParam(req.params.id), req.auth!.userId);

	res.status(200).json(ok(payment));
});

export const listMyPayments = asyncHandler(async (req: Request, res: Response) => {
	const payments = await paymentService.listForUser(req.auth!.userId);

	res.status(200).json(ok(payments));
});

export const cancelPayment = asyncHandler(async (req: Request, res: Response) => {
	const payment = await paymentService.cancel(getParam(req.params.id), req.auth!.userId);

	res.status(200).json(ok(payment));
});

export const refundPayment = asyncHandler(async (req: Request, res: Response) => {
	const payment = await paymentService.refund(
		getParam(req.params.id),
		req.auth!.userId,
		req.body?.amountSatang,
		req.body?.reason
	);

	res.status(202).json(ok(payment));
});

export const confirmListingReceiptAndCapture = asyncHandler(async (req: Request, res: Response) => {
	const result = await paymentService.confirmReceiptForListing(
		getParam(req.params.id),
		req.auth!.userId
	);

	res.status(200).json(ok(result));
});
