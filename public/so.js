const HttpStatus = {
  OK: 200,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
};

const IMPORT_URL = new URL(import.meta.url);
const BASE_URL = IMPORT_URL.origin;

const api_internal_access_tokens_url = `${BASE_URL}/api/internal/access_tokens`;
const api_internal_posts_url = `${BASE_URL}/api/internal/posts`;
const new_subscription_url = `${BASE_URL}/subscriptions/new`;
const new_user_session_url = `${BASE_URL}/auth/sign_in`;

let onLoadExecuted = false;

function readAccessToken() {
  return document.cookie
    .split("; ")
    .find((row) => row.startsWith("access_token="))
    ?.split("=")[1];
}

function storeAccessToken(accessToken, expires = null) {
  if (expires == null) {
    expires = new Date();
    expires.setFullYear(expires.getFullYear() + 1);
    expires = expires.toUTCString();
  }
  // Secure is supposed to be ignored on localhost but this exemption isn't
  // followed on WebKit-based browsers. So, it is applied conditionally.
  //
  // Note also that the cookie won't show up in Safari's "Storage" tab, on the
  // inspector, for unknown reasons. The cookies must be inspected on the
  // console. E.g.
  //
  //   > document.cookie
  //   < "access_token=..."
  const secure = IMPORT_URL.protocol === "https:" ? "secure" : "";
  document.cookie = `access_token=${accessToken}; path=/; ` +
    `expires=${expires}; samesite=strict; ${secure}`;
  return accessToken;
}

function deleteAccessToken() {
  storeAccessToken("DELETED", "Thu, 01 Jan 1970 00:00:00 UTC");
}

const e = function createElement(type = "div", props = {}, children = []) {
  if (props?.constructor !== Object) {
    children = props;
    props = {};
  }
  if (!Array.isArray(children)) children = [children];
  const el = document.createElement(type);
  Object.assign(el, props);
  Object.assign(el.style, props.style || {});
  el.append(...children.filter(Boolean));
  return el;
}

function PlaceholderSentence(width) {
  return e("span", { style: {
    display: "inline-block",
    minHeight: "1em",
    verticalAlign: "middle",
    cursor: "wait",
    backgroundColor: "currentColor",
    opacity: .5,
    width,
  }});
}

function PlaceholderRow(widths) {
  const style = { display: "flex", gap: "8px" };
  return e("div", { style }, widths.map(PlaceholderSentence));
}

function PlaceholderText() {
  const style = { display: "flex", flexDirection: "column", gap: "8px" };

  return e("div", { style }, [
    PlaceholderRow(["30%", "70%"]),
    PlaceholderRow(["10%", "50%", "40%"]),
    PlaceholderRow(["40%", "60%"]),
    PlaceholderRow(["20%", "40%", "40%"]),
    PlaceholderRow(["90%"]),
  ]);
}

function Paywall(publicToken, showSignIn = false) {
  const styles = {
    container: {
      background: "#fffcf2",  // $body-bg
      borderRadius: "6px",  // $card-border-radius
      border: "1px solid #dee2e6",  // $card-border-width, $card-border-color
      fontFamily: "VAG Rounded Next, system-ui, sans-serif",
      fontSize: "18px",
      padding: "4em 1em",
      "-webkit-font-smoothing": "antialiased",
    },
    content: {
      alignItems: "center",
      display: "flex",
      flexDirection: "column",
      gap: "2em",
      textAlign: "center",
    },
    header: {
      fontSize: "2.5em",
      fontWeight: 800,
      lineHeight: "1.25em",
      margin: 0,
    },
    button: {
      backgroundColor: "#e76f51",  // $primary
      borderRadius: "800px",  // $border-radius-pill
      color: "white",
      fontWeight: 600,
      padding: ".75em 1.5em",
      textDecorationLine: "none",
    },
    paragraph: {
      margin: 0,
    },
    link: {
      color: "#e76f51",  // $primary
      textDecoration: "underline",
      textDecorationColor: "#e76f51",  // $primary
    },
  };

  const subscribeLink = new URL(new_subscription_url);
  subscribeLink.searchParams.set("public_token", publicToken);
  subscribeLink.searchParams.set("return_to", window.location.href);

  const signInLink = new URL(new_user_session_url);
  signInLink.searchParams.set("return_to", window.location.href);

  return (
    e("aside", { style: styles.container }, [
      e("div", { style: styles.content }, [
        e("h1", { style: styles.header },
          "This post is for paying subscribers only"),
        e("a", { href: subscribeLink, style: styles.button }, "Subscribe now"),
        showSignIn && e("p", { style: styles.paragraph }, [
          "Already subscribed? ",
          e("a", { href: signInLink, style: styles.link }, "Sign in"),
        ])
      ])
    ])
  );
}

async function requestAccessToken(code) {
  const res = await fetch(api_internal_access_tokens_url, {
    method: "POST",
    headers: { "Accept": "application/json" },
    body: new URLSearchParams({ code }),
  });
  return [res.status, res.status === HttpStatus.OK && await res.json()];
}

async function readOrRequestAccessToken() {
  const accessToken = readAccessToken();
  if (accessToken != null) return accessToken;

  const params = new URLSearchParams(window.location.search);
  const code = params.get("code");
  if (!code) return;

  const [status, payload] = await requestAccessToken(code);
  if (status !== HttpStatus.OK) {
    console.error("Failed to get an access token.", payload);
    return;
  }
  return storeAccessToken(payload.access_token);
}

async function downloadPost(publicToken, accessToken) {
  const params = new URLSearchParams({
    public_token: publicToken,
    post_url: window.location.href,
  });
  const res = await fetch(`${api_internal_posts_url}?${params}`, {
    headers: {
      "Accept": "application/json",
      ...(accessToken && { "Authorization": `Bearer ${accessToken}` })
    }
  });
  return [res.status, res.status === HttpStatus.OK && await res.json()];
}

async function renderPostOrPaywall(container, publicToken) {
  const accessToken = await readOrRequestAccessToken();

  const [status, post] = await downloadPost(publicToken, accessToken);
  if (status === HttpStatus.OK) {
    container.outerHTML = post.content;
    return;
  }

  if (status === HttpStatus.UNAUTHORIZED) deleteAccessToken();

  const paywall = Paywall(publicToken, status !== HttpStatus.FORBIDDEN);
  container.replaceWith(paywall);
}

async function onLoad() {
  if (onLoadExecuted) return;
  onLoadExecuted = true;

  const container = document.querySelector("[data-subscriber-only]");
  if (!container) return;

  const placeholder = PlaceholderText();
  container.replaceWith(placeholder);

  await renderPostOrPaywall(placeholder, container.dataset.publicToken);
}

document.addEventListener("turbo:load", onLoad);
document.addEventListener("turbolinks:load", onLoad);
document.addEventListener("DOMContentLoaded", onLoad);
