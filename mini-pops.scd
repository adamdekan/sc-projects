(
~busReverb = Bus.audio(server:s, numChannels:2);
r = {
  Out.ar(bus:0,
    channelsArray:MiVerb.ar(inputArray:In.ar(bus:~busReverb, numChannels:2),
      time:0.7, drywet:0.5, damp:0.5, hp:0.05, freeze:0, diff:0.625, mul:1.0, add:0.0))
}.play;

SynthDef(\sine, {
    |freq = 440, phase = 0, mul = 1, hold = 0.3, amp = 1, rbus = 0|
    var env = Env.new(levels: [0, 1, 1, 0], times: [0.03, hold, 0.03], curve: [-5, 0, -4]);
    var envAdsr = EnvGen.kr(env, doneAction: 2);
    var sig = SinOsc.ar(freq: freq, phase: phase, mul: mul) * envAdsr * amp;
    // Route either to output bus 0 or to ~busReverb depending on rbus
    Out.ar(Select.kr(rbus, [0, ~busReverb.index]), sig ! 2);
}).add;

SynthDef(\white, {
  |freq=440, phase=0, mul=1, hold=0.3, amp=1 |
  var envDec = Env.perc(attackTime:0.01, releaseTime:0.01).kr(doneAction: 2);
  var sig = WhiteNoise.ar();
  sig = Pan2.ar(sig, LFNoise2.kr(4));
  Out.ar(0, sig *envDec *amp );
}).add;

SynthDef(\pulse, {
  |freq=440, speed=1, mul=1, hold=0.3, amp=1 |
  var sig = Impulse.ar(speed);
  var envDec = Env.perc(releaseTime:0.01).kr(doneAction: 2);
  sig = Pan2.ar(sig, LFNoise2.kr(4));
  Out.ar(0, sig *amp );
}).add;
)

(
~list = [1/4, 1/8, 1/8, 1/2];
~clck.stop;
b = Pbind(
  \instrument, \pulse,
  \hold, Pwhite.new(lo:0.001, hi:0.01, length:inf),
  \dur, Pseq(~list.dupEach(4).scramble, inf),
  \amp, 1
);
~clck = b.play(quant: [2]);
)

(
~sin.stop;
a = Pbind(
  \instrument, \sine,
  \freq, Pseq([8000, 1000, 50, Rest(1)], inf),
  \hold, Pseq([0.1, 0.03, 2, Rest(1)], inf),
  \rbus, Pseq([0, 1, 0, 0], inf),
  \dur, Pseq([2], inf),
  \amp, 0.2,
);
~sin = a.play(quant: [2]);
)


(
~list = [1/4, 1/8, 1/8, 1/2];
~hihat.stop;
b = Pbind(
  \instrument, \white,
  \hold, Pwhite.new(lo:0.001, hi:0.01, length:inf),
  \dur, Pseq(~list.dupEach(4).scramble, inf),
  \amp, 0.1
);
~hihat = b.play(quant: [2]);
)

(
~list = Array.fib(14, 2, 1)/1000;
~hihat.stop;
b = Pbind(
  \instrument, \white,
  \hold, Pwhite.new(lo:0.001, hi:0.01, length:inf),
  \dur, Pseq(~list, inf),
  \amp, 0.1
);
~hihat = b.play(quant: [2]);
)

(
{ 
  var env = Env.perc(releaseTime:0.1).kr(doneAction: 2);
  SinOsc.ar(freq:env.exprange(10, 300), mul:env)!2;
}.play
)

////////////////////////
////////////////////////
////////////////////////
