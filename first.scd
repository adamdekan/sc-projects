s.boot;
s.volume.gui;

SynthDef(\default, {
	arg freq = 440, amp = 0.5;
	var sig = SinOsc.ar(freq) * amp;
	Out.ar(0, sig.dup);
}).add;

Pbind(
	\instrument, \default,}
	\freq, Pseq([440, 550, 660], inf),
	\amp, Pseq([0.5, 0.3, 0.1], inf),
	\dur, 0.2
).play;

~bpm = 80;
~beatDur = 60 / ~bpm; // duration of 1 beat in seconds

// infinite run
// hs = { [SinOsc.ar(12000, 0, 0.5), SinOsc.ar(12005, 0, 0.5)] }.play;

// function test
(
f = {
	"St Fun eval".postln;
	"Fin Fun eval".postln
};
f.value;
f;
)

// randomizatoin and counting
(
g = { 3.0.rand };
10.do({f.value(g);});
)

( //BLK
SynthDef(\highClick, {
	arg amp = 0.3, atk = 0.005, hold = 0.02, rel = 0.05;
	var env = EnvGen.kr(
		Env.linen(atk, hold, rel),
		doneAction: 2
	);
	var sig = Mix([
		SinOsc.ar(12000, 0, 0.5),
		SinOsc.ar(12005, 0, 0.5)
	]) * env * amp;
	Out.ar(0, sig.dup);
}).add;
)

( //BLK
~playHighClicks = {
	var dur = 60 / ~bpm;
	Pbind(
		\instrument, \highClick,
		\dur, dur,
		\amp, Pseq([1, 0, 1, 1, 0, 1, 0], inf),
		\atk, 0.002,
		\hold, 0.215,
		\rel, 0.04
	).play;
};
)
~playHighClicks;

// weird beep/noise pattern
( //BLK
SynthDef(\beep, { arg freq = 440, dur = 0.01;
	var env = EnvGen.kr(Env.perc(0.001, dur), doneAction: 2);
	var sig = SinOsc.ar(freq) \* env;
	Out.ar(0, sig.dup);
}).add;
)

( //BLK
SynthDef(\noise, {
	arg amp = 0.1, dur = 0.3;
	var env = EnvGen.kr(Env.perc(0.01, dur.rand), doneAction: 2);
	var sig = WhiteNoise.ar _ amp _ env;
	Out.ar(0, sig.dup);
}).add;
)

( // Function returning a playing Routine with variabl base frequency
~startBeepLoop = { |baseFreq = 440, beatMult = 1|
	var beatDur = 60 / ~bpm;
	Routine({
		loop {
			if(0.9.coin) {
				Synth(\beep, [\freq, baseFreq + 200.rand]);
				Synth(\noise, [\freq, baseFreq + 200.rand]);
			};
			(beatDur \* beatMult).wait;
		}
	}).play;
};
)
(
r = {
	var freq_list = [200, 1000, 2000, 6000];
	var time_div_list = [1, 2, 3, 4, 8];
	4.do({~startBeepLoop.(freq_list.choose, time_div_list.choose)});
	~highClickPattern = ~playHighClicks.();
};
)
r.play;

b = NetAddr.new("127.0.0.1", 7771); // create the NetAddr
loop {
	b.sendMsg("/hello", "there");
	1.wait;
}
