const HttpStatus = {
  OK: 200,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
};

const BASE_URL = new URL(import.meta.url).origin;

const api_internal_posts_url = `${BASE_URL}/api/internal/posts`;
const new_subscription_url = `${BASE_URL}/subscriptions/new`;
const new_user_session_url = `${BASE_URL}/auth/sign_in`;

let onLoadExecuted = false;

const e = function createElement(type = "div", props = {}, children = []) {
  if (arguments.length === 2) children = props;
  if (!Array.isArray(children)) children = [children];
  const el = document.createElement(type);
  Object.assign(el, props);
  Object.assign(el.style, props.style || {});
  el.append(...children.filter(Boolean));
  return el;
}

function createPaywall(publicToken, showSignIn = false) {
  const styles = {
    container: {
      background: "#fffcf2",  // $body-bg
      borderRadius: "6px",  // $card-border-radius
      border: "1px solid #dee2e6",  // $card-border-width, $card-border-color
      fontFamily: `ui-rounded, 'Hiragino Maru Gothic ProN', Quicksand,
        Comfortaa, Manjari, 'Arial Rounded MT Bold', Calibri, source-sans-pro,
        sans-serif`,  // $font-family-sans-serif
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

  const subscribeParams = new URLSearchParams({
    public_token: publicToken,
    referer_url: window.location.href,
  });
  const signInParams = new URLSearchParams({ return_to: window.location.href });

  return (
    e("aside", { style: styles.container }, [
      e("div", { style: styles.content }, [
        e("h1", { style: styles.header },
          "This post is for paying subscribers only"),
        e("a", { href: `${new_subscription_url}?${subscribeParams}`,
                 style: styles.button },
          "Subscribe now"),
        showSignIn && e("p", { style: styles.paragraph }, [
          "Already subscribed? ",
          e("a", { href: `${new_user_session_url}?${signInParams}`,
                   style: styles.link },
            "Sign in"),
        ])
      ])
    ])
  );
}

async function downloadPost(publicToken) {
  const params = new URLSearchParams({
    public_token: publicToken,
    post_url: window.location.href,
  });
  const res = await fetch(`${api_internal_posts_url}?${params}`, {
    headers: { "Accept": "application/json" },
    credentials: "include",
  });
  return [res.status, res.status === HttpStatus.OK && await res.json()];
}

async function onLoad() {
  if (onLoadExecuted) return;
  onLoadExecuted = true;

  const container = document.querySelector("[data-subscriber-only]");
  if (!container) return;

  const publicToken = container.dataset.publicToken;
  const [status, post] = await downloadPost(publicToken);

  if (status === HttpStatus.UNAUTHORIZED || status === HttpStatus.FORBIDDEN) {
    const el = createPaywall(publicToken, status !== HttpStatus.FORBIDDEN);
    container.replaceWith(el);
  } else {
    container.outerHTML = post.content;
  }
}

document.addEventListener("turbo:load", onLoad);
document.addEventListener("turbolinks:load", onLoad);
document.addEventListener("DOMContentLoaded", onLoad);
