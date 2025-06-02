TempoClock.default.tempo = 144 / 60;

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

~moog = Pmono(
  \monoMoog,
  \freq, Pseq([80, 140], inf), 
  \amp, 0.9,
  \dur, Pseq([1/8, 1/16],inf)
);
~moog.play();
)

~moog.free;

  
{ Decay.ar(Impulse.ar(XLine.kr(1,40,3), 0.25), 0.2, PinkNoise.ar!2, 0) }.play;

( // noisetest
SynthDef(
  \noise, {
    |sig, rat = 0, bit = 1, amp = 0, gate = 1, pitch = 5000|
    var env = EnvGen.kr(Env.perc(0.01, 0.3), gate, doneAction: 2);
    sig = Decimator.ar(SinOsc.ar([pitch, pitch+2], 0, amp), rat, bit);
    Out.ar(0, sig * env);
  }
).add;

~p1n = Pbind(
  \instrument, \noise,
  \pitch, 50,
  \rat, Pseq([100, 200, 100, 400]*3, inf),
  \bit, Pseq([2.4, 5.3, 8.5, 0.9], inf),
  \amp, Pseq([0.3, 0.3, 0.5, 0.9]/2, 2),
  \dur, 1/4
); //.play;

~p2n = Pbind(
  \instrument, \noise,
  \pitch, 50,
  \rat, Pseq([500, 200, 800, 400]*3, inf),
  \bit, Pseq([2.4, 0.3, 0.5, 0.9], inf),
  \amp, Pseq([1.3, 0.3, 0.5, 0.9, 1, 1]/2, 1),
  \dur, 1/2
);//.play;

~p3n = Pbind(
  \instrument, \noise,
  \pitch, 50,
  \rat, Pseq([500, 900, 800, 400]*8, inf),
  \bit, Pseq([0.4, 0.3, 0.5, 0.9], inf),
  \amp, Pseq([3.3, 3.3, 0.5, 0.9, 1, 1]/2, 4),
  \dur, 1/8
);//.play;
)

(
~seq1 = Pseq([
  //Pn(~p1n, 2),
  //Pn(~p2n, 1),
  Pn(Ppar([~p3n, ~rhythmPattern], 4), 2)
], inf);
~player = ~seq1.play;
)

s.plotTree;
s.meter;

(
// SynthDef for a simple sine tone
SynthDef(\sine, { |out, freq=440, amp=0.1, gate=1|
    var env = EnvGen.kr(Env.asr(0.01, 0.5, 0.1), gate, doneAction: 2);
    Out.ar(out, SinOsc.ar(freq, 0, amp)!2 * env);
}).add;

// SynthDef for a percussive noise hit
SynthDef(\percNoise, { |out, amp=0.1, gate=1|
    var env = EnvGen.kr(Env.perc(0.001, 0.1), gate, doneAction: 2);
    Out.ar(out, WhiteNoise.ar(amp)!2 * env);
}).add;

// Pattern 1: A melodic sequence
~melodyPattern = Pbind(
    \instrument, \sine,
    \degree, Pseq([0, 2, 4, 7, 9, 12], inf), // C D E G A C
    \dur, 0.25,
    \amp, 0.2
);

// Pattern 2: A rhythmic noise pulse
~rhythmPattern = Pbind(
    \instrument, \percNoise,
    \dur, Pseq([0.5, 0.25, 0.25], 6), // Long, short, short
    \amp, 0.1
);
)

// Combine ~melodyPattern and ~rhythmPattern to play simultaneously
~parallelPatterns = Ppar([
    ~melodyPattern,
    ~rhythmPattern
]);

// Play the parallel combination
~player = ~parallelPatterns.play;

