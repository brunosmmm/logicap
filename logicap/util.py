"""Utilities."""

from logicap.config import validate_config, DeferValidation
from logicap.validators import (
    Validator,
    ValidateType,
    validate_integer,
    validate_positive_integer,
    validate_string,
)


class AutoValidateList(Validator):
    """Automatically validate list elements."""

    def __init__(self, required_keys, optional_keys=None):
        """Initialize."""
        super().__init__()
        self._required = required_keys
        self._optional = optional_keys

    def __call__(self, fn):
        """Decorator."""

        @ValidateType((tuple, list))
        def _validate(_value, **kwargs):
            """Perform sub-validation."""
            return fn(
                [
                    validate_config(entry, self._required, self._optional)
                    for entry in _value
                ],
                **kwargs
            )

        return _validate


class AutoValidateDict(Validator):
    """Automatically validate dict elements."""

    def __init__(self, required_keys, optional_keys=None):
        """Initialize."""
        super().__init__()
        self._required = required_keys
        self._optional = optional_keys

    def __call__(self, fn):
        """Decorator."""

        @ValidateType(dict)
        def _validate(_value, **kwargs):
            """Perform sub-validation."""
            return fn(
                validate_config(_value, self._required, self._optional),
                **kwargs
            )

        return _validate


class KeyDependencyMap(Validator):
    """Check for dependencies."""

    def __init__(self, **dependency_map):
        """Initialize."""
        super().__init__()
        self._depmap = dependency_map

    def __call__(self, fn):
        """Decorator."""

        def _validate(_value, **kwargs):
            """Perform checks."""

            missing_deps = []
            deps = self._depmap[_value]
            for dep in deps:
                if dep not in kwargs:
                    missing_deps.append(dep)

            if missing_deps:
                raise DeferValidation(*missing_deps)

            return fn(_value, **kwargs)

        return _validate


@validate_integer
def default_validate_int(_value, **kwargs):
    """Default integer validator."""
    return _value


@validate_positive_integer
def default_validate_pos_int(_value, **kwargs):
    """Default positive integer validator."""
    return _value


@validate_string
def default_validate_str(_value, **kwargs):
    """Default string validator."""
    return _value
