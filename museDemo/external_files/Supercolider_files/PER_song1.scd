//DENNIS FRANK & ALEX JENKINS
//MUSE EEG SUPERCOLIDER CODE
//SONG 1 for PERFv2 - REVISED IN 2025 FOR CEE4803/LMC4813.
//Copyright (c) GEORGIA INSTITUTE OF TECHNOLOGY. All rights reserved.

s.boot;
s.quit;
thisProcess.openUDPPort(57120);

OSCFunc.trace(true);
OSCFunc.trace(false);

MIDIClient.init()
MIDIClient.disposeClient

m = MIDIOut(0);n = MIDIOut(1);o = MIDIOut(2);p = MIDIOut(3);q = MIDIOut(4);


m.noteOn(1, 96, 100); //test
m.allNotesOff(16)
n.noteOn(1, 75, 100); //test
n.allNotesOff(16)
o.noteOn(1, 75, 100); //test
o.allNotesOff(16)
p.noteOn(1, 62, 100); //test
p.allNotesOff(16)
q.noteOn(1, 62, 100); //test
q.allNotesOff(16)

//play that funky music
(
var base_tempo = 85; //CHANGE TEMPO

var new_beta_tempo;
var new_beta2_tempo;
var new_theta_tempo;
var alpha_sel;
var gamma_sel;
var beta_sel;
var vels = [70,80,95,105,110];
var vel_weights = [0.05,0.1,0.7,0.1,0.05];
var flag = true;

var chord_1 = [48,52,55];
var chord_2 = [48,52,55];
var chord_3 = [50,55,59];
var chord_4 = [48,52,57];
var chord_5 = [50,53,57];
var chord_array = [chord_1, chord_2, chord_3, chord_4, chord_5];
var chord;
var chord_vel;

var great_diff;
var muse1avg;
var muse2avg;

var beta_tempos;
var beta_notes = [79,81,83,84,86,88,89,91,93,95,96];

var theta_tempos;
var theta_notes = [36, 38, 43, 45];

var alpha_diff;
var beta_diff;
var gamma_diff;
var delta_diff;
var theta_diff;


base_tempo = base_tempo/60;

beta_tempos = [(base_tempo * 2), (base_tempo * 1), (base_tempo * 0.5), (base_tempo * 0.25)];
theta_tempos = [(base_tempo * 0.125), (base_tempo / 16)];

//HEADSET 1 with path: /eeg/
OSCdef.new(\alpha1, { | msg |
	var alpha = msg[1].asFloat;
	~alpha1 = alpha;
	} ,
path: '/eeg/alpha'
).enable;

OSCdef.new(\beta1, { | msg |
	var beta = msg[1].asFloat;
	~beta1 = beta;
	} ,
path: '/eeg/beta'
).enable;

OSCdef.new(\gamma1, { | msg |
	var gamma = msg[1].asFloat;
	~gamma1 = gamma;
	} ,
path: '/eeg/gamma'
).enable;

OSCdef.new(\delta1, { | msg |
	var delta = msg[1].asFloat;
	~delta1 = delta;
	} ,
path: '/eeg/delta'
).enable;

OSCdef.new(\theta1, { | msg |
	var theta = msg[1].asFloat;
	~theta1 = theta;
	} ,
path: '/eeg/theta'
).enable;

//initialize in case not connected
~alpha1 = 0;
~beta1 = 0;
~gamma1 = 0;
~delta1 = 0;
~theta1 = 0;
~alpha2 = 0;
~beta2 = 0;
~gamma2 = 0;
~delta2 = 0;
~theta2 = 0;

c = TempoClock.new(base_tempo);//gamma
b = TempoClock.new(base_tempo);//beta
a = TempoClock.new(base_tempo);//alpha
h = TempoClock.new(base_tempo);//theta
d = TempoClock.new(base_tempo/8);//delta

b.schedAbs(b.beats.ceil,
	{beta_diff = abs(~beta1 - ~beta2);
	 beta_sel = (beta_diff*4).round(1);
	 if (beta_sel < 0, {beta_sel = 0}, {beta_sel = beta_sel});
	 if (beta_sel > 3, {beta_sel = 3}, {beta_sel = beta_sel});
	 //("new_beta_tempo: " ++ new_beta_tempo).postln;
	 b.tempo = beta_tempos[beta_sel];
	 n.noteOn(1, 12 + beta_notes.choose, vels.wchoose(vel_weights));
1});

h.schedAbs(h.beats.ceil,
	{theta_diff = abs(~theta1 - ~theta2);
	 if (theta_diff < 0.4, {new_theta_tempo = 0}, {new_theta_tempo = 1});
	 //("new_theta_tempo: " ++ new_theta_tempo).postln;
	 h.tempo = theta_tempos[new_theta_tempo];
	 p.allNotesOff(16);
	 p.noteOn(1, theta_notes.choose, vels.wchoose(vel_weights));

	 if (flag == true, {flag = false}, {flag = true});
	 if (flag,
		 {alpha_diff = abs(~alpha1 - ~alpha2);
          gamma_diff = abs(~gamma1 - ~gamma2);
	      alpha_sel = (alpha_diff*5).round(1);
	      if (alpha_sel < 0, {alpha_sel = 0}, {alpha_sel = alpha_sel});
	      if (alpha_sel > 4, {alpha_sel = 4}, {alpha_sel = alpha_sel});
	      ("alpha_sel: " ++ alpha_sel).postln;

		  gamma_sel = gamma_diff;
	      if (gamma_sel > 0.2, {gamma_sel = 0}, {gamma_sel = 1});

		  chord = chord_array[alpha_sel];

		  chord_vel = vels.wchoose(vel_weights);
		  o.allNotesOff(16);
	      o.noteOn(1, chord[0], chord_vel);
          o.noteOn(1, chord[1], chord_vel);
          o.noteOn(1, chord[2], chord_vel);
		  m.allNotesOff(16);
		  if ((gamma_sel == 1), {m.noteOn(1, 96, 100)}, {1});
	      ("gamma_sel: " ++ gamma_sel).postln;

		 },
	     1);
1});

d.schedAbs(d.beats.ceil,
	{muse1avg = (~alpha1 + ~beta1 + ~gamma1 + ~delta1 + ~theta1)/5;
	 muse2avg = (~alpha2 + ~beta2 + ~gamma2 + ~delta2 + ~theta2)/5;
	 great_diff = abs(muse1avg - muse2avg) * 170;
     if ((great_diff > 110), {great_diff = 110}, {great_diff = great_diff});
	 q.allNotesOff(16);
	 great_diff.postln;
	 q.noteOn(1, 60, 110 - (great_diff - 20));
1});


)

//post raw data
(
	("ALPHA 1: " ++ ~alpha1).postln;
	("BETA 1: " ++ ~beta1).postln;
	("GAMMA 1: " ++ ~gamma1).postln;
	("DELTA 1: " ++ ~delta1).postln;
	("THETA 1: " ++ ~theta1).postln;
    "--------------------------".postln;
	("ALPHA 2: " ++ ~alpha2).postln;
	("BETA 2: " ++ ~beta2).postln;
	("GAMMA 2: " ++ ~gamma2).postln;
	("DELTA 2: " ++ ~delta2).postln;
	("THETA 2: " ++ ~theta2).postln;
    "--------------------------".postln;
    ("ALPHA DIFF: " ++ abs(~alpha1 - ~alpha2)).postln;
	("BETA DIFF: " ++ abs(~beta1 - ~beta2)).postln;
	("GAMMA DIFF: " ++ abs(~gamma1 - ~gamma2)).postln;
	("DELTA DIFF: " ++ abs(~delta1 - ~delta2)).postln;
	("THETA DIFF: " ++ abs(~theta1 - ~theta2)).postln;
)