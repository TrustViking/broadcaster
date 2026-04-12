from __future__ import annotations


class BroadcasterError(RuntimeError):
    """Base application error."""


# Legacy aliases
RestreamerError = BroadcasterError
StreamertgError = BroadcasterError


class ConfigurationError(BroadcasterError):
    """Configuration/validation error."""


class TemplateError(ConfigurationError):
    """Template loading/validation error."""
