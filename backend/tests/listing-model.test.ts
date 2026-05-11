import assert from "node:assert/strict";
import test from "node:test";

import { createListingSchema, updateListingSchema } from "../src/models/listing-model.js";

test("update listing schema does not apply defaults", () => {
	const result = updateListingSchema.parse({});

	assert.deepEqual(result, {});
});

test("update listing schema keeps only provided fields", () => {
	const result = updateListingSchema.parse({ price: 200 });

	assert.deepEqual(result, { price: 200 });
});

test("create listing schema applies defaults", () => {
	const result = createListingSchema.parse({
		title: "Robotics Starter Kit",
		description: "Complete kit with sensors.",
		price: 850,
		categoryId: "category-id",
		pickupLocationId: "pickup-id",
	});

	assert.equal(result.isFree, false);
	assert.equal(result.status, "AVAILABLE");
	assert.equal(result.condition, "GOOD");
	assert.deepEqual(result.images, []);
});
