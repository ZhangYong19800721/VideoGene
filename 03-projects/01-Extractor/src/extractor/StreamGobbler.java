package extractor;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;

public class StreamGobbler extends Thread {
    private InputStream inputStream;
    private OutputStream outputStream;

    public StreamGobbler(InputStream inputStream) {
        this(inputStream, null);
    }

    public StreamGobbler(InputStream inputStream, OutputStream outputStream) {
        this.inputStream = inputStream;
        this.outputStream = outputStream;
    }

    public void run() {
        PrintWriter printWriter = null;
        InputStreamReader inputStreamReader = null;
        BufferedReader bufferedReader = null;
        try {
            if (outputStream != null) {
                    printWriter = new PrintWriter(outputStream);
            }
            inputStreamReader = new InputStreamReader(inputStream);
            bufferedReader = new BufferedReader(inputStreamReader);
            String line = null;
            while ((line = bufferedReader.readLine()) != null) {
                    if (outputStream != null) {
                            printWriter.write(line);
                            printWriter.println();
                    }
            }
            if (outputStream != null) {
                    printWriter.flush();
            }
        } catch (IOException ex) {
            ex.printStackTrace();
        } finally {
            try {
                    // 关闭IO流
                    if (bufferedReader != null) {
                            bufferedReader.close();
                    }
                    if (inputStreamReader != null) {
                            inputStreamReader.close();
                    }
            } catch (IOException e) {
                    e.printStackTrace();
            }
        }
    }
}