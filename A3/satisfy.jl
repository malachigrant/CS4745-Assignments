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

function satisfy_CUDAnative()
    A_d = CUDA.zeros(1<<NBITS-1)
    @cuda threads=1<<NBITS satisfyKernel(A_d)
end

function satisfyKernel(A_d)
    id = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    if (id <= 1<<NBITS-1)
        A_d[id] = check(id)
    end
    nothing
end
