/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package prepare;

import java.io.File;
import java.util.regex.Pattern;

/**
 *
 * @author Administrator
 */
public class Prepare {
    
    private static int image_idx = 0;

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
        
        String input_path = args[0];  // 指定图片库的输入目录，可能含有多个子目录
        String ouput_path = args[1];  // 指定图片库的输出目录
        image_idx = Integer.parseInt(args[2]);

        File inputFilePath = new File(input_path);
        File ouputFilePath = new File(ouput_path);
        
        String regex_filter = ".*\\.(jpg|jpeg|JPG|JPEG)"; // 正则表达式，用于过滤jpg和jpeg文件，只对这两种文件进行处理
        
        Prepare.rename_copy(input_path, ouput_path, regex_filter);
    }
     
    /**
     * @param inputPath 输入目录
     * @param ouputPath 输出目录
     * @param regex 用于指定处理文件类型的正则表达式
     */
    public static void rename_copy(String inputPath, String ouputPath, String regex) {
        File inputFilePath = new File(inputPath);
        File ouputFilePath = new File(ouputPath);
        Operator.makeDir(ouputFilePath); // 建立输出目录
        
        // 扫描输入目录
        if (inputFilePath.exists()) {
            File[] files = inputFilePath.listFiles();
            if (files.length == 0) {
                System.out.println("文件夹是空的!");
            } else {
                for (File a_file : files) {
                    if (a_file.isDirectory()) {
                        Prepare.rename_copy(a_file.getAbsolutePath(),ouputPath,regex);
                    } else {
                        Pattern pattern = Pattern.compile(regex);
                        String fullFileName = a_file.getAbsolutePath();
                        if(pattern.matcher(fullFileName).matches()) {
                            String fileType = fullFileName.substring(fullFileName.lastIndexOf("."));
                            fileType = ".jpg";
                            String destFileName = String.format("%09d", image_idx) + fileType;
                            String destFullFileName = ouputPath + "\\" + destFileName;
                            Operator.copyFile(fullFileName, destFullFileName, true);
                            ++image_idx;
                        }
                    }
                }
            }
        } else {
            System.out.println("目录不存在!");
        }
    }
}
