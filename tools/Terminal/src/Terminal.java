import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

import com.fazecast.jSerialComm.SerialPort;

public class Terminal {

//	private SerialPort serialPortList[] = SerialPort.getCommPorts();
//	private JDialog frame = new JDialog();
//	private JEditorPane editorPane = new JEditorPane();

	private String portName = null;

	private int baud = 115200;
	// private int flow = SerialPort.FLOW_CONTROL_XONXOFF_OUT_ENABLED;
	private int flow = SerialPort.FLOW_CONTROL_DISABLED;
	private int parity = SerialPort.NO_PARITY;
	private int stopBits = SerialPort.ONE_STOP_BIT;
	private SerialConnection sc = null;
	private String op = null;
	private String fileName = null;

	private byte ACK = (byte) 'A';
	private byte SEND = (byte) 's';
	private byte COMPLETE = (byte) 'c';
	private byte QUIT = (byte) 'q';
	private byte CPM = (byte) 'p';

	private void parseArguments(String[] args) {
		fileName = args[args.length - 1];
		for (int i = 0; i < args.length; i++) {
			System.out.println(i + ":" + args[i]);
			switch (args[i]) {
			case "-p":
				if (i + 1 < args.length) {
					portName = args[i + 1];
				}
			case "send":
			case "recv":
			case "quit":
			case "cpm":
				op = args[i];
			}
		}
	}

	private byte getByte() {
		byte[] b = new byte[1];
		sc.getSerialPort().readBytes(b, 1);
		return b[0];
	}

	private boolean ack() {
		return (getByte() == ACK);
	}

	private void sendAck() {
		sc.writeByte(ACK);
	}

	private String getFilename(String fname) {
		return fileName.substring(fileName.lastIndexOf(File.separator) + 1);
	}

	private boolean openCom() {
		if (op != null && portName != null && fileName != null) {
			sc = new SerialConnection(portName, baud, parity, stopBits, flow, null);
			return sc.getSerialPort().isOpen();
		}

		return false;
	}

	private void doCPM() {
		if (!openCom()) {
			return;
		}
		sc.writeByte(CPM);
		sc.getSerialPort().closePort();
	}

	private void doQuit() {
		if (!openCom()) {
			return;
		}
		sc.writeByte(QUIT);
		sc.getSerialPort().closePort();
	}

	private void doSend() {
		byte[] buf = new byte[128];
		int len;
		boolean lastAck;
		FileInputStream fin;

		if (!openCom()) {
			return;
		}

		try {
			fin = new FileInputStream(fileName);

			System.out.println("sending " + fileName + " on " + portName);

			sc.writeByte(SEND);
			if (!ack()) {
				fin.close();
				return;
			}

			sc.writeBytes(getFilename(fileName).getBytes());
			sc.writeBytes("\r\n".getBytes());
			if (!ack()) {
				fin.close();
				return;
			}

			do {
				len = fin.read(buf);
				if (len <= 0) {
					lastAck = true;
					break;
				}

				System.out.print(".");

				sc.writeByte(SEND);
				sc.writeBytes(buf);
				if (!(lastAck = ack()))
					break;
			} while (len == 128);

			if (lastAck)
				sc.writeByte(COMPLETE);

			fin.close();
			System.out.println();
			sc.getSerialPort().closePort();
		} catch (IOException e) {
			System.out.println("can't open " + fileName);
		}
	}

	private void doReceive() {
		byte[] buf = new byte[128];
		FileOutputStream fout = null;
		byte b;

		if (!openCom()) {
			return;
		}

		try {
			fout = new FileOutputStream(fileName);

			System.out.print("receiving " + fileName + " on " + portName + " ");

			sc.writeByte((byte) 'r');
			if (!ack()) {
				fout.close();
				return;
			}

			sc.writeBytes(getFilename(fileName).getBytes());
			sc.writeBytes("\r\n".getBytes());
			if (!ack()) {
				fout.close();
				return;
			}

			do {
				b = getByte();
				if (b == SEND) {
					sc.getSerialPort().readBytes(buf, buf.length);
					fout.write(buf);
					System.out.print(".");
					sendAck();
				}
			} while (b == SEND);

			fout.close();
			sc.getSerialPort().closePort();
			System.out.println();

		} catch (IOException e) {
			System.out.println("can't open " + fileName);
		}

	}

	private void doOperation() {
		if (op.equals("send"))
			doSend();
		if (op.equals("recv"))
			doReceive();
		if (op.equals("quit"))
			doQuit();
		if (op.equals("cpm"))
			doCPM();
	}

	public Terminal(String[] args) {
		// initialize();

		parseArguments(args);

//		for (SerialPort sp : serialPortList) {
//			System.out.println(sp.getSystemPortName() + " " + sp.getDescriptivePortName());
//		}

		if (op != null) {
			doOperation();
		} else {
			System.out.println("terminal -p port send|recv|quit");
		}

		// System.out.println("Exit");
	}

	public static void main(String[] args) {
		new Terminal(args);
	}
}
