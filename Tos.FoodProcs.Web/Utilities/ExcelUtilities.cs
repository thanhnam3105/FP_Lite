using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

using DocumentFormat.OpenXml;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Spreadsheet;

namespace Tos.FoodProcs.Web.Utilities
{
    public static class ExcelUtilities
    {

        /// <summary>
        /// EXCELファイルのテンプレートディレクトリを返却する
        /// </summary>
        /// <param name="str">tmpファイル名</param>
        /// <returns>ディレクトリ</returns>
        public static string getTemplateFile(string name, string path, string lang)
        {
            if (lang == "ja")
            {
                return path + "\\Templates" + "\\" + name + "_ja.xlsx";
            }
            else if (lang == "zh")
            {
                return path + "\\Templates" + "\\" + name + "_zh.xlsx";
            }
            else if (lang == "vi")
            {
                return path + "\\Templates" + "\\" + name + "_vi.xlsx";
            }
            else 
            {
                return path + "\\Templates" + "\\" + name + "_en.xlsx";
            }
        }

        public static Worksheet FindWorkSheet(WorkbookPart wbPart, string sheetName) {
            Sheet sheet = wbPart.Workbook.Descendants<Sheet>().Where((s) => s.Name == sheetName).FirstOrDefault();
            if (sheet != null)
            {
                return ((WorksheetPart)(wbPart.GetPartById(sheet.Id))).Worksheet;
            }
            return null;
        }

        /// <summary>
        /// EXCELファイルへ値のセットを行う
        /// </summary>
        /// <param name="ws">ワークシート</param>
        /// <param name="addressName">アドレス</param>
        /// <param name="value">セルに設定する値</param>
        /// <param name="styleIndex">スタイルインデクス</param>
        /// <param name="isString">値がstringかどうか</param>
        /// <returns>ture/false</returns>
        public static void UpdateValue(WorkbookPart wbPart, Worksheet ws, string addressName, string value,
                                UInt32Value styleIndex, bool isString)
        {
            // Assume failure.

            Cell cell = InsertCellInWorksheet(ws, addressName);

            if (isString)
            {
                // nullの場合、空文字に変更します
                // 【2014.02.12：tsujita】
                // 　nullをマッピングしようとすると大幅に性能が低下し、件数が多い場合にはエラーとなる為
                if (value == null)
                {
                    value = "";
                }

                // 既存の文字列のインデックスを取得し、
                // 共有文字列テーブルに文字列を挿入し、
                // 新しい項目のインデックスを取得します。
                int stringIndex = InsertSharedStringItem(wbPart, value);

                cell.CellValue = new CellValue(stringIndex.ToString());
                cell.DataType = new EnumValue<CellValues>(CellValues.SharedString);
            }
            else
            {
                // nullまたは空文字の場合、0に変更します(2014.02.12：tsujita)
                if (value == "null" || string.IsNullOrEmpty(value))
                {
                    value = "0";
                }

                cell.CellValue = new CellValue(value);
                cell.DataType = new EnumValue<CellValues>(CellValues.Number);
            }

            if (styleIndex > 0)
                cell.StyleIndex = styleIndex;

        }

        /// <summary>
        /// EXCELファイルへ関数のセットを行う
        /// </summary>
        /// <param name="ws">ワークシート</param>
        /// <param name="addressName">アドレス</param>
        /// <param name="value">セルに設定する関数</param>
        /// <param name="styleIndex">スタイルインデクス</param>
        public static void UpdateFormula(Worksheet ws, string addressName, string value, UInt32Value styleIndex)
        {
            // Assume failure.

            Cell cell = InsertCellInWorksheet(ws, addressName);

            // 指定セルに関数を設定する
            cell.CellFormula = new CellFormula() { Text = value };
            cell.DataType = new EnumValue<CellValues>(CellValues.Number);

            // スタイルインデックスの設定
            cell.StyleIndex = styleIndex;

        }

        // 数式セルの再計算を強制する。
        // CellValueは 評価式のキャッシュされた値を持っている。
        public static void RemoveCellValue(WorkbookPart wbPart, Worksheet ws, string addressName)
        {
            
            Cell cell = InsertCellInWorksheet(ws, addressName);

            // セルの値がある場合には強制的再計算
            if (cell.CellValue != null)
            {
                cell.CellValue.Remove();
            }

        }

        private static Cell InsertCellInWorksheet(Worksheet ws, string addressName)
        {
            SheetData sheetData = ws.GetFirstChild<SheetData>();
            Cell cell = null;

            UInt32 rowNumber = GetRowIndex(addressName);
            Row row = GetRow(sheetData, rowNumber);

            //指定セルの有無で、ある場合はそのセル、無ければ１を返す。
            Cell refCell = row.Elements<Cell>().
                Where(c => c.CellReference.Value == addressName).FirstOrDefault();
            if (refCell != null)
            {
                cell = refCell;
            }
            else
            {
                cell = CreateCell(row, addressName);
                //明細行の高さ調整を行います。
                //row.Height = 28.5;
                //row.CustomHeight = true;
            }
            return cell;
        }

        private static Cell CreateCell(Row row, String address)
        {
            Cell cellResult;
            Cell refCell = null;
            // 追加するカラム名
            string targetColName = System.Text.RegularExpressions.Regex.Replace(address, @"\d", "");
            // 比較対象のカラム名
            string cellColumn;

            // 新しい挿入箇所の指定。
            foreach (Cell cell in row.Elements<Cell>())
            {
                cellColumn = System.Text.RegularExpressions.Regex.Replace(cell.CellReference.Value, @"\d", "");
                if (targetColName.Length <= cellColumn.Length && string.Compare(cell.CellReference.Value, address, true) > 0)
                {
                    refCell = cell;
                    break;
                }
            }

            cellResult = new Cell();
            cellResult.CellReference = address;

            row.InsertBefore(cellResult, refCell);
            return cellResult;
        }

        private static Row GetRow(SheetData wsData, UInt32 rowIndex)
        {
            var row = wsData.Elements<Row>().
            Where(r => r.RowIndex.Value == rowIndex).FirstOrDefault();
            if (row == null)
            {
                row = new Row();
                row.RowIndex = rowIndex;
                wsData.Append(row);
            }
            return row;
        }

        private static UInt32 GetRowIndex(string address)
        {
            string rowPart;
            UInt32 l;
            UInt32 result = 0;

            for (int i = 0; i < address.Length; i++)
            {
                if (UInt32.TryParse(address.Substring(i, 1), out l))
                {
                    rowPart = address.Substring(i, address.Length - i);
                    if (UInt32.TryParse(rowPart, out l))
                    {
                        result = l;
                        break;
                    }
                }
            }
            return result;
        }

        //ワークブックパーツ、およびテキストの値を与え、共有文字列テーブルにテキストを挿入する。
        //必要に応じてテーブルを作成。
        //値がすでに存在する場合、そのインデックスを返します。
        //存在しない場合は、新しい値を挿入し、その新しいインデックスを返します。
        private static int InsertSharedStringItem(WorkbookPart wbPart, string value)
        {
            int index = 0;
            bool found = false;
            var stringTablePart = wbPart.GetPartsOfType<SharedStringTablePart>().FirstOrDefault();

            // 文字列テーブルが、存在しない場合には、セルの値を返します。
            // 存在する場合には、正しいテキストを返します。
            if (stringTablePart == null)
            {
                // 作成
                stringTablePart = wbPart.AddNewPart<SharedStringTablePart>();
            }

            var stringTable = stringTablePart.SharedStringTable;
            if (stringTable == null)
            {
                stringTable = new SharedStringTable();
            }

            // テキストが見つかるまで、テーブル内の値を比較する。
            foreach (SharedStringItem item in stringTable.Elements<SharedStringItem>())
            {
                if (item.InnerText == value)
                {
                    found = true;
                    break;
                }
                index += 1;
            }

            if (!found)
            {
                stringTable.AppendChild(new SharedStringItem(new Text(value)));
                stringTable.Save();
            }

            return index;
        }

        /// <summary>
        /// シートコピー
        /// </summary>
        /// <param name="tempSpDoc">コピーしたスプレッドシートドキュメント</param>
        /// <param name="wbPart">ワークブックパート</param>
        /// <param name="wsPart">ワークシートパート</param>
        /// <param name="sheetName">シート名</param>
        public static void CreateCopySheet(WorkbookPart wbPart, WorksheetPart wsPart,　string sheetName)
        {
            // 変数定義
            WorksheetPart copyWsPart;       // コピーワークシートパートのコピー
            Sheet copiedSheet;              // コピーワークブックパート
            Sheets sheets;                  // テンプレートのシートテーブル

            // シートテーブル
            sheets = wbPart.Workbook.Sheets;

            // 
            copyWsPart = wbPart.AddNewPart<WorksheetPart>();
            copyWsPart.Worksheet = (Worksheet)wsPart.Worksheet.Clone();

            // コピーしたワークシートのシート情報を設定する
            copiedSheet = new Sheet();
            copiedSheet.Name = sheetName;
            copiedSheet.Id = wbPart.GetIdOfPart(copyWsPart);
            copiedSheet.SheetId = (uint)sheets.ChildElements.Count + 1;

            // 出力するワークシートのシートテーブルにコピーシートを追加する
            sheets.Append(copiedSheet);
        }

        
        /// <summary>
        /// 取得結果がNULLだった場合、空白を設定します
        /// </summary>
        /// <param name="wbPart">WorkbookPart</param>
        /// <param name="ws">ワークシート</param>
        /// <param name="address">アドレスネーム</param>
        /// <param name="value">取得結果</param>
        /// <param name="index">書式番号</param>
        public static void changeNullToBlank(WorkbookPart wbPart, Worksheet ws, string address, decimal? value, UInt32 index, string lang)
        {
            if (value == null)
            {
                // NULLだった場合、空白を設定
                UpdateValue(wbPart, ws, address, "", 0, true);
            }
            else
            {
                string val = value.ToString();
                switch (lang) {
                    case "vi": {
                        val = val.Replace(',', '.');
                        break;
                    }
                    default: break;
                }                    

                UpdateValue(wbPart, ws, address, val, index, false);
            }
        }

    }    
}