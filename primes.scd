(
SynthDef(\sinGrain, { |out, freq = 440, amp = 0.1, gate = 1|
	var env = EnvGen.kr(Env.perc(0.01, 0.2, amp), gate);
	var sig = SinOsc.ar(freq);
	Out.ar(out, sig * env);
}).add;
)

( // Function to check if a number is prime
~isPrime = {|num|
	if (num <= 1) { false } {
		2.sqrt.asInteger.do { |i|
			if (num % i == 0) { ^false };
		};
		^true;
	}
};
)
~isPrime.value(2);

( // Pattern to generate the sequence and play notes for primes
p = Pseq(1, 128, 1).collect({ |number|
	if (~isPrime.value(number)) {
		// Map prime number to a MIDI pitch (you can adjust the range)
		var midiPitch = number % 50 + 50;
		Pbind(
			\instrument, \sinGrain,
			\midinote, midiPitch,
			\dur, 0.2
		)
	} {
		Pbind(\instrument, \silent, \dur, 0.2) // Play nothing for non-primes
	}
}).play;
)