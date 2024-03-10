function clean_2009(filepath)
    file = XLSX.readxlsx(filepath)

    sheet = file["Sheet1"]
    file = DataFrame(sheet["A:C"], :auto)
    file = file[2:end, :]
    rename!(file, [:state, :state_tax, :local_tax])
    file[:, :state_tax] = replace.(file[:, :state_tax],"%"=>"")
    file[:, :local_tax] = replace.(file[:, :local_tax],"%"=>"")
    file[file.state_tax .== "none", :state_tax] .= "0.0"
    file[file.local_tax .== "none", :local_tax] .= "0.0"
    file[file.local_tax .== "n/a", :local_tax] .= "0.0"
    
    file[:, :state_tax] = parse.(Float64, file[:, :state_tax])
    file[:, :local_tax] = parse.(Float64, file[:, :local_tax] )

    r = r"[0123456789]"
    file.state = replace.(file.state, r => "")
    return file
end

function read_standard_rate(filepath, year)
    
    file = XLSX.readxlsx(filepath)

    if year <= 2006
        sheet = file["Sheet1"]
        file = DataFrame(sheet["A:B"], :auto)
        file = file[2:end, :]
        rename!(file, [:state, :state_tax])
        file = leftjoin(file, select(df_2009, [:state,:local_tax]), on = :state)
        insertcols!(file, :standard_tax => file.state_tax .+ file.local_tax)
    else
        sheet = file["Sheet1"]
        file = DataFrame(sheet["A:D"], :auto)
        file = file[2:end, :]
        rename!(file, [:state, :state_tax, :local_tax, :standard_tax])
    end
    
    return file
end
