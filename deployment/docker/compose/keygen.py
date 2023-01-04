# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

import base64
import os

def generate_encryption_key(name):
    key = os.urandom(32)
    encoded_key = base64.b64encode(key).decode("utf-8")
    print("Base 64 encoded encryption key for {}: {}".format(name,encoded_key))

keys=["global", "worker", "recovery"]
for key in keys:
    generate_encryption_key(key)
