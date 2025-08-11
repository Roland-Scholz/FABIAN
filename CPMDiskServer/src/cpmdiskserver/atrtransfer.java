package cpmdiskserver;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Enumeration;

import purejavacomm.CommPortIdentifier;
import purejavacomm.NoSuchPortException;
import purejavacomm.PortInUseException;
import purejavacomm.SerialPort;
import purejavacomm.UnsupportedCommOperationException;

public class atrtransfer {
	private SerialPort mSerialPort;
	InputStream serin;
	OutputStream serout;
	byte[] atrHeader = new byte[16];
	int atrsize;
	int secsize;
	int secnum;

	public static void main(String[] args)
			throws NoSuchPortException, PortInUseException, UnsupportedCommOperationException, IOException {
		new atrtransfer(args);

	}

	private int getByte(byte i) {
		return i & 0xff;
	}

	private int getWord(byte[] bs, int i) {
		return getByte(bs[i]) + (bs[i + 1] << 8);
	}

	private void waitStart() throws IOException {
		byte[] inb = new byte[1];

		while (true) {
			serin.read(inb);
			if (inb[0] == 'S')
				break;
		}
	}

	private void waitAck() throws IOException {
		byte[] inb = new byte[1];

		while (true) {
			serin.read(inb);
			if (inb[0] == 'A')
				break;
		}
	}

	private void openPort(String portname)
			throws NoSuchPortException, PortInUseException, UnsupportedCommOperationException, IOException {

		System.out.println("open port " + portname);

		Enumeration<CommPortIdentifier> e = CommPortIdentifier.getPortIdentifiers();
		CommPortIdentifier comId;
		String comName;
		while (e.hasMoreElements()) {
			comId = e.nextElement();
			comName = comId.getName();
			if (comName.equalsIgnoreCase(portname)) {
				System.out.println("port found: " + comName);
				mSerialPort = (SerialPort) comId.open(comName, 1000);
				mSerialPort.setSerialPortParams(9600, 8, 1, 0);
				mSerialPort.setFlowControlMode(SerialPort.FLOWCONTROL_NONE);

				serin = mSerialPort.getInputStream();
				serout = mSerialPort.getOutputStream();
				break;
			}
		}

	}

	private void openATRFile(String filename) throws IOException {
		byte[] inb = new byte[1];
		FileInputStream fin = new FileInputStream(new File(filename));

		fin.read(atrHeader);

		if (atrHeader[0] == (byte) 0x96 && atrHeader[1] == (byte) 0x02) {
			System.out.println("valid ATR " + filename);
			atrsize = getWord(atrHeader, 2) << 4;
			secsize = getWord(atrHeader, 4);
			secnum = atrsize / secsize;
			// secnum = 32;

			System.out.println("size: " + atrsize);
			System.out.println("secsize: " + secsize);
			System.out.println("seclen: " + secnum);
		} else {
			return;
		}

		waitAck();

		try {
			Thread.sleep(0100);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		System.out.println("sending header");

		inb[0] = atrHeader[4];
		serout.write(inb);
		System.out.println(inb[0] & 0xff);
		inb[0] = atrHeader[5];
		serout.write(inb);
		System.out.println(inb[0] & 0xff);

		inb[0] = (byte) (secnum & 0xff);
		serout.write(inb);
		System.out.println(inb[0] & 0xff);
		inb[0] = (byte) ((secnum) >> 8 & 0xff);
		serout.write(inb);
		System.out.println(inb[0] & 0xff);

		byte[] sec = null;
		boolean once1 = false;
		boolean once2 = false;

		for (int seccnt = 0; seccnt < secnum; seccnt++) {
			if (seccnt < 3) {
				if (!once1)
					sec = new byte[128];
				once1 = true;
			} else {
				if (!once2)
					sec = new byte[secsize];
				once2 = true;
			}
			System.out.println("sending sector: " + (seccnt + 1) + " length: " + sec.length);

			fin.read(sec);
			serout.write(sec);
			// System.out.println("waiting for ack");
			waitAck();
			// System.out.println("ack received");
		}

		System.out.println("transfer completed");
		fin.close();
	}

	private void processArgs(String[] args)
			throws NoSuchPortException, PortInUseException, UnsupportedCommOperationException, IOException {

		for (String arg : args) {
			if (arg.length() > 0 && arg.substring(0, 1).equals("-")) {
				openPort(arg.substring(1));
			} else {
				openATRFile(arg);
			}
		}
	}

	public atrtransfer(String[] args)
			throws NoSuchPortException, PortInUseException, UnsupportedCommOperationException, IOException {

		System.out.println("ATR tansfer");
		processArgs(args);
	}
}
