( // Sine with 
SynthDef(\sine, {
  |freq = 440, phase = 0, mul = 1, hold = 0.3 |
  var env = Env.new(levels: [0, 1, 1, 0], times: [0.03, hold, 0.03], curve: [-5, 0, -4]);
  var envAdsr = EnvGen.kr(env, doneAction:2);
  var sig = SinOsc.ar(freq:freq, phase:phase, mul:mul);
  Out.ar(0, sig!2 *envAdsr );
}).add;
Synth(\sine, [\freq, 900, \hold, 0.1]);
)


( // White noise
SynthDef(\white, {
  |freq = 440, phase = 0, mul = 1, hold = 0.3 |
  var env = Env.new(levels: [0, 1, 1, 0], times: [0.03, hold, 0.03], curve: [-5, 0, -4]);
  var envAdsr = EnvGen.kr(env, doneAction:2);
  var sig = WhiteNoise.ar();
  Out.ar(0, sig!2 *envAdsr );
}).add;
Synth(\white, [\freq, 900, \hold, 0.1]);
)


(
a = Pbind(
  \instrument, \sine,
  \freq, Pseq([8000, 900], inf),
  \hold, Pseq([0.1, 0.3], inf),
  \dur, Pseq([1, 1], inf),
).play(quant: [2]);
)

(
b = Pbind(
  \instrument, \white,
  \hold, Pseq([0.001, 0.01, 0.05], inf),
  \dur, Pseq([1/4, 1/8, 1/8, 1/2], inf),
).play(quant: [2]);
)

////////////////////////
////////////////////////
////////////////////////
