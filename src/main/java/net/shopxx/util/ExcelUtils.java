package net.shopxx.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.reflect.Field;
import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFDataFormat;
import org.apache.poi.hssf.usermodel.HSSFDateUtil;
import org.apache.poi.hssf.usermodel.HSSFFont;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.util.HSSFColor;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.CreationHelper;
import org.apache.poi.ss.usermodel.DateUtil;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFCellStyle;
import org.apache.poi.xssf.usermodel.XSSFColor;
import org.apache.poi.xssf.usermodel.XSSFFont;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

/**
 * 导出excel
 * 
 * @author Fred.xu
 * @version v0.0.1: ExcelUtils.java, v 0.1 2017年6月21日 上午10:04:53 Fred.xu Exp $
 */
public class ExcelUtils<E> {
    private E                e;
    private SimpleDateFormat sdf    = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    private int              etimes = 0;

    public ExcelUtils(E e) {
        this.e = e;
    }
    //excel默认宽度；  
    private static int width = 256*14;  
    //默认字体  
    private static String excelfont = "微软雅黑";  
      
    /** 
     *  
     * @param excelName  导出的EXCEL名字 
     * @param sheetName  导出的SHEET名字  当前sheet数目只为1 
     * @param headers      导出的表格的表头 
     * @param ds_titles      导出的数据 map.get(key) 对应的 key 
     * @param ds_format    导出数据的样式 
     *                          1:String left;  
     *                          2:String center    
     *                          3:String right 
     *                          4 int  right 
     *                          5:float ###,###.## right  
     *                          6:number: #.00% 百分比 right 
     * @param widths      表格的列宽度  默认为 256*14 
     * @param data        数据集  List<Map> 
     * @param response 
     * @throws IOException 
     */  
    public static void export(String excelName, String sheetName,String[] headers,String[] ds_titles,int[] ds_format,int[] widths, List<Map<String,Object>> data ,HttpServletRequest request, HttpServletResponse response) throws IOException {  
        HttpSession session = request.getSession();    
        session.setAttribute("state", null);    
        if(widths==null){  
              widths = new int[ds_titles.length];  
              for(int i=0;i<ds_titles.length;i++){  
                  widths[i]=width;  
              }  
          }  
          if(ds_format==null){  
              ds_format = new int[ds_titles.length];  
              for(int i=0;i<ds_titles.length;i++){  
                  ds_format[i]=1;  
              }  
          }  
           //设置文件名  
            String fileName = "";  
            if(StringUtil.isNotEmpty(excelName)){  
                fileName = excelName;  
            }  
            //创建一个工作薄  
            HSSFWorkbook wb = new HSSFWorkbook();  
            //创建一个sheet  
            HSSFSheet  sheet = wb.createSheet(StringUtil.isNotEmpty(sheetName)?sheetName:"excel");  
            //创建表头，如果没有跳过  
            int headerrow = 0;  
            if(headers!=null){  
                HSSFRow  row = sheet.createRow(headerrow);  
                //表头样式  
                HSSFCellStyle style = wb.createCellStyle();    
                HSSFFont font = wb.createFont();  
                font.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);  
                font.setFontName(excelfont);  
                font.setFontHeightInPoints((short) 11);  
                style.setFont(font);  
                style.setAlignment(HSSFCellStyle.ALIGN_CENTER);    
                style.setBorderBottom(HSSFCellStyle.BORDER_THIN);  
                style.setBorderLeft(HSSFCellStyle.BORDER_THIN);  
                style.setBorderRight(HSSFCellStyle.BORDER_THIN);  
                style.setBorderTop(HSSFCellStyle.BORDER_THIN);  
                 for (int i = 0; i < headers.length; i++) {    
                    sheet.setColumnWidth((short)i,(short)widths[i]);   
                    HSSFCell cell = row.createCell(i);    
                    cell.setCellValue(headers[i]);    
                    cell.setCellStyle(style);    
                }    
                headerrow++;  
            }  
            //表格主体  解析list  
            if(data != null){  
                List styleList = new ArrayList();  
                  
                for (int i = 0; i <ds_titles.length; i++) {  //列数  
                    HSSFCellStyle style = wb.createCellStyle();    
                    HSSFFont font = wb.createFont();  
                    font.setFontName(excelfont);  
                    font.setFontHeightInPoints((short) 10);  
                    style.setFont(font);  
                    style.setBorderBottom(HSSFCellStyle.BORDER_THIN);  
                    style.setBorderLeft(HSSFCellStyle.BORDER_THIN);  
                    style.setBorderRight(HSSFCellStyle.BORDER_THIN);  
                    style.setBorderTop(HSSFCellStyle.BORDER_THIN);  
                    if(ds_format[i]==1){  
                        style.setAlignment(HSSFCellStyle.ALIGN_LEFT);    
                    }else if(ds_format[i]==2){  
                        style.setAlignment(HSSFCellStyle.ALIGN_CENTER);    
                    }else if(ds_format[i]==3){  
                        style.setAlignment(HSSFCellStyle.ALIGN_RIGHT);   
                         //int类型  
                    }else if(ds_format[i]==4){  
                        style.setAlignment(HSSFCellStyle.ALIGN_RIGHT);   
                         //int类型  
                        style.setDataFormat(HSSFDataFormat.getBuiltinFormat("0"));     
                    }else if(ds_format[i]==5){  
                        //float类型  
                        style.setAlignment(HSSFCellStyle.ALIGN_RIGHT);   
                        style.setDataFormat(HSSFDataFormat.getBuiltinFormat("#,##0.00"));     
                    }else if(ds_format[i]==6){  
                        //百分比类型  
                        style.setAlignment(HSSFCellStyle.ALIGN_RIGHT);   
                        style.setDataFormat(HSSFDataFormat.getBuiltinFormat("0.00%"));    
                    }  
                    styleList.add(style);  
                }  
                for (int i = 0; i < data.size() ; i++) {  //行数  
                    HSSFRow  row = sheet.createRow(headerrow);  
                    Map map = data.get(i);  
                    for (int j = 0; j <ds_titles.length; j++) {  //列数  
                         HSSFCell cell = row.createCell(j);    
                         Object o = map.get(ds_titles[j]);  
                         if(o==null||"".equals(o)){  
                             cell.setCellValue("");  
                         }else if(ds_format[j]==4){  
                             //int  
                             cell.setCellValue((Long.valueOf((map.get(ds_titles[j]))+"")).longValue());   
                         }else if(ds_format[j]==5|| ds_format[j]==6){  
                             //float  
                             cell.setCellValue((Double.valueOf((map.get(ds_titles[j]))+"")).doubleValue());   
                         }else {  
                             cell.setCellValue(map.get(ds_titles[j])+"");   
                         }  
                           
                         cell.setCellStyle((HSSFCellStyle)styleList.get(j));    
                    }  
                    headerrow++;  
                }  
            }  
             
            fileName=fileName+".xls";  
            String filename = "";  
            try{  
               filename =encodeChineseDownloadFileName(request,fileName);  
            }catch(Exception e){  
                e.printStackTrace();  
            }  
//          final String userAgent = request.getHeader("USER-AGENT");  
//            if(userAgent.indexOf( "MSIE")!=-1){//IE浏览器  
//              filename = URLEncoder.encode(fileName,"UTF8");  
//            }else if(userAgent.indexOf( "Mozilla")!=-1){//google,火狐浏览器  
//              filename = new String(fileName.getBytes(), "ISO8859-1");  
//            }else{  
//              filename = URLEncoder.encode(fileName,"UTF8");//其他浏览器  
//            }  
              
            response.setHeader("Content-disposition", filename);  
            response.setContentType("application/vnd.ms-excel");    
            response.setHeader("Content-disposition", "attachment;filename="+filename);    
            response.setHeader("Pragma", "No-cache");  
            OutputStream ouputStream = response.getOutputStream();    
            wb.write(ouputStream);    
            ouputStream.flush();    
            ouputStream.close();  
            session.setAttribute("state", "open");  
              
    }  
      
    /**  
     * 对文件流输出下载的中文文件名进行编码 屏蔽各种浏览器版本的差异性  
     * @throws UnsupportedEncodingException   
     */    
    public static String encodeChineseDownloadFileName(    
            HttpServletRequest request, String pFileName) throws Exception {    
            
         String filename = null;      
            String agent = request.getHeader("USER-AGENT");      
            if (null != agent){      
                if (-1 != agent.indexOf("Firefox")) {//Firefox      
                    filename = "=?UTF-8?B?" + (new String(org.apache.commons.codec.binary.Base64.encodeBase64(pFileName.getBytes("UTF-8"))))+ "?=";      
                }else if (-1 != agent.indexOf("Chrome")) {//Chrome      
                    filename = new String(pFileName.getBytes(), "ISO8859-1");      
                } else {//IE7+      
                    filename = java.net.URLEncoder.encode(pFileName, "UTF-8");      
                    filename = filename.replace("+", "%20");  
                }      
            } else {      
                filename = pFileName;      
            }      
            return filename;     
    } 
    @SuppressWarnings("unchecked")
    public E get() throws InstantiationException, IllegalAccessException {
        return (E) e.getClass().newInstance();
    }

    /**
     * 将数据写入到Excel文件
     * 
     * @param filePath
     *            文件路径
     * @param sheetName
     *            工作表名称
     * @param title
     *            工作表标题栏
     * @param data
     *            工作表数据
     * @throws FileNotFoundException
     *             文件不存在异常
     * @throws IOException
     *             IO异常
     */
    public static void writeToFile(String filePath, String[] sheetName, List<? extends Object[]> title, List<? extends List<? extends Object[]>> data) throws FileNotFoundException,
                                                                                                                                                       IOException {
        // 创建并获取工作簿对象
        Workbook wb = getWorkBook(sheetName, title, data);

        FileOutputStream out = null;
        try {
            // 写入到文件
            out = new FileOutputStream(filePath);
            wb.write(out);

        } finally {
            if (out != null) {
                out.close();
            }
        }
    }

    /**
     * 创建工作簿对象<br>
     * <font color="red">工作表名称，工作表标题，工作表数据最好能够对应起来</font><br>
     * 比如三个不同或相同的工作表名称，三组不同或相同的工作表标题，三组不同或相同的工作表数据<br>
     * <b> 注意：<br>
     * 需要为每个工作表指定<font color="red">工作表名称，工作表标题，工作表数据</font><br>
     * 如果工作表的数目大于工作表数据的集合，那么首先会根据顺序一一创建对应的工作表名称和数据集合，然后创建的工作表里面是没有数据的<br>
     * 如果工作表的数目小于工作表数据的集合，那么多余的数据将不会写入工作表中 </b>
     * 
     * @param sheetName
     *            工作表名称的数组
     * @param title
     *            每个工作表名称的数组集合
     * @param data
     *            每个工作表数据的集合的集合
     * @return Workbook工作簿
     * @throws FileNotFoundException
     *             文件不存在异常
     * @throws IOException
     *             IO异常
     */
    public static Workbook getWorkBook(String[] sheetName, List<? extends Object[]> title, List<? extends List<? extends Object[]>> data) throws FileNotFoundException,
                                                                                                                                          IOException {

        // 创建工作簿
        Workbook wb = new SXSSFWorkbook();
        // 创建一个工作表sheet
        Sheet sheet = null;
        // 申明行
        Row row = null;
        // 申明单元格
        Cell cell = null;
        // 单元格样式
        CellStyle titleStyle = wb.createCellStyle();
        CellStyle cellStyle = wb.createCellStyle();
        // 字体样式
        Font font = wb.createFont();
        // 粗体
        font.setBoldweight(XSSFFont.BOLDWEIGHT_BOLD);
        titleStyle.setFont(font);
        // 水平居中
        titleStyle.setAlignment(CellStyle.ALIGN_CENTER);
        // 垂直居中
        titleStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);

        // 水平居中
        cellStyle.setAlignment(CellStyle.ALIGN_CENTER);
        // 垂直居中
        cellStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);

        cellStyle.setFillBackgroundColor(HSSFColor.BLUE.index);

        // 标题数据
        Object[] title_temp = null;

        // 行数据
        Object[] rowData = null;

        // 工作表数据
        List<? extends Object[]> sheetData = null;

        // 遍历sheet
        for (int sheetNumber = 0; sheetNumber < sheetName.length; sheetNumber++) {
            // 创建工作表
            sheet = wb.createSheet();
            // 设置默认列宽
            sheet.setDefaultColumnWidth(18);
            // 设置工作表名称
            wb.setSheetName(sheetNumber, sheetName[sheetNumber]);
            // 设置标题
            title_temp = title.get(sheetNumber);
            row = sheet.createRow(0);

            // 写入标题
            for (int i = 0; i < title_temp.length; i++) {
                cell = row.createCell(i);
                cell.setCellStyle(titleStyle);
                cell.setCellValue(title_temp[i].toString());
            }

            try {
                sheetData = data.get(sheetNumber);
            } catch (Exception e) {
                continue;
            }
            // 写入行数据
            for (int rowNumber = 0; rowNumber < sheetData.size(); rowNumber++) {
                // 如果没有标题栏，起始行就是0，如果有标题栏，行号就应该为1
                row = sheet.createRow(title_temp == null ? rowNumber : (rowNumber + 1));
                rowData = sheetData.get(rowNumber);
                for (int columnNumber = 0; columnNumber < rowData.length; columnNumber++) {
                    cell = row.createCell(columnNumber);
                    cell.setCellStyle(cellStyle);
                    cell.setCellValue(rowData[columnNumber] + "");
                }
            }
        }
        return wb;
    }

    /**
     * 将数据写入到EXCEL文档
     * 
     * @param list
     *            数据集合
     * @param edf
     *            数据格式化，比如有些数字代表的状态，像是0:女，1：男，或者0：正常，1：锁定，变成可读的文字
     *            该字段仅仅针对Boolean,Integer两种类型作处理
     * @param filePath
     *            文件路径
     * @throws Exception
     */
    public static <T> void writeToFile(List<T> list, ExcelDataFormatter edf, String filePath) throws Exception {
        // 创建并获取工作簿对象
        Workbook wb = getWorkBook(list, edf);
        FileOutputStream out = null;
        try {
            // 写入到文件
            out = new FileOutputStream(filePath);
            wb.write(out);

        } finally {
            if (out != null) {
                out.close();
            }
        }
    }
    
    /**
     * 将数据写入到EXCEL文档
     * 
     * @param list
     *            数据集合
     * @param edf
     *            数据格式化，比如有些数字代表的状态，像是0:女，1：男，或者0：正常，1：锁定，变成可读的文字
     *            该字段仅仅针对Boolean,Integer两种类型作处理
     * @param filePath
     *            文件路径
     * @throws Exception
     */
    public <T> void writeToResponseForExcel(List<T> list, ExcelDataFormatter edf,String fileName, HttpServletResponse  response) throws Exception {
        response.setContentType("application/vnd.ms-excel");  
        // 创建并获取工作簿对象
        Workbook wb = getWorkBook(list, edf);
        OutputStream out = response.getOutputStream();
        fileName = java.net.URLEncoder.encode(fileName, "UTF-8");  
        response.setHeader("content-disposition", "attachment;filename=" + fileName + ".xlsx");  
        try {
            wb.write(out);

        } finally {
            if (out != null) {
                out.close();
            }
        }
    }


    /**
     * 获得Workbook对象
     * 
     * @param list
     *            数据集合
     * @return Workbook
     * @throws Exception
     */
    public static <T> Workbook getWorkBook(List<T> list, ExcelDataFormatter edf) throws Exception {
        // 创建工作簿
        Workbook wb = new SXSSFWorkbook();

        if (list == null || list.size() == 0)
            return wb;

        // 创建一个工作表sheet
        Sheet sheet = wb.createSheet();
        // 申明行
        Row row = sheet.createRow(0);
        // 申明单元格
        Cell cell = null;

        CreationHelper createHelper = wb.getCreationHelper();

        Field[] fields = list.get(0).getClass().getDeclaredFields();

        XSSFCellStyle titleStyle = (XSSFCellStyle) wb.createCellStyle();
        titleStyle.setFillPattern(CellStyle.SOLID_FOREGROUND);
        // 设置前景色
        titleStyle.setFillForegroundColor(new XSSFColor(new java.awt.Color(159, 213, 183)));
        titleStyle.setAlignment(CellStyle.ALIGN_CENTER);

        Font font = wb.createFont();
        font.setColor(HSSFColor.BROWN.index);
        font.setBoldweight(Font.BOLDWEIGHT_BOLD);
        // 设置字体
        titleStyle.setFont(font);

        int columnIndex = 0;
        Excel excel = null;
        for (Field field : fields) {
            field.setAccessible(true);
            excel = field.getAnnotation(Excel.class);
            if (excel == null || excel.skip()) {
                continue;
            }
            // 列宽注意乘256
            sheet.setColumnWidth(columnIndex, excel.width() * 256);
            // 写入标题
            cell = row.createCell(columnIndex);
            cell.setCellStyle(titleStyle);
            cell.setCellValue(SpringUtils.getMessage(excel.name()));

            columnIndex++;
        }

        int rowIndex = 1;

        CellStyle cs = wb.createCellStyle();

        for (T t : list) {
            row = sheet.createRow(rowIndex);
            columnIndex = 0;
            Object o = null;
            for (Field field : fields) {

                field.setAccessible(true);

                // 忽略标记skip的字段
                excel = field.getAnnotation(Excel.class);
                if (excel == null || excel.skip()) {
                    continue;
                }
                // 数据
                cell = row.createCell(columnIndex);

                o = field.get(t);
                // 如果数据为空，跳过
                if (o == null) {
                    continue;
                }

                // 处理日期类型
                if (o instanceof Date) {
                    cs.setDataFormat(createHelper.createDataFormat().getFormat("yyyy-MM-dd HH:mm:ss"));
                    cell.setCellStyle(cs);
                    cell.setCellValue((Date) field.get(t));
                } else if (o instanceof Double || o instanceof Float) {
                    cell.setCellValue((Double) field.get(t));
                } else if (o instanceof Boolean) {
                    Boolean bool = (Boolean) field.get(t);
                    if (edf == null) {
                        cell.setCellValue(bool);
                    } else {
                        Map<String, String> map = edf.get(field.getName());
                        if (map == null) {
                            cell.setCellValue(bool);
                        } else {
                            cell.setCellValue(map.get(bool.toString().toLowerCase()));
                        }
                    }

                } else if (o instanceof Integer) {
                    Integer intValue = (Integer) field.get(t);

                    if (edf == null) {
                        cell.setCellValue(intValue);
                    } else {
                        Map<String, String> map = edf.get(field.getName());
                        if (map == null) {
                            cell.setCellValue(intValue);
                        } else {
                            cell.setCellValue(map.get(intValue.toString()));
                        }
                    }
                } else {
                    cell.setCellValue(field.get(t).toString());
                }

                columnIndex++;
            }

            rowIndex++;
        }

        return wb;
    }

    /**
     * 从文件读取数据，最好是所有的单元格都是文本格式，日期格式要求yyyy-MM-dd HH:mm:ss,布尔类型0：真，1：假
     * 
     * @param edf
     *            数据格式化
     * 
     * @param file
     *            Excel文件，支持xlsx后缀，xls的没写，基本一样
     * @return
     * @throws Exception
     */
    public List<E> readFromFile(ExcelDataFormatter edf, File file, int sheetIndex) throws Exception {
        InputStream is = new FileInputStream(file);
        return readFromStream(edf, is, sheetIndex);
    }

    @SuppressWarnings("resource")
    public List<E> readFromStream(ExcelDataFormatter edf, InputStream file, int sheetIndex) throws Exception {

        Field[] fields = e.getClass().getDeclaredFields();

        Map<String, String> textToKey = new HashMap<String, String>();

        Excel _excel = null;
        for (Field field : fields) {
            _excel = field.getAnnotation(Excel.class);
            if (_excel == null || _excel.skip()) {
                continue;
            }
            textToKey.put(_excel.name(), field.getName());
        }

        Workbook wb = new XSSFWorkbook(file);
        Sheet sheet = wb.getSheetAt(sheetIndex);
        Row title = sheet.getRow(sheet.getFirstRowNum());
        // 标题数组，后面用到，根据索引去标题名称，通过标题名称去字段名称用到 textToKey
        String[] titles = new String[title.getPhysicalNumberOfCells()];
        for (int i = 0; i < title.getPhysicalNumberOfCells(); i++) {
            titles[i] = title.getCell(i).getStringCellValue();
        }

        List<E> list = new ArrayList<E>();

        E e = null;

        int rowIndex = 0;
        int columnCount = titles.length;
        Cell cell = null;
        Row row = null;

        for (Iterator<Row> it = sheet.rowIterator(); it.hasNext();) {

            row = it.next();
            if (rowIndex++ == 0) {
                continue;
            }

            if (row == null) {
                break;
            }

            e = get();

            for (int i = 0; i < columnCount; i++) {
                cell = row.getCell(i);
                etimes = 0;
                readCellContent(textToKey.get(titles[i]), fields, cell, e, edf);
            }
            list.add(e);
        }
        return list;

    }
    
    //获取Excel表头列表
    public List<String> listTitleFromStream(ExcelDataFormatter edf, InputStream file, int sheetIndex) throws Exception {

        Field[] fields = e.getClass().getDeclaredFields();

        Map<String, String> textToKey = new HashMap<String, String>();

        Excel _excel = null;
        for (Field field : fields) {
            _excel = field.getAnnotation(Excel.class);
            if (_excel == null || _excel.skip()) {
                continue;
            }
            textToKey.put(_excel.name(), field.getName());
        }

        Workbook wb = new XSSFWorkbook(file);
        Sheet sheet = wb.getSheetAt(sheetIndex);
        Row title = sheet.getRow(sheet.getFirstRowNum());
        // 标题数组，后面用到，根据索引去标题名称，通过标题名称去字段名称用到 textToKey
        String[] titles = new String[title.getPhysicalNumberOfCells()];
        for (int i = 0; i < title.getPhysicalNumberOfCells(); i++) {
            titles[i] = title.getCell(i).getStringCellValue();
        }
        wb.close();
        return Arrays.asList(titles);
    }

    /**
     * 从单元格读取数据，根据不同的数据类型，使用不同的方式读取<br>
     * 有时候POI自作聪明，经常和我们期待的数据格式不一样，会报异常，<br>
     * 我们这里采取强硬的方式<br>
     * 使用各种方法，知道尝试到读到数据为止，然后根据Bean的数据类型，进行相应的转换<br>
     * 如果尝试完了（总共7次），还是不能得到数据，那么抛个异常出来，没办法了
     * 
     * @param key
     *            当前单元格对应的Bean字段
     * @param fields
     *            Bean所有的字段数组
     * @param cell
     *            单元格对象
     * @param e
     * @throws Exception
     */
    public void readCellContent(String key, Field[] fields, Cell cell, E e, ExcelDataFormatter edf) throws Exception {

        if (cell == null) {
            return;
        }

        Object o = null;
        try {
            switch (cell.getCellType()) {
                case XSSFCell.CELL_TYPE_BOOLEAN:
                    o = cell.getBooleanCellValue();
                    break;
                case XSSFCell.CELL_TYPE_NUMERIC:
                    o = cell.getNumericCellValue();
                    if (HSSFDateUtil.isCellDateFormatted(cell)) {
                        o = DateUtil.getJavaDate(cell.getNumericCellValue());
                    }
                    break;
                case XSSFCell.CELL_TYPE_STRING:
                    o = cell.getStringCellValue();
                    break;
                case XSSFCell.CELL_TYPE_ERROR:
                    o = cell.getErrorCellValue();
                    break;
                case XSSFCell.CELL_TYPE_BLANK:
                    o = null;
                    break;
                case XSSFCell.CELL_TYPE_FORMULA:
                    o = cell.getCellFormula();
                    break;
                default:
                    o = null;
                    break;
            }

            if (o == null)
                return;

            for (Field field : fields) {
                field.setAccessible(true);
                if (field.getName().equals(key)) {
                    Boolean bool = true;
                    Map<String, String> map = null;
                    if (edf == null) {
                        bool = false;
                    } else {
                        map = edf.get(field.getName());
                        if (map == null) {
                            bool = false;
                        }
                    }

                    if (field.getType().equals(Date.class)) {
                        if (o instanceof Date) {
                            field.set(e, o);
                        } else {
                            field.set(e, sdf.parse(o.toString()));
                        }
                    } else if (field.getType().equals(String.class)) {
                        if (o instanceof String) {
                            field.set(e, o);
                        } else if (o instanceof Number) {
                            DecimalFormat decimalFormat = new DecimalFormat("###################.###########");
                            field.set(e, decimalFormat.format(o));
                        } else {
                            field.set(e, o.toString());
                        }
                    } else if (field.getType().equals(Long.class)) {
                        if (o instanceof Number) {
                            field.set(e, ((Number) o).longValue());
                        } else {
                            field.set(e, Long.parseLong(o.toString()));
                        }
                    } else if (field.getType().equals(Integer.class)) {
                        Integer o1;
                        if (o instanceof Number) {
                            o1 = ((Number) o).intValue();

                            field.set(e, o1);
                        } else {
                            o1 = Integer.parseInt(o.toString());
                        }

                        // 检查是否需要转换
                        if (bool) {
                            field.set(e, map.get(o1.toString()) != null ? Integer.parseInt(map.get(o1.toString())) : Integer.parseInt(o1.toString()));
                        } else {
                            field.set(e, o1);
                        }

                    } else if (field.getType().equals(BigDecimal.class)) {
                        if (o instanceof BigDecimal) {
                            field.set(e, o);
                        } else {
                            field.set(e, BigDecimal.valueOf(Double.parseDouble(o.toString())));
                        }
                    } else if (field.getType().equals(Boolean.class)) {
                        if (o instanceof Boolean) {
                            field.set(e, o);
                        } else {
                            // 检查是否需要转换
                            if (bool) {
                                field.set(e, map.get(o.toString()) != null ? Boolean.parseBoolean(map.get(o.toString())) : Boolean.parseBoolean(o.toString()));
                            } else {
                                field.set(e, Boolean.parseBoolean(o.toString()));
                            }
                        }
                    } else if (field.getType().equals(Float.class)) {
                        if (o instanceof Float) {
                            field.set(e, o);
                        } else {
                            field.set(e, Float.parseFloat(o.toString()));
                        }
                    } else if (field.getType().equals(Double.class)) {
                        if (o instanceof Number) {
                            field.set(e, ((Number) o).doubleValue());
                        } else {
                            field.set(e, Double.parseDouble(o.toString()));
                        }

                    }

                }
            }

        } catch (Exception ex) {
            ex.printStackTrace();
            // 如果还是读到的数据格式还是不对，只能放弃了
            if (etimes > 7) {
                throw ex;
            }
            etimes++;
            if (o == null) {
                readCellContent(key, fields, cell, e, edf);
            }
        }
    }

}