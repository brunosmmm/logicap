"""Standard validators."""

from logicap.config import TestConfigurationError


def validate_integer(fn):
    """Validate integer."""

    def _validate(value, **kwargs):
        """Perform validation."""
        if not isinstance(value, int):
            # try converting
            try:
                value = int(value)
            except ValueError:
                try:
                    value = int(value.lstrip("0x"), 16)
                except ValueError:
                    try:
                        value = int(value.lstrip("0b"), 2)
                    except ValueError:
                        raise TestConfigurationError(
                            "cannot convert value to integer"
                        )
        return fn(value, **kwargs)

    return _validate


def validate_positive_integer(fn):
    """Validate positive integer."""

    @validate_integer
    def _validate(value, **kwargs):
        """Perform validation."""
        if value < 0:
            raise TestConfigurationError("value must be a positive integer")
        return fn(value, **kwargs)

    return _validate


def validate_string(fn):
    """Validate string value."""

    def _validate(value, **kwargs):
        """Perform validation."""
        if not isinstance(value, str):
            raise TestConfigurationError("value must be a string")

        return fn(value, **kwargs)

    return _validate
