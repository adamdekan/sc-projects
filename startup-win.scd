(
if (\SCNvim.asClass.notNil) {
  Server.program = "C:/sc/scsynth.exe";
};
s.options.numInputBusChannels = 2;
s.options.numOutputBusChannels = 2;
s.options.device = "ASIO4ALL v2";
s.boot;
)
{ MiPlaits.ar(50, mul:0.1) }.play

// Always reboot server after ASIO change
s.reboot;

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
