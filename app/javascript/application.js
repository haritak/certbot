// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import {Turbo} from "@hotwired/turbo-rails"
import "trix"
import "@rails/actiontext"

import "@rails/request.js"
import "controllers"
import { FetchRequest } from '@rails/request.js'

import { dragOverHandler, dragLeaveHandler, dropHandler } from "custom/drag_n_drop"

//import { dragOverHandler } from "custom/drag_n_drop"
//import { dragLeaveHandler } from "custom/drag_n_drop"
//import { dropHandler } from "custom/drag_n_drop"



// The default of 500ms is too long
// and users can loose the causal link between
// clicking an link and seeing the browser respond.
// (source : Sustainable Web Development with RoR pg 155
Turbo.setProgressBarDelay(100);

