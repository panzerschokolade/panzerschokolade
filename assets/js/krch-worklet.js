// EICHLER 2000 noise engine. Runs on the audio thread.
// pitched core (triangle -> chaos -> noise) -> stutter -> wavefold -> bitcrush
// -> decimate -> comb feedback

const MAX_DELAY = 4096;
const MAX_STUTTER = 48000;

class KrchProcessor extends AudioWorkletProcessor {
  static get parameterDescriptors() {
    return [
      { name: "pitch", defaultValue: 80, minValue: 1, maxValue: 4000 },
      { name: "chaos", defaultValue: 0.3, minValue: 0, maxValue: 1 },
      { name: "fm", defaultValue: 0.2, minValue: 0, maxValue: 1 },
      { name: "fold", defaultValue: 0.2, minValue: 0, maxValue: 1 },
      { name: "bits", defaultValue: 6, minValue: 1, maxValue: 8 },
      { name: "decimate", defaultValue: 2, minValue: 1, maxValue: 512 },
      { name: "feedback", defaultValue: 0.3, minValue: 0, maxValue: 1.2 },
      { name: "stutter", defaultValue: 0.2, minValue: 0, maxValue: 1 },
    ];
  }

  constructor() {
    super();
    this.phase = 0;
    this.logistic = 0.5;
    this.logiSmooth = 0;
    this.fmRand = 0; // random pitch offset, re-rolled every cycle
    this.jump = 1;
    this.hold = 0;
    this.holdCount = 0;
    this.delay = new Float32Array(MAX_DELAY);
    this.delayPos = 0;
    this.delayLen = 300;
    this.stutterBuf = new Float32Array(MAX_STUTTER);
    this.recPos = 0;
    this.stutterStart = 0;
    this.stutterLen = 0;
    this.stutterPos = 0;
    this.stutterLeft = 0;
    this.dcX = 0;
    this.dcY = 0;
  }

  process(_inputs, outputs, p) {
    const out = outputs[0];
    const L = out[0];
    const R = out[1] || out[0];
    const n = L.length;
    const v = (name, i) => (p[name].length > 1 ? p[name][i] : p[name][0]);

    for (let i = 0; i < n; i++) {
      const pitch = v("pitch", i);
      const chaos = v("chaos", i);
      const fm = v("fm", i);
      const fold = v("fold", i);
      const bits = v("bits", i);
      const dec = Math.max(1, Math.round(v("decimate", i)));
      const fb = v("feedback", i);
      const stutter = v("stutter", i);

      // random octave jumps, more often with more chaos
      if (Math.random() < Math.pow(chaos, 4) * 0.0005) {
        this.jump = Math.pow(2, Math.floor(Math.random() * 5) - 2);
      }

      // oscillator; fm scatters the pitch by up to +-4 octaves, per cycle
      const freq = pitch * this.jump * Math.pow(2, this.fmRand * fm * 4);
      this.phase += freq / sampleRate;
      if (this.phase >= 1) {
        this.phase -= Math.floor(this.phase);
        this.fmRand = Math.random() * 2 - 1;
      }
      const tri = 4 * Math.abs(this.phase - 0.5) - 1;

      // logistic map stepped twice per cycle: pitched, but gritty and unstable
      if (this.phase < freq / sampleRate || Math.abs(this.phase - 0.5) < freq / sampleRate / 2) {
        const r = 3.6 + chaos * 0.4;
        this.logistic = r * this.logistic * (1 - this.logistic);
        if (!(this.logistic > 0.0001 && this.logistic < 0.9999)) this.logistic = Math.random();
      }
      // glide towards the map value so the folder/crusher have slopes to chew on
      this.logiSmooth += (this.logistic * 2 - 1 - this.logiSmooth) * Math.min(1, (freq * 6) / sampleRate);
      const logi = this.logiSmooth;
      const noise = Math.random() * 2 - 1;

      // chaos: 0 = triangle, 0.5 = chaotic map, 1 = noise
      let x;
      if (chaos < 0.5) {
        const t = chaos * 2;
        x = tri * (1 - t) + logi * t;
      } else {
        const t = (chaos - 0.5) * 2;
        x = logi * (1 - t) + noise * t;
      }
      x *= 0.8;

      // stutter: loops the source, so every effect below keeps reacting to the sliders
      this.stutterBuf[this.recPos] = x;
      this.recPos = (this.recPos + 1) % MAX_STUTTER;
      if (this.stutterLeft <= 0 && Math.random() < stutter * stutter * 0.0006) {
        this.stutterLen = 64 + Math.floor(Math.random() * 3000);
        this.stutterLeft = this.stutterLen * (2 + Math.floor(Math.random() * 7));
        this.stutterStart = (this.recPos - this.stutterLen + MAX_STUTTER) % MAX_STUTTER;
        this.stutterPos = 0;
      }
      if (this.stutterLeft > 0) {
        x = this.stutterBuf[(this.stutterStart + this.stutterPos) % MAX_STUTTER];
        this.stutterPos = (this.stutterPos + 1) % this.stutterLen;
        this.stutterLeft--;
      }

      // wavefold
      x = Math.sin(x * (1 + fold * 12) * Math.PI * 0.5);

      // bitcrush
      const steps = Math.pow(2, bits - 1);
      x = Math.round(x * steps) / steps;

      // decimate (sample & hold)
      if (this.holdCount <= 0) {
        this.hold = x;
        this.holdCount = dec;
      }
      this.holdCount--;
      x = this.hold;

      // comb feedback: short delay rings at its own pitch, self-oscillates above 1
      if (Math.random() < 0.00001 + fb * 0.00005) {
        this.delayLen = 16 + Math.floor(Math.random() * (MAX_DELAY - 16));
      }
      let readPos = this.delayPos - this.delayLen;
      if (readPos < 0) readPos += MAX_DELAY;
      const delayed = this.delay[readPos];
      this.delay[this.delayPos] = Math.tanh(x * (1 - fb * 0.6) + delayed * fb);
      this.delayPos = (this.delayPos + 1) % MAX_DELAY;
      x = Math.tanh(x * (1 - fb * 0.5) + delayed * fb * 1.2);

      // dc blocker
      const y = x - this.dcX + 0.995 * this.dcY;
      this.dcX = x;
      this.dcY = y;

      const s = Math.max(-1, Math.min(1, y));
      L[i] = s;
      // slightly wrong stereo
      R[i] = this.stutterLeft > 0 ? -s : s * (0.8 + Math.random() * 0.2);
    }
    return true;
  }
}

registerProcessor("krch", KrchProcessor);
