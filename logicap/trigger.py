"""Trigger configuration."""

from logicap.config import validate_config, TestConfigurationError

from logicap.validators import validate_int_percent
from logicap.util import default_validate_pos_int, KeyDependency


def _validate_trigger_config(trigger_config, **kwargs):
    """Validate trigger configuration."""
    _TRIGGER_KEYS = ("type", "level", "mask")
    if not isinstance(trigger_config, (tuple, list)):
        raise TestConfigurationError("trigger configuration must be a list")

    result = []
    for idx, stage in enumerate(trigger_config):
        if idx > 7:
            # ignore, only 8 stages possible
            break
        if not isinstance(stage, dict):
            raise TestConfigurationError(
                "trigger stage configuration must be a dictionary"
            )
        _stage = {}
        for key in _TRIGGER_KEYS:
            if key not in stage:
                raise TestConfigurationError(f"missing required key '{key}'")

            if isinstance(stage[key], int):
                if stage[key] < 0:
                    raise TestConfigurationError(
                        f"{key} must be a positive integer"
                    )
                key_value = stage[key]
            elif isinstance(stage[key], str):
                try:
                    key_value = int(stage[key])
                except ValueError:
                    try:
                        key_value = int(stage[key].lstrip("0x"), 16)
                    except ValueError:
                        try:
                            key_value = int(stage[key].lstrip("0b"), 2)
                        except ValueError:
                            raise TestConfigurationError(
                                f"invalid value for {key}"
                            )
            else:
                raise TestConfigurationError(
                    f"{key} must be either an integer or string"
                )
            _stage[key] = key_value
        result.append(stage)

    if idx < 7:
        # missing a few stages, insert blanks
        empty_stages = [
            {key: 0 for key in _TRIGGER_KEYS} for _ in range(idx, 8)
        ]
        result.append(empty_stages)

    return result


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
