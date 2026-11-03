#!/bin/sh
# Stand-in editor for the lab: makes one small change to the
# decrypted file sops hands it, the way a person would.
sed -i 's/max_items: 25/max_items: 30/' "$1"
