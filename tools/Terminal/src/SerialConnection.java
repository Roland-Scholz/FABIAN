import javax.swing.JEditorPane;

import com.fazecast.jSerialComm.SerialPort;

public class SerialConnection {
	private SerialPort sp = null;
	private byte[] b1 = new byte[1];

	private boolean halt = false;
	private byte XON = 17;
	private byte XOFF = 19;

	public SerialConnection(String portName, int baud, int parity, int stopBits, int flow, JEditorPane pane) {
		// Document doc = pane.getDocument();

		sp = SerialPort.getCommPort(portName);
		this.setParameters(portName, baud, parity, stopBits, flow);
//		sp.addDataListener(new SerialPortDataListener() {
//
//			@Override
//			public void serialEvent(SerialPortEvent e) {
//
//				// System.out.println(e);
//				byte[] newData = new byte[sp.bytesAvailable()];
//				int numBytes = sp.readBytes(newData, newData.length);
//				// System.out.print(new String(newData, Charset.defaultCharset()));
//				for (byte b : newData) {
//					if (b == XOFF) {
//						halt = true;
//					}
//					if (b == XON) {
//						halt = false;
//					}
//
//				}
//				try {
//					System.out.println("received: " + numBytes);
//					doc.insertString(doc.getLength(), new String(newData, StandardCharsets.UTF_8), null);
//					pane.setCaretPosition(doc.getLength());
//				} catch (BadLocationException e1) {
//					e1.printStackTrace();
//				}
//
//			}
//
//			@Override
//			public int getListeningEvents() {
//				return SerialPort.LISTENING_EVENT_DATA_AVAILABLE;
//			}
//		});

	}

	public SerialPort getSerialPort() {
		return this.sp;
	}

	public void writeByte(byte b) {
		b1[0] = b;
		sp.flushIOBuffers();
		sp.flushDataListener();

		sp.writeBytes(b1, 1);

		while (halt) {
			try {
				Thread.sleep(1);
			} catch (InterruptedException e) {
			}
		}
	}

	public void writeBytes(byte b[]) {
		for (byte c : b) {
			writeByte(c);
		}
	}

	private void setParameters(String portName, int baud, int parity, int stopBits, int flow) {
		sp.closePort();
		sp.setBaudRate(baud);
		sp.setParity(parity);
		sp.setComPortParameters(baud, 8, stopBits, parity);
		sp.setFlowControl(flow);
		sp.setComPortTimeouts(SerialPort.TIMEOUT_READ_BLOCKING, 0, 0);
		sp.openPort();
		/*
		 * System.out.println(sp.openPort());
		 * System.out.println(sp.getDeviceReadBufferSize());
		 * System.out.println(sp.getDeviceWriteBufferSize());
		 * System.out.println(sp.getLastErrorCode());
		 * System.out.println(sp.getLastErrorLocation());
		 */
	}

}
