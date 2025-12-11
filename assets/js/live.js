"use strict";

const base_url = "https://panzerschokolade.klingt.org";
const app_url = `${base_url}/hls`;

const params = new URLSearchParams(window.location.search);
let streamName = params.get("stream");
if (!streamName) streamName = "stream";

const video = document.getElementById("video");
// const caption = document.getElementById("caption");

const src = `${base_url}/hls/${streamName}.m3u8`;
if (video.canPlayType("application/vnd.apple.mpegurl")) {
  video.src = src;
} else if (Hls.isSupported()) {
  const hls = new Hls();
  hls.on(Hls.Events.ERROR, (e) => {
    console.error(e);
    //caption.textContent = "Failed to play";
  });
  hls.loadSource(src);
  hls.attachMedia(video);
}
/*
//TODO: fetch active stream list from stats
window.fetch("https://velak.klingt.org/live/stat").then((res) => {
  res.text().then((str) => {
    var xml = new window.DOMParser().parseFromString(str, "application/xml");
    console.log(xml);
    console.log(xml.firstChild.children.item(10));
    var live = xml.firstChild.children
      .item(10)
      .children.item(0)
      .children.item(1);
    console.log(live.children);
    for (var i = 0; i < live.children.length; i++) {
      if (live.children[i].nodeName === "stream") {
        var stream = live.children[i];
        var name = stream.children.item(0).textContent;
        var time = stream.children.item(1).textContent;
        console.log(name, time);
      }
    }
  });
});
*/
