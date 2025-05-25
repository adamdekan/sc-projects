(
x = { var sig;
  sig = SinOsc.ar(freq: {rrand(40, 400)}!20);
  sig = Splay.ar(inArray:sig);
  sig = sig * -10.dbamp;
}.play;
)

~mnDrone = Buffer.read(s, "/s/mn-drome.wav");
d = Buffer.readChannel(s, "/s/mn-drome.wav", channels:0);
e = Buffer.readChannel(s, "/s/mn-drome.wav", channels:1);

d.play//plays the buffer (channel 1)
e.play//plays the buffer (channel 2)
{Out.ar(0,[PlayBuf.ar(1,d,1,doneAction:2),PlayBuf.ar(1,e,1,doneAction:2)])}.play; //Plays both buffers in two channels. In this case, Left and Right (Stereo)
e.query //tells you info about your sample. Such as its number of frames(samples)

(
{GrainBuf.ar(numChannels:2,
  trigger:Impulse.kr(4),
  dur:1,
  sndbuf:~mnDrone,
  rate:1,
  pos:0,
  interp:2,
  pan:0,
  envbufnum:-1,
  maxGrains:512,
  mul:1,
  add:0)
}.play;
)

(
{
  var ratew;
  ratew = LFNoise2.kr(XLine.kr(1, 20, 800), 200);
  PlayBuf.ar(numChannels:2,
  bufnum:~mnDrone,
  rate:ratew,
  trigger:1.0,
  startPos:0.0,
  loop:1.0,
  doneAction:2)
}.play;
)

(
SynthDef(\grains, { | rat = 1, startPos = 0, decay = 0.3 |
	var outenv =  EnvGen.kr(Env.perc(0.001, decay, 1, -4), doneAction: 2);
  var trigger = Impulse.kr(4);
  var startControl = MouseX.kr(0, BufFrames.kr(~mnDrone)).poll;
  var sig = PlayBuf.ar(numChannels:2, bufnum:~mnDrone, rate:rat, trigger:1.0, start:MouseX.kr(0, BufFrames.kr(~mnDrone)), loop:1, doneAction:2);
  Out.ar(bus:0, channelsArray:sig * outenv);
}.play).add;
//Pbind(
//  \instrument, \grains,
//  \startPos, Pseq([0, 0.3], inf),
//  \rat, Prand([2, 4, 7, 12], inf),
//  \dur, Pseq([1, 1/4, 1/8, 1/4, 1/32, 1/64], inf),
//).play();
)


(
SynthDef(\gloop2,{
    | tfq=20,vel=1,fq=1,pos=0,out,gate=1,bal=0, vol=1,bend=0|
    var sig, env, sigL, sigR ,ggt, env2;
	ggt = Impulse.kr(tfq,mul:1);
	sigL = PlayBuf.ar(1,d,fq* bend.midiratio,ggt,pos,0,2);
	sigR = PlayBuf.ar(1,e,fq* bend.midiratio,ggt,pos,0,2);
	env = EnvGen.ar(Env([0,vel,vel,0],[0.01,1/tfq-0.02,0.01]), ggt);
	env2= EnvGen.ar(Env.asr(0.005,vel,0.005),gate,doneAction:2);
	bal = Balance2.ar(sigL,sigR,bal,vol);
	Out.ar(0, (bal*env)*env2)
}).add;
)

Synth(\gloop2)
Synth(\gloop2,[\tfq,1])
Synth(\gloop2, [\bal,1])
Synth(\gloop2, [\bal,0,\pos,30000])

(
// --- Load a sound buffer first ---
// Make sure you have a sound file at this path or change it to your own.
// For example, you can use one of SuperCollider's built-in sounds:
// b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

// Or, if you have a specific file:
// b = Buffer.read(s, "path/to/your/soundfile.wav");

// For this example, let's create a simple sine wave buffer if you don't have a sound file handy.
//b = Buffer.alloc(s, s.sampleRate * 2, 1); // 2 seconds mono buffer
//b.sine1(1.0, [440]); // Fill with a 440 Hz sine wave
b = Buffer.read(s, "/s/mn-drome.wav");

// --- The Granular Sampler SynthDef ---
SynthDef(\granularSampler, {
	arg bufnum = 0, // The buffer to granulate
	    out = 0,
	    amp = 0.5,
	    // Grain Parameters
	    trigRate = 10,  // Grains per second (amount)
	    grainDur = 0.1, // Duration of each grain in seconds
	    playbackRate = 1, // Playback speed of the grain (1 = normal, 0.5 = half speed, 2 = double speed)
	    startPos = 0,   // Start position of grain in the buffer (0 to 1)
	    pan = 0,        // Stereo panning (-1 to 1)
	    // Jitter/Randomness (optional, but often desirable for granular textures)
	    posRand = 0.01, // Randomness in grain start position
	    durRand = 0.0,  // Randomness in grain duration
	    rateRand = 0.0, // Randomness in playback rate
	    ampRand = 0.1;  // Randomness in grain amplitude

	var trig, grainEnv, snd;

	// Trigger for grains
	trig = Impulse.ar(trigRate);

	// Grain envelope (a simple percussive envelope)
	grainEnv = EnvGen.kr(Env.perc(0.001, grainDur, 1, -4), trig);

	// The granular synthesis UGen
	snd = GrainBuf.ar(
		numChannels: BufChannels.kr(bufnum), // Number of channels from buffer
		trigger: trig,
		dur: grainDur + (LFNoise0.kr(1).range(0, durRand)), // Grain duration with randomness
		sndbuf: bufnum,
		rate: playbackRate * BufRateScale.kr(bufnum) + (LFNoise0.kr(1).range(0, rateRand)), // Playback rate with randomness
		pos: startPos + (LFNoise0.kr(1).range(0, posRand)), // Start position with randomness (normalized 0-1)
		interp: 2, // Interpolation mode (2 is linear, 4 is cubic - more CPU)
		pan: pan,
		envbufnum: -1, // -1 uses a built-in hann envelope, or you can supply your own buffer
		maxGrains: 64 // Maximum simultaneous grains (adjust based on CPU)
	);

	// Apply the per-grain envelope and overall amplitude
	snd = snd * grainEnv * amp * (1 - (LFNoise0.kr(1).range(0, ampRand)));

	Out.ar(out, snd);
}).add;
)


//Granulators. Matias Monteagudo 2020

//==========================================Model based on GrainBuf
(
Server.local.options.device = "ASIO : ASIO PreSonus FireStudio";
Server.local.options.sampleRate=48000;
Server.local.options.hardwareBufferSize=128;
)

//here we split our stereo sample file into two channels which is required by GrainBuf
(
d=Buffer.readChannel(s,"C:/Audio/VCV/Mat VCV/Guitar 1.wav",channels:0);
e=Buffer.readChannel(s,"C:/Audio/VCV/Mat VCV/Guitar 1.wav",channels:1);
)

d.play//plays the buffer (channel 1)
e.play//plays the buffer (channel 2)
{Out.ar(0,[PlayBuf.ar(1,d,1,doneAction:2),PlayBuf.ar(1,e,1,doneAction:2)])}.play; //Plays both buffers in two channels. In this case, Left and Right (Stereo)
e.query //tells you info about your sample. Such as its number of frames(samples)

//Here we can launch the MIDI client in the server. It will show you all your devices and will be ready for commands.
MIDIClient.init;
//Here we can connect specific MIDI devices.
MIDIIn.connect(0,6);
MIDIIn.disconnect(0,6);
//Here we can connect them all at once. I personally like connecting individual devices because I have tons of them. But this should be the best option if your setup is simple.
MIDIIn.connectAll

(
SynthDef(\gloop1,{
    | tfq=30,vel=1,fq=1,pos=0,out,gate=1,bend=0|
    var sigL, sigR, env, signal;
    sigL=GrainBuf.ar(2,Impulse.kr(tfq),1/tfq*2,d,fq* bend.midiratio,pos,4,1,-1,100,1,0);
    sigR=GrainBuf.ar(2,Impulse.kr(tfq),1/tfq*2,e,fq* bend.midiratio,pos,4,-1,-1,100,1,0);
    env = EnvGen.ar(Env.asr(0.0015, vel, 0.005), gate, doneAction: 2);
	Out.ar(0, [sigL*env, sigR*env])
}).add;
)

Synth(\gloop1)//We can test if it works here.

//MIDI functions. Interpret this to be able to play notes on your MIDI keyboard. It supports velocity, pedal cc64 and cc1 (Mod Wheel). These MIDI functions are optimized for polyphony.

(
~notes = Array.newClear(128);
~liftednotes = Array.newClear(128);
~pedaldown = 0;
~cc1= 127;
~bend = 8192;

MIDIdef.noteOn(\noteOn, {
	arg vel, nn, chan, src;
	if(~notes[nn] != nil){ //release notes if you're trying to repeat them
		~notes[nn].set(\gate, 0); ~notes[nn] = nil
	};

	~notes[nn] = Synth.new(\gloop1,
		[
			\fq, nn.midicps/100,
			\gate, 1,
			\vel, vel/100,
			\pos, ~cc1.linlin(0, 127, 0, 600000), //This uses the last used value from cc1
			\bend, ~bend.linlin(0, 16383, -2, 2),//This uses the last used value from your pitch bend wheel.
		]
	);
});

MIDIdef.noteOff(\noteOff, {
	arg vel, nn;
	if(~pedaldown == 127) {//if pedal is down:
		~liftednotes[nn] = ~notes[nn];
	}
	{//else if pedal is up:
		~notes[nn].set(\gate,0);
		~notes[nn] = nil;
	}
} );

MIDIdef.cc(\cc1, {
	arg val, chan, src;
	['ModWheel', val].postln;
	~cc1 = val; //This will store the last used cc1 value.
	~notes.do{arg synth; synth.set(\pos, val.linlin(0, 127, 0, 600000))}; //send value to all active nodes, also rescale 0,127 to 0,600000
},ccNum:1, chan: 0);

MIDIdef.bend(\bend, {
	arg val, chan, src;
	['bend', val, chan, src].postln;  // [ bend, 11888, 0, 1 ]
	~bend = val;//This will store the last used bend value.
	// also update any notes currently in ~notes
	~notes.do{arg synth; synth.set(\bend, val.linlin(0, 16383, -2, 2))};
}, chan: 0);

MIDIdef.cc(\pedal,{
	arg val, key;
	['pedal',val].postln;
	if(key ==64) { //only worry about pedal control messages
	~pedaldown = val;
	if(val == 0) {
		~liftednotes.do{arg synth;synth.set(\gate, 0); synth = nil;
			}
	};
	}
},ccNum:64);
)




//==============================Model based on PlayBuf with balance. Balance2.ar requires you also to split your sound file.

(
Server.local.options.device = "ASIO : ASIO PreSonus FireStudio";
Server.local.options.sampleRate=48000;
)

(
d=Buffer.readChannel(s,"C:/Audio/VCV/Mat VCV/Guitar 1.wav",channels:0);
e=Buffer.readChannel(s,"C:/Audio/VCV/Mat VCV/Guitar 1.wav",channels:1);
)

MIDIClient.init
MIDIIn.connect(0,6); //connect specific devices (optional)
MIDIIn.connectAll //Connect all devices


(
SynthDef(\gloop2,{
    | tfq=20,vel=1,fq=1,pos=0,out,gate=1,bal=0, vol=1,bend=0|
    var sig, env, sigL, sigR ,ggt, env2;
	ggt = Impulse.kr(tfq,mul:1);
	sigL = PlayBuf.ar(1,d,fq* bend.midiratio,ggt,pos,0,2);
	sigR = PlayBuf.ar(1,e,fq* bend.midiratio,ggt,pos,0,2);
	env = EnvGen.ar(Env([0,vel,vel,0],[0.01,1/tfq-0.02,0.01]), ggt);
	env2= EnvGen.ar(Env.asr(0.005,vel,0.005),gate,doneAction:2);
	bal = Balance2.ar(sigL,sigR,bal,vol);
	Out.ar(0, (bal*env)*env2)
}).add;
)

Synth(\gloop2)
Synth(\gloop2,[\tfq,1])
Synth(\gloop2, [\bal,1])


(
~notes = Array.newClear(128);
~liftednotes = Array.newClear(128);
~pedaldown = 0;
~cc1= 127;
~bend = 8192;

MIDIdef.noteOn(\noteOn, {
	arg vel, nn, chan, src;
	if(~notes[nn] != nil){ //release notes if you're trying to repeat them
		~notes[nn].set(\gate, 0); ~notes[nn] = nil
	};

	~notes[nn] = Synth.new(\gloop2,
		[
			\fq, nn.midicps/100,
			\gate, 1,
			\vel, vel/100,
			\pos, ~cc1.linlin(0, 127, 0, 600000), //This uses the last used value from cc1
			\bend, ~bend.linlin(0, 16383, -2, 2),//This uses the last used value from your pitch bend wheel.
		]
	);
});

MIDIdef.noteOff(\noteOff, {
	arg vel, nn;
	if(~pedaldown == 127) {//if pedal is down:
		~liftednotes[nn] = ~notes[nn];
	}
	{//else if pedal is up:
		~notes[nn].set(\gate,0);
		~notes[nn] = nil;
	}
} );

MIDIdef.cc(\cc1, {
	arg val, chan, src;
	['ModWheel', val].postln;
	~cc1 = val; //This will store the last used cc1 value.
	~notes.do{arg synth; synth.set(\pos, val.linlin(0, 127, 0, 600000))}; //send value to all active nodes, also rescale 0,127 to 0,600000
},ccNum:1, chan: 0);

MIDIdef.bend(\bend, {
	arg val, chan, src;
	['bend', val, chan, src].postln;  // [ bend, 11888, 0, 1 ]
	~bend = val;//This will store the last used bend value.
	// also update any notes currently in ~notes
	~notes.do{arg synth; synth.set(\bend, val.linlin(0, 16383, -2, 2))};
}, chan: 0);

MIDIdef.cc(\pedal,{
	arg val, key;
	['pedal',val].postln;
	if(key ==64) { //only worry about pedal control messages
	~pedaldown = val;
	if(val == 0) {
		~liftednotes.do{arg synth;synth.set(\gate, 0); synth = nil;
			}
	};
	}
},ccNum:64);
)


//=========================================================Randomizing Balance (\bal) and Grain Size (\tfq) on each note stroke. Uses MIDIFunc instead of MIDIDef.

(
var bit, on,off,pos;
x=Synth(\gloop2,[\gate,0]);
bit = Array.newClear(128);

on = MIDIFunc.noteOn({
    | velocity, midinote |
    [ "velocity: " + velocity, "midinote: " + midinote ].postln;
	bit[midinote] = Synth(\gloop2, [\tfq,rrand(4,6,8,10), \bal, rrand(-0.7,0.5,0.7),\gate, midinote/100, \fq, midinote.midicps/100, \vel, velocity/100])
});


off = MIDIFunc.noteOff({
    | velocity, midinote |
	bit[midinote].release
});

)

// Randomizing position(\pos), here it starts sounding like "Steve Reich - Piano Phases" when you play fifths and fourths. Uses MIDIFunc instead of MIDIDef.

(
var bit, on,off,pos;
x=Synth(\gloop2,[\gate,0]);
bit = Array.newClear(128);

on = MIDIFunc.noteOn({
    | velocity, midinote |
    [ "velocity: " + velocity, "midinote: " + midinote ].postln;
	bit[midinote] = Synth(\gloop2, [\pos, rrand(0,50000,614000,300000,450000,500000),\tfq,rrand(1.1,1.2,1.3,1.4), \bal, rrand(-0.7,0.5,0.7),\gate, midinote/100, \fq, midinote.midicps/100, \vel, velocity/100])
});


off = MIDIFunc.noteOff({
    | velocity, midinote |
	bit[midinote].release
});

)

// "Steve Reich" Phase randomization with gloop1b (GrainBuf) added cc->pos (no bend or pedal)//Note how per note randomization is implemented.

(
SynthDef(\gloop1b,{
    | tfq=30,vel=1,fq=1,pos=0,out,gate=1|
    var sigL, sigR, env, signal;
    sigL=GrainBuf.ar(2,Impulse.kr(tfq),1/tfq*2,d,fq,pos,4,1,-1,100,1,0);
    sigR=GrainBuf.ar(2,Impulse.kr(tfq),1/tfq*2,e,fq,pos,4,-1,-1,100,1,0);
    env = EnvGen.ar(Env.asr(0.0015, vel, 0.005), gate, doneAction: 2);
	Out.ar(0, [sigL*env, sigR*env])
}).add;
)

(
var bit, bit2, cc, on,off,pos;
bit = Array.newClear(128);
bit2 = Array.newClear(128);
on = MIDIFunc.noteOn({
    | velocity, midinote |
    [ "velocity: " + velocity, "midinote: " + midinote ].postln;
	bit[midinote] = x=Synth(\gloop1b, [\tfq,rrand(1.1,1.2,1.3,1.4), \bal, rrand(-0.7,0.5,0.7),\gate, midinote/100, \fq, midinote.midicps/100, \vel, velocity/100])//Randomizations.
});

cc = MIDIFunc.cc({|val|
	["position:"+val].postln;
	bit2[val]= x.set(\pos, val*46000)
},1);

off = MIDIFunc.noteOff({
    | velocity, midinote |
	bit[midinote].release
});

)

//////// Working everything through ".set" (turns out is good for single node manipulation (aka, mono synth as opposed to poly synth) this one is shaky.

(
SynthDef(\gloop3,{
    | tfq=20,vel=1,fq=1,pos=0,out,gate=1,bal=0.5|
    var sig, env, sigL, sigR ,ggt, env2;
	ggt = Impulse.kr(tfq,mul:1);
	sigL = PlayBuf.ar(1,d,fq,ggt,pos,0,2);
	sigR = PlayBuf.ar(1,e,fq,ggt,pos,0,2);
	env = EnvGen.ar(Env([0,vel,vel,0],[0.01,1/tfq-0.02,0.01]), ggt);
	env2= EnvGen.ar(Env.asr(0.005,vel,0.005),gate);
	bal = Balance2.ar(sigL,sigR,bal,1);
	Out.ar(0, (bal*env)*env2)
}).add;
)

(
x = Synth(\gloop3,[\gate,0]);
~noteOn = {arg src, chan, num, vel;
    x.set(\fq, num.midicps/100);
    x.set(\gate, 1);
	x.set(\tfq, rrand(5,10,20,30));
};
MIDIIn.addFuncTo(\noteOn, ~noteOn);

~noteOff = { arg src,chan,num,vel;
    x.set(\gate, 0.0);
};

MIDIFunc.noteOff({
    | velocity, num |
	num[num.midicps].release
});

~bend = { arg src,chan,val;
    //(val * 0.048828125).postln;
    x.set(\bwfreq, val * 0.048828125 );
};
MIDIIn.addFuncTo(\bend, ~bend);
)

/////////////////////////////////////////////////////////////////////////////////Adding effects, let's use a Reverb.

//Interpret your Synth.
(
SynthDef(\gloop1c,{
    | tfq=30,vel=1,fq=1,pos=0,out,gate=1,bend=0|
    var sigL, sigR, env, signal;
    sigL=GrainBuf.ar(2,Impulse.kr(tfq),1/tfq*2,d,fq* bend.midiratio,pos,4,1,-1,100,1,0);
    sigR=GrainBuf.ar(2,Impulse.kr(tfq),1/tfq*2,e,fq* bend.midiratio,pos,4,-1,-1,100,1,0);
    env = EnvGen.ar(Env.asr(0.0015, vel, 0.005), gate, doneAction: 2);
	Out.ar(0, [sigL*env, sigR*env])
}).add;
)
//Call your MIDI controllers so you can play notes.
(
~notes = Array.newClear(128);
~liftednotes = Array.newClear(128);
~pedaldown = 0;
~cc1= 127;
~bend = 8192;

MIDIdef.noteOn(\noteOn, {
	arg vel, nn, chan, src;
	if(~notes[nn] != nil){ //release notes if you're trying to repeat them
		~notes[nn].set(\gate, 0); ~notes[nn] = nil
	};

	~notes[nn] = Synth.new(\gloop1c,
		[
			\fq, nn.midicps/100,
			\gate, 1,
			\vel, vel/100,
			\pos, ~cc1.linlin(0, 127, 0, 600000), //This uses the last used value from cc1
			\bend, ~bend.linlin(0, 16383, -2, 2),//This uses the last used value from your pitch bend wheel.
		]
	);
});

MIDIdef.noteOff(\noteOff, {
	arg vel, nn;
	if(~pedaldown == 127) {//if pedal is down:
		~liftednotes[nn] = ~notes[nn];
	}
	{//else if pedal is up:
		~notes[nn].set(\gate,0);
		~notes[nn] = nil;
	}
} );

MIDIdef.cc(\cc1, {
	arg val, chan, src;
	['ModWheel', val].postln;
	~cc1 = val; //This will store the last used cc1 value.
	~notes.do{arg synth; synth.set(\pos, val.linlin(0, 127, 0, 600000))}; //send value to all active nodes, also rescale 0,127 to 0,600000
},ccNum:1, chan: 0);

MIDIdef.bend(\bend, {
	arg val, chan, src;
	['bend', val, chan, src].postln;  // [ bend, 11888, 0, 1 ]
	~bend = val;//This will store the last used bend value.
	// also update any notes currently in ~notes
	~notes.do{arg synth; synth.set(\bend, val.linlin(0, 16383, -2, 2))};
}, chan: 0);

MIDIdef.cc(\pedal,{
	arg val, key;
	['pedal',val].postln;
	if(key ==64) { //only worry about pedal control messages
	~pedaldown = val;
	if(val == 0) {
		~liftednotes.do{arg synth;synth.set(\gate, 0); synth = nil;
			}
	};
	}
},ccNum:64);
)

//Interpret your Verb

(
SynthDef(\FreeVerb2x2, { |out, mix = 0.25, room = 0.15, damp = 0.5, amp = 1.0|
    var signal;

    signal = In.ar(out, 2);

    ReplaceOut.ar(out,
        FreeVerb2.ar( // FreeVerb2 - true stereo UGen
            signal[0], // Left channel
            signal[1], // Right Channel
            mix, room, damp, amp
        )
    ); // same params as FreeVerb 1 chn version

}).add;
)

// kick it in, note its now processing the output from your synth.

z = Synth(\FreeVerb2x2, [\outbus, 0,\room,1], addAction:\addToTail)

// experiment with some settings
z.set(\room, 1)
z.set(\mix, 0.3)
z.set(\damp, 0.0)

// silence
[z].do(_.free)

/*=============="Executing (spawning) synthDefs through Pbinds" (internal sequencing)
Here we tell Pbind to create a new \gloop2 node each 0.5s with random values for "\fq" (note height)     */

(
Pbind(\instrument, \gloop2,//we tell Pbind "which instrument to play"
	\tfq, 30,//\gloop2's "\tfq" (grain size)
	\fq, Prand([0.2,0.4, 0.6, 0.7, 0.8, 0.9, 1], inf)*4,//we randomize \gloop2's "\fq" which controls GrainBuf's arg "rate")
	\dur, 0.5).play;//Each node lasts 0.5s - "\dur" is an argument from Pbind(option for node duration)
)

//Here we randomize "\tfq" "\fq" "\pos" and Pbind's "\dur"
((
Pbind(\instrument, \gloop2,
	\tfq, Prand([2,4,8,10,12,14], inf),
	\fq, Prand([0.2,0.4, 0.6, 0.7, 0.8, 0.9, 1], inf)*4,
	\pos, Prand([0,100000,200000,300000,400000,500000,600000],inf),
	\bal,0,
	\dur, Prand([0.1,0.2,0.3,0.4,0.5],inf)).play;
);
z = Synth(\FreeVerb2x2, [\outbus, 0,\room,1,\mix,0.2], addAction:\addToTail);
)
//=======================Here we also add balance randomization. We can also make the waveform to play backwards.
//Note also the relationship between tfq (grain size) and dur (duration of each node, argument from Pbind) to try on achieving one grain per node.
((
Pbind(\instrument, \gloop2,
	\tfq, Prand([2,4,8,10,12,14], inf),
	\fq, Prand([-1,-0.5,-0.3,0.4,0.6,0.7,1], inf)*4,
	\pos, Prand([0,100000,200000,300000,400000,500000,600000], inf),
	\bal, Prand([-1,-0.7,-0.5,-0.3,0,0.3,0.5,0.7,1],inf),
	\dur, Prand([2,4,8,10,12,14]/100, inf)).play;
);
z = Synth(\FreeVerb2x2, [\outbus, 0,\room,1,\mix,0.2], addAction:\addToTail);
)

//Playing two or more Pbinds. Note the importance of the semicolon (;) to define where each expression is.
((
Pbind(\instrument, \gloop2,
	\tfq, Prand([2,4,8,10,12,14], inf),
	\fq, Prand([-1,-0.5,-0.3,0.4,0.6,0.7,1], inf)*4,
	\pos, Prand([0,100000,200000,300000,400000,500000,600000], inf),
	\bal, Prand([-1,-0.7,-0.5,-0.3,0,0.3,0.5,0.7,1],inf),
	\dur, Prand([2,4,8,10,12,14]/100, inf)).play;
);//Here

(
Pbind(\instrument, \gloop2,
	\tfq, Prand([2,4,8,10,12,14], inf),
	\fq, Prand([-1,-0.5,-0.3,0.4,0.6,0.7,1], inf)*4,
	\pos, Prand([0,100000,200000,300000,400000,500000,600000], inf),
	\bal, Prand([-1,-0.7,-0.5,-0.3,0,0.3,0.5,0.7,1],inf),
	\dur, Prand([2,4,8,10,12,14]/100, inf)).play;
);//Here
z = Synth(\FreeVerb2x2, [\outbus, 0,\room,1,\mix,0.2], addAction:\addToTail);
)

//Playing 5 of them. Note how density increases. You can also manipulate the arguments on each.

((
Pbind(\instrument, \gloop2,
	\tfq, Prand([2,4,8,10,12,14], inf),
	\fq, Prand([-1,-0.5,-0.3,0.4,0.6,0.7,1], inf)*4,
	\pos, Prand([0,100000,200000,300000,400000,500000,600000], inf),
	\bal, Prand([-1,-0.7,-0.5,-0.3,0,0.3,0.5,0.7,1],inf),
	\vol,0.3,
	\dur, Prand([2,4,8,10,12,14]/100, inf)).play;
);

(
Pbind(\instrument, \gloop2,
	\tfq, Prand([2,4,8,10,12,14], inf),
	\fq, Pseq([0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1], inf)*4,//here we use a "Pseq" instead of "Prand"
	\pos, Prand([0,100000,200000,300000,400000,500000,600000], inf)-0.2,//here we offset by -0.2
	\bal, Prand([-1,-0.7,-0.5,-0.3,0,0.3,0.5,0.7,1],inf)*0.6,//here we scaled * 0.6 (less open panning)
	\dur, Prand([2,4,8,10,12,14]/80, inf)).play;
);

(
Pbind(\instrument, \gloop2,
	\tfq, Prand([2,4,8,10,12,14], inf)-0.1,//offset
	\fq, Pseq([0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1].reverse, inf)*4, //".reverse" after Pseq's array reverses the values, no need to re type them backwards.
	\pos, Prand([0,100000,200000,300000,400000,500000,600000], inf),
	\bal, Prand([-1,-0.7,-0.5,-0.3,0,0.3,0.5,0.7,1],inf)-0.2, //offset
	\dur, Prand([2,4,8,10,12,14]/100, inf)-0.01).play;//offset
);

(
Pbind(\instrument, \gloop2,
	\tfq, Prand([2,4,8,10,12,14]+0.15, inf),//offset
	\fq, Prand([-1,-0.5,-0.3,0.4,0.6,0.7,1], inf)*3,//mult
	\pos, Prand([0,100000,200000,300000,400000,500000,600000]*0.6, inf),//offset
	\bal, Prand([-1,-0.7,-0.5,-0.3,0,0.3,0.5,0.7,1]+0.2,inf),//offset
	\vol,0.3,
	\dur, Prand([2,4,8,10,12,14]/100, inf)+0.15).play;//offset
);

(
Pbind(\instrument, \gloop2,
	\tfq, Prand([2,4,8,10,12,14], inf)-0.22,//offset
	\fq, Prand([-1,-0.5,-0.3,0.4,0.6,0.7,1], inf)*2.3,//Mul
	\pos, Prand([0,100000,200000,300000,400000,500000,600000], inf)+0.1,//offset
	\bal, Prand([-1,-0.7,-0.5,-0.3,0,0.3,0.5,0.7,1],inf)-0.4,//offset
	\vol,0.3,
	\dur, Prand([2,4,8,10,12,14]/100, inf)-0.0022).play;//offset
);
z = Synth(\FreeVerb2x2, [\outbus, 0,\room,1,\mix,0.2], addAction:\addToTail);
)

//======= "Piano Phases" effect again, this time using Pbind. //Note each time you execute it it chooses
(
(
Pbind(\instrument, \gloop2,
	\tfq,1,
	\fq,1,
	\pos, Pwhite(0,500000),
	\bal, -0.7,
	\dur, 1000).play;
);

(
Pbind(\instrument, \gloop2,
	\tfq,1.02,
	\fq,1,
	\pos, Pwhite(0,500000),
	\bal, 0.7,
	\dur, 1000).play;
);

(
Pbind(\instrument, \gloop2,
	\tfq,1.03,
	\fq,1,
	\pos, Pwhite(0,500000),
	\bal, 0,
	\dur, 1000).play;
);
z = Synth(\FreeVerb2x2, [\outbus, 0,\room,1,\mix,0.2], addAction:\addToTail);
)

//=============================== Launching a SynthDef + its MIDI functions + Verb. aka "complete synth"
//Kill all servers and reboot. (otherwise load SC from scratch)

//First boot your server.
(
Server.local.options.device = "ASIO : ASIO PreSonus FireStudio";
Server.local.options.sampleRate=48000;
s.boot;
)

//Interpret the bracket below. It will connect to your specific MIDI device (change the number accordingly) you should be able to play notes and navigate through the sample using cc1.
(

(
MIDIClient.init;
MIDIIn.connect(0,6);
);

(
d=Buffer.readChannel(s,"C:/Audio/VCV/Mat VCV/Guitar 1.wav",channels:0);
e=Buffer.readChannel(s,"C:/Audio/VCV/Mat VCV/Guitar 1.wav",channels:1);
);

(
SynthDef(\gloop1b,{
    | tfq=30,vel=1,fq=1,pos=0,out,gate=1,bend=0|
    var sigL, sigR, env, signal;
    sigL=GrainBuf.ar(2,Impulse.kr(tfq),1/tfq*2,d,fq* bend.midiratio,pos,4,1,-1,100,1,0);
    sigR=GrainBuf.ar(2,Impulse.kr(tfq),1/tfq*2,e,fq* bend.midiratio,pos,4,-1,-1,100,1,0);
    env = EnvGen.ar(Env.asr(0.0015, vel, 0.005), gate, doneAction: 2);
	Out.ar(0, [sigL*env, sigR*env])
}).add;
);

(
~notes = Array.newClear(128);
~liftednotes = Array.newClear(128);
~pedaldown = 0;
~cc1= 127;
~bend = 8192;

MIDIdef.noteOn(\noteOn, {
	arg vel, nn, chan, src;
	if(~notes[nn] != nil){ //release notes if you're trying to repeat them
		~notes[nn].set(\gate, 0); ~notes[nn] = nil
	};

	~notes[nn] = Synth.new(\gloop1,
		[
			\fq, nn.midicps/100,
			\gate, 1,
			\vel, vel/100,
			\pos, ~cc1.linlin(0, 127, 0, 600000), //This uses the last used value from cc1
			\bend, ~bend.linlin(0, 16383, -2, 2),//This uses the last used value from your pitch bend wheel.
		]
	);
});

MIDIdef.noteOff(\noteOff, {
	arg vel, nn;
	if(~pedaldown == 127) {//if pedal is down:
		~liftednotes[nn] = ~notes[nn];
	}
	{//else if pedal is up:
		~notes[nn].set(\gate,0);
		~notes[nn] = nil;
	}
} );

MIDIdef.cc(\cc1, {
	arg val, chan, src;
	['ModWheel', val].postln;
	~cc1 = val; //This will store the last used cc1 value.
	~notes.do{arg synth; synth.set(\pos, val.linlin(0, 127, 0, 600000))}; //send value to all active nodes, also rescale 0,127 to 0,600000
},ccNum:1, chan: 0);

MIDIdef.bend(\bend, {
	arg val, chan, src;
	['bend', val, chan, src].postln;  // [ bend, 11888, 0, 1 ]
	~bend = val;//This will store the last used bend value.
	// also update any notes currently in ~notes
	~notes.do{arg synth; synth.set(\bend, val.linlin(0, 16383, -2, 2))};
}, chan: 0);

MIDIdef.cc(\pedal,{
	arg val, key;
	['pedal',val].postln;
	if(key ==64) { //only worry about pedal control messages
	~pedaldown = val;
	if(val == 0) {
		~liftednotes.do{arg synth;synth.set(\gate, 0); synth = nil;
			}
	};
	}
},ccNum:64);
);

//Verb
(
SynthDef(\FreeVerb2x2, { |out, mix = 0.25, room = 0.15, damp = 0.5, amp = 1.0|
    var signal;

    signal = In.ar(out, 2);

    ReplaceOut.ar(out,
        FreeVerb2.ar( // FreeVerb2 - true stereo UGen
            signal[0], // Left channel
            signal[1], // Right Channel
            mix, room, damp, amp
        )
    ); // same params as FreeVerb 1 chn version

}).add;
);
//Verb turn on.
z = Synth(\FreeVerb2x2, [\outbus, 0,\room,1], addAction:\addToTail);
)

//Piano Phases Pbind with reverb. Note how reverb is applied to all nodes.
//======= "Phasing" effect again, this time using Pbind.
(
(
Pbind(\instrument, \gloop2,
	\tfq, 1.03,//Note each Pbing has a different tfq to make them phase.
	\fq, 1.002,//slightly detuned high
	\pos, Pwhite(0,500000),
	\bal, -0.7,//balanced right
	\vol,0.4,
	\dur, 10).play;//Note each Pbind has a differend duration. New nodes play out of sync and with a different position.
);
(
Pbind(\instrument, \gloop2,
	\tfq, 1.02,
	\fq, 0.998,//slightly detuned low
	\pos, Pwhite(0,500000),
	\bal, 0.7,//balanced left
	\vol,0.4,
	\dur, 11).play;//duration
);

(
Pbind(\instrument, \gloop2,
	\tfq,1,
	\fq,1,
	\pos, Pwhite(0,500000),
	\bal, 0,
	\vol,0.6,
	\dur, 12).play;//duration
);

z = Synth(\FreeVerb2x2, [\outbus, 0,\room,1], addAction:\addToTail);
)

//Another variation just for fun. This one has Pbinds that sounds like waves coming and going.
(
(
Pbind(\instrument, \gloop2,
	\tfq, 0.24,
	\fq, 1.19,
	\pos, Prand([20000,40000,80000,100000,120000], inf), //Note how position is randomized using specific values to avoid unwanted grains.
	\bal, -0.7,
	\vol, Pseq([0,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95,1].mirror, inf), //A series of (volume) values with ".mirror". Nodes gradually increase and decrease volume.
	\dur, 0.12).play;
);

(
Pbind(\instrument, \gloop2,
	\tfq, 0.28,
	\fq,0.998,
	\pos, Prand([20000,40000,80000,100000,120000], inf), //Note how position is randomized using specific values to avoid unwanted grains.
	\bal, 0.7,
	\vol, Pseq([0,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95,1].mirror, inf),
	\dur, 0.14).play;
);

(
Pbind(\instrument, \gloop2,
	\tfq, 0.2,
	\fq,1.5,
	\pos, Prand([20000,40000,80000,100000,120000], inf),
	\bal, 0,
	\vol, Pseq([0,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95,1].mirror, inf),
	\dur, 0.1).play;
);

z = Synth(\FreeVerb2x2, [\outbus, 0,\room,1], addAction:\addToTail);
)

//MULTICHANNEL EXPANSIONS - Panning across more than 2 channels.
//Azimuth panning (to make sounds go in circle)
//Example from the documentation (5 channel)
(
{
    PanAz.ar(
        numChans: 5,
        in: ClipNoise.ar(0.1),
        pos: LFSaw.kr(MouseX.kr(0.2, 8, 'exponential')),
        level: 0.5,
        width: 3,
        orientation: 0.5
    );
}.scope
)

// In a SynthDef (4 channel)

//With a noise SD
(
SynthDef(\WN, {
	|pan|
	var signal,env;
	signal=WhiteNoise.ar(0.05);
	env=EnvGen.ar(Env([0,1,0], [0.01,0.1,0.5]),1,doneAction:2);
	Out.ar(0,PanAz.ar(4,signal*env,pan).scope);
}).add;
)
//With one PlayBuf channel.
(
SynthDef(\gloop4,{
    | tfq=2,vel=1,fq=1,pos=0,out,gate=1, vol=1,pan|
    var sig, env, ggt, env2,pan4;
	ggt = Impulse.kr(tfq,mul:1);
	sig = PlayBuf.ar(1,d,fq,ggt,pos,0,2);
	env = EnvGen.ar(Env([0,vel,vel,0],[0.01,1/tfq-0.02,0.01]), ggt);
	env2= EnvGen.ar(Env.asr(0.005,vel,0.005),gate,doneAction:2);
	pan4 = PanAz.ar(4,sig,pan,vol).scope;
	Out.ar(0, (pan4*env)*env2)
}).add;
)

u=Synth(\gloop3).scope;

//Using Pseries in a Pbind to modulate panning.
Pbind(\instrument,\gloop3,\pan, Pwhite(-1,1,inf), \dur,0.2).play;

//A Pbind using \WN that executes nodes each 0.05s with increased panning value so it goes around all 4 speakers.

(
Pbind(\instrument, \WN,
	\pan, Pseries(0,0.01,inf),
	\dur, 0.05).play;
)
//Same kind of excercize but with \gloop4
(
Pbind(\instrument, \gloop4,
	\tfq, 0.2,
	\fq,1.5,
	\pos, Pwhite(0,100000),
	\bal, 0,
	\vol, Pseq([0,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95,1].mirror, inf),
	\pan, Pseries(0,0.01,inf),
	\dur, 0.05).play;
)

//Add some bells for good measure. (With slight detuning)
((
SynthDef(\bell, {
	|fq, vol, pan,sca=1|
	var sigLa,sigLb,sigRa,sigRb,env,panner;
	env=EnvGen.ar(Env([0,0.6,0],[0,0.1,2],-4),1,timeScale:sca, doneAction:2);
	sigLa=LFTri.ar(fq-6,mul:env);
	sigLb=LFTri.ar(fq+15,mul:env);
	sigRa=LFTri.ar(fq-8,mul:env);
	sigRb=LFTri.ar(fq+20,mul:env);
	panner=Balance2.ar(sigLa+sigLb,sigRa+sigRb,pan,vol);
		Out.ar(0, (panner*env));
}).add;
);

(
Pbind(\instrument, \bell,
	\pan,  Pwhite(-1,1),
	\vol, Pwhite(0.02,0.1),
	\fq, Pwhite(3000,6000),
	\sca, Pwhite(2,10),
	\dur, Pwhite(0.05,1)).play;
);
(
Pbind(\instrument, \bell,
	\pan,  Pwhite(-1,1),
	\vol, Pwhite(0.02,0.1),
	\fq, Pwhite(3000,6000),
	\sca, Pwhite(2,10),
	\dur, Pwhite(0.05,2)).play;
);
(
Pbind(\instrument, \bell,
	\pan,  Pwhite(-1,1),
	\vol, Pwhite(0.02,0.1),
	\fq, Pwhite(3000,6000),
	\sca, Pwhite(2,10),
	\dur, Pwhite(0.05,2)).play;
);
(
Pbind(\instrument, \bell,
	\pan,  Pwhite(-1,1),
	\vol, Pwhite(0.02,0.1),
	\fq, Pwhite(6000,10000),
	\sca, Pwhite(2,10),
	\dur, Pwhite(0.05,1)).play;
);
(
Pbind(\instrument, \bell,
	\pan,  Pwhite(-1,1),
	\vol, Pwhite(0.02,0.1),
	\fq, Pwhite(6000,10000),
	\sca, Pwhite(2,10),
	\dur, Pwhite(0.05,2)).play;
);
(
Pbind(\instrument, \bell,
	\pan,  Pwhite(-1,1),
	\vol, Pwhite(0.02,0.1),
	\fq, Pwhite(6000,10000),
	\sca, Pwhite(2,10),
	\dur, Pwhite(0.05,2)).play;
);
)
