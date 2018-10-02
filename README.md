# SSNoiseReduction: automatic noise reduction from recorded speech
## Example
```
library(tuneR)
library(vadeR)
library(audio2specgram)
library(SSNoiseReduction)


x <- readWave("noisyvoice.wav")
y <- SSNoiseReduction(x)
play(y)
```

## Requires:
tuneR (from CRAN)
vadeR [https://github.com/akinori-ito/vadeR](https://github.com/akinori-ito/vadeR)
audio2specgram [https://github.com/akinori-ito/audio2specgram](https://github.com/akinori-ito/audio2specgram)
