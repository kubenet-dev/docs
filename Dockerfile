# Copyright 2024 Nokia
# Licensed under the Apache License 2.0
# SPDX-License-Identifier: Apache-2.0

FROM squidfunk/mkdocs-material:9.1.4

# Install the Mermaid plugin
RUN pip install mkdocs-mermaid2-plugin 