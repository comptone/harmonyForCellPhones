import android.media.*;
import android.view.WindowManager;
import android.view.View;
import android.os.Bundle;
import android.media.AudioManager;
import android.speech.tts.TextToSpeech;

import android.speech.tts.TextToSpeech.OnInitListener;
import android.media.MediaPlayer.OnPreparedListener;
import android.content.res.*;
int frequency;
static String OAuthConsumerKey = "";
static String OAuthConsumerSecret = "";
// This is where you enter your Access Token info
static String AccessToken = "";
static String AccessTokenSecret = "";
TwitterStream twitter = new TwitterStreamFactory().getInstance();
FilterQuery query = new FilterQuery();
PlaySound sineOne = new PlaySound();
PlaySound sineTwo = new PlaySound();
TextToSpeech tts;
MediaPlayer player;
PImage satellite;
String scannerString ="";
String tweet = "... ";
int numTweets = 1;
int  ms;
int ms2;
int ms3;
int heightmult;
int delayTime = 10000;
boolean on = false;
String policeScanner = "http://audio2.radioreference.com/il_chicago_police2";
String keywords[] = { "gov", "NSA", "privacy", "security", "america", "government", "peace", "brutality", "killing", "siren",  "police", "cop", "officer", "gun", "shots fired"
};
double[][]locations = {{-87.940267,41.644335 }, {-87.524044, 42.023131}};

void setup(){

 ms = millis();
 ms2 = millis();
 ms3 = millis();
 tts = new TextToSpeech(this, new TextToSpeech.OnInitListener() {

        public void onInit(int status) {

            if(status != TextToSpeech.ERROR) 
            {

                tts.setPitch(1f); 

                tts.setSpeechRate(0.6f); 

                //tts.setLanguage(Locale.US);
            }

        }
    });
  size(displayWidth, displayHeight);
  heightmult = displayHeight/15;
  satellite = loadImage("satellite.jpg");
  satellite.resize(displayWidth-20,0);
  sineOne.genTone(120);
  sineTwo.genTone(300);
  player = new MediaPlayer();
  try{
  player.setDataSource(policeScanner);
  player.prepareAsync();
  player.setOnPreparedListener(new OnPreparedListener(){
    public void onPrepared(MediaPlayer player){
      player.start();
    }
  });
  player.setAudioStreamType(AudioManager.STREAM_MUSIC);
  }
  catch(IOException e){
    
   scannerString = "could not fetch police scanner stream";
      tts.speak(scannerString,1,null);
  }
  
  connectTwitter();
  twitter.addListener(listener);
 query.locations(locations);

  twitter.filter(query);
  
}
void draw(){
  background(0);
  textSize(20);
  text("chicago", 20, heightmult);
  text(scannerString, 20, (heightmult*2));
  text(numTweets, 20,(heightmult*3));
  text(tweet, 20, (height*4), displayWidth-30, (displayHeight/2)-30);
 // imageMode(CORNERS);
  image(satellite, 10, displayHeight/2);
  
  
  //resets the tweet counter every ten seconds
  if(millis()-ms3>delayTime){
    numTweets =1;
   ms3= millis();
    println("Reset NumTweets...");
  }
   float time2 = random(1500,7000);
  int numtime =   abs(int(time2)- (numTweets*numTweets*numTweets));
   if(millis()-ms2>numtime){    
    float r2 = random(60,250);
      frequency = int(r2 );
      sineTwo.genTone(frequency);
      println("wave 2 is " + frequency + "numTweets is " + numTweets + "time is " + numtime);
  // wave.setFrequency( ms*(ms%100) );
   ms2=millis();
  }
  float time = random(1000,3000);
  //1 every 1-3 seconds at random, using the numtweets to change the pitch
  if(millis()-ms>int(time)){
    float r = random(100,200);
      frequency = int(r);
      sineOne.genTone((40*(numTweets/2)));
      
      println("wave 1 is " + frequency+ "... time is " + time+ "numTweets is " + numTweets );
  // wave.setFrequency( ms*(ms%100) );
   ms=millis();
  }
     
  if (mousePressed) { 
    delay(100);
    if (on) {
      on=false;
      sineOne.playSound(false);
      sineTwo.playSound(false);
      print("off");
    }
    else {
      on=true;      
      sineOne.playSound(true);
      sineTwo.playSound(true);
      print("on");
    }
  }
}
  
 
  //this class is adapted from "julienrat" on the processing forums
  public class PlaySound {
  private final int sampleRate = 8000;
  private final int numSamples = sampleRate;
  private final double samples[] = new double[numSamples];
  private final byte generatedSnd[] = new byte[2*(numSamples)];
 
  final AudioTrack audioTrack = new AudioTrack(AudioManager.STREAM_MUSIC, 
  sampleRate, AudioFormat.CHANNEL_CONFIGURATION_MONO, 
  AudioFormat.ENCODING_PCM_16BIT, numSamples, 
  AudioTrack.MODE_STATIC);
 
  void genTone(double freqOfTone) {
    // fill out the array
 
    for (int i = 0; i < numSamples; ++i) {
      samples[i] = Math.sin(2 * Math.PI * i / (sampleRate/freqOfTone));
    }
    // convert to 16 bit pcm sound array
    // assumes the sample buffer is normalised.
    int idx = 0;
    for (double dVal : samples) {
      // scale to maximum amplitude
      short val = (short) ((dVal * 32767));
      // in 16 bit wav PCM, first byte is the low order byte
      generatedSnd[idx++] = (byte) (val & 0x00ff);
      generatedSnd[idx++] = (byte) ((val & 0xff00) >>> 8);
    }
    audioTrack.write(generatedSnd, 0, numSamples*2);
    audioTrack.setLoopPoints(0, numSamples/2, -1);
  }
 
  void playSound(boolean on) {
    if (on) {
 
      audioTrack.play();
    }
    else {
      audioTrack.pause();
    }
  }
}

void connectTwitter() {
  twitter.setOAuthConsumer(OAuthConsumerKey, OAuthConsumerSecret);
  AccessToken accessToken = loadAccessToken();
  twitter.setOAuthAccessToken(accessToken);
}

private static AccessToken loadAccessToken() {
  return new AccessToken(AccessToken, AccessTokenSecret);
}

StatusListener listener = new StatusListener() {
  public void onStatus(Status status) {
    numTweets = numTweets+1;
    for(int i=0; i<keywords.length; i++){
    if(status.getText().toLowerCase().contains(keywords[i])){
      tweet=status.getText();
      println(" - " + status.getText());
      sineTwo.genTone(440);
      tts.speak(tweet,1,null);
      
    break;
    }
  }
  }
  
  void onStallWarning(StallWarning stall){
    
    System.exit(-1);
  }
  public void onDeletionNotice(StatusDeletionNotice statusDeletionNotice) {
    System.out.println("Got a status deletion notice id:" + statusDeletionNotice.getStatusId());
  }
  public void onTrackLimitationNotice(int numberOfLimitedStatuses) {
    //  System.out.println("Got track limitation notice:" + numberOfLimitedStatuses);
  }
  public void onScrubGeo(long userId, long upToStatusId) {
    System.out.println("Got scrub_geo event userId:" + userId + " upToStatusId:" + upToStatusId);
  }

  public void onException(Exception ex) {
    ex.printStackTrace();
  }
};

void onCreate(Bundle bundle) 
{
  super.onCreate(bundle);
  // fix so screen doesn't go to sleep when app is active
  getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
}

