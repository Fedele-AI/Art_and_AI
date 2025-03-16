//DENNIS FRANK & ALEX JENKINS
//MUSE EEG SUPERCOLIDER CODE
//BELL SONG - REVISED IN 2025 FOR CEE4803/LMC4813.
//Copyright (c) GEORGIA INSTITUTE OF TECHNOLOGY. All rights reserved.

s.boot;
s.quit;
thisProcess.openUDPPort(57120);

OSCFunc.trace(true);
OSCFunc.trace(false);

MIDIClient.init()
MIDIClient.disposeClient

n = MIDIOut(0)
o = MIDIOut(1)
p = MIDIOut(2)

n.noteOn(1, 49, 100); //test
n.allNotesOff(16)

o.noteOn(1, 54, 100); //test
o.allNotesOff(16)

p.noteOn(1, 61, 30); //test
p.allNotesOff(16)

//play that funky music
(
var base_tempo = 55/60; //CHANGE TEMPO
var multiplier = 2; // CHANGE HOW RESPONSIVE PROGRAM IS

var vels = [25,50,80,110,120];
var vel_weights = [0.05,0.1,0.7,0.1,0.05];
var beta_notes = [49, 50, 53, 54, 55, 57, 60, 61];
var beta_weights = [0.5,0.05,0.05,0.05,0.05,0.05,0.05,0.2];
var beta_sel;
var beta_tempos = [(base_tempo / 16), (base_tempo / 8), (base_tempo * 2), (base_tempo * 4)];
var tempo_multipliers = [0.95,0.98,1,1.02,1.05];
var tempo_multiplier_weights = [0.05,0.1,0.7,0.1,0.05];

var keep_note = false;
var my_note;
var counter = 0;
var beta_sel_keep;

var alpha_sel;

var fifty_fifty = [true, false, false];
var p_note = 49;

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
~beta1 = 0;
~alpha1 = 0;
~delta1 = 0;

b = TempoClock.new(base_tempo);//beta

b.schedAbs(b.beats.ceil,
	{//beta stuff
	 beta_sel = (~beta1*2.4*multiplier) + 0.12; //2.4*x + 0.12
	 beta_sel = beta_sel.round(1);
		// (~beta1).postln;
	 if (beta_sel < 0, {beta_sel = 0}, {beta_sel = beta_sel});
	 if (beta_sel > 3, {beta_sel = 3}, {beta_sel = beta_sel});
	 if (keep_note == true, {beta_sel = beta_sel_keep}, {1});
	 //("new_beta_tempo: " ++ new_beta_tempo).postln;
		// (beta_sel).postln;
		(~delta1).postln;
	 //alpha stuff
	 alpha_sel = (~alpha1*2.4) + 0.12;
	 alpha_sel = alpha_sel.round(1);
/*		(alpha_sel).postln;
		(~alpha1).postln;*/
	 if (alpha_sel <= 1, {alpha_sel = 0}, {alpha_sel = alpha_sel});
	 if (alpha_sel > 1, {alpha_sel = 1}, {alpha_sel = alpha_sel});
		// if (alpha_sel == 1, {o.noteOn(1, 54, vels.wchoose(vel_weights))}, {1});
	 // play beta
	 if (beta_sel == 0, {if (fifty_fifty.choose, {p.allNotesOff(16); p.noteOn(1, p_note, 64*~delta1+33);}, {1}); if (alpha_sel == 1, {o.noteOn(1, 54, vels.wchoose(vel_weights))}, {1}); b.tempo = beta_tempos[beta_sel];n.noteOn(1, beta_notes.wchoose(beta_weights), vels.wchoose(vel_weights));} , {
			if ( beta_sel == 1, {if (fifty_fifty.choose, {p.allNotesOff(16); p.noteOn(1, p_note, 64*~delta1+33);}, {1}); if (alpha_sel == 1, {o.noteOn(1, 54, vels.wchoose(vel_weights))}, {1}); b.tempo = beta_tempos[beta_sel];n.noteOn(1, beta_notes.wchoose(beta_weights), vels.wchoose(vel_weights));}, {
				if ( beta_sel == 2, {
				if (counter == 0, {
					if (fifty_fifty.choose, {p.allNotesOff(16); p.noteOn(1, p_note, 64*~delta1+33);}, {1});
					if (alpha_sel == 1, {o.noteOn(1, 54, vels.wchoose(vel_weights))}, {1});
					beta_sel_keep = beta_sel;
					keep_note = true;
					b.tempo = beta_tempos[beta_sel];
					my_note = beta_notes.wchoose(beta_weights);
					counter = counter + 1;
					n.noteOn(1, my_note, vels.wchoose(vel_weights));
				}, {
					if (counter == 3, {
						keep_note = false;
						counter = 0;
						b.tempo = b.tempo * tempo_multipliers.wchoose(tempo_multiplier_weights);
						n.noteOn(1, my_note, vels.wchoose(vel_weights));
					}, {
						counter = counter + 1;
						b.tempo = b.tempo * tempo_multipliers.wchoose(tempo_multiplier_weights);
						n.noteOn(1, my_note, vels.wchoose(vel_weights));
					})
				})
			} ,{  if (counter == 0, {
					if (fifty_fifty.choose, {p.allNotesOff(16); p.noteOn(1, p_note, 64*~delta1+33);}, {1});
					if (alpha_sel == 1, {o.noteOn(1, 54, vels.wchoose(vel_weights))}, {1});
					beta_sel_keep = beta_sel;
					keep_note = true;
					b.tempo = beta_tempos[beta_sel];
					my_note = beta_notes.wchoose(beta_weights);
					counter = counter + 1;
					n.noteOn(1, my_note, vels.wchoose(vel_weights));
				}, {
					if (counter == 7, {
						keep_note = false;
						counter = 0;
						b.tempo = b.tempo * tempo_multipliers.wchoose(tempo_multiplier_weights);
						n.noteOn(1, my_note, vels.wchoose(vel_weights));
					}, {
						counter = counter + 1;
						b.tempo = b.tempo * tempo_multipliers.wchoose(tempo_multiplier_weights);
						n.noteOn(1, my_note, vels.wchoose(vel_weights));
					})
				})
			})
		});
	});
1});

)