import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["card"];

  highlight(event) {
    for (const card of this.cardTargets) {
      if (card.contains(event.currentTarget)) {
        card.classList.add("border-primary");
        card.querySelector(".card-header")
          .classList
          .add("text-bg-primary", "border-primary");
        continue;
      }

      card.classList.remove("border-primary");
      card.querySelector(".card-header")
        .classList
        .remove("text-bg-primary", "border-primary");
    }
  }
}
