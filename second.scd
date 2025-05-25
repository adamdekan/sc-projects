(
{ LFPulse.ar(LFPulse.kr(LFPulse.kr(0.2,0,0.5,8,10),0,0.5, 400,800),0,0.5,0.1) }.scope(1, zoom: 4);
{ LPulse.ar(LFPulse.kr(3, 0, 0.3, 200, 200), 0, 0.2, 0.1) }.scope(1, zoom: 4);
{ LFPulse.ar(XLine.kr(100,15000,6),0,0.5,0.1) }.scope(1, zoom: 4);
)

{SinOscFB.ar(freq:430.0!2, feedback:Line.kr(start:0.0, end:20.0, dur:10.0, mul:1.0, add:0.0, doneAction:2), mul:0.2, add:0.0)}.play;

// pulse width modulation
{ LFPulse.ar(300,0,MouseY.kr(0,1),0.1) }.scope(1, zoom: 4);
{ LFPulse.ar(100,0,LFTri.kr(0.2,0,0.5,0.5),0.6) }.scope(1, zoom: 4);

{ VarSaw.kr(1,0.2,8,10) }.scope(1, zoom: 1);

{ SinOsc.ar(SinOsc.kr(SinOsc.kr(0.2,0,8,10),0, 400,800),0,0.1) }.scope(1, zoom: 4);
{ SinOsc.ar(SinOsc.kr(0.2, 0, 400,800),0,0.1) }.scope(1, zoom: 4);
{ SinOsc.ar(800,0,0.1) }.scope(1, zoom: 4);
{ SinOsc.ar(XLine.kr(100,15000,6),0,0.1) }.scope(1, zoom: 4);

{ Blip.ar(XLine.kr(20000,200,6),100,1.2) }.scope(1);
{ Blip.ar(XLine.kr(100,15000,6),100,0.7) }.scope(1); // no aliasing
// modulate number of harmonics
{ Blip.ar(200,Line.kr(1,100,20),1.2) }.scope(1);

s.volume.gui;

{ Osc.ar(80, 100, 0, 0.1) }.scope(1, zoom:4);

b.sine1(1.0/(1..12));
b.sine1(1.0/(1..24));
b.sine1(1.0/(1..32));
b.sine1([1.0/(1,3..12), 0].flop.flat.postln);
b.sine1([1.0/(1,3..32).squared, 0].flop.flat.postln);
b.sine1((1.dup(4) ++ 0.dup(8)).scramble.postln);
b.sine1((1.dup(4) ++ 0.dup(8)).scramble.postln);
b.sine1((1.dup(4) ++ 0.dup(8)).scramble.postln);
b.sine1((1.dup(4) ++ 0.dup(8)).scramble.postln);
b.sine1({1.0.rand2.cubed}.dup(8).round(1e-3).postln);
b.sine1({1.0.rand2.cubed}.dup(12).round(1e-3).postln);
b.sine1({1.0.rand2.cubed}.dup(16).round(1e-3).postln);
b.sine1({1.0.rand2.cubed}.dup(24).round(1e-3).postln);

{ LFClipNoise.ar(MouseX.kr(200, 10000, 1), 0.125) }.scope(1);
{ LFNoise0.ar(MouseX.kr(200, 10000, 1), 0.25) }.scope(1);
{ LFNoise1.ar(MouseX.kr(200, 10000, 1), 0.25) }.scope(1);
{ LFNoise2.ar(MouseX.kr(200, 10000, 1), 0.25) }.scope(1);

// used as controls
{ LFPar.ar(LFNoise0.kr(MouseX.kr(0.5, 64, 1), 200, 400), 0, 0.2) }.scope(1, zoom:8);
{ LFPar.ar(LFNoise1.kr(MouseX.kr(0.5, 64, 1), 200, 400), 0, 0.2) }.scope(1, zoom:8);
{ LFPar.ar(LFNoise2.kr(MouseX.kr(0.5, 64, 1), 200, 400), 0, 0.2) }.scope(1, zoom:8);

{ ClipNoise.ar(0.2) }.scope(1);
{ WhiteNoise.ar(0.2) }.scope(1);
{ PinkNoise.ar(1.4) }.scope(1);
{ BrownNoise.ar(1.2) }.scope(1);
{ GrayNoise.ar(0.2) }.scope(1);

{ Dust.ar(MouseX.kr(1,10000,1), 4.4) }.scope(1, zoom:4);
{ Dust2.ar(MouseX.kr(1,10000,1), 1.4) }.scope(1, zoom:4);
{ LPF.ar(WhiteNoise.ar, MouseX.kr(1e2,2e4,4), 1.2) }.scope(1);
{ HPF.ar(WhiteNoise.ar, MouseX.kr(1e2,2e4,1), 0.2) }.scope(1);
{ LPF.ar(Saw.ar(100), MouseX.kr(1e2,2e4,1), 0.2) }.scope(1);
{ HPF.ar(Saw.ar(100), MouseX.kr(1e2,2e4,1), 0.2) }.scope(1);
{ Ringz.ar(Dust.ar(3, 0.3), 2000, 2) }.scope(1, zoom:4);

{ Ringz.ar(WhiteNoise.ar(0.005), 2000, 0.5) }.scope(1);

// modulate frequency
{ Ringz.ar(WhiteNoise.ar(0.005), XLine.kr(100,3000,10), 0.5) }.scope(1, zoom:4);

{ Ringz.ar(Impulse.ar(6, 0, 0.3),  XLine.kr(100,3000,10), 0.5) }.scope(1, zoom:4);

// modulate ring time
{ Ringz.ar(Impulse.ar(6, 0, 0.3), 2000, XLine.kr(0.04, 4, 8)) }.scope(1, zoom:4);

{ SinOsc.ar(300, 0, MouseX.kr(0.1,80,1)).distort * 0.2 }.scope(1);
{ SinOsc.ar(300, 0, MouseX.kr(0.1,80,1)).softclip * 0.2 }.scope(1);
{ SinOsc.ar(300, 0, MouseX.kr(0.1,80,1)).clip2(1) * 0.2 }.scope(1);
{ SinOsc.ar(300, 0, MouseX.kr(0.1,80,1)).fold2(1) * 0.2 }.scope(1);
{ SinOsc.ar(100, 0, MouseX.kr(~xBus)).wrap2(~yBus) * 4.2 }.scope(1);
{ SinOsc.ar(300, 0, MouseX.kr(0.1,80,1)).wrap2(1) * 0.2 }.scope(1);

(
~xBus = Bus.control(s, 1);
~yBus = Bus.control(s, 1);

w = Window("Control", Rect(100, 100, 400, 400)).front;

w.view.mouseMoveAction = { |view, mx, my|
    var width = view.bounds.width;
    var height = view.bounds.height;

    // Normalize and map to parameter ranges
    var amp = mx.linlin(0, width, 0.1, 80);  // replaces MouseX
    var wrap = my.linlin(0, height, -1, 1);  // replaces MouseY

    ~xBus.set(amp);
    ~yBus.set(wrap);
};
)


(
~quantizeToScale = { |inSig, scale = #[0, 2, 4, 5, 7, 9, 11], root = 60|
    var index = inSig.linlin(0, 1, 0, scale.size - 1).round.asInteger;
    var note = scale.wrapAt(index) + root;
    note.midicps;
};
)

(
{
    var pitch = ~quantizeToScale.(Line.kr);
    SinOsc.ar(pitch, 0, 0.2)
}.play;
)

{ Pan2.ar(PinkNoise.ar(1.2), SinOsc.kr(0.5)) }.play;

{ PinkNoise.ar(1.2) + SinOsc.ar(440, 0, 0.2) + Saw.ar(660, 0.2) }.play;
// now here's an equivalent SynthDef
SynthDef.new("tutorial-SinOsc", { |out| Out.ar(out, SinOsc.ar(440, 0, 0.2)) }).play;



b = NetAddr.new("127.0.0.1", 7000);    // create the NetAddr
b.sendMsg("/hello", "there");    // send the application the message "hello" with the parameter "there"

OSCFunc.trace(false);

{WhiteNoise.ar([0.5, 0])}.play;
