rrand(1, 20).postln.linexp(1, 20, 40, 1000);

(
var num;
num = (1..100);
[
  num,
  num.linexp(1, 100, 1, 100),
  num.explin(1, 100, 1, 100),
  num.lincurve(1, 100, 1, 100, 8), // lincurve -8 to 8
].plot;
)

s.scope;
// Usage to modulate the waveform
(
{
  var sig, mod;
  mod = LFNoise2.kr(1!2).range(-10, 10); // Multiachannel Expansion !2 creates 2 independent UGens
  sig = SinOsc.ar([400, 402] * -5.midiratio); // Note midiratio!
  sig = sig.lincurve(-1, 1, -1, 1, mod);
  sig = sig * 0.2;
}.play
)

// Exprange creates exponential change directly to .range()
(
{
  var sig, freq;
  freq = LFTri.ar(0.14, 3).exprange(50, 1200);
  sig = SinOsc.ar(freq + [0, 1], mul:0.2); // note the multichannel expansion
}.play
)

// Other mapping ranges that works with UGens
LFTri.ar(1).unipolar;
LFTri.ar(1).bipolar;
