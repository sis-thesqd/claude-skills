# Squadit — Next.js Project Audit Skill

## Purpose
Perform a comprehensive audit of a Next.js project across 7 categories, grading each from A to F, and provide actionable feedback ordered from easiest to hardest fix in beginner-friendly language.

## Trigger
When the user runs `/squadit` or asks to "audit", "review", or "grade" a Next.js project.

## Inputs
- `PROJECT_PATH`: The root directory of the Next.js project to audit. Ask the user if not obvious.
- `CONTEXT` (optional): Free-form notes from the user to guide the audit. After confirming the project path, always ask: **"Any context I should know before auditing? For example: UI libraries in use, files/directories to ignore, recent migrations, known tech debt, or anything else."** If the user provides context, apply it throughout the audit. Examples of what context might include:
  - UI component libraries (e.g., "We use shadcn/ui" — don't flag those component files for style inconsistency or refactoring)
  - Files or directories to skip (e.g., "Ignore `src/generated/`" — exclude from all categories)
  - Known tech debt (e.g., "We know the auth flow is messy, focusing on dashboard next" — still audit it but acknowledge it's known)
  - Architecture decisions (e.g., "We intentionally co-locate components with routes" — don't flag as disorganized)
  - In-progress migrations (e.g., "Migrating from Pages Router to App Router" — grade leniently on having both)

## Assumptions
- All projects are deployed on **Vercel**. Do NOT flag anything that Vercel handles natively as a platform feature, including: rate limiting, DDOS protection, edge caching, CDN distribution, SSL/TLS, and serverless function isolation. Focus only on what the developer controls in their code.

## Pre-Audit: Project Discovery

Before starting, gather project metadata:

1. **Check for previous audits**
   - Look for a `squadits/` directory at the project root.
   - If it exists, read all `audit-*.md` files and parse the grade table from each one (the `| Category | Grade | Summary |` table).
   - Identify the **most recent previous audit** (highest audit number) to use as the baseline for comparison.
   - Store all historical grades so you can show trends across multiple audits if more than one exists.
   - If no previous audits exist, note this is the first audit and skip comparison.

2. **Detect framework version & router type**
   - Read `package.json` for `next` version.
   - Check for `app/` directory (App Router) and/or `pages/` directory (Pages Router). Report which is detected.
3. **Detect monorepo vs single app**
   - Look for `turbo.json`, `nx.json`, `pnpm-workspace.yaml`, or `workspaces` key in root `package.json`.
   - If monorepo, identify all Next.js apps within it and ask the user which to audit (or audit all).
4. **Count project scope**
   - Count total files (excluding `node_modules`, `.next`, `.git`, `dist`, `build`, `squadits`).
   - Count total lines of code across `.ts`, `.tsx`, `.js`, `.jsx`, `.css`, `.scss`, `.json`, `.md` files (excluding `squadits/`).
   - Estimate audit time: ~1 minute per 500 files or 50,000 lines of code (whichever is larger), minimum 2 minutes.
   - Report the count and estimate to the user before proceeding. Ask for confirmation to continue.

---

## Audit Categories

### Category 1: Directory Organization (Grade A–F)

**What to check:**
- Is there a clear separation of concerns? Look for directories like `components/`, `lib/`, `utils/`, `hooks/`, `services/`, `types/`, `constants/`, `styles/`, `public/`.
- Are route files (`page.tsx`, `layout.tsx`, `route.ts`) only inside `app/` or `pages/`?
- Are components co-located with their routes or organized in a shared directory? Either is fine but it should be consistent.
- Are there files in the project root that should be in subdirectories (e.g., utility files sitting in root)?
- Is there a clear pattern for where API-related code lives vs UI code?
- Are assets organized (images in `public/`, fonts properly placed)?
- Are there empty directories or orphaned files that serve no purpose?

**Grading rubric:**
- **A**: Clean, predictable structure. A new developer could find any file in seconds.
- **B**: Good structure with minor inconsistencies (e.g., one-off files in odd places).
- **C**: Some structure exists but it's inconsistent or partially organized.
- **D**: Disorganized. Files scattered with no clear pattern.
- **F**: No discernible organization. Files dumped everywhere.

---

### Category 2: Code Professionalism (Grade A–F)

**What to check (compared to enterprise-grade apps by Google, Meta, Shopify, etc.):**
- Are components well-named with descriptive, PascalCase names?
- Are functions and variables named clearly (no `x`, `temp`, `data2`, `handleClick2`)?
- Is TypeScript used with proper typing (no excessive `any` types)?
- Are there proper error boundaries and error handling patterns?
- Is loading/error/empty state handled in UI components?
- Are magic numbers and magic strings avoided (use constants instead)?
- Is there separation between business logic and UI rendering?
- Are custom hooks used to extract reusable logic?
- Are comments used where logic is complex (not obvious code)?
- Is there proper use of React patterns (controlled components, composition, etc.)?
- **Hardcoded config values**: Flag any hardcoded configuration data (URLs, feature flags, thresholds, tier limits, plan names, pricing, etc.) that should be stored in a database or CMS to be made dynamic. List each instance with the file, line, and a suggestion for where it could live instead (e.g., Supabase table, environment variable, CMS).

**Grading rubric:**
- **A**: Could pass a code review at a FAANG company. Clean, typed, well-separated, enterprise patterns.
- **B**: Professional quality with minor gaps (a few `any` types, occasional unclear naming).
- **C**: Functional but amateur patterns. Inline logic, weak typing, inconsistent naming.
- **D**: Messy. Poor naming, no error handling, `any` everywhere, spaghetti logic.
- **F**: Unreadable or unmaintainable code.

---

### Category 3: Consistency of Style (Grade A–F)

**What to check:**
- Is the code formatting consistent across all files (indentation, semicolons, quotes, trailing commas)?
- Are imports ordered consistently (e.g., React first, then third-party, then local)?
- Is the component structure consistent (e.g., always hooks at top, then handlers, then render)?
- Are file naming conventions consistent (kebab-case vs camelCase vs PascalCase)?
- Are CSS/styling approaches consistent (all Tailwind, all CSS modules, all styled-components — not a mix)?
- Are API calls structured the same way across the app?
- Are TypeScript interfaces/types defined in a consistent location and pattern?
- Is there a consistent pattern for exports (default vs named)?

**Grading rubric:**
- **A**: Every file feels like it was written by the same developer. Perfectly consistent.
- **B**: Mostly consistent with a few deviations.
- **C**: Mixed styles. Some files follow a pattern, others don't.
- **D**: Inconsistent across most of the codebase.
- **F**: No consistency whatsoever. Every file is different.

---

### Category 4: Redundant Code and Files (Grade A–F)

**What to check:**
- Are there duplicate components that do nearly the same thing?
- Are there utility functions that duplicate each other or duplicate built-in JS/library methods?
- Are there unused imports in files?
- Are there files that are not imported or referenced anywhere in the project?
- Are there commented-out blocks of code that should be removed?
- Are there multiple copies of the same type definition?
- Are there CSS classes or Tailwind utilities that are duplicated across components instead of being extracted?
- Are there unused dependencies in `package.json`?
- Are there dead routes (pages/API routes that aren't linked to from anywhere)?

**Grading rubric:**
- **A**: Zero redundancy. Every file and function has a clear, unique purpose.
- **B**: Minor redundancy (a few unused imports, one or two similar utilities).
- **C**: Noticeable redundancy. Several duplicate patterns or unused files.
- **D**: Significant bloat. Many unused files, duplicate logic, dead code.
- **F**: The project is full of copy-pasted code and dead files.

---

### Category 5: Files That Need Refactoring (Grade A–F)

**What to check:**
- Flag any single file over **300 lines** as a candidate for refactoring.
- Flag any single function/component over **100 lines** as too large.
- Flag any file with more than **10 imports** as potentially doing too much.
- Flag any component that manages more than **5 pieces of state** (useState calls) as needing decomposition.
- Flag any single file that mixes API calls, business logic, AND UI rendering.
- Flag deeply nested JSX (more than 4 levels of nesting inside a return statement).

**Grading rubric:**
- **A**: No files need refactoring. Everything is small, focused, and single-purpose.
- **B**: 1–3 files could benefit from splitting. Nothing urgent.
- **C**: 4–8 files are too large or doing too much.
- **D**: 9–15 files need refactoring. Several god-components or mega-files.
- **F**: 15+ files are oversized. The codebase is dominated by monolithic files.

---

### Category 6: App Performance (Grade A–F)

**What to check:**
- Are images using `next/image` instead of raw `<img>` tags?
- Are heavy components wrapped in `React.lazy()` or `dynamic()` imports where appropriate?
- Is `use client` directive used sparingly and only where needed (not on every component)?
- Are large lists virtualized (react-window, react-virtuoso, etc.) or paginated?
- Are expensive computations wrapped in `useMemo` or `useCallback` where appropriate?
- Are there unnecessary re-renders caused by inline object/array/function creation in JSX props?
- Is data fetching efficient (no waterfall requests, proper caching with SWR/React Query/fetch cache)?
- Are fonts loaded efficiently using `next/font`?
- Are third-party scripts loaded with `next/script` with proper strategy?
- Is there excessive client-side JavaScript that could be server-rendered?
- Are there large bundle dependencies that could be replaced with lighter alternatives?

**Grading rubric:**
- **A**: Optimized for production. Follows all Next.js performance best practices.
- **B**: Good performance with a few missed optimizations.
- **C**: Some performance issues. Missing image optimization or excessive client components.
- **D**: Multiple performance problems. Likely slow on mobile or low-bandwidth.
- **F**: No attention to performance. Raw img tags, everything client-rendered, no optimization.

---

### Category 7: Security (Grade A–F)

**Important: These apps are deployed on Vercel.** Vercel natively handles rate limiting, DDOS protection, edge caching, CDN, and SSL. Do NOT flag the absence of these as issues. Focus only on application-level security that the developer controls.

**What to check:**

**Secrets & Environment Variables:**
- Is `.env` (or `.env.local`, `.env.production`, etc.) listed in `.gitignore`?
- Are there any hardcoded API keys, tokens, passwords, or secrets in source code files?
- Are `NEXT_PUBLIC_` environment variables used appropriately (only for truly public data)?
- Are any secret keys accidentally prefixed with `NEXT_PUBLIC_`?

**API Route Protection:**
- Are all external API calls (to third-party services like Supabase, Stripe, OpenAI, etc.) made through Next.js API routes (`app/api/` or `pages/api/`) rather than directly from client components?
- Flag every instance where a client component makes a direct fetch/axios call to an external API that isn't a Next.js API route. These leak API endpoints and potentially keys to the browser.
- Are API routes validating input and sanitizing data?
- Are API routes checking authentication/authorization before processing requests?

**Data Exposure:**
- Are database queries returning more fields than needed (over-fetching)?
- Are API responses including sensitive data that the client doesn't need?
- Are error messages leaking internal details (stack traces, database schema, internal paths)?
- Are there any `console.log` statements that output sensitive data?
- Are there any open endpoints that could be used to enumerate data (e.g., `/api/user/[id]` without auth)?

**Grading rubric:**
- **A**: Secrets properly managed, all external calls go through API routes, no data leaks.
- **B**: Good security posture with 1–2 minor gaps (e.g., a missing auth check on one route).
- **C**: Some security issues. A few direct client-side API calls or missing auth checks.
- **D**: Multiple security concerns. Hardcoded secrets, exposed endpoints.
- **F**: Critical security failures. API keys in source code, no API route usage, wide-open endpoints.

---

## Output Format

Generate a Markdown report with this structure:

```markdown
# Squadit Report
**Project:** [project name from package.json]
**Path:** [PROJECT_PATH]
**Date:** [current date]
**Framework:** Next.js [version] ([App Router / Pages Router / Both])
**Structure:** [Single App / Monorepo]
**Hosting:** Vercel
**Scope:** [X] files | [Y] lines of code
**User Context:** [print the user's context verbatim here, or "None provided" if skipped]

---

## Overall Grade: [weighted average letter grade]

| Category | Grade | Summary |
|----------|-------|---------|
| Directory Organization | [A-F] | [one-line summary] |
| Code Professionalism | [A-F] | [one-line summary] |
| Consistency of Style | [A-F] | [one-line summary] |
| Redundant Code & Files | [A-F] | [one-line summary] |
| Files Needing Refactoring | [A-F] | [one-line summary] |
| App Performance | [A-F] | [one-line summary] |
| Security | [A-F] | [one-line summary] |

---

## Detailed Findings

### 1. Directory Organization — Grade: [X]

#### What's Good
- [positive findings]

#### What to Improve
[Ordered from easiest to hardest. Each item written in beginner-friendly language.]

1. **[Issue Title]** (📁 `path/to/file`)
   **What's wrong:** [plain English explanation]
   **How to fix:** [step-by-step in simple terms]
   **Why it matters:** [one sentence]

---

### 2. Code Professionalism — Grade: [X]
[same format as above]

#### Hardcoded Config That Should Be Dynamic
| File | Line | Current Value | Suggestion |
|------|------|---------------|------------|
| `path/file.ts` | 42 | `"https://api.example.com"` | Move to database config table or env var |

---

[...repeat for all 7 categories...]

---

## API Calls Not Using API Routes

Every instance where a client-side component calls an external API directly instead of going through a Next.js API route.

| File | Line | External URL/Service | Risk |
|------|------|---------------------|------|
| `components/Chat.tsx` | 55 | `https://api.openai.com/v1/chat` | API key exposed to browser |

---

## Progress Since Last Audit

[Only include this section if a previous audit exists in the `squadits/` directory. If this is the first audit, replace this section with: "🆕 **First audit** — no previous data to compare. Run `/squadit` again after making improvements to track progress."]

**Comparing:** Audit [N] (today) vs Audit [N-1] ([date of previous audit])

| Category | Previous | Current | Change |
|----------|----------|---------|--------|
| Directory Organization | [prev grade] | [current grade] | [⬆️ improved / ➡️ same / ⬇️ regressed] |
| Code Professionalism | [prev grade] | [current grade] | [⬆️/➡️/⬇️] |
| Consistency of Style | [prev grade] | [current grade] | [⬆️/➡️/⬇️] |
| Redundant Code & Files | [prev grade] | [current grade] | [⬆️/➡️/⬇️] |
| Files Needing Refactoring | [prev grade] | [current grade] | [⬆️/➡️/⬇️] |
| App Performance | [prev grade] | [current grade] | [⬆️/➡️/⬇️] |
| Security | [prev grade] | [current grade] | [⬆️/➡️/⬇️] |
| **Overall** | **[prev]** | **[current]** | **[⬆️/➡️/⬇️]** |

### What Improved
- [List specific issues from the previous audit that have been fixed. Reference the original finding number/description so the user can see exactly what they addressed.]

### What Regressed
- [List any categories or specific areas that got worse since last audit. Be specific about what changed.]

### Still Outstanding
- [List the top issues from the previous audit that remain unfixed. These should be prioritized in the fix list below.]

### Audit History Trend
[Only include if 3+ audits exist. Show the grade progression over time.]

| Audit | Date | Overall | Dir | Prof | Style | Redund | Refactor | Perf | Security |
|-------|------|---------|-----|------|-------|--------|----------|------|----------|
| #1 | [date] | [grade] | ... | ... | ... | ... | ... | ... | ... |
| #2 | [date] | [grade] | ... | ... | ... | ... | ... | ... | ... |
| #[N] | today | [grade] | ... | ... | ... | ... | ... | ... | ... |

---

## Priority Fix List (All Categories Combined)

This is your action plan. Start at the top and work your way down.

### 🟢 Quick Wins (< 5 minutes each)
1. [fix description with file path]
2. ...

### 🟡 Medium Effort (15–60 minutes each)
1. [fix description with file path]
2. ...

### 🔴 Major Refactors (1+ hours each)
1. [fix description with file path]
2. ...
```

## Report Delivery

1. **Create the `squadits` directory** at the project root (`[PROJECT_PATH]/squadits/`) if it doesn't already exist.
2. **Determine the next audit number** by checking existing files in the `squadits` directory. Look for files matching the pattern `audit-[N].md` (e.g., `audit-1.md`, `audit-2.md`). The new audit should use the next available number. If the directory is empty or new, start with `audit-1.md`.
3. **Save the Markdown report** to `[PROJECT_PATH]/squadits/audit-[N].md` (e.g., `squadits/audit-1.md`, `squadits/audit-2.md`, etc.).
4. Print the full report to stdout so the user can read it immediately.
5. At the end, print a short summary: overall grade, biggest win, biggest risk, and the file path where the report was saved.

---

## Execution Instructions

When running this audit, follow this order:

1. **History phase**: Check for previous audits in `squadits/` directory. Parse grades from the most recent audit to use as comparison baseline. If multiple audits exist, collect all historical grades for the trend table.
2. **Context phase**: Ask the user for optional free-form context. If provided, note any files/directories to skip, libraries to account for, or leniency to apply. Carry this context into every subsequent phase.
3. **Discovery phase**: Detect framework, router, monorepo, count files/lines (excluding any user-specified skip paths). Report estimate, mention how many previous audits were found, and ask to continue.
4. **Read phase**: Read all relevant source files systematically. Start with the project structure (directory listing), then read files grouped by category relevance.
5. **Analysis phase**: For each category, collect findings and assign a grade.
6. **Comparison phase**: Compare current grades against previous audit. Identify fixed issues, regressions, and outstanding items.
7. **Report phase**: Generate the Markdown report (including progress comparison), save it to the `squadits` directory, and print it.

**Important rules:**
- Never modify any project files (read-only audit).
- Skip `node_modules`, `.next`, `.git`, `dist`, `build`, `coverage` directories.
- For very large projects (2000+ files), sample representative files from each directory rather than reading every file. Note in the report that sampling was used.
- Be specific in findings. Always include file paths and line numbers where possible.
- Write all feedback in plain, beginner-friendly language. Avoid jargon. If you must use a technical term, explain it in parentheses.
- Order feedback within each category from easiest fix to hardest fix.
- Assume Vercel hosting. Do not flag the absence of rate limiting, DDOS protection, or other Vercel-native platform features.
