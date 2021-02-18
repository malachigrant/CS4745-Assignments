using CUDA, BenchmarkTools

function reduction_CuArray(A_d)
  n = 2^25
  @views @inbounds for i = Int(log(2, n)-1):-1:1
    A_d[1:2^i] .+= A_d[2^i+1:2^(i+1)]
  end
  synchronize()
  return Float64(A_d[1])
end

function test_Reduction_CuArray()
  A_d = CUDA.ones(2^25);
  @btime reduction_CuArray($A_d);
end

test_Reduction_CuArray();