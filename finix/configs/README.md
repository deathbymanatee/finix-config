# modules/configs

This directory contains "recipes" for building a finix system; they can all be included / imported / enabled with (hopefully) no conflicts between each other. Any dependencies are auto handled.

This makes it so I don't have to copy tons of nix if I want a basic setup, and I can instead just set up a user account, install some packages if needed, and go.

In a roundabout way this is just me reinventing the `finix-community/profiles` wheel.
