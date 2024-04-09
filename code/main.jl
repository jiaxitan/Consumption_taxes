using Pkg
using DataFrames, XLSX, CSV

function_path = "/Users/jiaxitan/UMN/Fed RA/Heathcote/sales_taxes/main/code/functions/"
input_path = "/Users/jiaxitan/UMN/Fed RA/Heathcote/sales_taxes/main/input/"
output_path = "/Users/jiaxitan/UMN/Fed RA/Heathcote/sales_taxes/main/output/"
sample_year = [2005, 2006, 2010, 2011, 2015, 2016]

#################################
# Read Standard Tax rate

include(function_path * "read_standard_tax.jl")
df_2009 = clean_2009(input_path * "Sales taxes on goods/Raw/salestaxstatelocal09.xlsx")

df_standard_tax = DataFrame(state = String[], year = Int64[], state_tax = Float64[], local_tax = Float64[], standard_tax = Float64[])
for y in sample_year
    # I deleted Column B of the 2010 input file, because it is just the abbreviation of statenames. Other input files used here don't have that column.
    filename_tmp = input_path * "Sales taxes on goods/Raw/" * string(y) * "_aftertaxes.xlsx"
    df_y = read_standard_rate(filename_tmp, y)
    insertcols!(df_y, :year => y)

    append!(df_standard_tax, df_y)
end

CSV.write(output_path * "standard tax rate.csv", df_standard_tax)

#################################
# Read Food at Home Tax rate
include(function_path * "read_food_tax.jl")

df_food_tax = DataFrame(state = String[], year = Int64[], state_tax = Float64[], food_state_tax = Float64[])
for y in sample_year
    filename_tmp = input_path * "Taxes on Food at Home/" * string(y) * " Sales Tax.xlsx"
    df_y = read_food_tax(filename_tmp)
    insertcols!(df_y, :year => y)

    append!(df_food_tax, df_y)
end
df_food_tax[df_food_tax.state .== "Dist. of Columbia", :state] .= "District of Columbia"

# Check if the state tax rate here is the same as in df_standard_tax. I'm using rounded values because sometimes the tax rate is, for example, actually 5.599999 instead of 5.6.
check_state_tax = leftjoin(df_food_tax[:, [:state, :year, :state_tax]], df_standard_tax[:, [:state, :year, :state_tax]], on = [:state, :year], makeunique=true)
if (sum(round.(check_state_tax.state_tax, digits=2) .!= round.(check_state_tax.state_tax_1, digits=2)) != 0)
    println("Some state tax rates not matching")
end
# Note that there is a mistake in the cleaned version of the tax foundation raw file for 2010 Colorado state tax rate. The raw file downloaded from tax foundation says 2.90 but the cleaned file somehow says 2.00. I manually corrected it in the raw file.

# Add local tax rate
df_food_tax = leftjoin(df_food_tax, df_standard_tax[:, [:state, :year, :local_tax]], on = [:state, :year])
insertcols!(df_food_tax, :food_tax => df_food_tax.food_state_tax .+ (df_food_tax.local_tax) .* (df_food_tax.food_state_tax .!= 0))

CSV.write(output_path * "food tax rate.csv", df_food_tax)

#################################
# Read Services Tax Rate 

include(function_path * "read_services_tax_2007.jl")

df_services_2007 = read_services_tax_2007(input_path * "services2007_clean.xlsx")

df_state_info = DataFrame(XLSX.readxlsx(input_path * "State names concordance.xlsx")["state"]["A:C"], :auto)
rename!(df_state_info, [:state, :state_short, :state_postal])
df_state_info = df_state_info[2:end, :]

# Convert statenames from postal to full state names
df_services_2007 = leftjoin(df_services_2007, df_state_info[:, [:state, :state_postal]], on = :state_postal)
select!(df_services_2007, Not(:state_postal))

# Compute the ratio of sample-year state tax rate to 2007 state tax rate
df_standard_tax = leftjoin(df_standard_tax, df_services_2007[df_services_2007.JF .== 0, [:services_state_tax, :state]], on= :state)
insertcols!(df_standard_tax, :state_tax_ratio_2007 => df_standard_tax.state_tax ./ df_standard_tax.services_state_tax)
# This step is ok, because nan in our sample only happens when both state tax in our sample year and state tax in 2007 are 0.
df_standard_tax[isnan.(df_standard_tax.state_tax_ratio_2007), :state_tax_ratio_2007] .= 1.0

df_services_tax = DataFrame(JF = Int64[], state = String[], year = Int64[], services_state_tax = Float64[])
for y in sample_year
    df_y = leftjoin(df_services_2007, df_standard_tax[df_standard_tax.year .== y, [:state, :year, :state_tax_ratio_2007]], on = [:state])
    df_y_out = DataFrame(JF = df_y.JF, state = df_y.state, year = y, services_state_tax = df_y.services_state_tax .* df_y.state_tax_ratio_2007)

    append!(df_services_tax, df_y_out)
end

# Add local tax rates
df_services_tax = leftjoin(df_services_tax, df_standard_tax[:, [:state, :year, :local_tax]], on = [:state, :year]) 
insertcols!(df_services_tax, :services_tax => df_services_tax.services_state_tax .+ df_services_tax.local_tax .* (df_services_tax.services_state_tax .!= 0))

CSV.write(output_path * "services tax rate.csv", df_services_tax)

#################################
# Combine all of the above into the color-coded file

include(function_path * "read_color_code_file.jl")
include(function_path * "read_output_format.jl")

df_color_code = read_color_code(input_path * "cu-all-multi-year-2006-2012_new_Jiaxi.xlsx")
deleteat!(df_color_code, ismissing.(df_color_code.Item) .& (df_color_code."JF code" .== "missing"))

df_format = read_output_format(input_path * "category_format.xlsx")

df_color_code[ismissing.(df_color_code.standard_code), :standard_code] .= -1;
df_color_code[ismissing.(df_color_code.number_of_sub_components), :number_of_sub_components] .= 0;

deleteat!(df_services_tax, .!in(df_color_code.JF).(df_services_tax.JF))

for y in sample_year
    println(y)
    states = unique(df_standard_tax[:, :state])
    df_out = copy(df_color_code)
    for s in states
        s_name = Symbol(s)
        insertcols!(df_out, s_name => 0.0)
        #insertcols!(df_empty_row, s_name => missing)
        allowmissing!(df_out)
        df_out[df_out.standard_code .== 0, s_name] .= df_food_tax[(df_food_tax.state .== s) .& (df_food_tax.year .== y), :food_tax]
        df_out[df_out.standard_code .== 1, s_name] .= df_standard_tax[(df_standard_tax.state .== s) .& (df_standard_tax.year .== y), :standard_tax]
        df_out[df_out.standard_code .== 2, s_name] .= leftjoin(df_out[df_out.standard_code .== 2, :], df_services_tax[(df_services_tax.state .== s) .& (df_services_tax.year .== y), :], on = [:JF])[:, :services_tax]
        
        for i in 1:nrow(df_out)
            if (df_out[i, :number_of_sub_components] .!= 0)
                n = df_out[i, :number_of_sub_components]
                df_out[i, s_name] = sum(df_out[(i+1):(i+n), s_name] .* df_out[(i+1):(i+n), :shares_of_Components])
            end 
        end

        df_out[(df_out.standard_code .== -1) .& (df_out.number_of_sub_components .== 0), s_name] .= missing
    end

    select!(df_out, Not(["JF code", "2015_sub", "2015", "shares of total expenditure", "shares_of_Components", "number_of_sub_components", "standard_code", "JF", "2010", "2010 share", "missing"]))

    deleteat!(df_out, ismissing.(df_out.Item))
    df_out = leftjoin(df_out, df_format, on = :Item)
    deleteat!(df_out, ismissing.(df_out.tax_rate_category))
    select!(df_out, 1, :tax_rate_category, :)
    df_out[df_out.tax_rate_category .== "Z", 3:end] .= 0.0


    XLSX.writetable(output_path * string(y) * "_tax_rates_by_CEX_states.xlsx", df_out)
end