"""Standard validators."""

from logicap.config import TestConfigurationError


def validate_integer(fn):
    """Validate integer."""

    def _validate(_value, **kwargs):
        """Perform validation."""
        if not isinstance(_value, int):
            # try converting
            try:
                value = int(_value)
            except ValueError:
                try:
                    if _value.startswith("0x"):
                        _value = _value[2:]
                    _value = int(_value, 16)
                except ValueError:
                    try:
                        if _value.startswith("0b"):
                            _value = _value[2:]
                        _value = int(_value.lstrip("0b"), 2)
                    except ValueError:
                        raise TestConfigurationError(
                            f"cannot convert value to integer: '{_value}'"
                        )
        return fn(_value, **kwargs)

    return _validate


def validate_positive_integer(fn):
    """Validate positive integer."""

    @validate_integer
    def _validate(_value, **kwargs):
        """Perform validation."""
        if _value < 0:
            raise TestConfigurationError("value must be a positive integer")
        return fn(_value, **kwargs)

    return _validate


def validate_string(fn):
    """Validate string value."""

    def _validate(_value, **kwargs):
        """Perform validation."""
        if not isinstance(_value, str):
            raise TestConfigurationError("value must be a string")

        return fn(_value, **kwargs)

    return _validate
