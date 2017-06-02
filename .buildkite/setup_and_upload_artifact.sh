#!/usr/bin/env bash

set -euo pipefail

pip install --upgrade gcloud
pip install requests

python .buildkite/upload_artifacts.py