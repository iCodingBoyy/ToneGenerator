package com.libra.sinvoice;

public class SinApi implements com.libra.sinvoice.SinVoicePlayer.Listener {

	private SinVoicePlayer mSinVoicePlayer;
	private SinVoiceRecognition mRecognition;

	void initPlayer() {
		mSinVoicePlayer = new SinVoicePlayer(Common.DEFAULT_CODE_BOOK);
		mSinVoicePlayer.setListener(this);
	}

	void initReceiver() {
		mRecognition = new SinVoiceRecognition(Common.DEFAULT_CODE_BOOK);
	}

	public void play() {

	}

	public String receiver() {

		return null;
	}

	@Override
	public void onPlayStart() {
		// TODO Auto-generated method stub

	}

	@Override
	public void onPlayEnd() {
		// TODO Auto-generated method stub

	}
}
