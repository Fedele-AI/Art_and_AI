# -*- coding: utf-8 -*-
"""
demo.py
Estimate Relaxation from Band Powers of the Muse2 EEG with Real-time Visualization

A note from the author: This script is a VERY simple example.
It is meant to provide a basic understanding of how to estimate
relaxation from EEG data and visualize band powers in real-time.

It is not a medical tool and should not be used as such.
It is intended for educational purposes only.

Adapted from https://github.com/NeuroTechX/bci-workshop,
& https://github.com/alexandrebarachant/muse-lsl/blob/master/examples/

Modified by: Alex Jenkins (https://alexj.io) - for CEE4803/LMC4813 - (c) Georgia Tech, Spring 2025.
"""
import numpy as np
import matplotlib.pyplot as plt
from pylsl import StreamInlet, resolve_byprop
import sys
import utils
import tkinter as tk
from pythonosc import udp_client

# Initialize OSC client 
client = udp_client.SimpleUDPClient("127.0.0.1", 57120)

# Enum class for band power - DO NOT TOUCH!
class Band:
    Delta = 0
    Theta = 1
    Alpha = 2
    Beta = 3

# PARAMETERS - DO NOT TOUCH!
BUFFER_LENGTH = 2
EPOCH_LENGTH = 1
OVERLAP_LENGTH = 0.8
SHIFT_LENGTH = EPOCH_LENGTH - OVERLAP_LENGTH
INDEX_CHANNEL = [0]

def stream_eeg_values(alpha, beta, delta, theta):
    """Send EEG values to SuperCollider via OSC."""
    client.send_message("/eeg/alpha", alpha)
    client.send_message("/eeg/beta", beta)
    client.send_message("/eeg/delta", delta)
    client.send_message("/eeg/theta", theta)

def connect_to_eeg_stream():
    """Connect to the EEG stream and return the StreamInlet and sampling frequency."""
    print('Looking for an EEG stream...')
    streams = resolve_byprop('type', 'EEG', timeout=2)
    if len(streams) == 0:
        raise RuntimeError('Can\'t find EEG stream.')

    print("Start acquiring data")
    inlet = StreamInlet(streams[0], max_chunklen=12)
    info = inlet.info()
    fs = int(info.nominal_srate())
    return inlet, fs

def initialize_buffers(fs):
    """Initialize EEG and band power buffers."""
    eeg_buffer = np.zeros((int(fs * BUFFER_LENGTH), 1))
    filter_state = None
    n_win_test = int(np.floor((BUFFER_LENGTH - EPOCH_LENGTH) / SHIFT_LENGTH + 1))

    try:
        band_buffer = np.zeros((n_win_test, 4))
    except ValueError:
        print("Error: Headset is not connected or malfunctioning.")
        sys.exit(1)

    return eeg_buffer, filter_state, band_buffer

def acquire_data(inlet, fs, eeg_buffer, filter_state):
    """Acquire EEG data from the stream and update the EEG buffer."""
    try:
        eeg_data, timestamp = inlet.pull_chunk(timeout=1, max_samples=int(SHIFT_LENGTH * fs))
        ch_data = np.array(eeg_data)[:, INDEX_CHANNEL]
        eeg_buffer, filter_state = utils.update_buffer(eeg_buffer, ch_data, notch=True, filter_state=filter_state)
        return eeg_buffer, filter_state
    except IndexError:
        print("Error: EEG device disconnected. Attempting to reconnect...")
        return None, None

def compute_band_powers(eeg_buffer, fs, band_buffer):
    """Compute band powers from the EEG buffer and update the band buffer."""
    data_epoch = utils.get_last_data(eeg_buffer, EPOCH_LENGTH * fs)
    band_powers = utils.compute_band_powers(data_epoch, fs)
    band_buffer, _ = utils.update_buffer(band_buffer, np.asarray([band_powers]))
    smooth_band_powers = np.mean(band_buffer, axis=0)
    return band_powers, smooth_band_powers

def on_closing():
    """Ensure that closing the Tkinter window terminates the script."""
    print("Closing the application...")
    plt.close('all')
    root.destroy()
    sys.exit(0)

root = tk.Tk()
root.title("EEG Visualization")
root.geometry("800x600")
root.protocol("WM_DELETE_WINDOW", on_closing)

def main_loop(inlet, fs, eeg_buffer, filter_state, band_buffer):
    """Main loop to acquire data, compute band powers, and display live graph."""
    plt.ion()
    fig, axs = plt.subplots(4, 1, figsize=(10, 8), sharex=True)
    fig.suptitle('Real-time EEG Band Powers')
    bands = ['Delta', 'Theta', 'Alpha', 'Beta']
    colors = ['blue', 'green', 'red', 'purple']
    lines = []

    for i, ax in enumerate(axs):
        line, = ax.plot([], [], label=bands[i], color=colors[i])
        ax.legend(loc='upper right')
        ax.set_ylabel('Power')
        ax.set_ylim(-3, 3)
        lines.append(line)
    axs[-1].set_xlabel('Time (samples)')
    plt.tight_layout()

    max_data_points = 50
    delta_data, theta_data, alpha_data, beta_data = [], [], [], []

    print('Press Ctrl-C in the console to break the while loop.')
    try:
        while True:
            eeg_buffer, filter_state = acquire_data(inlet, fs, eeg_buffer, filter_state)
            if eeg_buffer is None:
                continue

            band_powers, smooth_band_powers = compute_band_powers(eeg_buffer, fs, band_buffer)

            print(f'Delta: {band_powers[Band.Delta]:.2f}  Theta: {band_powers[Band.Theta]:.2f} '
                  f'Alpha: {band_powers[Band.Alpha]:.2f}  Beta: {band_powers[Band.Beta]:.2f}')

            delta_data.append(band_powers[Band.Delta])
            theta_data.append(band_powers[Band.Theta])
            alpha_data.append(band_powers[Band.Alpha])
            beta_data.append(band_powers[Band.Beta])

            stream_eeg_values(band_powers[Band.Delta], band_powers[Band.Alpha], band_powers[Band.Alpha], band_powers[Band.Beta])

            for data in [delta_data, theta_data, alpha_data, beta_data]:
                if len(data) > max_data_points:
                    data.pop(0)

            x = list(range(len(delta_data)))
            for i, line in enumerate(lines):
                y = [delta_data, theta_data, alpha_data, beta_data][i]
                line.set_xdata(x)
                line.set_ydata(y)
                axs[i].relim()
                axs[i].autoscale_view()

            plt.draw()
            plt.pause(0.001)
            root.update()

    except KeyboardInterrupt:
        print('Closing!')
        on_closing()

if __name__ == "__main__":
    try:
        inlet, fs = connect_to_eeg_stream()
        eeg_buffer, filter_state, band_buffer = initialize_buffers(fs)
        main_loop(inlet, fs, eeg_buffer, filter_state, band_buffer)
    except RuntimeError as e:
        print(f"Error: {e}")
        print("This script requires an LSL stream from a MUSE device.")
        sys.exit(1)