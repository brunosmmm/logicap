"""Input generation."""

from logicap.config import validate_config, TestConfigurationError

INPUT_REQ = ()
INPUT_OPT = ()


def validate_input_config(input_config):
    """Validate input configuration."""
    return validate_config(input_config, INPUT_REQ, INPUT_OPT)
