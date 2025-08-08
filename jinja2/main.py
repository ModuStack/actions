from jinja2 import Template
from dotenv import load_dotenv

import json
import yaml
import os

load_dotenv()


def main():
    VARS = os.environ['VARS']
    TEMPLATE = os.environ['TEMPLATE']

    template = Template(TEMPLATE, trim_blocks=True, lstrip_blocks=True)

    try:
        vars = json.loads(VARS)
    except json.JSONDecodeError:
        vars = yaml.safe_load(VARS)

    if isinstance(vars, list):
        vars = {'all': vars}

    return template.render(vars)


if __name__ == '__main__':
    print(main())