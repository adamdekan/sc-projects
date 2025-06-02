s.volume.gui;
s.latency;
s.mute;
s.unmute;

(
~busReverb = Bus.audio(server:s, numChannels:2);
r = {
  Out.ar(bus:0,
    channelsArray:MiVerb.ar(inputArray:In.ar(bus:~busReverb, numChannels:2),
      time:0.7, drywet:0.5, damp:0.5, hp:0.05, freeze:0, diff:0.625, mul:1.0, add:0.0))
}.play;

SynthDef(\sine, {
    var env = Env.new(
        levels: [0, 1, 1, 0],
        times: [0.03, \hold.kr(1), 0.03],
        curve: [-5, 0, -4]);
    var envAdsr = EnvGen.kr(env, doneAction: 2);
    var sig = SinOsc.ar(\freq.kr(440), \phase.kr(0)) * envAdsr * \amp.kr(1);
    // Route either to output bus 0 or to ~busReverb depending on rbus
    Out.ar(Select.kr(\rbus.kr(0), [0, ~busReverb.index]), sig ! 2);
}).add;


SynthDef(\white, {
  var envDec = Env.perc(attackTime:0.01, releaseTime:0.01).kr(doneAction: 2);
  var sig = WhiteNoise.ar();
  sig = Pan2.ar(sig, LFNoise2.kr(4));
  Out.ar(0, sig *envDec *\amp.kr(1) );
}).add;

SynthDef(\pulse, {
  var sig = Impulse.ar(\speed.kr(1));
  var envDec = Env.perc(releaseTime:0.01).kr(doneAction: 2);
  sig = Pan2.ar(sig, LFNoise2.kr(4));
  Out.ar(0, sig  *\amp.kr(1) );
}).add;
)

(
SynthDef(\kick, { 
  var env = Env.perc(releaseTime:0.1).kr(doneAction: 2);
  Out.ar(0, SinOsc.ar(freq:env.exprange(10, 300)/1.5) *env /1 !2);
}).add;
~kick.stop;
p = Pbind(\instrument, \kick, \dur, Prand([1], inf));
~kick = p.play(quant: [2]);
)

(
~list = [1/4, 1/8, 1/8, 1/2];
~clck.stop;
b = Pbind(
  \instrument, \pulse,
  \hold, Pwhite.new(lo:0.001, hi:0.01, length:inf),
  \dur, Pseq(~list.dupEach(4).scramble, inf),
  \amp, 10
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
  \amp, 1/2
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

//(
//~list = Array.fib(14, 2, 1)/1000;
//~hihat.stop;
//b = Pbind(
//  \instrument, \white,
//  \hold, Pwhite.new(lo:0.001, hi:0.01, length:inf),
//  \dur, Pseq(~list, inf),
//  \amp, 0.1
//);
//~hihat = b.play(quant: [2]);
//)
//
////////////////////////
////////////////////////
////////////////////////
