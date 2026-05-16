import type { Request, Response } from "express";

import { asyncHandler } from "@/utils/async-handler.js";
import { ok } from "@/utils/api-response.js";
import { sellerOnboardingService } from "@/services/seller-onboarding-service.js";

export const startSellerOnboarding = asyncHandler(async (req: Request, res: Response) => {
	const result = await sellerOnboardingService.startOnboarding(req.auth!.userId);

	res.status(200).json(ok(result));
});

export const refreshSellerStatus = asyncHandler(async (req: Request, res: Response) => {
	const profile = await sellerOnboardingService.refreshFromStripe(req.auth!.userId);

	res.status(200).json(ok(profile));
});

export const getMySellerProfile = asyncHandler(async (req: Request, res: Response) => {
	const profile = await sellerOnboardingService.getMyProfile(req.auth!.userId);

	res.status(200).json(ok(profile));
});

export const getMySellerBalance = asyncHandler(async (req: Request, res: Response) => {
	const balance = await sellerOnboardingService.getMyBalance(req.auth!.userId);

	res.status(200).json(ok(balance));
});

export const listMySellerPayouts = asyncHandler(async (req: Request, res: Response) => {
	const payouts = await sellerOnboardingService.listMyPayouts(req.auth!.userId);

	res.status(200).json(ok(payouts));
});
