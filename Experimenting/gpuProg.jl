using CUDA, BenchmarkTools

const MAX_THREADS_PER_BLOCK = CUDA.attribute(
   CUDA.CuDevice(0), CUDA.DEVICE_ATTRIBUTE_MAX_THREADS_PER_BLOCK,
)
function subsetKernel(F, s, S, j)
    id = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    id += 1 # 2 ≤ id ≤ S+1
    if(id ≤ S+1)
        F[id,j] = F[id,j-1]
        if(id > s[j])
            F[id,j] = F[id,j] | F[id - s[j], j-1]		
        end
    end
    return nothing
end
function subsetSumCuNative(s, S)
    n = length(s)
    F_d = CUDA.zeros(Int8, S+1, n)
    s_d = CuArray{Int64,1}(s)
    F_d[1,:] .= 1
    if(s_d[1]≤ S) 
        F_d[s_d[1]+1,1] = 1
    end
    blockSize = MAX_THREADS_PER_BLOCK
    nbl = cld(S, blockSize)
    for j in 2:n
        @cuda blocks=nbl threads=blockSize subsetKernel(F_d, s_d, S, j)
    end
    synchronize()
    return Bool(F_d[S+1,n])
end

function test()
  s = ones(11)
  S = 45
  @btime subsetSumCuNative($s, $S);
end