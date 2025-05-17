(
SynthDef(\monoMoog, {
  |lfo, amp = 0.1, out, freq = 400, width = 0|
  width = LFNoise2.kr(0.3);
  lfo = LFNoise1.kr(0.3).range(300, 600);
  out = Pulse.ar(freq:freq, width:width, mul:amp, add:0.0);
  out = MoogFF.ar(in:out, freq:lfo, gain:3.8, reset:0, mul:1, add:0);
  out = Pan2.ar(in:out, pos:width, level:1.0);
  Out.ar(bus:0, channelsArray:out);
}).add;

e = Pmono(
  \monoMoog,
  \freq, Pseq([80, 140], inf), 
  \amp, 0.1,
  \dur, Prand([1/8, 1/16, 1/6],inf)
);
e.play;
)


  

( // noisetest
SynthDef(
  \noise, {
    |sig, rat = 0, bit = 1, amp = 0|
    sig = Decimator.ar(SinOsc.ar([440, 444], 0, amp), rat, bit);
    sig = HPF.ar(sig, 2000);
    Out.ar(0, sig);
  }
).add;

Pmono(
  \noise,
  \rat, Pseq([100, 200, 300, 400], inf),
  \bit, Pseq([0.1, 0.3, 0.5, 0.9], inf),
  \amp, Pseq([0.1, 0.3, 0.5, 0.9, 0, 0.4, 0]/2, inf),
  \dur, 1/8
).play;
)

s.plotTree;
