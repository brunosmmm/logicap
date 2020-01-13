"""Trigger configuration."""

from logicap.config import validate_config

from logicap.validators import validate_int_percent
from logicap.util import (
    default_validate_pos_int,
    default_validate_int,
    KeyDependency,
    AutoValidateList,
)

TRIGGER_REQ_KEYS = {
    "mask": default_validate_int,
    "type": default_validate_int,
    "level": default_validate_int,
}


@AutoValidateList(TRIGGER_REQ_KEYS)
def _validate_trigger_config(trigger_config, **kwargs):
    """Validate trigger configuration."""
    if len(trigger_config) < 8:
        # missing a few stages, insert blanks
        empty_stages = [
            {key: 0 for key in TRIGGER_REQ_KEYS}
            for _ in range(len(trigger_config) - 1, 8)
        ]
        trigger_config.append(empty_stages)
    elif len(trigger_config) > 8:
        trigger_config = trigger_config[:8]

    return trigger_config


@validate_int_percent
@KeyDependency("mem_size")
def _validate_trigger_pos(trigger_pos, **kwargs):
    """Validate trigger position."""
    # depends on mem_size key
    return int(kwargs["mem_size"] * (trigger_pos / 100.0))


CONFIGURATION_REQ_KEYS = {
    "trigger_config": _validate_trigger_config,
    "trigger_pos": _validate_trigger_pos,
    "mem_size": default_validate_pos_int,
}
CONFIGURATION_OPT_KEYS = ()


def validate_trigger_config(trigger_config):
    """Validate trigger configuration."""
    return validate_config(
        trigger_config, CONFIGURATION_REQ_KEYS, CONFIGURATION_OPT_KEYS
    )
