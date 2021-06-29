#!/usr/bin/env python3

"""
Automatically generate Github Actions documentation.

Usage:
    action-document.py [-p|--path path] [-i|--in-place]
    action-document.py -h

Pre-requsitie:
    The README.md file should have the following HTML tags:
    <!-- BEGIN_ACTION_DOC -->
    <!-- END_ACTION_DOC -->
"""

import yaml
import argparse
import re
import os


def inputs_as_md(inputs):
    md = "### Inputs\n"
    if inputs is not None:
        for input, value in inputs.items():
            md += f"""* `{input}`:\n
  _Description_: {value['description']}\n
  _Required_: `{str(value['required']).lower()}`\n
"""
            if 'default' in value:
                d = value['default'] if value['default'] != "" else "\"\""
                md += f"  _Default_: `{d}`\n\n"
            if 'deprecationMessage' in value:
                md += f"  _Deprecation_: `{value['deprecationMessage']}`\n\n"
    else:
        md += "None\n"
    return md


def outputs_as_md(outputs):
    md = "### Outputs\n"
    if outputs is not None:
        for output, value in outputs.items():
            md += f"""* `{output}`:\n
  _Description_: {value['description']}\n
"""
    else:
        md += "None\n"
    return md


# Add args
parser = argparse.ArgumentParser()
parser.add_argument("-p", "--path",
                    help="Path to action directory",
                    dest="path")
parser.add_argument("-i", "--in-place",
                    help="Update README in-place" +
                    "Content is added between the <!-- BEGIN_ACTION_DOC --> " +
                    "and <!-- END_ACTION_DOC --> tags",
                    dest="inplace",
                    action="store_true")
args = parser.parse_args()

# Read action.yaml
action_file = os.path.join(args.path, "action.yaml")
with open(action_file, 'r') as f:
    try:
        action = yaml.load(f, Loader=yaml.SafeLoader)
    except yaml.YAMLError as exc:
        print(exc)

# Extract fields
name = action.get("name")  # Required field, no default needed
desc = action.get("description")  # Required field, no default needed
runs = action.get("runs")  # Required field, no default needed
author = action.get("author", None)
inputs = action.get("inputs", None)
outputs = action.get("outputs", None)

# Get action type
types = {
    "docker": "Docker",
    "node12": "Node.js",
    "composite": "Composite",
}
type = types[runs["using"]]

# Set doc template
doc = f"""# {name}\n
### Description
{desc}
### Action Type
{type}\n
"""

# Set Author
if author is not None:
    doc += f"### Author\n{author}\n\n"

# Create inputs markdown table
doc += inputs_as_md(inputs)

# Create inputs markdown table
doc += outputs_as_md(outputs)

# Read README.md
readme_file = os.path.join(args.path, "README.md")
with open(readme_file, 'r') as r:
    readme = r.read()

# Update README contents
updated_readme = re.sub(
    string=readme,
    pattern=r"<!-- BEGIN_ACTION_DOC -->(.*?)\n<!-- END_ACTION_DOC -->",
    repl=f'<!-- BEGIN_ACTION_DOC -->\n{doc}<!-- END_ACTION_DOC -->',
)

# Write README file
if args.inplace:
    f = open(readme_file, "w")
    f.write(updated_readme)
    f.close()
    print("Successfully updated README.md!")
else:
    print(updated_readme)
