import path from "node:path";
import { fileURLToPath } from "node:url";

import { FlatCompat } from "@eslint/eslintrc";
import { fixupConfigRules, fixupPluginRules } from "@eslint/compat";
import js from "@eslint/js";
import globals from "globals";
import _import from "eslint-plugin-import";
import prettier from "eslint-plugin-prettier";
import tsParser from "@typescript-eslint/parser";
import unusedImports from "eslint-plugin-unused-imports";
import noRelativeImportPaths from "eslint-plugin-no-relative-import-paths";
import typescriptEslint from "@typescript-eslint/eslint-plugin";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const compat = new FlatCompat({
	baseDirectory: __dirname,
	recommendedConfig: js.configs.recommended,
	allConfig: js.configs.all,
});

export default [
	{
		ignores: ["**/dist", "**/node_modules", "**/coverage", "**/build", "**/*.config.js"],
	},
	...fixupConfigRules(compat.extends("plugin:prettier/recommended")),
	{
		files: ["**/*.ts", "**/*.js", "**/*.mjs"],

		plugins: {
			"unused-imports": unusedImports,
			import: fixupPluginRules(_import),
			"@typescript-eslint": typescriptEslint,
			prettier: fixupPluginRules(prettier),
			"no-relative-import-paths": noRelativeImportPaths,
		},

		languageOptions: {
			globals: {
				...globals.node,
			},
			parser: tsParser,
			ecmaVersion: 12,
			sourceType: "module",
		},

		rules: {
			"no-console": "off",
			"prettier/prettier": [
				"warn",
				{
					useTabs: true,
					tabWidth: 4,
				},
			],
			"no-unused-vars": "off",
			"unused-imports/no-unused-vars": "off",
			"unused-imports/no-unused-imports": "warn",

			"@typescript-eslint/no-unused-vars": [
				"warn",
				{
					args: "after-used",
					ignoreRestSiblings: false,
					argsIgnorePattern: "^_.*?$",
					varsIgnorePattern: "^_.*?$",
					caughtErrorsIgnorePattern: "^_.*?$",
				},
			],

			"import/extensions": ["error", "ignorePackages"],

			"import/order": [
				"warn",
				{
					groups: [
						"type",
						"builtin",
						"object",
						"external",
						"internal",
						"parent",
						"sibling",
						"index",
					],
					pathGroups: [
						{
							pattern: "@/**",
							group: "internal",
							position: "after",
						},
					],
					"newlines-between": "always",
				},
			],

			"no-relative-import-paths/no-relative-import-paths": [
				"warn",
				{ allowSameFolder: true, rootDir: "src", prefix: "@" },
			],

			"padding-line-between-statements": [
				"warn",
				{
					blankLine: "always",
					prev: "*",
					next: "return",
				},
				{
					blankLine: "always",
					prev: ["const", "let", "var"],
					next: "*",
				},
				{
					blankLine: "any",
					prev: ["const", "let", "var"],
					next: ["const", "let", "var"],
				},
			],
		},
	},
];
