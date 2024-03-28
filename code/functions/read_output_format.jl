function read_output_format(filepath)
    file = DataFrame(XLSX.readxlsx(filepath)["Sheet1"]["A:B"], :auto)
    rename!(file, [:Item, :tax_rate_category])

    return file
end