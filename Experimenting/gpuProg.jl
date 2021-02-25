using CUDA, BenchmarkTools

function subsetSumCuArrays(s, S)
    n = length(s)
    x = Int(n^2)
    F_d = CUDA.zeros(Int8, S+1, n)
    s_d = CuArray{Int64,1}(s)
    F_d[1,:] .= 1
    s_d[1]≤ S && (F_d[s_d[1]+1,1] = 1)
    @views @inbounds for j in 2:n
        F_d[2:S+1,j] .=  F_d[2:S+1,j-1]
        if(s_d[j] <= S)
            F_d[s_d[j]+1:S+1,j] .= F_d[s_d[j]+1:S+1,j] .| F_d[1:S+1-s_d[j],j-1]
        end
    end
    synchronize()
    return Bool(F_d[S+1,n])
end

function test()
  s = ones(11)
  S = 45
  @btime subsetSumCuArrays(s, S);
end