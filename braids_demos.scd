s.quit;
( // Boot Pipewire Server
Server.program = "pw-jack scsynth";
s.boot;
QtGUI.style = "kvantum-dark";
)
s.scope;
// gcc to comment out line, gcap to comment out paragraph

(
{ MiBraids.ar([60, 62], Line.kr(dur:20), Line.kr(dur:20, doneAction: 2), 14, mul: 1) }.play;
{ MiPlaits.ar(pitch: 60,
    engine:4, 
    harm:Line.kr(dur:20, doneAction:2), 
    timbre:Line.kr(dur:20) ) 
}.play;
)
Pbind(\scale, a, \degree, Pseq((0..7) ++ (6..0) ++ [\rest], 1), \dur, 0.25).play;

( // Complex Synth and Pattern
t = TempoClock(144/30);

SynthDef(\brds, {
    | note = 40, harm = 1, timbre = 1, morph = 0, decay = 0.1, eng = 2 |
	var outenv =  EnvGen.kr(Env.perc(0.001, decay, 1, -4), doneAction: Done.freeSelf);
    var sig = MiPlaits.ar(note, eng, harm,  timbre, morph, mul:1);
	Out.ar(0, sig * outenv);
}).add;

Pbind(
	\instrument, \brds,
	\note, Pseq([40, 42, 45, 46, 48], inf),
    \harm, Prand([0.1, 1, 0.3], inf),
	\eng, Prand([9, 12, 3], inf),
	\decay, Prand([0.3, 1, 3], inf)
).play(t);
// s.scope;
)

( // some modulation over 20s
n = 40;
{SinOsc.ar([n,SinOsc.kr(1/10).range(n-2,n+2)], mul: 0.2)}.play;
{
    var mod = LFNoise1.kr(0.5,0.5,0.5);
	var mod2 = LFNoise1.kr(0.3,0.2,0.5);
	// SinOsc.ar([n,SinOsc.kr(1/10).range(n-2,n+2)], mul: 0.2);
	Out.ar(0,
        [MiBraids.ar(n, mod, 0, 1, mul: 0.1),
        MiBraids.ar(n, mod2, 0,01, mul: 0.1)
	])
}.play
)


// To join 2 arrays I can use:
// ++
// a.addAll(arrayB);
(  // Joining arrays for 2 octaves MIDI notes in scale (C2 as root)
~pentscale = Scale.minorPentatonic.degrees ++ (Scale.minorPentatonic.degrees + 12) + 48;
s.freeAll; // stop all previos synths
m = {
    | speed = 2, engine = 9 |
    var scale = ~pentscale + 24;
    var index = LFNoise0.kr(speed).range(0, scale.size).round; // random index in scale
    var trig = Impulse.kr(speed*3);
    // var trig = Dust.kr(speed*8);
    var midiPitch = Select.kr(index, scale); // pick scale note
    var freq = midiPitch.midicps; // convert to Hz
    var timb = LFNoise1.kr(0.3).range(0, 1);
    var harm = LFNoise1.kr(0.3).range(0, 1);
    var morph = LFNoise1.kr(0.3).range(0, 1);
    var sig1 = SinOsc.ar(freq/2!2, mul: 0.2); // frequency input
    var sig2 = MiPlaits.ar(midiPitch, timbre:timb, morph:morph, harm:harm, engine:engine, mul: 1, trigger:trig, lpg_colour:0.1, decay:0.8); // MIDI note number in the scale from midiPitch
    MiVerb.ar(Mix([sig1, sig2]));
}.play
)
m.set(\engine, rrand(1, 11)); // sets arg/var for function

(
{
    var mod = BPF.ar(
        WhiteNoise.ar(1!2),
        freq: Saw.kr(0.25).range(4000, 40),
        rq: 0.7);
    var sig = SinOsc.ar(40, phase:mod, mul: Saw.kr(0.5));
    Out.ar(0, sig!2);
}.play;
)
s.stop;

// 5 channel out
a = { SinOsc.ar([100, 300, 500, 700, 900], mul: 0.2) }.play;
a.free;
c = { Mix(SinOsc.ar([800, 300, 500, 700, 900], mul: 0.1))!2 }.play; // mixed into LR
c = { Splay.ar(SinOsc.ar([800, 300, 500, 700, 900], mul: 0.2)) }.play; // spread out in panorama
c.free;

// Instant cluster generator
c = { Mix.fill(16, (SinOsc.ar(rrand(100, 3000), mul: 0.01))) }.play;

(   // fluted
{
    var pit = 24;
    var timb = MouseX.kr(0.7,1);
    var color = MouseY.kr();
    MiBraids.ar(pit, timb, color, 31, resamp: 1, mul: 0.5) ! 2;
}.play
)


(   // scanning
{
	var timb = LFNoise1.kr(0.3,0.5,0.5);
    var color = LFNoise1.kr(0.3,0.5,0.5);
    var pit = MouseY.kr(33,72);
    var model = MouseX.kr(0, 47);
    MiBraids.ar(pit, timb, color, model, mul: 0.2)!2;
}.play
)

a = { |x| x + 1 }; b = a.exp; [a.value(1), b.value(1)];
a = Pseries(0, 0.25, inf).exp; a.asStream.nextN(8);
{ a = LFNoise1.kr(1500); [a, a.exp] }.plot;

(
{
    // Define harmonic minor scale degrees (semitones from root)
    var harmMinor = [0, 2, 3, 5, 7, 8, 11];

    // Generate random values with LFNoise0
    var noiseRate = 4; // change per second
    var octaveRange = 2; // Range in octaves
    var rootNote = 38; // Your original base pitch

    // Generate random index with explicit integer conversion
    var noteIndex = LFNoise0.kr(noiseRate).range(0, harmMinor.size-1).round.asInteger;

    // Use integer index to look up in scale
    var scaleDegree = Select.kr(noteIndex, harmMinor);

    // Add octave variation
    var octaveOffset = LFNoise0.kr(noiseRate * 0.5).range(0, octaveRange).round.asInteger * 12;

    // Calculate final pitch
    var pit = rootNote + scaleDegree + octaveOffset;

    var timb = MouseX.kr(0.7, 1);
    var color = MouseY.kr();

    var sig = MiBraids.ar(pit, timb, color, 21, resamp: 1, mul: 0.5) ! 2;
	sig = MiVerb.ar(sig, drywet:timb, damp:0.1);
	Out.ar(0, sig);
}.play
)

// more:


(   // paraphonic
{
    var timb = LFNoise1.kr(0.03,0.5,0.5);
    var color = LFNoise1.kr(0.05,0.5,0.5);  // chord
    MiBraids.ar(38, timb, color, 40, resamp: 1) ! 2;
}.play
)


(   // trigger (plugged)
{
    var trig = Dust.kr(0.6);
    var pit = TRand.kr(45,72,trig).round;
    var timb = 0.5;
    var color = LFNoise1.kr(0.3,0.5,0.5);

    MiBraids.ar(pit, timb, color, 28, trig, mul: 0.4) ! 2;

}.play
)

(   // kick it
{
    var trig =  Impulse.kr(4);
    var pit = Latch.kr(PinkNoise.kr(), trig).range(30, 50).round;
    var timb = LFNoise1.kr(0.4,0.5,0.5);
    var color = LFNoise1.kr(0.3,0.5,0.5);

    MiBraids.ar(pit, timb, color, 34, trig, mul: 0.5) ! 2;
}.play
)


(   // sample rate, bit reduction and distortion
{
    var trig =  CoinGate.kr(0.3, Impulse.kr(4));
    var decim = TRand.kr(1,32,trig);
    var dist = LFTri.kr(0.2).range(0,1);

    MiBraids.ar(40, 0.7, 0.7, 34, trig, resamp: 2, decim: decim, bits: 3, ws: dist, mul: 0.5) ! 2;
}.play
)

(  // stereo example, with freezing
{
    var imp = Dust.ar([0.7, 0.8]);
    var freq = Latch.ar(PinkNoise.ar(24,80), imp).midicps;
    var input = RLPF.ar(imp, freq, 0.002, 3);

    var freez = TRand.kr(-1, 1, Dust.kr(0.7));
    var revtime = 0.8;
    var drywet = 0.5;
    var damping = 0.3;

    var diff = LFNoise1.kr(0.1,0.5,0.5);

    MiVerb.ar(input, revtime, drywet, damping, freeze: freez);
}.play
)

// basics
x = { MiRings.ar(Impulse.ar(1)) }.play
y = { MiRings.ar(PinkNoise.ar(0.1), pit: 35) }.play
x.free
y.free

// using the 'trig' input to excite the resonator
{MiRings.ar(trig: Dust.kr(0.7), pit: 33, model: 1)}.play

// using the 'pit' input to set MIDI pitch and excite the resonator
{MiRings.ar(pit: LFNoise0.kr(2).range(30, 50), model: 2)}.play


more:

(  // sympathetic strings (have to love it...)
{
    var trig = Dust.kr(1);
    var pit = Latch.kr(WhiteNoise.kr(), trig).range(30, 60).round;
    var struct = LFNoise2.kr(0.4).range(0,1);

    MiRings.ar(0, 0, pit, struct, 0.5, 0.7, 0.15, model: 1, poly: 4, mul: 0.2)
}.play
)


(   // inharmonic string
{
    var trig = Dust.kr(3);
    var trigPit = Dust.kr(0.5);
    var pit = Latch.kr(WhiteNoise.kr(), trigPit).range(30, 60);
    var struct = Latch.kr(PinkNoise.kr(), trig).range(0.1,1);

    MiRings.ar(0, trig, pit, struct, 0.5, 0.8, model: 2, poly: 4)
}.play
)


(   // simple vibrato
{
    var trig = Dust.kr(0.9);
    var pit = Latch.kr(WhiteNoise.kr(), trig).range(36, 48);
    var vib = SinOsc.kr(3);

    MiRings.ar(0,0, pit+vib, 0.1, model: 0)
}.play
)


// basics
x = { MiPlaits.ar(60, 0, harm: 0.252, morph: 0.2, mul: 0.2) }.play
x.free

// Mouse control
{ MiPlaits.ar(48, 2, MouseX.kr(0, 1),  MouseY.kr(0,1), mul: 0.5) }.play

// some talking
{ MiPlaits.ar(MouseY.kr(24,72), 7, MouseX.kr(0, 1),  0.5, LFSaw.ar(0.11, 0, 0.5, 0.5)) }.play


// scanning through some engines + vibrato
// note: there's no interpolation happening when changing the synthesis engine,
// so eventual clicks are unavoidable
(
{
    var pit = 50;
    var vib = SinOsc.ar(6, 0, 0.1);
	var e = LFNoise0.kr(3, 1, 2);
    MiPlaits.ar(pit+vib, e, mul: 0.6);
}.play
)



more:

(   // some FM
{
    var harm = MouseX.kr(0, 1);
    var timbre = MouseY.kr(0,1);
    var morph = LFNoise2.kr(0.2).range(0,1);
    var trigger = Impulse.ar(8);
    MiPlaits.ar(48, 2, harm,  timbre, morph, trigger, decay: 0.5)
}.play
)


(   // wavetable + trigger
{
    var trigger = Impulse.kr(8);
    var harm = LFNoise2.kr(0.3,0.25,0.25);
    var timbre = LFNoise1.kr(0.4,0.5,0.5);
    var dec = LFNoise2.kr(0.2).range(0.01,0.8);
    MiPlaits.ar(44, 5, harm, timbre, 0, trigger, decay: dec, mul: 0.5)
}.play
)


(   // some chords + trigger + level
{
    var harm = MouseY.kr(0,1);  // select chord
    var timbre = 0.5;
    var morph = 0.5;
    var trigger = Impulse.kr(6);
    var lev = TRand.kr(trig: trigger);
    var out = MiPlaits.ar(40, 6, harm, timbre, morph, trigger, lev.squared,
        decay: 0.5, timb_mod: 0.4, mul: 0.5);
    out[0] ! 2
}.play
)


(   // super saw
{
    var harm = 0.16;
    var timbre = 0;
    var morph = 1;
    var pit = TIRand.kr(39, 49, Dust.kr(0.5));
    var out = MiPlaits.ar(pit, 8, harm, timbre, morph, mul: 0.3);
    out[0]!2
}.play
)


(   // slow swarm
{
    var harm = 0.9;
    var timbre = 0;
    var morph = 0.5;
    var out = MiPlaits.ar(48, 8, harm, timbre, morph);
    Mix.ar([out[0]*0.03, out[1]!2])
}.play
)


(   // inharmonic string
{
    var harm = LFNoise2.kr(0.2).range(0,1);
    var timbre = 0.0;
    var morph = 0.85;
    var out = MiPlaits.ar(60, 11, harm, timbre, morph);
    out[0]!2
}.play
)


(   // modal resonator + trigger
{
    var harm = LFNoise2.kr(0.2).range(0,1);
    var timbre = 0.0;
    var morph = 0.85;
    var trigger = Impulse.kr(1);
    var lev = TRand.kr(trig: trigger).squared;
    var out = MiPlaits.ar(56, 12, harm, timbre, morph, trigger, lev);
    Mix.new(out)!2
}.play
)


(   // snare drumsss
~snares = {
    var harm = LFNoise2.kr(0.5).range(0,0.5);
    var timbre = 0.173;
    var morph = 0.827;
    var trigger = Impulse.kr(8);
    var lev = TRand.kr(trig: trigger).squared;
    MiPlaits.ar(47, 14, harm, timbre, morph, trigger, lev, fm_mod: 0.2, timb_mod: 0.43, decay: 0.4)
}
)
~snares.play;

(   // filtered noise
{
    var harm = 0.575;
    var timbre = 0.02;
    var morph = LFNoise1.kr(0.3).range(0.55,0.9); // filter resonance
    MiPlaits.ar(62, 9, harm, timbre, morph);
}.play
)


(  // something...
{
    var trigger = Dust.kr( LFNoise2.kr(0.1).range(0.1, 7) );
    var harmonics = SinOsc.kr(0.03, 0, 0.5, 0.5).range(0.0, 1.0);
    var timbre = LFTri.kr(0.07, 0, 0.5, 0.5).range(0.0, 1.0);
    var morph = LFTri.kr(0.11, 0, 0.5, 0.5).squared;
    var pitch = TIRand.kr(24, 48, trigger);
    var engine = TRand.kr(0, 15, trig: trigger).round;
    var sub = SinOsc.ar(pitch.midicps, 0, 0.1);

    var mi = MiPlaits.ar( pitch, engine, harmonics, timbre, morph,
        trigger: trigger, decay: 0.8, lpg_colour: 0.2, mul: 0.5);
    mi + sub
}.play
)
