# CLAUDE.md — broadcaster (production checkout and build target)

## Project map — read first

- broadcaster is the **production** checkout: real Google Sheet, real Drive
  folder, real Telegram supergroup. It is also the **build target** for the
  Windows executable and installer (`broadcaster.spec`, `build_*.bat`,
  `installer.iss`).
- Development does **not** happen here. The `app/` folder is developed and
  tested in the restreamer sandbox (`D:\_projects\restreamer`, its own git
  repo) and then copied into this checkout as a whole. Work in this repo is
  limited to: verifying a synced `app/`, adapting the wrapper around it
  (`bot_main.py`, `promo.py`, `setup_deploy.py`, `broadcaster.spec`,
  `build_*.bat`, `installer.iss`, `dist_layout.md`, `.env.example`,
  `app_config.example.yaml`), venv maintenance, and building.
- The previous `app/` is kept at `_HELP\.app\` (gitignored) as the reference
  for comparisons after a sync.
- Python 3.13, venv `.venv_broadcaster`. Every python / pip / pytest call
  goes through `.\.venv_broadcaster\Scripts\python.exe -m ...`.
- Entry points: `bot_main.py` (Telegram bot, aiogram v3, starts the pipeline
  on button press), `promo.py`. LLM: OpenAI Responses API via `app/llm/`.
- Pipeline order: Prompt → LLM → Parse (`merge_parser`) → Validate
  (`merge_service` + `merge_validation_helpers`) → Normalize (`merge_quality`)
  → Enforce paragraphs → Sanitize (`post_llm_sanitation`) → Publish
  (`google_docs_writer` + Telegram). Contract modes: compact (2 sources),
  expanded (3+ sources), narrative (single event).
- Test baseline after the 2026-09-08 sync: **727 passed** with
  `python -m pytest -q` (requires `pytest-asyncio` in the venv). The bar is
  "no new failures beyond baseline", never a hardcoded count.
- `requirements.txt` is regenerated manually by `pip freeze` from the venv.
  It is the deploy manifest: anything installed in the venv lands in it, so
  the venv must contain only what the code, the tests and the build need.
  PyInstaller stays in the venv because the build scripts depend on it.

## Code conventions — enforced

- `from __future__ import annotations` in every module.
- Type hints on every function signature and every variable.
- No hardcoded constants inside logic: configs, enums, resource files under
  `app/resources/text/`, or at most a named module-level constant.
- OOP over functions with many arguments; reuse the request/config object
  pattern already present in the code.
- Loggers are hierarchical under the value of `LOGGER_NAME`
  (default `pipeline`); never a hardcoded project-name string.
- Naming: package folders plural, file names = singular domain + semantic
  suffix (`merge_parser.py`, `docs_client.py`, `quality_normalizer.py`).
- Moving or splitting a module: the old module stays as a re-export facade.
  No duplicated code.
- Business logic (merge contracts, validation, retry, quality gate) does not
  change during infrastructure work. The test suite is the guarantee.

## Known non-bugs — do not "fix"

- `block_spacing` deviations are normalized in post-processing;
  `block_spacing_ok` is a diagnostic indicator, never a validation gate.
- `script_mix_contamination` on Ukrainian proper nouns and `hook_present=no`
  in `merge_style_coverage` are stochastic / heuristic signals, not validator
  bugs. No new reject codes without a strong, stated justification.
- `docs_batch_update_429` warnings followed by a successful write are the
  retry engine (`app/google/api_retry.py`) absorbing the Docs write quota.

## Rules for Claude Code sessions in this repo

- **Never run the pipeline, the bot, or any build script.** A pipeline run
  here publishes to the production Telegram group and writes to the
  production Sheet; builds are started by the operator. Claude only reads,
  compares, runs `pytest`, and — when a task explicitly says so — edits the
  wrapper files or the venv.
- Do not edit anything under `app/` unless the task explicitly names the
  file. `app/` is synced from restreamer; a fix made here and not in
  restreamer is lost at the next sync. Report needed `app/` changes instead.
- The task prompt carries the scope lock: touch only the files it lists.
  Unrelated dead code, smells or ideas → report them, don't act on them.
- Work only on the branch named in the task. No push, no tags. Commit message
  text comes from the task; no `Co-Authored-By` trailer unless the task asks.
- Never edit: `requirements.txt` (regenerated at startup),
  `app/config/runtime/app_config.yaml` (operator's config), anything under
  `secrets/`, `state/`, `tools/`, `logs/`, `dist/`, `build/`, `_HELP/`.
  Never print or quote values from `secrets/.env` — key names only.
- Never install, upgrade or uninstall packages unless the task is explicitly
  about the venv.
- Verification for every task: full `pytest -q` before and after, plus the
  task-specific checks.
- Ask before: any action outside the listed steps, any change to
  `broadcaster.spec` datas/hiddenimports, any change to a build script.
- The shell under the desktop Code tab is Git Bash: use `D:/_projects/...`
  style paths and POSIX tools; PowerShell cmdlets are not available there.

---

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

Tradeoff: These guidelines bias toward caution over speed. For trivial tasks, use judgment.

1. Think Before Coding
Don't assume. Don't hide confusion. Surface tradeoffs.

Before implementing:

State your assumptions explicitly. If uncertain, ask.
If multiple interpretations exist, present them - don't pick silently.
If a simpler approach exists, say so. Push back when warranted.
If something is unclear, stop. Name what's confusing. Ask.
2. Simplicity First
Minimum code that solves the problem. Nothing speculative.

No features beyond what was asked.
No abstractions for single-use code.
No "flexibility" or "configurability" that wasn't requested.
No error handling for impossible scenarios.
If you write 200 lines and it could be 50, rewrite it.
Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

3. Surgical Changes
Touch only what you must. Clean up only your own mess.

When editing existing code:

Don't "improve" adjacent code, comments, or formatting.
Don't refactor things that aren't broken.
Match existing style, even if you'd do it differently.
If you notice unrelated dead code, mention it - don't delete it.
When your changes create orphans:

Remove imports/variables/functions that YOUR changes made unused.
Don't remove pre-existing dead code unless asked.
The test: Every changed line should trace directly to the user's request.

4. Goal-Driven Execution
Define success criteria. Loop until verified.

Transform tasks into verifiable goals:

"Add validation" → "Write tests for invalid inputs, then make them pass"
"Fix the bug" → "Write a test that reproduces it, then make it pass"
"Refactor X" → "Ensure tests pass before and after"
For multi-step tasks, state a brief plan:

1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

These guidelines are working if: fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

## Broadcaster packaging rules

- The application icon is `ico_code.ico`. Keep `broadcaster.spec`,
  `build_broadcaster_exe.bat`, `installer.iss`, and `dist_layout.md` in sync.
- Public examples must remain trackable in git: `.env.example`,
  `secrets/.env.example`, `app/config/runtime/app_config.example.yaml`.
- Real secrets must never be committed: `.env`, `token.json`, `credentials.json`,
  `service_account.json`, `cookies.txt`.
- The hidden duplicate `app/config/runtime/.app_config.example.yaml` is ignored.
- `app/config/runtime/app_config.yaml` is the operator's personal config
  (form URL, contacts) and is NOT tracked in git. Only
  `app_config.example.yaml` is tracked. `broadcaster.spec` still bundles
  `app_config.yaml`, so a fresh clone must copy the example to that name
  before building. Never re-add `app_config.yaml` to git.
- Single-instance enforcement is at the **process level** via a lock file
  `state/broadcaster.lock` (managed by `app/runtime/single_instance.py`).
  Acquired in `bot_main.py:main()` BEFORE logging setup. On conflict the
  process writes a Russian operator message to stderr AND appends one
  `lock_rejected ...` line to `logs/bot_startup.log`, then exits with
  code 1. Stale locks (PID dead) are overwritten via atomic recovery —
  `unlink` then retry `O_EXCL` create exactly once. If the recovery
  `O_EXCL` also loses, the policy is **fail-closed**: raise
  `AnotherInstanceRunning` rather than overwrite. Never write to an
  existing lock file via `write_text` — only through fresh `O_EXCL`
  creates. Released in `finally` on every exit path including
  BaseException. Successful acquire and release are mirrored to
  `logs/bot_startup.log` so all startup-phase events are visible in the
  same shippable `logs/` directory (NOT in `state/`, which is runtime
  data and never shipped for analysis).
- Telegram-side conflict handling (`TelegramConflictError`, getUpdates probe)
  was tried in a previous round and **proven insufficient** in production logs
  (20260512_15* — three bots passed probe, three pipelines ran, 12 duplicate
  publications). Do not reintroduce the probe. The process-level lock is the
  source of truth.
- Within-process duplicate triggers (one user spam-clicking the run button
  inside the same bot process) are handled by `_pipeline_lock: threading.Lock`
  in `bot_handlers_info.py` — leave that mechanism alone.
- Run-status resolution in `_resolve_run_status` (analytics_formatters.py)
  considers `fallback_merge_blocks` and `partial_merge_artifacts` as
  `partial` signals. Do not let `run_final_summary status=success` slip
  through when `audit_done overall_status=partial`.
- Portable build target is `dist\broadcaster\`. It contains both real config
  and example config so the same folder can be redistributed minus secrets.
- Installer build is two-track:
  - `build_release.bat` strips real secrets AND replaces `app_config.yaml`
    with `app_config.example.yaml` in the staging folder before invoking
    ISCC. Output filename is `broadcaster-setup-<version>.exe`. Safe for
    GitHub Releases.
  - `build_local.bat` keeps real secrets and real `app_config.yaml`.
    Output filename is `broadcaster-setup-local-<version>.exe` to prevent
    overwriting a release build sitting in `dist\installer\`.
    For personal use only.
- The installer (`installer.iss`) writes only to `{app}` and the standard
  Inno uninstall entry. It must not add custom registry keys.
- Do not use broad ignore rules like `*.bat` or `*.ico` — they hide
  intentional project files.
