/*
 * 
 * 
 * 
 */
package extractor;

import java.util.regex.*;
import java.io.*;

/**
 *
 * @author ZhangYong
 */
public class Extractor {

    public static boolean renameFile(String path, String oldname, String newname) {
        if (!oldname.equals(newname)) {// 新的文件名和以前文件名不同时,才有必要进行重命名
            File oldfile = new File(path + oldname);
            File newfile = new File(path + newname);
            if (!oldfile.exists()) {
                return false; // 重命名文件不存在
            }
            if (newfile.exists())// 若在该目录下已经有一个文件和新文件名相同，则不允许重命名
            {
                return false;
            } else {
                oldfile.renameTo(newfile);
            }
        } else {
            return false;
        }
        return true;
    }

    public static String replaceBlank(String str) {
        String dest = "";
        if (str != null) {
            Pattern p = Pattern.compile("\\s*|\t|\r|\n");
            Matcher m = p.matcher(str);
            dest = m.replaceAll("");
        }
        return dest;
    }

    public static void makeDir(File dir) {
        if (!dir.getParentFile().exists()) {
            makeDir(dir.getParentFile());
        }
        dir.mkdir();
    }

    public static FilenameFilter filter(final String regex) {
        return new FilenameFilter() {
            private final Pattern pattern = Pattern.compile(regex);

            @Override
            public boolean accept(File dir, String name) {
                return pattern.matcher(name).matches();
            }
        };
    }

    public static int callexec(Runtime rt, String command) {
        return Extractor.callexec(rt, command, null);
    }

    public static int callexec(Runtime rt, String[] command) {
        return Extractor.callexec(rt, command, null);
    }

    public static int callexec(Runtime rt, String[] command, OutputStream outputStream) {
        Process process = null;
        int result = -1;
        try {
            process = rt.exec(command);
            // 启用StreamGobbler线程清理错误流和输入流 防止IO阻塞
            new extractor.StreamGobbler(process.getErrorStream(), outputStream).start();
            new extractor.StreamGobbler(process.getInputStream(), outputStream).start();
            result = process.waitFor();
        } catch (IOException | InterruptedException e) {

        } finally {
            if (process != null && result != 0) {
                process.destroy();
            }
        }

        return result;
    }

    public static int callexec(Runtime rt, String command, OutputStream outputStream) {
        Process process = null;
        int result = -1;
        try {
            process = rt.exec(command);
            // 启用StreamGobbler线程清理错误流和输入流 防止IO阻塞
            new extractor.StreamGobbler(process.getErrorStream(), outputStream).start();
            new extractor.StreamGobbler(process.getInputStream(), outputStream).start();
            result = process.waitFor();
        } catch (IOException | InterruptedException e) {

        } finally {
            if (process != null && result != 0) {
                process.destroy();
            }
        }

        return result;
    }

    /**
     * @param args the command line arguments 从视频中抽取图像帧
     */
    public static void main(String[] args) {
        String input_path = args[0]; // 指定视频的输入目录
        String output_path = args[1]; // 指定抽取图像的输出目录

        File inputFilePath = new File(input_path);
        File ouputFilePath = new File(output_path);
        String regex_filter = ".*\\.(mp4|MP4|ts|TS|m2ts)";

        // 扫描输入目录找到所有的输入视频文件
        String[] inputList = inputFilePath.list(filter(regex_filter));
        // 对视频文件重新命名以去除文件名中的空格
        for (String fileName : inputList) {
            String newFileName = Extractor.replaceBlank(fileName);
            Extractor.renameFile(input_path, fileName, newFileName);
        }
        inputList = inputFilePath.list(filter(regex_filter));

        Runtime rt = Runtime.getRuntime(); //获取运行时环境变量
        int exit = 0;

        for (String fileName : inputList) {
            String input_name = input_path + "\\" + fileName;
            String output_name = output_path + "\\" + fileName + "-image%06d.jpeg";
            String command = "ffmpeg -i " + input_name + " -r 0.025 -f image2 " + output_name;
            exit = Extractor.callexec(rt, command);
        }
    }
}
