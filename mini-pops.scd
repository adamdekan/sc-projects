s.boot;
( // Sine with 
SynthDef(\sine, {
  |freq = 440, phase = 0, mul = 1, hold = 0.3, amp = 1|
  var env = Env.new(levels: [0, 1, 1, 0], times: [0.03, hold, 0.03], curve: [-5, 0, -4]);
  var envAdsr = EnvGen.kr(env, doneAction:2);
  var sig = SinOsc.ar(freq:freq, phase:phase, mul:mul);
  Out.ar(0, sig!2 *envAdsr *amp );
}).add;
Synth(\sine, [\freq, 900, \hold, 0.1]);
)


( // White noise
SynthDef(\white, {
  |freq=440, phase=0, mul=1, hold=0.3, amp=1 |
  var env = Env.new(levels: [0, 1, 1, 0], times: [0.01, hold, 0.01], curve: [-5, 0, -4]);
  var envAdsr = EnvGen.kr(env, doneAction:2);
  var sig = WhiteNoise.ar();
  Out.ar(0, sig!2 *envAdsr *amp );
}).add;
Synth(\white, [\freq, 900, \hold, 0.1]);
)


(
a = Pbind(
  \instrument, \sine,
  //\freq, Pxrand(Scale.harmonicMinor, inf),
  \freq, Pseq([800, 900], inf),
  \hold, Pseq([0.1, 0.2], inf),
  \dur, Pseq([1], inf),
  \amp, 0.2,
).play(quant: [2]);
)

~list = [1/4, 1/8, 1/8, 1/2];
(
b = Pbind(
  \instrument, \white,
  \hold, Pwhite.new(lo:0.001, hi:0.01, length:inf),
  \dur, Pseq(~list, inf),
  \amp, 0.1
).play(quant: [2]);
)

////////////////////////
////////////////////////
////////////////////////
