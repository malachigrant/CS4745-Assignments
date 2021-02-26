using CUDA

function reduction_CuArray(A_d)
  n = length(A_d)
  @views @inbounds for i = Int(log(2, n)-1):-1:0
    A_d[1:2^i] .+= A_d[2^i+1:2^(i+1)]
  end
  synchronize()
  return Float64(A_d[1])
end

function test_Reduction_CuArray()
  A_d = CUDA.ones(2^25);
  reduction_CuArray(A_d);
end