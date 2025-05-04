t = TempoClock(144/60);

( // SynthDef for white noise with LPF and panning
SynthDef(\braids, {
    arg out=0, amp=0.3, pan=0, cutoff=2000, attack=0.01, hold=0.1, release=0.01;
    var sig, env;

    // White noise source
	sig = MiBraids.ar(440);

    // Apply low-pass filter
	// sig = LPF.ar(sig, cutoff);

    // AHR envelope
    env = EnvGen.ar(
        Env.new([0, 1, 1, 0], [attack, hold, release], [2, 0, -4]),
        doneAction: 2
    );

    // Apply envelope and panning
    sig = Pan2.ar(sig * env * amp, pan);

    Out.ar(out, sig);
}).add;
)


( // Pattern implementation for AND truth table
Pdef(\andLogic,
    Pbind(
        \instrument, \filterNoise,
        \dur, 0.5,

        // A and B values (alternating between all possible combinations)
        \a, Pseq([0, 0, 1, 1], inf),
        \b, Pseq([0, 1, 0, 1], inf),

        // AND evaluation - fixed to use == instead of >
        \result, Pfunc({ |event|
            (event[\a] == 1 && event[\b] == 1).asInteger
        }),

        // Routing based on AND result
        \pan, Pfunc({ |event|
            if(event[\result] == 1) {
                0 // Both channels (center) if true
            } {
                if(event[\a] == 1) { -1 } { 1 } // A to left, B to right
            }
        }),

        // Hold time is longer if result is true
        \hold, Pfunc({ |event|
            if(event[\result] == 1) { 0.3 } { 0.01 }
        }),

        // Filter cutoff - 2000Hz when true
        \cutoff, Pfunc({ |event|
            if(event[\result] == 1) { 2000 } { 10000 }
        }),

        \attack, 0.01,
        \release, 0.01,
        \amp, 0.2
    )
).play(t);
)
