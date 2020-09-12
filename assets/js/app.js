// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import { Socket } from "phoenix"
import NProgress from "nprogress"
import { LiveSocket } from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken } })

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

console.log("WAT")
// The following is a hack to play audio.
// We observe DOM element creation events underneath the element with ID "sound-fx".
// Those nodes have attributes that describe the audio file to play.
// I did try rendering <audio> elements from the live view but that made Chrome go janky.
// No idea why.
window.initSFX = function () {
  const soundFiles = [
    "/sfx/alarm.mp3",
    "/sfx/bowl.mp3",
  ];

  const context = new AudioContext();

  function decode(name, response) {
    return response.arrayBuffer().then(arrayBuffer =>
      context.decodeAudioData(arrayBuffer).then(buffer => ({
        name,
        buffer
      }))
    );
  }

  Promise.all(
    soundFiles.map(name => fetch(name).then(response => decode(name, response)))
  ).then(fetched => {
    return fetched.reduce(
      (acc, { name, buffer }) => ({ ...acc, [name]: buffer }),
      {}
    );
  }).then(files => {
    const targetNode = document.getElementById("sound-fx");
    const config = { childList: true, subtree: true };
    const callback = function (mutationsList) {
      for (const mutation of mutationsList) {
        if (mutation.type == "childList") {
          mutation.addedNodes.forEach(node => {
            const source = context.createBufferSource();
            source.buffer = files[node.getAttribute("data-src")];
            source.connect(context.destination);
            source.start(0);
          });
        }
      }
    };
    const observer = new MutationObserver(callback);
    observer.observe(targetNode, config);
  });
}

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket
