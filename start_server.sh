#!/bin/bash

# bin/rails db:encryption:init
# bin/rails credentials:edit

rails assets:precompile
rails s -e development

