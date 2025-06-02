(
if (\SCNvim.asClass.notNil) {
  Server.program = "C:/sc/scsynth.exe";
};
Server.default.options.safetyClipThreshold = 1;
s.options.numInputBusChannels = 2;
s.options.numOutputBusChannels = 2;
s.options.device = "ASIO4ALL v2";
s.boot;
s.waitForBoot {
    // Master limiter SynthDef
    SynthDef(\masterLimiter, {
        var in, out;
        in = In.ar(0, 2); // assuming stereo master bus is 0 and 1
        out = tanh(in) * 0.7;
        ReplaceOut.ar(0, out); // replaces final output with limited signal
    }).add;

    // Run master limiter AFTER everything is mixed
    Synth.after(s.defaultGroup, \masterLimiter);
};
)
{ MiPlaits.ar(50)*300}.play

// Always reboot server after ASIO change
s.reboot;
Server.killAll;

// Other settings
ServerOptions.outDevices;
Platform.userConfigDir;
Server.default.options.device = "ASIO";
Server.default.options.device = "ASIO : ASIO4ALL v2";
Server.default.options.device = "MME : Headphones (MOMENTUM 4)";
Server.default.options.device = "Windows WASAPI : Headphones (MOMENTUM 4)";
s.options.sampleRate = 44100;
s.options.sampleRate = 48000;
s.options.sampleRate = 96000;
Platform.systemExtensionDir;
Server.killAll;

s.plotTree;
