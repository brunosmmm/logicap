"""Standard validators."""

from logicap.config import TestConfigurationError


class Validator:
    """Validator abstract class."""


class ValidateType(Validator):
    """Type validator."""

    def __init__(self, _type):
        """Initialize."""
        self._type = _type

    @property
    def target_type(self):
        """Get target type."""
        return self._type

    def __call__(self, fn):
        """Decorator."""

        def _validate(_value, **kwargs):
            """Perform validation."""
            if not isinstance(_value, self.target_type):
                raise TestConfigurationError(
                    f"value must be of type '{self.target_type}'"
                )

            return fn(_value, **kwargs)

        return _validate


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

    @ValidateType(str)
    def _validate(_value, **kwargs):
        """Perform validation."""
        return fn(_value, **kwargs)

    return _validate


def validate_list(fn):
    """Validate lists."""

    @ValidateType((tuple, list))
    def _validate(_value, **kwargs):
        """Perform validation"""
        return fn(_value, **kwargs)

    return _validate
