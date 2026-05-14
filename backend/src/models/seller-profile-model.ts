import { z } from "zod";

/**
 * @swagger
 * components:
 *   schemas:
 *     SellerOnboardingResponse:
 *       type: object
 *       properties:
 *         url:
 *           type: string
 *         expiresAt:
 *           type: integer
 *         connectStatus:
 *           type: string
 */

export const onboardingSchema = z.object({});

export type OnboardingInput = z.infer<typeof onboardingSchema>;
