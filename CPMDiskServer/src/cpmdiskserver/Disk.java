package cpmdiskserver;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

public class Disk {

	private final int trackPerDisk = 77;
	private final int secPerTrack = 26;
	private final int bytesPerSec = 128;

	private int diskno = 0;
	private byte bytes[];
	private String fileName = null;

	public Disk(int diskno) {
		createDisk(diskno);
		this.fileName = null;
	}

	public Disk(int diskno, String filename) {
		createDisk(diskno);
		loadDisk(filename);
	}

	private String getFileName() {
		return this.fileName;
	}

	private int sector2offset(int sector, int track) {
		return (track * secPerTrack + sector) * bytesPerSec;
	}

	private void createDisk(int diskno) {
		this.diskno = diskno;
		bytes = new byte[secPerTrack * trackPerDisk * bytesPerSec];
		for (int i = 0; i < bytes.length; i++) {
			bytes[i] = (byte) 0xe5;
		}
	}

	public void closeDisk() {
		try {
			FileOutputStream fout = new FileOutputStream(getFileName());
			fout.write(bytes);
			fout.close();
		} catch (IOException e) {
		}

	}

	public boolean loadDisk(String filename) {

		this.fileName = filename;

		try {
			FileInputStream fin = new FileInputStream(filename);
			fin.read(bytes);
			fin.close();
			return true;
		} catch (IOException e) {
			System.out.println("can't load filename, add empty disk");
			for (int i = 0; i < bytes.length; i++) {
				bytes[i] = (byte) 0xe5;
			}
			return false;
		}

	}

	public int getDiskno() {
		return diskno;
	}

	public byte[] readSector(int sector, int track) {
		byte[] b = new byte[bytesPerSec];
		System.arraycopy(bytes, sector2offset(sector, track), b, 0, bytesPerSec);
		return b;
	}

	public void writeSector(int sector, int track, byte[] b) {
		System.arraycopy(b, 0, bytes, sector2offset(sector, track), bytesPerSec);
	}

}
