function read_food_tax(filepath)
    file = XLSX.readxlsx(filepath)
    sheet = file["Sheet1"]
    file = DataFrame(sheet["A:C"], :auto)

    file.nmissing = sum.(eachrow(ismissing.(file)));
    deleteat!(file, file.nmissing .>= 2);
    select!(file, Not(:nmissing))
    file = file[3:53, :]
    rename!(file, [:state, :state_tax, :food_state_tax])
    file = string.(file)

    file[:, :food_state_tax] .= replace.(file[:, :food_state_tax], "★" => "0.0")
    file[:, :food_state_tax] .= replace.(file[:, :food_state_tax], "+" => "0.0")
    
    # Remove footnotes 
    file.footnote = findfirst.("(", file.state);
    file[.!isnothing.(file.footnote), :state] .= SubString.(file[.!isnothing.(file.footnote), :state], 1, getindex.(file[.!isnothing.(file.footnote), :footnote], 1) .- 2);
    file.footnote = findfirst.("(", file.state_tax);
    file[.!isnothing.(file.footnote), :state_tax] .= SubString.(file[.!isnothing.(file.footnote), :state_tax], 1, getindex.(file[.!isnothing.(file.footnote), :footnote], 1) .- 2);
    file.footnote = findfirst.("(", file.food_state_tax);
    file[.!isnothing.(file.footnote), :food_state_tax] .= SubString.(file[.!isnothing.(file.footnote), :food_state_tax], 1, getindex.(file[.!isnothing.(file.footnote), :footnote], 1) .- 2);
    select!(file, Not(:footnote))

    file[file.state_tax .== "none", :state_tax] .= "0.0"
    file[:, :state_tax] .= replace.(file[:, :state_tax], "percent" => "")
    file[:, :state_tax] .= replace.(file[:, :state_tax], "%" => "")
    file[:, :state_tax] .= replace.(file[:, :state_tax], " " => "")
    
    file[length.(file.food_state_tax) .== 0, :food_state_tax] .= "missing"
    file[file.food_state_tax .== "missing", :food_state_tax] .= file[file.food_state_tax .== "missing", :state_tax]
    file[file.food_state_tax .== "N.A.", :food_state_tax] .= file[file.food_state_tax .== "N.A.", :state_tax]
    file[:, :food_state_tax] .= replace.(file[:, :food_state_tax], "percent" => "")
    file[:, :food_state_tax] .= replace.(file[:, :food_state_tax], "%" => "")
    file[:, :food_state_tax] .= replace.(file[:, :food_state_tax], " " => "")
    file.food_state_tax = parse.(Float64, file.food_state_tax)
    file.state_tax = parse.(Float64, file.state_tax)

    # Fix the issue that sometime % passed down by dividing the number by 100
    file[file.food_state_tax .< 1, :food_state_tax] .= file[file.food_state_tax .< 1, :food_state_tax] .* 100
    file[file.state_tax .< 1, :state_tax] .= file[file.state_tax .< 1, :state_tax] .* 100

    return file
end