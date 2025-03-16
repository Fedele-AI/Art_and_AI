//DENNIS FRANK & ALEX JENKINS
//MUSE EEG SUPERCOLIDER CODE
//CONS/DISS - REVISED IN 2025 FOR CEE4803/LMC4813.
//Copyright (c) GEORGIA INSTITUTE OF TECHNOLOGY. All rights reserved.

s.boot;
s.quit;
thisProcess.openUDPPort(57120);

OSCFunc.trace(true);
OSCFunc.trace(false);

MIDIClient.init()
MIDIClient.disposeClient

m = MIDIOut(0);n = MIDIOut(1);o = MIDIOut(2);p = MIDIOut(3);q = MIDIOut(4);

m.allNotesOff(16); n.allNotesOff(16); o.allNotesOff(16); p.allNotesOff(16);
m.noteOn(1, 60, 100); //test
m.allNotesOff(16)
n.noteOn(1, 64, 100); //test
n.allNotesOff(16)
o.noteOn(1, 60, 100); //test
o.allNotesOff(16)
p.noteOn(1, 62, 100); //test
p.allNotesOff(16)
/*q.noteOn(1, 62, 100); //test
q.allNotesOff(16)*/

//play that funky music
(

var base_tempo = 240; //CHANGE TEMPO

var root_notes = [60, 60, 60, 67, 60, 60, 60, 64, 60, 62, 60, 60, 60];
var harm_notes = [72, 72, 67, 72, 64, 69, 63, 72, 62, 72, 61, 71, 66];

var root_shift = [60, 60, 60, 67, 60, 60, 60, 64, 60, 62, 60, 60, 60];
var harm_shift = [72, 72, 67, 72, 64, 69, 63, 72, 62, 72, 61, 71, 66];

var keys = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
var key_tempos = [(base_tempo/4096), (base_tempo/2048), (base_tempo/1024), (base_tempo/512)];
var h_sel;
var key = 0;

var muse1avg;
var alpha_diff;
var beta_diff;
var gamma_diff;
var theta_diff;
var delta_diff;
var total_diff;

var diff_sel;
var diff_note_root;
var diff_note_harm;

var y_counter;
var z_counter;
var y_beat = [false, false, false, false, true, false, false, true,
	     false, true, false, false, true, false, false, false]; //snare
var z_beat = [true, false, true, false, false, false, true, false,
	     true, false, true, false, false, false, true, false]; //bass

y_counter = 0;
z_counter = 0;

base_tempo = base_tempo/60;

//beta_tempos = [(base_tempo * 2), (base_tempo * 1), (base_tempo * 0.5), (base_tempo * 0.25)];
//theta_tempos = [(base_tempo * 0.125), (base_tempo / 16)];

//HEADSET with path: /eeg/
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

d = TempoClock.new(base_tempo);
x = TempoClock.new(base_tempo / 4);
y = TempoClock.new(base_tempo * 2);
z = TempoClock.new(base_tempo * 2);
h = TempoClock.new(base_tempo / 32);

d.schedAbs(d.beats.ceil,
	{muse1avg = (~alpha1 + ~theta1)/2;
     alpha_diff = abs(~alpha1 - muse1avg);
     theta_diff = abs(~theta1 - muse1avg);

	 total_diff = alpha_diff + theta_diff;

		// (total_diff * 6).postln;

     diff_sel = (total_diff*6).round(1);
	 if (diff_sel < 0, {diff_sel = 0}, {diff_sel = diff_sel});
	 if (diff_sel > 12, {diff_sel = 12}, {diff_sel = diff_sel});

	 diff_note_root = root_shift[diff_sel];
	 diff_note_harm = harm_shift[diff_sel];

		(diff_sel).postln;
		// (diff_note_root).postln;
		// (diff_note_harm).postln;
		// ((~gamma1 + 0.5) * 3).postln;
		// ().postln;

     m.noteOn(1, diff_note_root, muse1avg * 200);
     p.noteOn(1, diff_note_harm, muse1avg * 200);

     //if ((great_diff > 110), {great_diff = 110}, {great_diff = great_diff});
	 //q.allNotesOff(16);
	 //great_diff.postln;
	 //q.noteOn(1, 60, 110 - (great_diff - 20));
1});

//change key
o.noteOn(1, 60, ((~alpha1 + ~beta1 + ~gamma1 + ~delta1 + ~theta1)/5) * 160);

h.schedAbs(h.beats.ceil,
	{h_sel = ((~gamma1 + 0.5) * 3).round(1);
	 if (h_sel < 0, {h_sel = 0}, {h_sel = h_sel});
	 if (h_sel > 3, {h_sel = 3}, {h_sel = h_sel});
	 h.tempo = key_tempos[h_sel];

	 key = keys.choose;

	 root_shift = root_notes + key;
	 harm_shift = harm_notes + key;

	 // ambience
	 o.noteOn(1, 60 + key, ((~alpha1 + ~beta1 + ~gamma1 + ~delta1 + ~theta1)/5) * 160);
	 (((~alpha1 + ~beta1 + ~gamma1 + ~delta1 + ~theta1)/5) * 160).postln;

	 (key).postln;
	 (h_sel).postln;

		().postln;
1});

x.schedAbs(x.beats.ceil,
	{o.noteOn(1, 60 + key, ((~alpha1 + ~beta1 + ~gamma1 + ~delta1 + ~theta1)/5) * 160);

1});//ambience


y.schedAbs(y.beats.ceil,
	{if ((y_beat[y_counter % 16]), {n.noteOn(1, 64, ~delta1 * 80)}, {1});
	 y_counter = y_counter + 1;
1});//snare

z.schedAbs(z.beats.ceil,
	{if ((z_beat[z_counter % 16]), {n.noteOn(1,60, ~delta1 * 80)}, {1});
	 z_counter = z_counter + 1;
1});//bass
/*
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

*/

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