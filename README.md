# Vowel Comparison

Just a few `mp3`s and scripts for plotting my vowels. The inspiration behind the project was the [Golden Speaker Builder - An interactive tool for pronunciation training](https://doi.org/10.1016/j.specom.2019.10.005) paper from Ding et Al (2019). It's noted that:

> prior research indicates that second-language learners are more likely to succeed when they imitate a speaker with a voice similar to their own, a so-called "golden speaker"

I decided to create a "golden speaker" for myself using the Voice Cloning and Text-to-Speech from [ElevenLabs](https://elevenlabs.io/text-to-speech), and to investigate

1.  How well (based on my perception) the *ElevenLabs* voice cloning is able to sound like me
2.  How well the clone is able to generalise to another language while still sounding like me
3.  How statistically different the clone is to my own real voice, when speaking another language

## Introduction

Using *ElevenLabs* to create an Instant Voice clone of myself from English language audio, I generated `mp3`s of the Aesop's Fable *The North Wind and the Sun* (*Die Sonne und der Wind*) in German, using their `Eleven Multilingual v2` model. Additionally, I recorded actual audio of me reading out *Die Sonne und der Wind* in German.

I manually created `TextGrid`s of utterances for each `mp3`, creating boundaries
between each sentence.

Using *Montreal Forced Alignment* (*MFA*), I generated `TextGrid`s for each audio file, annotated with phones.

Using *Praat*, I analysed the *F1*, *F2*, and *F3* formants of the vowels, and exported them.

Using `ggplot2` and *R*, I plotted a bunch of graphs comparing my own vowel formants to those of the voice clone.

## Getting Started

```         
vowel-comparison
│   .gitignore
│   README.md
│
└───ElevenLabsMp3
│   │   ElevenLabs_..._pvc_s50_sb75_m1.mp3
│   │   ElevenLabs_..._pvc_s50_sb75_m1.TextGrid
|   |   ...
│   │
│   └───ElevenLabsAligned
│       │   ElevenLabs_..._pvc_s50_sb75_m1.TextGrid
│       │   ElevenLabs_..._pvc_s38_sb75_m1.TextGrid
│       │   ...
│   
└───txt
    │   nordwind.txt
```
