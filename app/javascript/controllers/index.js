import * as env from 'env';
import { Application } from "@hotwired/stimulus";

import controllers from "*_controller.js";

const application = Application.start();
application.debug = (env.RAILS_ENV ?? "development") === "development";

for (const { name, module } of controllers) {
  application.register(name, module.default);
}

window["Stimulus"] = application;
