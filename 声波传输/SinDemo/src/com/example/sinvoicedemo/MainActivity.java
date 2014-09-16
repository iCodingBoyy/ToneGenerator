package com.example.sinvoicedemo;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.libra.sinvoice.Common;
import com.libra.sinvoice.LogHelper;
import com.libra.sinvoice.SinVoicePlayer;
import com.libra.sinvoice.SinVoiceRecognition;

public class MainActivity extends Activity implements SinVoiceRecognition.Listener, SinVoicePlayer.Listener {
    private final static String TAG = "MainActivity";
    private final static int MAX_NUMBER = 5;
    private final static int MSG_SET_RECG_TEXT = 1;
    private final static int MSG_RECG_START = 2;
    private final static int MSG_RECG_END = 3;

    private final static String CODEBOOK = "01234";

    private Handler mHanlder;
    private SinVoicePlayer mSinVoicePlayer;
    private SinVoiceRecognition mRecognition;
    
    private EditText et;
    @Override
    protected void onCreate(Bundle savedInstanceState) 
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        et = (EditText) findViewById(R.id.input_send_content);
        mSinVoicePlayer = new SinVoicePlayer(CODEBOOK);
        mSinVoicePlayer.setListener(this);

        mRecognition = new SinVoiceRecognition(CODEBOOK);
        mRecognition.setListener(this);

        final TextView playTextView = (TextView) findViewById(R.id.playtext);
        TextView recognisedTextView = (TextView) findViewById(R.id.regtext);
        mHanlder = new RegHandler(recognisedTextView);

        Button playStart = (Button) this.findViewById(R.id.start_play);
        playStart.setOnClickListener(new OnClickListener()
        {
            @Override
            public void onClick(View arg0) 
            {
                String text = genText(7);
                playTextView.setText(text);
                mSinVoicePlayer.play(text);
            }
        });

        Button playStop = (Button) this.findViewById(R.id.stop_play);
        playStop.setOnClickListener(new OnClickListener()
        {
            @Override
            public void onClick(View arg0) 
            {
                mSinVoicePlayer.stop();
            }
        });

        Button recognitionStart = (Button) this.findViewById(R.id.start_reg);
        recognitionStart.setOnClickListener(new OnClickListener() 
        {
            @Override
            public void onClick(View arg0)
            {
                mRecognition.start();
            }
        });

        Button recognitionStop = (Button) this.findViewById(R.id.stop_reg);
        recognitionStop.setOnClickListener(new OnClickListener()
        {
            @Override
            public void onClick(View arg0) 
            {
                mRecognition.stop();
            }
        });
    }

    private String genText(int count) 
    {
        StringBuilder sb = new StringBuilder();
        String result = et.getText().toString();
        if (TextUtils.isEmpty(result))
        {
			return "";
		}
        result = Common.stringToAscii(result);
        String[] tmp = result.split(",");
        for (int i = 0; i < tmp.length; i++) 
        {
        	if (0 != i)
        	{
        		sb.append("2");
			}
        	sb.append(Common.toBinaryString(tmp[i]));
		}
        return sb.toString();
    }

    private static class RegHandler extends Handler 
    {
        private StringBuilder mTextBuilder = new StringBuilder();
        private TextView mRecognisedTextView;

        public RegHandler(TextView textView) 
        {
            mRecognisedTextView = textView;
        }

        @Override
        public void handleMessage(Message msg)
        {
            switch (msg.what) {
            case MSG_SET_RECG_TEXT:
                char ch = (char) msg.arg1;
                mTextBuilder.append(ch);
               
                break;

            case MSG_RECG_START:
                mTextBuilder.delete(0, mTextBuilder.length());
                break;

            case MSG_RECG_END:
            	 if (null != mRecognisedTextView) 
            	 {
            		 String text = mTextBuilder.toString();
            		 String[] tmp = text.split("2");
            		 StringBuilder sb = new StringBuilder();
            		 for (int i = 0; i < tmp.length; i++) {
						sb.append(Common.asciiToString(Common.toDecimal(tmp[i])));
					}
                     mRecognisedTextView.setText(sb.toString());
                 }
            	 mTextBuilder = new StringBuilder();
                LogHelper.d(TAG, "recognition end");
                break;
            }
            super.handleMessage(msg);
        }
    }

    @Override
    public void onRecognitionStart() 
    {
        mHanlder.sendEmptyMessage(MSG_RECG_START);
    }

    @Override
    public void onRecognition(char ch) 
    {
        mHanlder.sendMessage(mHanlder.obtainMessage(MSG_SET_RECG_TEXT, ch, 0));
    }

    @Override
    public void onRecognitionEnd() {
        mHanlder.sendEmptyMessage(MSG_RECG_END);
    }

    @Override
    public void onPlayStart() {
        LogHelper.d(TAG, "start play");
    }

    @Override
    public void onPlayEnd() {
        LogHelper.d(TAG, "stop play");
    }

}
