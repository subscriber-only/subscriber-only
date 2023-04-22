import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["spinner", "success", "failure", "other"];

  static values = {
    // Stripe
    publishableKey: String,
    accountId: String,
  };

  async connect() {
    const params = new URLSearchParams(window.location.search);
    const clientSecret = params.get("payment_intent_client_secret");

    const { paymentIntent } =
      await this.#stripe.retrievePaymentIntent(clientSecret);
    switch (paymentIntent.status) {
      case "succeeded":
        this.successTarget.hidden = false;
        break;
      case "requires_payment_method":
        this.failureTarget.hidden = false;
        break;
      default:
        this.otherTarget.hidden = false;
        break;
    }
    this.spinnerTarget.hidden = true;
  }

  get #stripe() {
    if (this.element.__stripe == null) {
      this.element.__stripe = Stripe(this.publishableKeyValue, {
        stripeAccount: this.accountIdValue,
      });
    }
    return this.element.__stripe;
  }
}
