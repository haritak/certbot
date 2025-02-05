#!/usr/bin/env bash

# rails assets:clobber

rails assets:precompile 
rails server -e production 
