function read_color_code(filepath)
    file = DataFrame(XLSX.readxlsx(filepath)["Table"]["A:K"], :auto)
    #file.nmissing = sum.(eachrow(ismissing.(file)));
    #file_res = file[file.nmissing .>= 9, :]
    #file_res_index = findall(file.nmissing .>= 9)
    file = file[3:122, :]

    # deleteat!(file, file.nmissing .>= 9)
    # select!(file, [1,2,6,7,10])
    rename!(file, Symbol.(Vector(file[1,:])))
    #rename!(file_res, Symbol.(Vector(file[1,:])))
    file = file[2:end, :]

    file."JF code" = string.(file."JF code")
    file.JF_index = findfirst.("JF", file."JF code")
    file.JF .= -1
    file[.!isnothing.(file.JF_index), :JF] .= parse.(Int64, SubString.(file[.!isnothing.(file.JF_index), "JF code"], getindex.(file[.!isnothing.(file.JF_index), :JF_index], 1) .+ 2, length.(file[.!isnothing.(file.JF_index), "JF code"])));
    select!(file, Not([:JF_index]))
    #select!(file_res, Not([:missing, Symbol(1)]))

    return file
end