# Enforce a UTF-8 Local
import locale
locale.getpreferredencoding = lambda: "UTF-8"

import google.generativeai as genai
import IPython
from IPython.display import display, Audio
import soundfile as sf
import textwrap
import numpy as np  # For concatenating audio arrays

# TTS-Engine Setup:
!pip install -q kokoro>=0.3.4 soundfile
from kokoro import KPipeline
pipeline = KPipeline(lang_code='a')

# Flexible API key loading (Colab secrets or local file)
try:
    # Try Colab secrets first
    from google.colab import userdata
    GEMINI_API_KEY = userdata.get('GOOGLE_API_KEY')
except (ImportError, KeyError):
    # Fallback to local file
    try:
        with open('key.txt', 'r') as file:
            GEMINI_API_KEY = file.read().strip()
    except FileNotFoundError:
        raise ValueError("No API key found. Add to Colab secrets or create key.txt file")

genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel('gemini-pro')

# Story length slider
max_length_slider = widgets.IntSlider(
    value=200,
    min=100,
    max=800,
    step=50,
    description='Max Length (words):',
    continuous_update=False
)

# Temperature slider
temperature_slider = widgets.FloatSlider(
    value=0.5,
    min=0.1,
    max=1.0,
    step=0.1,
    description='Temperature:',
    continuous_update=False
)

# Display sliders in the notebook
display(max_length_slider)
display(temperature_slider)

def generate_tts_audio(input_text):
    generator = pipeline(
        input_text, voice='af_heart',
        speed=1, split_pattern=r'\n+'
    )

    # Initialize an empty list to store audio chunks
    audio_chunks = []

    for i, (gs, ps, audio) in enumerate(generator):
        # Append each audio chunk to the list
        audio_chunks.append(audio)

    # Concatenate all audio chunks into a single array
    full_audio = np.concatenate(audio_chunks)

    # Save the full audio as a single WAV file
    sf.write('output.wav', full_audio, 24000)

    # Display the full audio in the notebook
    display(Audio(data=full_audio, rate=24000, autoplay=True))

def generate_story(user_prompt):
    system_prompt = f"""You are a professional storyteller who loves Georgia Tech. Write a VERY SHORT story (under {max_length_slider.value} words) based on the user's query.
                        - MUST take place on Georgia Tech's campus
                        - MUST involve campus environment, culture, or community
                        - MUST have clear beginning and end
                        - NO internal thoughts/explanations/commentary
                        - ONLY output the story, nothing else"""

    response = model.generate_content(
        f"{system_prompt}\n\nUser Query: {user_prompt}\n\nStory:",
        generation_config=genai.types.GenerationConfig(
            temperature=temperature_slider.value,  # Use the slider value for temperature
            max_output_tokens=int(max_length_slider.value * 1.5)  # Convert words to tokens
        )
    )

    # Get cleaned story text
    story_text = response.text.strip()

    # Remove any markdown formatting
    clean_story = story_text.replace('**', '').replace('*', '').strip()

    # Print and process for TTS
    print("\nGenerated Story:\n", textwrap.fill(clean_story, width=120))

    if clean_story:
        generate_tts_audio(clean_story)