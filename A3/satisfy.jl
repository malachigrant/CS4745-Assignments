using CUDA, BenchmarkTools
const NBITS = 24

function extract_bits(val)
    v = Array{Bool, 1}(undef, NBITS)
    mask = 1<<(NBITS-1)
    for i = 1:NBITS
        v[i] =  (val & mask != 0 ? true : false)
        mask = mask >>> 1
    end
    return v
end

#= From Quinn's book
function check_circuit(num, v, nbits)
    extract_bits(num, v, nbits)
    test = (v[1] || v[2]) && (!v[2] || !v[4]) && (v[3] || v[4]) &&
      (!v[4] || !v[5]) && (v[5] || !v[6]) &&
      (v[6] || !v[7]) && (v[6] || v[7]) &&
      (v[7] || !v[16]) && (v[8] || !v[9]) &&
      (!v[8] || !v[14]) && (v[9] || v[10]) &&
      (v[9] || !v[10]) && (!v[10] || !v[11]) &&
      (v[10] || v[12]) && (v[11] || v[12]) &&
      (v[13] || v[14]) && (v[14] || !v[15]) &&
      (v[15] || v[16])
    if num == 28569
        for i in 1:16
            @cushow v[i]
        end
    end
    return test
end =#

function check(num)
    v = extract_bits(num)
    test = (!v[11] || v[12] || !v[6]) && 
            (!v[17] || v[14] || !v[4]) && 
            (v[22] || v[1] || v[23]) && 
            (v[15] || v[5] || !v[21]) && 
            (!v[15] || !v[18] || v[4]) && 
            (!v[16] || v[9] || v[19]) && 
            (v[12] || !v[10] || v[15]) && 
            (v[14] || v[15] || v[13]) && 
            (!v[10] || !v[11] || v[6]) && 
            (v[24] || !v[23] || !v[17]) && 
            (!v[21] || !v[15] || v[22]) && 
            (!v[7] || !v[6] || v[2]) && 
            (!v[1] || v[8] || v[24]) && 
            (!v[13] || v[12] || v[9]) && 
            (v[4] || !v[10] || !v[11]) && 
            (!v[16] || !v[19] || v[1]) && 
            (!v[17] || !v[11] || v[1]) && 
            (v[17] || !v[6] || v[9]) && 
            (v[14] || !v[2] || !v[21]) && 
            (v[6] || v[23] || v[19])
    return test
end

function satisfy()
    count = 0
    for i in 0:(1<<NBITS)-1
        count += check(i)
    end
    return count
end

function reduction_CuArray(A_d)
    n = length(A_d)
    @views @inbounds for i = Int(log(2, n)-1):-1:0
      A_d[1:2^i] .+= A_d[2^i+1:2^(i+1)]
    end
    synchronize()
    return Int64(A_d[1])
  end

function getBoolFromNum(num, i)
    return (num>>(NBITS-i) & 1) == 1
end

function CUDAnativeCheck(id)
    return ((!getBoolFromNum(id, 11) || getBoolFromNum(id, 12) || !getBoolFromNum(id, 6)) && 
    (!getBoolFromNum(id, 17) || getBoolFromNum(id, 14) || !getBoolFromNum(id, 4)) && 
    (getBoolFromNum(id, 22) || getBoolFromNum(id, 1) || getBoolFromNum(id, 23)) && 
    (getBoolFromNum(id, 15) || getBoolFromNum(id, 5) || !getBoolFromNum(id, 21)) && 
    (!getBoolFromNum(id, 15) || !getBoolFromNum(id, 18) || getBoolFromNum(id, 4)) && 
    (!getBoolFromNum(id, 16) || getBoolFromNum(id, 9) || getBoolFromNum(id, 19)) && 
    (getBoolFromNum(id, 12) || !getBoolFromNum(id, 10) || getBoolFromNum(id, 15)) && 
    (getBoolFromNum(id, 14) || getBoolFromNum(id, 15) || getBoolFromNum(id, 13)) && 
    (!getBoolFromNum(id, 10) || !getBoolFromNum(id, 11) || getBoolFromNum(id, 6)) && 
    (getBoolFromNum(id, 24) || !getBoolFromNum(id, 23) || !getBoolFromNum(id, 17)) && 
    (!getBoolFromNum(id, 21) || !getBoolFromNum(id, 15) || getBoolFromNum(id, 22)) && 
    (!getBoolFromNum(id, 7) || !getBoolFromNum(id, 6) || getBoolFromNum(id, 2)) && 
    (!getBoolFromNum(id, 1) || getBoolFromNum(id, 8) || getBoolFromNum(id, 24)) && 
    (!getBoolFromNum(id, 13) || getBoolFromNum(id, 12) || getBoolFromNum(id, 9)) && 
    (getBoolFromNum(id, 4) || !getBoolFromNum(id, 10) || !getBoolFromNum(id, 11)) && 
    (!getBoolFromNum(id, 16) || !getBoolFromNum(id, 19) || getBoolFromNum(id, 1)) && 
    (!getBoolFromNum(id, 17) || !getBoolFromNum(id, 11) || getBoolFromNum(id, 1)) && 
    (getBoolFromNum(id, 17) || !getBoolFromNum(id, 6) || getBoolFromNum(id, 9)) && 
    (getBoolFromNum(id, 14) || !getBoolFromNum(id, 2) || !getBoolFromNum(id, 21)) && 
    (getBoolFromNum(id, 6) || getBoolFromNum(id, 23) || getBoolFromNum(id, 19))) ? 1 : 0
end

function satisfyKernel(A_d)
    id = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    if (id <= 1<<NBITS)
        A_d[id] = CUDAnativeCheck(id)
    end
    nothing
end

function satisfy_CUDAnative()
    A_d = CUDA.zeros(Int64, 1<<NBITS)
    @cuda blocks=1<<(NBITS-10) threads=1024 satisfyKernel(A_d)
    synchronize()
    reduction_CuArray(A_d)
end

function satisfyChunkKernel(A_d, idsPerThread)
    @inbounds for i = 1:idsPerThread
        id = ((blockIdx().x - 1) * blockDim().x + threadIdx().x) * idsPerThread - i + 1
        if (id <= 1<<NBITS)
            A_d[id] = CUDAnativeCheck(id)
        end
    end
    nothing
end

function satisfy_CUDAnative_chunk(blockCount)
    A_d = CUDA.zeros(Int64, 1<<NBITS)
    @cuda blocks=blockCount threads=1024 satisfyChunkKernel(A_d, Int(ceil((1<<NBITS)/(1024*blockCount))))
    synchronize()
    reduction_CuArray(A_d)
end


println("satisfy:")
@btime satisfy()

println("satisfy_CUDAnative:")
@btime satisfy_CUDAnative()

println("satisfy_CUDAnative_chunk (1)")
@btime satisfy_CUDAnative_chunk(1)

println("satisfy_CUDAnative_chunk (168)")
@btime satisfy_CUDAnative_chunk(168)

println("satisfy_CUDAnative_chunk (4)")
@btime satisfy_CUDAnative_chunk(4)

println("satisfy_CUDAnative_chunk (64)")
@btime satisfy_CUDAnative_chunk(64)