from __future__ import annotations

import sys
from typing import Sequence

from app.application.application import BroadcasterApplication


def main(argv: Sequence[str]) -> int:
    application: BroadcasterApplication = BroadcasterApplication()
    return application.run(argv)


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
