/*
 * Copyright (C) 2013 gujicheng
 * 
 * Licensed under the GPL License Version 2.0;
 * you may not use this file except in compliance with the License.
 * 
 * If you have any question, please contact me.
 * 
 *************************************************************************
 **                   Author information                                **
 *************************************************************************
 ** Email: gujicheng197@126.com                                         **
 ** QQ   : 29600731                                                     **
 ** Weibo: http://weibo.com/gujicheng197                                **
 *************************************************************************
 */
package com.libra.sinvoice;

import java.math.BigInteger;

public class Common {
	public final static int START_TOKEN = 5;
	public final static int STOP_TOKEN = 6;
	public final static String DEFAULT_CODE_BOOK = "01234";

	public final static int DEFAULT_BUFFER_SIZE = 4096;
	public final static int DEFAULT_BUFFER_COUNT = 3;
	public final static int DEFAULT_SAMPLE_RATE = 44100;

	/**
	 * 转换为二进制， 默认入参为十进制
	 * 
	 * @param value
	 * @return
	 */
	public static String toBinaryString(String value) {
		BigInteger bigInteger = new BigInteger(value);
		return bigInteger.toString(2);
	}

	/**
	 * 转换为十进制，默认入参为二进制
	 * 
	 * @param value
	 * @return
	 */
	public static String toDecimal(String value) {
		BigInteger bigInteger = new BigInteger(value, 2);
		return bigInteger.toString();
	}

	public static String asciiToString(String value) {
		StringBuffer sbu = new StringBuffer();
		String[] chars = value.split(",");
		for (int i = 0; i < chars.length; i++) {
			sbu.append((char) Integer.parseInt(chars[i]));
		}
		return sbu.toString();
	}

	public static String stringToAscii(String value) {
		StringBuffer sbu = new StringBuffer();
		char[] chars = value.toCharArray();
		for (int i = 0; i < chars.length; i++) {
			if (i != chars.length - 1) {
				sbu.append((int) chars[i]).append(",");
			} else {
				sbu.append((int) chars[i]);
			}
		}
		return sbu.toString();
	}
}
