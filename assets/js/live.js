"use strict";

const DOMAIN = "panzerschokolade.klingt.org";
const BASE_URL = `https://${DOMAIN}`;
const APP_URL = `${BASE_URL}/hls`;
const STATS_URL = `${BASE_URL}/live/stat`;

const params = new URLSearchParams(window.location.search);
let streamName = params.get("stream") || "stream";
// const RTMP_URL = `rtmp://${DOMAIN}:1935/live/${streamName}`;

const video = document.getElementById("video");

function initVideo(src) {
  if (video.canPlayType("application/vnd.apple.mpegurl")) {
    video.src = src;
  } else if (window.Hls && Hls.isSupported()) {
    const hls = new Hls();
    hls.on(Hls.Events.ERROR, (event, data) => {
      console.error("HLS error:", event, data);
      // Optionally show a user-friendly message
    });
    hls.loadSource(src);
    hls.attachMedia(video);
  } else {
    console.error("HLS not supported in this browser");
  }
}

async function fetchServerStats() {
  try {
    const res = await fetch(STATS_URL);
    if (!res.ok) throw new Error(`Failed to fetch stats: ${res.status}`);
    const text = await res.text();
    const xml = new DOMParser().parseFromString(text, "application/xml");
    return xml;
  } catch (err) {
    console.error(err);
    return null;
  }
}

function parseActiveStreams(xml) {
  if (!xml) return [];
  const streams = [];
  const liveNode = xml.querySelector("live");
  if (!liveNode) return streams;
  liveNode.querySelectorAll("stream").forEach((streamNode) => {
    console.log("streamnode", streamNode);
    const name = streamNode.querySelector("name")?.textContent;
    const time = streamNode.querySelector("time")?.textContent;
    //TODO: parse other fields
    if (name) streams.push({ name, time });
  });
  return streams;
}

async function isStreamLive(name) {
  const xml = await fetchServerStats();
  const streams = parseActiveStreams(xml);
  return streams.find((s) => s.name === name) || null;
}

(async () => {
  const liveInfo = await isStreamLive(streamName);
  if (!liveInfo) {
    console.warn(`Stream "${streamName}" is not live.`);
    window.alert("0 available live transmissions");
    return;
  }
  console.log("Stream metadata:", liveInfo);
  const src = `${APP_URL}/${streamName}.m3u8`;
  initVideo(src);
})();
