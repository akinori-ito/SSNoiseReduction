#library(tuneR)
#library(vadeR)
#library(audio2specgram)

subspec <- function(sigspec,noisespec,alpha,beta) {
  y <- rep(0,length(sigspec))
  for (i in 1:length(sigspec)) {
    x <- sigspec[i]-alpha*noisespec[i]
    if (x < 0) {
      x <- beta*sigspec[i]
    }
    y[i] <- x
  }
  y
}

#' SSNoiseReduction: Automatic Noise Reduction using Spectral Subtraction
#' @param x a Wave object
#' @param windowWidth width of the analysis window (in sec)
#' @param alpha alpha parameter of SS
#' @param beta beta parameter of SS
#' @return a Wave object of noise-reduced signal
#' @importFrom vadeR voiceActivity
#' @importFrom tuneR channel
#' @importFrom audio2specgram audio2specgram specgram2audio sinewin
#' @export SSNoiseReduction

SSNoiseReduction <- function(x,windowwidth=0.02,alpha=1,beta=0.001,simple=TRUE,nclust=4,do_normalize=FALSE) {
  winlen <- as.integer(x@samp.rate*windowwidth)
  if (winlen %% 2 == 1) {
    winlen <- winlen+1
  }
# frame shift
  nshift <- winlen/2

# VAD
  minlen <- 16
  repeat {
    vad <- vadeR::voiceActivity(channel(x,"left"),simple=simple,frameshift=windowwidth/2,nclust=nclust,minlen=minlen)
    if (length(vad) != sum(vad)) {
      # silent segment found
      break
    }
    minlen <- as.integer(minlen/2)
  }

# convert to spectrogram
  conf <- audio2specgram::stftconfig(winlen,nshift,sinewin,sinewin)
  spec <- audio2specgram::audio2specgram(x@left,conf)
  pspec <- Re(spec*Conj(spec))
  aspec <- spec/(sqrt(pspec)+0.000001)
# noise configuration
  noise <- colMeans(pspec[!vad,])
# spectral subtraction
  for (i in 1:nrow(pspec)) {
    pspec[i,] <- subspec(pspec[i,],noise,alpha,beta)
  }

# create complex spectrum
  aspec <- aspec*sqrt(pspec)

# back to time sequence
  y <- audio2specgram::specgram2audio(aspec,conf)
# normalize of needed
  if (do_normalize) {
    vframes <- vadeR::voiceSegment(vad)
    to_max <- 2^(x@bit-1)
    for (i in 1:nrow(vframes)) {
      spos <- vframes$begin[i]*x@samp.rate/100
      epos <- vframes$end[i]*x@samp.rate/100
      cur_max <- max(abs(y[spos:epos]))
      y[spos:epos] <- y[spos:epos]/cur_max*to_max
    }
  }
  Wave(y,samp.rate=x@samp.rate,bit=x@bit)
}


