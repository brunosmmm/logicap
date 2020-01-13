"""Input generation."""

from logicap.config import (
    validate_config,
    TestConfigurationError,
    DeferValidation,
)

from logicap.validators import (
    validate_positive_integer,
    validate_string,
    ValidateChoice,
)

from logicap.util import AutoValidateList

EVENT_TYPES = ("initial", "set", "clear", "toggle")
_EVENT_DEPS = {
    "initial": ("value",),
    "set": ("mask",),
    "clear": ("mask",),
    "toggle": ("mask",),
}


@validate_string
@ValidateChoice(EVENT_TYPES)
def _validate_evt_type(evt_type, **kwargs):
    """Validate event type."""
    evt_deps = _EVENT_DEPS[evt_type]
    missing_deps = []
    for dep in evt_deps:
        if dep not in kwargs:
            missing_deps.append(dep)

    if missing_deps:
        raise DeferValidation(*missing_deps)

    # TODO fail if there are pending defers at end of validation


@validate_positive_integer
def _validate_mask(mask, **kwargs):
    """Validate mask."""
    return mask


def _validate_time(time, **kwargs):
    """Validate time."""


@validate_positive_integer
def _validate_value(value, **kwargs):
    """Validate value."""
    return value


EVENT_REQ = {"event": _validate_evt_type}
EVENT_OPT = {
    "mask": _validate_mask,
    "time": _validate_time,
    "value": _validate_value,
}


@AutoValidateList(EVENT_REQ, EVENT_OPT)
def _validate_sequence(seq_data, **kwargs):
    """Validate sequence."""
    return seq_data


INPUT_REQ = {"sequence": _validate_sequence}
INPUT_OPT = ()


def validate_input_config(input_config):
    """Validate input configuration."""
    return validate_config(input_config, INPUT_REQ, INPUT_OPT)
