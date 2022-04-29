package cpmdiskserver;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Enumeration;

import purejavacomm.CommPortIdentifier;
import purejavacomm.NoSuchPortException;
import purejavacomm.PortInUseException;
import purejavacomm.SerialPort;
import purejavacomm.UnsupportedCommOperationException;

public class CPMDiskServer {

	private int maxDisk = 0;
	private Disk[] disks = new Disk[4];
	private SerialPort mSerialPort;

	private byte command;
	private byte diskno;
	private byte track;
	private byte sector;

	public byte getDiskno() {
		return diskno;
	}

	public void setDiskno(byte diskno) {
		this.diskno = diskno;
	}

	public byte getTrack() {
		return track;
	}

	public void setTrack(byte track) {
		this.track = track;
	}

	public byte getSector() {
		return sector;
	}

	public void setSector(byte sector) {
		this.sector = sector;
	}

	public CPMDiskServer(String args[])
			throws IOException, NoSuchPortException, PortInUseException, UnsupportedCommOperationException {
		processArgs(args);
		server();
	}

	private void writePortByte(byte b) throws IOException {
		mSerialPort.getOutputStream().write(b);
	}

	private void writePort(byte b[]) throws IOException {
		mSerialPort.getOutputStream().write(b);
	}

	private byte readPortByte() throws IOException {
		return (byte) (readPort() & 0xff);
	}

	private int readPort() throws IOException {
		return mSerialPort.getInputStream().read();
	}

	private String readPortString() throws IOException {
		BufferedReader r = new BufferedReader(new InputStreamReader(mSerialPort.getInputStream()));
		return r.readLine();
	}

	private void sendAck() throws IOException {
		writePortByte((byte) 'A');
	}

	private void sendError() throws IOException {
		writePortByte((byte) 'E');
	}

	private void getCommandFrame() throws IOException {
		command = readPortByte();
		diskno = readPortByte();
		track = readPortByte();
		sector = readPortByte();

		// System.out.println(String.format("C: %c disk: %02X track %02X sector %02X",
		// command, diskno, track, sector));
	}

	private String getDiskMessage(String readWrite) {
		return String.format("%s disk %02d track %02d sector %02d", readWrite, getDiskno(), getTrack(), getSector());
	}

	private void server() throws IOException {
		boolean quit = false;
		byte b[] = new byte[128];
		Disk disk;

		while (!quit) {
			getCommandFrame();

			disk = null;
			if (getDiskno() < disks.length) {
				disk = disks[getDiskno()];
			}

			if (disk == null && command != 'O') {
				sendError();
				continue;
			}

			switch (command) {

			case 'R':
				System.out.println(getDiskMessage("read "));
				sendAck();
				writePort(disk.readSector(getSector(), getTrack()));
				break;

			case 'W':
				for (int i = 0; i < b.length; i++) {
					b[i] = readPortByte();
				}
				System.out.println(getDiskMessage("write"));
				disk.writeSector(getSector(), getTrack(), b);
				sendAck();
				break;

			case 'O':
				sendAck();
				String filename = readPortString();
				System.out.println("open disk: " + getDiskno() + " " + filename);
				if (disk != null) {
					disk.closeDisk();
					disk.loadDisk(filename);
				} else {
					disks[getDiskno()] = new Disk(getDiskno(), filename);
				}

				break;

			case 'C':
				System.out.println("close disk: " + getDiskno());
				disk.closeDisk();
				disks[getDiskno()] = null;
				sendAck();
				break;

			case 'Q':
				quit = true;
				break;
			default:
				sendError();
				System.out.println("unknown command :" + command);
			}
		}
	}

	private void openPort(String portname)
			throws NoSuchPortException, PortInUseException, UnsupportedCommOperationException {

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
				mSerialPort.setSerialPortParams(115200, 8, 1, 0);
				mSerialPort.setFlowControlMode(SerialPort.FLOWCONTROL_NONE);
				break;
			}
		}

	}

	private void openDisk(String filename) {
		System.out.println("open disk " + filename);
		disks[maxDisk] = new Disk(maxDisk, filename);
		maxDisk++;
	}

	private void processArgs(String[] args)
			throws NoSuchPortException, PortInUseException, UnsupportedCommOperationException {

		for (String arg : args) {
			if (arg.length() > 0 && arg.substring(0, 1).equals("-")) {
				openPort(arg.substring(1));
			} else {
				openDisk(arg);
			}
		}
	}

	public static void main(String[] args)
			throws IOException, NoSuchPortException, PortInUseException, UnsupportedCommOperationException {
		new CPMDiskServer(args);
	}

}
