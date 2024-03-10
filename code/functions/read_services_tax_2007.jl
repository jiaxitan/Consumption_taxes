function read_services_tax_2007(filepath)
    file = XLSX.readxlsx(filepath)
    sheet = file["Sheet1"]
    file = DataFrame(sheet["A:DA"], :auto)
    file[7, 3] = "JF"
    select!(file, Not(filter(c -> ismissing(file[7,c]), names(file))))

    file.nmissing = sum.(eachrow(ismissing.(file)));
    deleteat!(file, file.nmissing .>= 53);
    rename!(file, Symbol.(Vector(file[1,:])))
    file = file[2:end, :]
    file[1, :JF] = 0
    deleteat!(file, ismissing.(file.JF))
    file = file[1:findfirst(file.JF .== 183), :]
    
    file = string.(file)
    transform!(file, All() .=> (x -> replace(x, " E" => "E")) => identity)
    transform!(file, All() .=> (x -> replace(x, "T(4) & E" => "E")) => identity)
    transform!(file, All() .=> (x -> replace(x, " " => "")) => identity)
    transform!(file, All() .=> (x -> replace(x, "  " => "")) => identity)
    transform!(file, All() .=> (x -> replace(x, "" => "missing")) => identity)
    transform!(file, All() .=> (x -> replace(x, "missing" => x[1])) => identity)
    transform!(file, All() .=> (x -> replace(x, "N/A" => x[1])) => identity)
    transform!(file, All() .=> (x -> replace(x, "n/a" => x[1])) => identity)
    transform!(file, All() .=> (x -> replace(x, "E" => "0")) => identity)
    transform!(file, All() .=> (x -> replace(x, "T" => x[1])) => identity)
    select!(file, 1:53)
    file = stack(file, Not([:JF, :Services]))
    rename!(file, ["JF", "Services", "state_postal", "services_state_tax"])
    file.services_state_tax = parse.(Float64, file.services_state_tax)
    file.JF = parse.(Int64, file.JF)
    file.state_postal .= replace.(file.state_postal, " " => "")

    return file
end