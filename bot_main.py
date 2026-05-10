from __future__ import annotations

import asyncio
from typing import TYPE_CHECKING

from dotenv import load_dotenv

from app.bootstrap.logging_config import setup_bot_logging
from app.paths.project_paths import get_project_paths
from app.telegram_bot.bot_dispatcher import run_bot

if TYPE_CHECKING:
    from app.paths.project_paths import ProjectPaths


def main() -> int:
    project_paths: ProjectPaths = get_project_paths()
    load_dotenv(dotenv_path=project_paths.secrets_env_path, override=False)
    try:
        setup_bot_logging()
        asyncio.run(run_bot())
        return 0
    except BaseException as exc:
        import traceback
        from datetime import datetime
        try:
            fatal_log_path = project_paths.state_dir / "bot_startup_failure.log"
            project_paths.state_dir.mkdir(parents=True, exist_ok=True)
            with fatal_log_path.open("a", encoding="utf-8") as fp:
                fp.write(
                    f"\n=== FATAL bot startup failure at {datetime.now().isoformat()} ===\n"
                )
                fp.write(f"exception: {type(exc).__name__}: {exc}\n")
                fp.write(traceback.format_exc())
                fp.write("\n")
        except Exception:
            pass
        # Также пробуем штатный логгер, если он успел подняться
        try:
            import logging
            logging.getLogger("pipeline.bot").exception(
                "bot_startup_failed exception=%s", exc
            )
        except Exception:
            pass
        raise


if __name__ == "__main__":
    raise SystemExit(main())
