(

// A buggy stab at a scrolling freqscope.
// This code needs more work, obviously and It also relies on PV_MagBuffer
// from the SCPlugins3 pack. Install https://github.com/supercollider/sc3-plugins
// and You should be good to go.


var mags, w_width, w_height, bgCol, fgCol;
s.waitForBoot({

	mags=Buffer.allocConsecutive(2,s, 256);
	s.sync;

	SynthDef(\monitor, {
		FFT(b=[LocalBuf(512),LocalBuf(512)],SoundIn.ar([0,1]));
		PV_MagBuffer(b,mags);
		Out.ar(0, SoundIn.ar([0,1]))
	}).add;

	s.sync;

	w_width = 1024;
	w_height = 512;
	bgCol=Color.white;
	fgCol=Color.black;

	w=Window("",Rect(
		Window.screenBounds.width-w_width/2,
		Window.screenBounds.width-w_width/2,
		w_width,w_height)).front;
	u=UserView(w,w.view.bounds);
	u.clearOnRefresh_(false);
	u.frameRate_(15);
	u.animate_(true);
	u.background_(bgCol);
	i=Image.new(w_width,w_height,bgCol);
	i.interpolation_('fast');
	u.drawFunc_({
		i.drawAtPoint(Point(0,-4));
		Pen.width_(0.5);
		mags[0].getn(0, 255, {|z| l = z});
		mags[1].getn(0, 255, {|z| r = z});
		p=l.reverse++r;

		Pen.translate(0,w_height);
		Pen.strokeColor_(fgCol);
		Pen.fillColor_(bgCol);

		p.do{|y,x|
			if(y.notNil){Pen.lineTo(Point(((x*2)), y.tanh.neg*64));};};
		Pen.lineTo(w_width+1@ 0);
		Pen.fillStroke;

		{i=Image.fromWindow(w,Rect(0,0,w_width,w_height))}.defer(1/u.frameRate);
	});

	w.onClose_{w.close;x.free;mags[0,1].free;i.free};
	x=Synth(\monitor);
	CmdPeriod.doOnce{w.close};
	});
)