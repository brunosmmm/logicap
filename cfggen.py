"""Generate configuration vector."""

from argparse import ArgumentParser
import json

from logicap.config import validate_config, TestConfigurationError

if __name__ == "__main__":

    parser = ArgumentParser()
    parser.add_argument("config", help="configuration file")
    parser.add_argument(
        "--output", help="configuration output", default="config.txt"
    )

    args = parser.parse_args()

    try:
        with open(args.config, "r") as cfg:
            config = json.load(cfg)
            config = validate_config(config)
    except OSError:
        print("ERROR: cannot open configuration file")
        exit(1)
    except json.JSONDecodeError:
        print("ERROR: json decode error")
        exit(1)
    except TestConfigurationError as ex:
        print(f"ERROR: configuration error: '{ex}'")
        exit(1)

    # generate configuration
    trigger_stages = config["trigger_config"]
    try:
        with open(args.output, "w") as config_out:
            for stage in trigger_stages:
                config_out.write("{}\n".format(hex(stage["mask"])))
                config_out.write("{}\n".format(hex(stage["type"])))
                config_out.write("{}\n".format(hex(stage["level"])))
            # write size
            config_out.write("{}\n".format(hex(config["trigger_pos"])))
    except OSError:
        print("ERROR: cannot write configuration file")
        exit(1)
