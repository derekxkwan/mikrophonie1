s.boot;
Ndef(\filters).clear;
(
Ndef(\filters,{|inBus = 0, outBus = 0, lF = 30, hF = 10000, gain = 1, vol = 0, testGain = 0.3, which = 0, pan = 0|
	var input,test, select;
	input = SoundIn.ar(inBus, gain);
	test = BrownNoise.ar(testGain);

	select = Select.ar(which, [input, test]);
	select = BLowPass4.ar(select, hF, 1, 1);
	select = BHiPass4.ar(select, lF, 1, 1);
	select = Pan2.ar(select, pan, vol);
	OffsetOut.ar(outBus, select);
});
)


(
Ndef(\filters).play;


~win = Window.new("dxkMikrophonie", Rect(50, 200, 500, 600));
~win.front;

~lowFreqLabel = StaticText(~win, Rect(5, 5, 50, 25))
	.string_("lF");
~lowFreqSpec = ControlSpec.new(80, 6000, \exp, 5, 80);
~lowFreqNum = NumberBox.new(~win, Rect(5, 35, 50, 40))
.value_(30);
~lowFreq = Slider.new(~win, Rect(5, 80, 50, 400))
.value_(0)
.action_({
	var lFScale;
	lFScale = ~lowFreqSpec.map(~lowFreq.value);
	if(lFScale < 100, {lFScale = 30},{lFScale});
	if(lFScale > 5000, {lFScale = 10000},{lFScale});
	~lowFreqNum.value = lFScale;
	Ndef(\filters).set(\lF, lFScale);
});
	~hiFreqLabel = StaticText(~win, Rect(60, 5, 50, 25))
	.string_("hF");
~hiFreqSpec = ControlSpec.new(80, 6000, \exp, 5, 80);
~hiFreqNum = NumberBox.new(~win, Rect(60, 35, 50, 40))
.value_(10000);
~hiFreq = Slider.new(~win, Rect(60, 80, 50, 400))
.value_(1)
.action_({
	var hFScale;
	hFScale = ~hiFreqSpec.map(~hiFreq.value);
	if(hFScale < 100, {hFScale = 30},{hFScale});
	if(hFScale > 5000, {hFScale = 10000},{hFScale});
	~hiFreqNum.value = hFScale;
	Ndef(\filters).set(\hF, hFScale);
});
		~volLabel = StaticText(~win, Rect(115, 5, 50, 25))
	.string_("vol");

~volNum = NumberBox.new(~win, Rect(115, 35, 50, 40))
.value_(0);
~vol = Slider.new(~win, Rect(115, 80, 50, 400))
.value_(0)
.action_({
	var volScale;
	volScale = log(~vol.value*1.718+1);
	if(volScale < 0.001, {volScale = 0.001}, {volScale});
	~volNum.value = volScale;
	Ndef(\filters).set(\vol, volScale);

});
~volLabel = StaticText(~win, Rect(170, 5, 50, 25))
	.string_("pan");
~panNum = NumberBox.new(~win, Rect(170, 35, 50, 40))
.value_(0);
~panSpec = ControlSpec.new(-1, 1, \lin, 0.01, 0);
~pan = Slider.new(~win, Rect(170, 80, 50, 400))
.value_(0.5)
.action_({
	var panScale;
	panScale = ~panSpec.map(~pan.value);
	~panNum.value = panScale;
	Ndef(\filters).set(\pan, panScale);

});
~volLabel = StaticText(~win, Rect(5, 565, 50, 35))
	.string_("gain");
~gainNum = NumberBox.new(~win, Rect(5, 485, 50, 25))
.value_(0);
	~gain = Knob(~win, Rect(5, 515, 50, 50))
.value_(0)
.action_({
	var gainScale;
	gainScale = log(~gain.value*1.718+1);
	if(gainScale < 0.001, {gainScale = 0.001}, {gainScale});
	~gainNum.value = gainScale;
	Ndef(\filters).set(\gain, gainScale);

});

~selector = Button.new(~win, Rect(60, 485, 100, 50))
.states_([
	["input", Color.black, Color.green],
	["test", Color.black, Color.yellow]
])
.action_({|butt|
	butt.value.postln;
	Ndef(\filters).set(\which, butt.value);
});



OSCdef(\tlow, {|msg, time, addr, recvPort|
	{var val, spec;

		val = msg[1];
		~lowFreq.value_(val);
		spec = ~lowFreqSpec.map(val);
		if(spec < 100, {spec = 30},{spec});
	if(spec > 5000, {spec = 10000},{spec});
		~lowFreqNum.value_(spec);
		Ndef(\filters).set(\lF, spec);


	}.defer;
}, '/mik/low', recvPort: 9999);
OSCdef(\thigh, {|msg, time, addr, recvPort|
{var val, spec;

		val = msg[1];
		~hiFreq.value_(val);
		spec = ~hiFreqSpec.map(val);
			if(spec < 100, {spec = 30},{spec});
	if(spec > 5000, {spec = 10000},{spec});
		~hiFreqNum.value_(spec);
		Ndef(\filters).set(\hF, spec);


	}.defer;

}, '/mik/high', recvPort: 9999);

OSCdef(\tpan, {|msg, time, addr, recvPort|
{var val, spec;

		val = msg[1];
		~pan.value_(val);
		spec = ~panSpec.map(val);
		~panNum.value_(spec);
		Ndef(\filters).set(\pan, spec);


	}.defer;

}, '/mik/pan', recvPort: 9999);

OSCdef(\tvol, {|msg, time, addr, recvPort|
	{var val, spec;

		val = msg[1];
		~vol.value_(val);
		spec = log(val*1.718+1);
		if(spec < 0.001, {spec = 0.001}, {spec});
		~volNum.value_(spec);
		Ndef(\filters).set(\vol, spec);


	}.defer;
}, '/mik/vol', recvPort: 9999);






)
