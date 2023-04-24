import { Controller } from "@hotwired/stimulus";

import {
  api_internal_subscriptions_path,
  subscription_confirm_url
} from "../routes";
import * as utils from "../utils";

export default class extends Controller {
  static targets = ["billingCycles", "stripeElement", "errorMessage"];

  static values = {
    // Stripe
    publishableKey: String,
    accountId: String,
    // Subscription
    plan: Object,
    selectedBillingCycle: String,
  };

  connect() {
    const plan = this.planValue[this.selectedBillingCycleValue];
    const elements = this.#stripe.elements({
      mode: "subscription",
      amount: plan.amount,
      currency: plan.currency.toLowerCase(),
      appearance: {
        variables: {
          fontFamily: utils.cssVar("--bs-body-font-family"),
          fontSizeBase: utils.cssVar("--bs-root-font-size"),
          colorPrimary: utils.cssVar("--bs-primary"),
          colorText: utils.cssVar("--bs-body-color"),
          colorDanger: utils.cssVar("--bs-danger"),
          fontLineHeight: utils.cssVar("--bs-body-line-height"),
        },
        rules: {
          ".Input": {
            boxShadow: "none",
            // $input-btn-padding-y, $input-btn-padding-x
            padding: "0.375rem 0.75rem",
            lineHeight: utils.cssVar("--bs-body-line-height"),
          },
          ".Input:focus": {
            boxShadow: "none",
          },
        },
      },
    });
    const paymentElement = elements.create("payment");
    paymentElement.mount(this.stripeElementTarget);
    this.element.__elements = elements;
  }

  changeBillingCycle(event) {
    const billingCycle = event.currentTarget.value;
    const plan = this.planValue[billingCycle];
    this.#elements.update({
      amount: plan.amount,
      currency: plan.currency.toLowerCase(),
    });
    this.selectedBillingCycleValue = billingCycle;
  }

  async subscribe(event) {
    event.preventDefault();

    event.submitter.disabled = true;
    event.submitter.querySelector(".spinner-grow").hidden = false;
    const showError = (error) => {
      this.#showError(error);
      event.submitter.disabled = false;
      event.submitter.querySelector(".spinner-grow").hidden = true;
    };

    const { error: submitError } = await this.#elements.submit();
    if (submitError) {
      showError(submitError.message);
      return;
    }

    const params = new URLSearchParams(window.location.search);

    const [status, data] = await this.#createSubscription(params);
    if (status != 201) {
      showError(data.message);
      return;
    }
    const { subscription_id, client_secret } = data;

    const error = await this.#confirmPayment(
      client_secret,
      `${subscription_confirm_url(subscription_id)}?${params}`
    );
    if (error) showError(error.message);
  }

  async #createSubscription(params) {
    const res = await fetch(api_internal_subscriptions_path(), {
      method: "post",
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        public_token: params.get("public_token"),
        billing_cycle: this.selectedBillingCycleValue,
      }),
    });
    return [res.status, await res.json()];
  }

  async #confirmPayment(clientSecret, return_url) {
    const { error } = await this.#stripe.confirmPayment({
      elements: this.#elements,
      clientSecret,
      confirmParams: { return_url }
    });
    return error;
  }

  #showError(message) {
    this.errorMessageTarget.textContent = message;
    this.errorMessageTarget.hidden = false;
  }

  get #stripe() {
    if (this.element.__stripe == null) {
      this.element.__stripe = Stripe(this.publishableKeyValue, {
        stripeAccount: this.accountIdValue,
      });
    }
    return this.element.__stripe;
  }

  get #elements() {
    return this.element.__elements;
  }
}
