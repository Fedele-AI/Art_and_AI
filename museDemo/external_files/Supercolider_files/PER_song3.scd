//DENNIS FRANK & ALEX JENKINS
//MUSE EEG SUPERCOLIDER CODE
//SONG 3 (sensitive) FOR PERFv2 - REVISED IN 2025 FOR CEE4803/LMC4813.
//Copyright (c) GEORGIA INSTITUTE OF TECHNOLOGY. All rights reserved.

s.boot;
s.quit;
thisProcess.openUDPPort(57120);

OSCFunc.trace(true);
OSCFunc.trace(false);

MIDIClient.init()
MIDIClient.disposeClient

//gamma
m = MIDIOut(0);n = MIDIOut(1);o = MIDIOut(2);p = MIDIOut(3);q = MIDIOut(4);

m.noteOn(1, 68, 100); //test
m.allNotesOff(16)
n.noteOn(1, 68, 100); //test
n.allNotesOff(16)
o.noteOn(1, 75, 100); //test
o.allNotesOff(16)
p.noteOn(1, 75, 100); //test
p.allNotesOff(16)
q.noteOn(1, 62, 100); //test
q.allNotesOff(16)

/*//theta and alpha and gamma
m = MIDIOut(1);// CAREFUL: THIS CHANGES BETWEEN WINDOWS AND MAC
m.noteOn(1, 68, 100); //test
m.allNotesOff(16)

//beta1
n = MIDIOut(2);// CAREFUL: THIS CHANGES BETWEEN WINDOWS AND MAC
n.noteOn(1, 75, 100); //test
n.allNotesOff(16)

//DRUM (delta)
o = MIDIOut(3);// CAREFUL: THIS CHANGES BETWEEN WINDOWS AND MAC
o.noteOn(1, 62, 100); //test
o.allNotesOff(16)*/

//play that funky music
(
var base_tempo = 120; //CHANGE TEMPO

var new_beta_tempo;
var new_beta2_tempo;
var new_theta_tempo;
var beta_sel;
var alpha_sel;
var gamma_sel;
var vels = [70,80,95,105,110];
var vel_weights = [0.05,0.1,0.7,0.1,0.05];
var flag = true;

var chord_1 = [0,3,7];
var chord_2 = [0,3,7];
var chord_3 = [-2,2,5];
var chord_4 = [3,7,10];
var chord_5 = [5,8,12];
var chord_array = [chord_1, chord_2, chord_3, chord_4, chord_5];
var chord;
var chord_vel;

var sev_add = -8;
var extra_note;

var great_diff;
var muse1avg;
var muse2avg;

var beta_octave = 1;
var beta_tempos;
var beta_notes = (beta_octave * 12) + [33, 36, 38, 40, 43, 45, 48, 50, 52, 55];

var theta_tempos;
var theta_notes = [33, 36, 38, 40, 43];

var alpha_octave = 2;

var delta_scale = 0;

var x_counter = 0;
var y_counter = 0;
var z_counter = 0;
var x_beat = [true, true, true, true, true, true, true, true,
	     true, true, true, true, true, true, true, true,
	     true, true, true, true, true, true, true, true]; //hi-hat
var y_beat = [false, false, true, false, false, false, true, false,
	     false, false, true, false, false, false, true, false,
	     false, false, true, true, false, false, true, false]; //snare
var z_beat = [true, true, false, false, true, true, false, false,
	     true, true, false, true, false, true, false, false,
	     true, true, false, false, false, true, false, true]; //bass

var alpha_diff;
var beta_diff;
var gamma_diff;
var delta_diff;
var theta_diff;


base_tempo = base_tempo/60;

beta_tempos = [(base_tempo * 2), (base_tempo * 1), (base_tempo * 1), (base_tempo * 2)];
theta_tempos = [(base_tempo / 3), (base_tempo / 6)];

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

b = TempoClock.new(base_tempo);//melody1
c = TempoClock.new(base_tempo);//melody2
h = TempoClock.new(base_tempo / 3);//bass and harmony
x = TempoClock.new(base_tempo * 2);//hi-hat
y = TempoClock.new(base_tempo * 2);//snare
z = TempoClock.new(base_tempo * 2);//bass drum

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
	 p.noteOn(1, theta_notes.choose, vels.wchoose(vel_weights));

	 if (flag == true, {flag = false}, {flag = true});
	 if (flag,
		 {alpha_diff = abs(~alpha1 - ~alpha2);
          gamma_diff = abs(~gamma1 - ~gamma2);
	      alpha_sel = (alpha_diff*5).round(1);
	      if (alpha_sel < 0, {alpha_sel = 0}, {alpha_sel = alpha_sel});
	      if (alpha_sel > 4, {alpha_sel = 4}, {alpha_sel = alpha_sel});
	      //("alpha_sel: " ++ alpha_sel).postln;

		  gamma_sel = gamma_diff;
	      if (gamma_sel > 0.4, {gamma_sel = 0}, {gamma_sel = 1});
		  //("gamma_sel: " ++ gamma_sel).postln;
		  if (alpha_sel == 0, {sev_add = -9}, 1);
		  if (alpha_sel == 1, {sev_add = -9}, 1);
		  if (alpha_sel == 4, {sev_add = -9}, 1);
		  //("sev_add: " ++ sev_add).postln;

		  chord = chord_array[alpha_sel];
	      chord = chord + 33 + (alpha_octave * 12);

		  chord_vel = vels.wchoose(vel_weights);
	      o.noteOn(1, chord[0], chord_vel);
          o.noteOn(1, chord[1], chord_vel);
          o.noteOn(1, chord[2], chord_vel);
		  extra_note = chord[2] + sev_add;
	      //("chord: " ++ chord).postln;
		  //extra_note.postln;
		  if ((gamma_sel == 1), {m.noteOn(1, extra_note, 100)}, {1});

		  sev_add = -8;
		 },
	     1);
1});

x.schedAbs(x.beats.ceil,
	{muse1avg = (~alpha1 + ~beta1 + ~gamma1 + ~delta1 + ~theta1)/5;
	 muse2avg = (~alpha2 + ~beta2 + ~gamma2 + ~delta2 + ~theta2)/5;
	 great_diff = abs(muse1avg - muse2avg) * 170;
     if ((great_diff > 110), {great_diff = 110}, {great_diff = great_diff});
     if ((x_beat[x_counter % 24]), {q.noteOn(1, 71, 110 - great_diff)}, {1});
	 x_counter = x_counter + 1;
1});//hi-hat

y.schedAbs(y.beats.ceil,
	{muse1avg = (~alpha1 + ~beta1 + ~gamma1 + ~delta1 + ~theta1)/5;
	 muse2avg = (~alpha2 + ~beta2 + ~gamma2 + ~delta2 + ~theta2)/5;
	 great_diff = abs(muse1avg - muse2avg) * 170;
     if ((great_diff > 110), {great_diff = 110}, {great_diff = great_diff});
	 if ((y_beat[y_counter % 24]), {q.noteOn(1, 62, 110 - great_diff)}, {1});
	 y_counter = y_counter + 1;
1});//snare

z.schedAbs(z.beats.ceil,
	{muse1avg = (~alpha1 + ~beta1 + ~gamma1 + ~delta1 + ~theta1)/5;
	 muse2avg = (~alpha2 + ~beta2 + ~gamma2 + ~delta2 + ~theta2)/5;
	 great_diff = abs(muse1avg - muse2avg) * 170;
	 great_diff.postln;
     if ((great_diff > 110), {great_diff = 110}, {great_diff = great_diff});
	 if ((z_beat[z_counter % 24]), {q.noteOn(1, 60, 110 - great_diff)}, {1});
	 z_counter = z_counter + 1;
1});//bass


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