// 1. Define Control Buses for the filter parameters
// These buses will hold the current values for cutoff and resonance.
// We initialize them with default values.
(
~filterCutoffBus = Bus.control(s, 1); // Using .audio for control buses is a common practice,
                                        // though .kr (control rate) is also valid.
~filterRQBus     = Bus.control(s, 1);

// Set initial values for the buses
~filterCutoffBus.set(2000.0); // Default cutoff frequency
~filterRQBus.set(0.5);      // Default resonance (RQ = 1/Q, so 0.5 is Q=2)

// 2. Define your SynthDef with a controllable filter
SynthDef(\filteredSynth, { |out=0, freq=440, amp=0.1, gate=1|
    // Read the filter parameters from the control buses
    var cutoff = In.kr(~filterCutoffBus, 1);
    var rq = In.kr(~filterRQBus, 1);

    var env = EnvGen.ar(Env.adsr(0.01, 0.1, 0.8, 0.5), gate, doneAction: 2);
    var osc = Saw.ar(freq); // Using a Saw wave for a richer sound to filter

    // Apply a LowPass Filter (LPF)
    var filteredSound = LPF.ar(osc, cutoff, rq);

    Out.ar(out, filteredSound * amp * env);
}).add;

// 3. Set up OSC Receivers
// Create a global variable to store the OSC port.
~oscPort = NetAddr.new("10.0.0.3", 7000);

// OSCdef for controlling filter cutoff
OSCdef(\receiveCutoff, { |msg, time, addr, port|
    var newCutoff = msg[1].asFloat;
    ~filterCutoffBus.set(newCutoff);
    "Received OSC cutoff: %.2f".format(newCutoff).postln;
}, '/filter/cutoff', nil, 8004); // Listen on port 8004 for /filter/cutoff

// OSCdef for controlling filter resonance (RQ)
OSCdef(\receiveRQ, { |msg, time, addr, port|
    var newRQ = msg[1].asFloat;
    ~filterRQBus.set(newRQ);
    "Received OSC RQ: %.2f".format(newRQ).postln;
}, '/filter/rq', nil, 8004); // Listen on port 8004 for /filter/rq

// 4. Create a running sequence of synths
// We'll use a Pbind to play a sequence of notes using our SynthDef.
// Each new synth will read the current values from the control buses.
~sequence = Pbind(
    \instrument, \filteredSynth,
    \degree, Pseq([0, 2, 4, 5, 7, 9, 10, 12], inf), // A simple major scale sequence
    \dur, Pseq([0.25, 0.25, 0.5, 0.25, 0.25, 0.5, 0.25, 0.75], inf),
    \amp, 0.15,
    \legato, 0.8,
    \atk, 0.01,
    \rel, 0.5
).play;
)

// Post a message to confirm setup
"SuperCollider is now listening for OSC messages on port 8004.".postln;
"Send messages to /filter/cutoff (float) and /filter/rq (float).".postln;

// To clean up (execute these lines when you want to stop):
/*
~sequence.stop; // Stop the running sequence
~sequence.free; // Free the Pbind
OSCdef(\receiveCutoff).free; // Free the cutoff OSC listener
OSCdef(\receiveRQ).free;     // Free the RQ OSC listener
~filterCutoffBus.free;   // Free the control buses
~filterRQBus.free;
"Sequence, OSC listeners, and buses cleaned up.".postln;
*/
