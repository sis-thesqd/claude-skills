# Squadit — Next.js Project Audit Skill

## Purpose
Perform a comprehensive audit of a Next.js project across up to 8 categories, grading each from A to F, and provide actionable feedback ordered from easiest to hardest fix in beginner-friendly language.

## Trigger
When the user runs `/squadit` or asks to "audit", "review", or "grade" a Next.js project.

## Inputs
- `PROJECT_PATH`: The root directory of the Next.js project to audit. Ask the user if not obvious.

## Assumptions
- All projects are deployed on **Vercel**. Do NOT flag anything that Vercel handles natively as a platform feature, including: rate limiting, DDOS protection, edge caching, CDN distribution, SSL/TLS, and serverless function isolation. Focus only on what the developer controls in their code.

---

## Phase 1: Pre-Audit Interview

Before auditing anything, conduct a short interactive interview with the user. The purpose is to understand the codebase through the developer's eyes so the audit is accurate, relevant, and doesn't flag intentional decisions as problems.

**Important:** These questions should be answerable by a beginner. Use plain language. Do NOT dump all questions at once — ask them in 3 conversational rounds so it feels like a natural discussion, not a form.

### Round 1: Project Basics

After confirming `PROJECT_PATH`, silently scan the project to detect:
- `package.json` dependencies (UI libraries, state management, data fetching, etc.)
- Directory structure (top-level folders)
- Router type (App Router vs Pages Router)
- Config files present (tailwind.config, .eslintrc, tsconfig, etc.)

Then present your findings and ask:

> **Here's what I found in your project:**
>
> - **Framework:** Next.js [version] with [App Router / Pages Router / Both]
> - **Styling:** [Tailwind CSS / CSS Modules / styled-components / etc.]
> - **UI Library:** [shadcn/ui / MUI / Chakra / Mantine / Ant Design / Radix / none detected]
> - **State Management:** [Zustand / Redux / Jotai / React Context only / none detected]
> - **Data Fetching:** [React Query / SWR / tRPC / fetch only / none detected]
> - **Other Notable Deps:** [list any significant ones like Framer Motion, Zod, Prisma, etc.]
>
> **Questions:**
> 1. Does this look right? Anything I got wrong or missed?
> 2. If I detected a UI library: **Are you actively using [library name] as your primary component library? Should I flag custom-built components that could be replaced with [library name] components instead?**
>    If no UI library detected: **Are you using any UI component library I might have missed? Or is everything custom-built intentionally?**

Wait for the user's response before continuing.

### Round 2: Architecture Understanding

After the silent scan, present what you believe the project's architecture pattern is:

> **Here's how I understand your project structure:**
>
> ```
> [Print the detected top-level directory tree, 2 levels deep]
> ```
>
> **From what I can see, it looks like:**
> - Components live in: `[detected path]`
> - Pages/routes live in: `[detected path]`
> - Utility/helper functions live in: `[detected path]`
> - API routes live in: `[detected path]`
> - Types/interfaces live in: `[detected path]`
> - Hooks live in: `[detected path or "no dedicated directory detected"]`
> - Services/API clients live in: `[detected path or "no dedicated directory detected"]`
>
> **Questions:**
> 1. Is this how you intend the project to be organized? Or should certain things live somewhere else?
> 2. Are there any directories I should **skip** during the audit? (e.g., generated files, legacy code you're planning to delete, experimental features)
> 3. Are components meant to be **co-located with their routes** (inside `app/` folders), or kept in a **shared components directory**, or a **mix of both**? Which approach do you *want* to follow going forward?

Wait for the user's response before continuing.

### Round 3: Context & Expectations

> **Last few questions before I start:**
>
> 1. Is there any **known tech debt** or messy areas I should be aware of? (I'll still audit them but I won't be surprised by them)
> 2. Are you in the middle of any **migrations**? (e.g., Pages Router → App Router, JavaScript → TypeScript, one styling approach to another)
> 3. Is there anything specific you're **most worried about** or want me to pay extra attention to?
> 4. How would you describe the **stage** of this project? (e.g., early prototype, MVP, production app with real users, mature product)

Wait for the user's response before continuing.

### Storing Interview Answers

After all 3 rounds, compile the user's answers into an `INTERVIEW_CONTEXT` object that is referenced throughout every audit category:

```
INTERVIEW_CONTEXT:
  ui_library: [name or "none"]
  ui_library_enforce: [true/false — should we flag custom components that could use the library?]
  ui_library_components_available: [list of component names from the detected library, populated by reading the library's installed components or docs]
  intended_architecture: [user's description of how they want things organized]
  component_strategy: [co-located / shared / mixed — and which they want going forward]
  skip_directories: [list of dirs to skip]
  known_tech_debt: [user's notes]
  active_migrations: [user's notes]
  focus_areas: [what they care most about]
  project_stage: [prototype / MVP / production / mature]
  detected_deps: [full list of notable dependencies]
  styling_approach: [Tailwind / CSS Modules / etc.]
```

---

## Phase 2: UI Library Inventory (if applicable)

If `ui_library_enforce` is `true`, before starting the category audits:

1. **Identify installed UI library components.** For example:
   - For **shadcn/ui**: Read the `components/ui/` directory (or wherever shadcn components are installed) to get the list of available components.
   - For **MUI**: Check `@mui/material` imports used across the project to understand what's available.
   - For **Chakra UI**: Check `@chakra-ui/react` usage patterns.
   - For other libraries: Adapt accordingly.

2. **Build a component map** of what the UI library provides. This will be used in the audit to suggest specific replacements. For example, if shadcn/ui is detected and has `Button`, `Dialog`, `Card`, `Input`, `Select`, `Table`, `Tabs`, `Badge`, `Alert`, `Toast`, `Dropdown Menu`, `Popover`, `Tooltip`, `Sheet`, `Accordion` installed — store all of these.

3. **Scan for custom implementations** that duplicate UI library functionality:
   - Custom button components when `Button` exists in the library
   - Custom modal/dialog components when `Dialog` exists
   - Custom dropdown components when `Select` or `DropdownMenu` exists
   - Custom card wrappers when `Card` exists
   - Custom input wrappers when `Input` exists
   - Custom toast/notification systems when `Toast`/`Sonner` exists
   - Custom tab components when `Tabs` exists
   - Custom tooltip implementations when `Tooltip` exists
   - Custom accordion/collapsible when `Accordion` exists
   - Custom table components when `Table`/`DataTable` exists

---

## Phase 3: Project Discovery

1. **Check for previous audits**
   - Look for a `squadits/` directory at the project root.
   - If it exists, read all `audit-*.md` files and parse the grade table from each one (the `| Category | Grade | Summary |` table).
   - Identify the **most recent previous audit** (highest audit number) to use as the baseline for comparison.
   - Store all historical grades so you can show trends across multiple audits if more than one exists.
   - If no previous audits exist, note this is the first audit and skip comparison.

2. **Detect monorepo vs single app**
   - Look for `turbo.json`, `nx.json`, `pnpm-workspace.yaml`, or `workspaces` key in root `package.json`.
   - If monorepo, identify all Next.js apps within it and ask the user which to audit (or audit all).

3. **Count project scope**
   - Count total files (excluding `node_modules`, `.next`, `.git`, `dist`, `build`, `squadits`, and any user-specified skip directories).
   - Count total lines of code across `.ts`, `.tsx`, `.js`, `.jsx`, `.css`, `.scss`, `.json`, `.md` files (excluding `squadits/` and skip directories).
   - Estimate audit time: ~1 minute per 500 files or 50,000 lines of code (whichever is larger), minimum 2 minutes.
   - Report the count and estimate to the user before proceeding. Ask for confirmation to continue.

---

## Phase 4: Audit Categories

### Category 1: Directory Organization (Grade A–F)

**What to check:**
- Is there a clear separation of concerns? Look for directories like `components/`, `lib/`, `utils/`, `hooks/`, `services/`, `types/`, `constants/`, `styles/`, `public/`.
- Are route files (`page.tsx`, `layout.tsx`, `route.ts`) only inside `app/` or `pages/`?
- Are components co-located with their routes or organized in a shared directory? Either is fine but it should be consistent.
- **Compare against the user's stated intended architecture from the interview.** Grade based on how well the codebase matches what the user *wants* it to be, not just general best practices.
- Are there files in the project root that should be in subdirectories (e.g., utility files sitting in root)?
- Is there a clear pattern for where API-related code lives vs UI code?
- Are assets organized (images in `public/`, fonts properly placed)?
- Are there empty directories or orphaned files that serve no purpose?
- If the user stated a preference for co-located vs shared components, check if the codebase follows that preference consistently.

**Grading rubric:**
- **A**: Clean, predictable structure that matches the user's intended architecture. A new developer could find any file in seconds.
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

### Category 8: UI Library Usage (Grade A–F)

**Only include this category if `ui_library_enforce` is `true` in the interview context. If `false` or no UI library detected, skip this category entirely and keep the audit at 7 categories.**

**What to check:**
- Are there custom-built components that duplicate functionality already available in the installed UI library?
- Is the UI library being used consistently across the app, or are some areas using it while others use raw HTML/custom components?
- Are UI library components being used correctly (proper props, variants, composability)?
- Are there wrapper components around UI library components that add no value (unnecessary abstraction)?
- Are there areas where the UI library's theming/design tokens are being bypassed with hardcoded styles?
- Is the UI library's form components being used for forms, or are there custom form inputs alongside library inputs?
- Are the UI library's layout primitives being used, or is layout done with custom CSS that the library already handles?

**For each custom component that should use the library instead, provide:**
1. The file path of the custom component
2. What it does (in plain English)
3. The specific UI library component(s) that should replace it
4. A brief example of what the replacement would look like
5. Difficulty estimate (easy / medium / hard)

**Grading rubric:**
- **A**: UI library is used consistently everywhere it should be. No unnecessary custom components. Theming is respected.
- **B**: Mostly consistent. 1–3 components could use the library but don't. Minor gaps.
- **C**: Mixed usage. The UI library is used in some places but several custom components exist that duplicate its functionality.
- **D**: The UI library is installed but largely unused. Most components are custom-built despite the library being available.
- **F**: The UI library is installed but essentially ignored. Custom implementations everywhere.

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
**UI Library:** [name and version, or "None"]
**Project Stage:** [from interview]

---

## Interview Summary

**User's Intended Architecture:**
[Summary of how the user described their intended structure]

**Known Tech Debt:**
[What the user flagged, or "None noted"]

**Active Migrations:**
[What the user flagged, or "None"]

**Focus Areas:**
[What the user wants extra attention on, or "General audit"]

**Skipped Directories:**
[List, or "None"]

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
| UI Library Usage | [A-F] | [one-line summary] |

[Omit the UI Library Usage row if category was skipped]

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

[...repeat for all categories...]

---

### 8. UI Library Usage — Grade: [X]

[Only include if ui_library_enforce is true]

#### Components You Already Have Available
[List all installed UI library components detected in the project]

#### Custom Components That Should Use [Library Name] Instead

| Custom Component | File | What It Does | Suggested Replacement | Difficulty |
|-----------------|------|--------------|----------------------|------------|
| `CustomButton` | `components/Button.tsx` | Renders a styled button with variants | Use `<Button>` from shadcn/ui with `variant` prop | 🟢 Easy |
| `ConfirmModal` | `components/ConfirmModal.tsx` | Confirmation dialog with overlay | Use `<AlertDialog>` from shadcn/ui | 🟡 Medium |
| `CustomDropdown` | `components/Dropdown.tsx` | Dropdown menu with items | Use `<DropdownMenu>` from shadcn/ui | 🟡 Medium |

#### Example Replacements

For each flagged component, show a brief before/after:

**Before (custom):**
```tsx
// components/CustomButton.tsx — 45 lines of custom code
```

**After (using [library]):**
```tsx
// Direct usage, no custom component needed
import { Button } from "@/components/ui/button"

<Button variant="destructive" size="sm" onClick={handleDelete}>
  Delete
</Button>
```

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
| UI Library Usage | [prev grade] | [current grade] | [⬆️/➡️/⬇️] |
| **Overall** | **[prev]** | **[current]** | **[⬆️/➡️/⬇️]** |

### What Improved
- [List specific issues from the previous audit that have been fixed.]

### What Regressed
- [List any categories or specific areas that got worse since last audit.]

### Still Outstanding
- [List the top issues from the previous audit that remain unfixed.]

### Audit History Trend
[Only include if 3+ audits exist.]

| Audit | Date | Overall | Dir | Prof | Style | Redund | Refactor | Perf | Security | UI Lib |
|-------|------|---------|-----|------|-------|--------|----------|------|----------|--------|
| #1 | [date] | [grade] | ... | ... | ... | ... | ... | ... | ... | ... |
| #[N] | today | [grade] | ... | ... | ... | ... | ... | ... | ... | ... |

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

1. **Interview phase**: Conduct the 3-round interactive interview. Do NOT proceed until the user has answered all rounds. Compile answers into `INTERVIEW_CONTEXT`.
2. **UI Library inventory phase**: If a UI library is confirmed, build the component map and scan for custom duplicates.
3. **History phase**: Check for previous audits in `squadits/` directory. Parse grades from the most recent audit to use as comparison baseline.
4. **Discovery phase**: Detect monorepo, count files/lines (excluding any user-specified skip paths). Report estimate, mention how many previous audits were found, and ask to continue.
5. **Read phase**: Read all relevant source files systematically. Start with the project structure (directory listing), then read files grouped by category relevance.
6. **Analysis phase**: For each category, collect findings and assign a grade. Always reference `INTERVIEW_CONTEXT` when grading — the user's stated intentions matter.
7. **Comparison phase**: Compare current grades against previous audit. Identify fixed issues, regressions, and outstanding items.
8. **Report phase**: Generate the Markdown report (including interview summary and progress comparison), save it to the `squadits` directory, and print it.

**Important rules:**
- Never modify any project files (read-only audit).
- Skip `node_modules`, `.next`, `.git`, `dist`, `build`, `coverage` directories, plus any user-specified skip directories from the interview.
- For very large projects (2000+ files), sample representative files from each directory rather than reading every file. Note in the report that sampling was used.
- Be specific in findings. Always include file paths and line numbers where possible.
- Write all feedback in plain, beginner-friendly language. Avoid jargon. If you must use a technical term, explain it in parentheses.
- Order feedback within each category from easiest fix to hardest fix.
- Assume Vercel hosting. Do not flag the absence of rate limiting, DDOS protection, or other Vercel-native platform features.
- When grading Directory Organization, weight the user's intended architecture heavily. If they told you how they want it organized, grade against that vision.
- When the UI Library category is active, be specific about replacements. Don't just say "use the library" — name the exact component, the exact props, and show a brief code example.
- Adjust grading leniency based on project stage from the interview: prototypes get more leniency than production apps.
