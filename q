
[1mFrom:[0m /home/alex/work/budget/app/controllers/concerns/budget_file_upload.rb @ line 21 BudgetFileUpload#read_table_from_file:

    [1;34m14[0m: [32mdef[0m [1;34mread_table_from_file[0m path
    [1;34m15[0m:   require [31m[1;31m'[0m[31mroo[1;31m'[0m[31m[0m
    [1;34m16[0m: 
    [1;34m17[0m:   [32mcase[0m [1;34;4mFile[0m.extname(path).upcase
    [1;34m18[0m:     [32mwhen[0m [31m[1;31m'[0m[31m.CSV[1;31m'[0m[31m[0m
    [1;34m19[0m:       read_csv_xls [1;34;4mRoo[0m::[1;34;4mCSV[0m.new(path, [35mcsv_options[0m: {[35mcol_sep[0m: [31m[1;31m"[0m[31m;[1;31m"[0m[31m[0m})
    [1;34m20[0m:     [32mwhen[0m [31m[1;31m'[0m[31m.XLS[1;31m'[0m[31m[0m
 => [1;34m21[0m:       binding.pry
    [1;34m22[0m:       xls = [1;34;4mRoo[0m::[1;34;4mExcel[0m.new(path)
    [1;34m23[0m:       [1;34m# binding.pry[0m
    [1;34m24[0m: 
    [1;34m25[0m:       xls.default_sheet = xls.sheets.first
    [1;34m26[0m:       read_csv_xls xls
    [1;34m27[0m:     [32mwhen[0m [31m[1;31m'[0m[31m.XLSX[1;31m'[0m[31m[0m
    [1;34m28[0m:       xls = [1;34;4mRoo[0m::[1;34;4mExcelx[0m.new(path)
    [1;34m29[0m:       xls.default_sheet = xls.sheets.first
    [1;34m30[0m:       read_csv_xls xls
    [1;34m31[0m:     [32mwhen[0m [31m[1;31m'[0m[31m.DBF[1;31m'[0m[31m[0m
    [1;34m32[0m:       read_dbf [1;34;4mDBF[0m::[1;34;4mTable[0m.new(path)
    [1;34m33[0m:   [32mend[0m
    [1;34m34[0m: [32mend[0m

