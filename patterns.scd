
Pbind(\degree, 0, \amp, 0.1).play;
Pbind(\degree, Pseries(0, 1, 30), \dur, 0.05, \amp, 0.2).trace.play;

(
~inner = Pbind(
    \freq, Pwhite(350, 400),
    \dur, Prand([0.15, 0.25, 0.3], 6),
    \amp, 1,
    \legato, 0.3
).trace.play;
)

(
SynthDef.new(name:"ssin", ugenGraphFunc:{
    arg freq = 440, amp = 0.1, release = 0.01;
    var env = Env.perc(level:amp, releaseTime:release).kr(2);
    var snd = SinOsc.ar([freq, freq + LFNoise1.kr(freq:1, mul:30)], 0, env);
    Out.ar(0, snd);
}).add;
)

s.plotTree;

(
x = Pbind(
    \instrument, \ssin,
    \degree, Pxrand([0, 2, 3, 5, 7] + 7, inf),
    \dur, Prand([0.2, 0.1, 0.1, 0.2, 0.35], inf),
    \release, Prand([0.06, 0.01, 0.5, 2, 0.35]*2, inf),
    \amp, Prand([0.06, 0.01, 0.1, 0.15, 0.1]/2, inf),
    \legato, 0.9.rand,
).trace.play;
)
x.stop;

(
Pbind (
    \note, Pshuf([0, 2, 3, 5, 7, 8, 11, 12], 11),
    \dur, 0.15,
    \amp, 0.3,
).play;
)

(
Pbind (
    \note, Pslide([0, 2, 3, 5, 7, 8, 11, 12], 7, 3, 11),
    \dur, 0.15,
    \amp, 1,
).play;
)

(
Pbind (
	\instrument, \fmSynth,
    \note, Pseries(0, 3, 15),
    \dur, 0.05,
    \amp, 1,
).play;
)


(
Pbind (
    \note, Pseq([0, 2, 3, 5, 7, 11, 12], inf),
    \dur, Pgeom(0.2, 0.9, 300),
    \amp, 1.3,
).play;
)

(
Pbind(
    \note, Pseq([0, Pn(2, 3), 3, Pn(5, 3), 7, Pn(8, 3), 11, Pn(12, 10)], inf),
    \dur, 0.15,
    \amp, 1
).trace.play;
)

(
Pbind (
    \note, Pseries(0, 2, 15),
    \dur, 0.15,
    \amp, 0.1,
).play;
)

( // basic use
    w=Window.new.front;
    g=EZKnob(w, 50@90," test  ", \freq,{|a| a.value.postln});
    g.setColors(Color.grey,Color.white);
);


( // Scales
Pbind(
    \scale, Scale.harmonicMinor,
    \degree, Pxrand([0, 1, 2, 3, 4, 5, 6, 7], inf),
    \amp, 1,
    \dur, Prand([0.1, 0.1, 0.3, 0.6, Rest(0.3), 0.25], inf);
).play;
)


( // open big block
    Pbind(
        \freq, Pn(Pseries(110, 111, 10)),
        \dur, 1/2,
        \legato, Pwhite(0.1, 1)
    ).play;
    Pbind(
        \freq, Pn(Pseries(220, 222, 10)),
        \dur, 1/4,
        \legato, Pwhite(0.1, 1)
    ).play;
    Pbind(
        \freq, Pn(Pseries(330, 333, 10)),
        \dur, 1/6,
        \legato, 0.1
).play;
) // close big block

// Using the same sequence of numbers a lot? Save it in a variable:
c = [0, 2, 3, 5, 7, 8, 11, 12];
t = TempoClock(144/60);

// Now you can just refer to it:
Pbind(\note, Pseq(c, 1), \dur, 0.15).play;
Pbind(\note, Prand(c, 6), \dur, 0.15, \amp, 1).play;
Pbind(\note, Pslide(c, 5, 3, 1), \dur, 0.15).play;

~scale = [0, 1, 2, 3, 4, 5, 6, 7];
~durs = [0.4, 0.2, 0.2, 0.4, 0.8, 0.2, 0.2, 0.2];
(
Pbind(
    \degree, Pseq(~scale),
    \dur, Pseq(~durs),
    \amp, 1,
).play;
Pbind(
    \degree, Pseq(~scale.reverse + 7),
    \dur, Pseq(~durs),
    \amp, 1,
).play;
)

(
p = Pbind(
    \midinote, Pseq([57, 62, 64, 65, [67, 73], 69], inf),
    \dur, 1/4,
    \amp, 0.2,
	// \strum, 0.1
); // no play !!!
)

~pPlayer = p.play(t);
~pPlayer.stop;
~pPlayer.resume;
~pPlayer.stop.reset;
~pPlayer.start;

2.even;
(40..60);

{LFNoise0.kr(10).range(400,500).poll}.play;

a = [1, 2, 3, 4, 5, 6, 7];
a.linexp(1, 7, 0, 127);

(
x = {|amp = 1| SinOsc.ar(In.ar(55), 0, amp)}.play;
l = {LFSaw.kr(0.5).range(220, 880)};
n = {Out.ar(55, SinOsc.ar(l).range(200,400))}.play;
)
x.set(\amp, 1);
x.free;
n.free;

x.set(\freq, In.ar(55));

// Run this first ('turn reverb on' −− you won't hear anything at first)
r = {Out.ar(0, FreeVerb.ar(In.ar(55, 2), mix: 0.9, room: 0.9, mul: 0.4))}.play;
// Now run this second ('feed the busy tone into the reverb bus')
a = {Out.ar(55, SinOsc.ar([800, 880], mul: LFPulse.ar(2)))}.play;
a.free;


(
// Define FM synth with AR envelope
SynthDef(\fmSynth, {
    arg freq=440, amp=0.5, attack=0.01, decay=0.5, modRatio=2, modIndex=5;
    var carrier, modulator, env, sig;

    // Random decay value per note
    decay = decay * rrand(0.5, 2.0);

    // AR envelope
    env = EnvGen.ar(Env.perc(attack, decay), doneAction: 2);

    // FM synthesis
    modulator = SinOsc.ar(freq * modRatio, 0, freq * modIndex);
    carrier = SinOsc.ar(freq + modulator);

    sig = carrier * env * amp;
    Out.ar(0, sig!2);
}).add;
)

s.queryAllNodes;

// Your Pbind using the FM synth
// Create a shared bus for modIndex
~modBus = Bus.control(s, 1).set(5.0);

// Updated SynthDef that reads from the bus
(
SynthDef(\fmSynth, {
    arg freq=440, amp=0.5, attack=0.01, decay=0.5, modRatio=2, modBus;
    var carrier, modulator, env, sig, modIndex;

    // Get modIndex from the control bus
    modIndex = In.kr(modBus, 1);

    // Random decay value per note
    decay = decay * rrand(0.5, 2.0);

    // AR envelope
    env = EnvGen.ar(Env.perc(attack, decay), doneAction: 2);

    // FM synthesis
    modulator = SinOsc.ar(freq * modRatio, 0, freq * modIndex);
    carrier = SinOsc.ar(freq + modulator);

    sig = carrier * env * amp;
    Out.ar(0, sig!2);
}).add;
)

// Create a simple GUI with slider
(
var window = Window("FM Controls", Rect(200, 200, 400, 100));
var slider = Slider(window, Rect(20, 20, 360, 30))
    .value_(0.5) // Initial value (0.5 = 5.0 in our range)
    .action_({ |sl|
        var val = sl.value.linexp(0, 1, 0.1, 20); // Map 0-1 to exponential range 0.1-20
        ~modBus.set(val);
        ("modIndex: " ++ val.round(0.01)).postln;
    });
window.front;
)

// Run the Pbind with the modBus parameter
(
Pbind(
    \instrument, \fmSynth,
    \note, Pseq([0, Pn(2, 3), 3, Pn(5, 3), 7, Pn(8, 3), 11, Pn(12, 10)], inf),
    \dur, 0.15,
    \amp, 1,
    \attack, 0.01,
    \decay, Pwhite(0.1, 0.6),
    \modRatio, 2.0,
    \modBus, ~modBus.index
).play;
)
