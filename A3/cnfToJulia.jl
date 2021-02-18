function cnfToJulia(filename = "satex.cnf")
    params = Array{Int}(undef,2)
    clauses = String[]
    open(filename) do f  
        for l in eachline(f)
            l[1] == 'c' && continue
            if l[1] == 'p' 
                params = [parse(Int, x) for x in split(l[7:end])]
                nvars = params[1]
                nclauses = params[2]
                continue
            end
            terms = split(l)
            clause = "("
            for t in terms
                if t == "0"
                    clause = clause[1:end-4] * ")"
                elseif t[1] == '-'
                    clause = clause * "!v[" * t[2:end] * "] || "
                else
                    clause = clause * "v[" * t * "] || "
                end
            end
            push!(clauses, clause)
        end
    end
    for i in 1:length(clauses)
        if i < length(clauses)
            println(clauses[i]," && ")
        else
            println(clauses[i])
        end
    end
end