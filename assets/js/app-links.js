/* ONE place to set where people get the app. Fill in when ready. */
window.BARENA_APP = {
  playStore: "",   // e.g. https://play.google.com/store/apps/details?id=com.barena.hub
  apk: "https://github.com/BENIQUE01/barenahub-app/releases/latest"
};
(function () {
  var c = window.BARENA_APP, url = c.playStore || c.apk;
  document.querySelectorAll("[data-app-link]").forEach(function (el) {
    if (url) { el.href = url; el.rel = "noopener"; }
    else { el.removeAttribute("href"); el.setAttribute("aria-disabled", "true"); el.textContent = "Android app: coming soon"; }
  });
  document.querySelectorAll("[data-app-note]").forEach(function (el) {
    el.textContent = url ? "Free Android app. Open the downloaded file and allow installs from this source if Android asks." : "We are finishing the release. Follow the tournaments page for updates.";
  });
})();
