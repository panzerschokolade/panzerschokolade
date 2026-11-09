"use strict";

// EICHLER 2000 control panel
(() => {
  const root = document.getElementById("krch");
  if (!root) return;

  const workletURL = root.dataset.worklet;
  const scope = root.querySelector("canvas");
  const btn = root.querySelector("[data-krch=power]");
  const sliders = [...root.querySelectorAll("input[type=range]")];

  let ctx, node, filter, wet, dry, out, analyser, lfoTimer, raf;

  // log sliders run 0..1 and map to data-min..data-max exponentially
  const val = (name) => {
    const el = root.querySelector(`[name=${name}]`);
    const x = parseFloat(el.value);
    if (!("min" in el.dataset)) return x;
    const min = parseFloat(el.dataset.min);
    const max = parseFloat(el.dataset.max);
    return min * Math.pow(max / min, x);
  };

  function apply(name) {
    if (!ctx) return;
    const t = ctx.currentTime;
    if (name === "volume") {
      out.gain.setTargetAtTime(val("volume"), t, 0.02);
    } else if (name === "schrei") {
      // crossfades into the filter; a narrow bandpass needs makeup gain to scream
      const amt = val("schrei");
      filter.Q.setTargetAtTime(0.7 + amt * 40, t, 0.05);
      wet.gain.setTargetAtTime(amt * (1 + amt * 20), t, 0.02);
      dry.gain.setTargetAtTime(1 - amt, t, 0.02);
    } else {
      node.parameters.get(name).setTargetAtTime(val(name), t, 0.02);
    }
  }

  async function start() {
    ctx = new AudioContext();
    await ctx.audioWorklet.addModule(workletURL);
    node = new AudioWorkletNode(ctx, "krch", { outputChannelCount: [2] });

    filter = ctx.createBiquadFilter();
    filter.type = "bandpass";
    filter.frequency.value = 1200;

    wet = ctx.createGain();
    dry = ctx.createGain();

    // soft clipper as the safety stage: unlike a compressor it keeps the level differences
    const bus = ctx.createGain();
    bus.gain.value = 0.25;
    const clip = ctx.createWaveShaper();
    const curve = new Float32Array(4097);
    for (let i = 0; i < curve.length; i++) curve[i] = Math.tanh((i / 2048 - 1) * 4);
    clip.curve = curve;

    out = ctx.createGain();
    out.gain.value = 0;
    analyser = ctx.createAnalyser();
    analyser.fftSize = 2048;

    node.connect(filter).connect(wet).connect(bus);
    node.connect(dry).connect(bus);
    bus.connect(clip).connect(out).connect(analyser).connect(ctx.destination);

    sliders.forEach((s) => apply(s.name));

    // random "scream" sweeps
    lfoTimer = setInterval(() => {
      const amt = val("schrei");
      const f = 80 + Math.random() * Math.random() * 8000 * (0.2 + amt);
      filter.frequency.setTargetAtTime(f, ctx.currentTime, 0.02 + Math.random() * 0.3);
    }, 120);

    draw();
  }

  async function stop() {
    clearInterval(lfoTimer);
    cancelAnimationFrame(raf);
    if (ctx) await ctx.close();
    ctx = null;
    const g = scope.getContext("2d");
    g.clearRect(0, 0, scope.width, scope.height);
  }

  async function toggle() {
    if (ctx) {
      await stop();
      btn.setAttribute("aria-pressed", "false");
    } else {
      btn.setAttribute("aria-pressed", "true");
      try {
        await start();
      } catch (e) {
        console.error(e);
        btn.setAttribute("aria-pressed", "false");
        ctx = null;
      }
    }
  }

  function draw() {
    const g = scope.getContext("2d");
    const buf = new Float32Array(analyser.fftSize);
    const loop = () => {
      raf = requestAnimationFrame(loop);
      const w = (scope.width = scope.clientWidth);
      const h = (scope.height = scope.clientHeight);
      analyser.getFloatTimeDomainData(buf);
      g.clearRect(0, 0, w, h);
      g.strokeStyle = Math.random() < 0.05 ? "#f8ed01" : "#ff0000";
      g.lineWidth = 2;
      g.beginPath();
      for (let i = 0; i < buf.length; i++) {
        const x = (i / buf.length) * w;
        const y = h / 2 + buf[i] * h * 0.45;
        i ? g.lineTo(x, y) : g.moveTo(x, y);
      }
      g.stroke();
    };
    loop();
  }

  function randomize() {
    sliders.forEach((s) => {
      if (s.name === "volume") return;
      const min = parseFloat(s.min);
      const max = parseFloat(s.max);
      s.value = min + Math.random() * (max - min);
      apply(s.name);
    });
  }

  function panic() {
    const v = root.querySelector("[name=volume]");
    v.value = 0;
    apply("volume");
  }

  btn.addEventListener("click", toggle);
  root.querySelector("[data-krch=random]").addEventListener("click", randomize);
  sliders.forEach((s) => s.addEventListener("input", () => apply(s.name)));
  document.addEventListener("keydown", (e) => {
    if (e.target.tagName === "INPUT" && e.target.type !== "range") return;
    if (e.code === "Space") {
      e.preventDefault();
      toggle();
    } else if (e.code === "Escape") {
      panic();
    }
  });
})();
