"""Validate test configuration."""


class TestConfigurationError(Exception):
    """Test configuration error."""


class DeferValidation(Exception):
    """Defer key validation."""

    def __init__(self, *depends):
        """Initialize."""
        self._depends = depends
        super().__init__("")

    @property
    def depends(self):
        """Get key dependencies."""
        return self._depends


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


def _validate_trigger_pos(trigger_pos, **kwargs):
    """Validate trigger position."""
    if not isinstance(trigger_pos, int):
        raise TestConfigurationError("position must be integer")
    if trigger_pos < 0 or trigger_pos > 100:
        raise TestConfigurationError("position must be in [0, 100] range")
    # depends on mem_size key
    if "mem_size" not in kwargs:
        raise DeferValidation("mem_size")

    return int(kwargs["mem_size"] * (trigger_pos / 100.0))


def _validate_mem_size(mem_size, **kwargs):
    """Validate mem size."""
    if not isinstance(mem_size, int):
        raise TestConfigurationError("memory size must be integer")

    if mem_size < 0:
        raise TestConfigurationError("memory size must be a positive integer")


CONFIGURATION_REQ_KEYS = {
    "trigger_config": _validate_trigger_config,
    "trigger_pos": _validate_trigger_pos,
    "mem_size": _validate_mem_size,
}
CONFIGURATION_OPT_KEYS = ()


def validate_config(config):
    """Validate configuration."""
    if not isinstance(config, dict):
        raise TypeError("configuration must be a dictionary")

    for key in CONFIGURATION_REQ_KEYS:
        if key not in config:
            raise TestConfigurationError(
                f"invalid configuration, missing required key '{key}'"
            )

    transformed_config = {}
    deferred_keys = {}
    for key, value in config.items():
        if (
            key not in CONFIGURATION_REQ_KEYS
            and key not in CONFIGURATION_OPT_KEYS
        ):
            # warning, unknown key
            continue

        if key in CONFIGURATION_REQ_KEYS:
            # call validate
            try:
                transform = CONFIGURATION_REQ_KEYS[key](
                    value, **transformed_config
                )
            except DeferValidation as defer:
                deferred_keys[key] = defer.depends
                continue

        if transform is not None:
            transformed_config[key] = transform
        else:
            transformed_config[key] = value

    # resolve dependencies
    for key, depends in deferred_keys.items():
        transform = CONFIGURATION_REQ_KEYS[key](
            config[key], **transformed_config
        )

        if transform is not None:
            transformed_config[key] = transform
        else:
            transformed_config[key] = config[key]

    return transformed_config
