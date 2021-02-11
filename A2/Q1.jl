using BenchmarkTools

function reduction_threads!(a)
  for k = Int(log(2, length(a)))-1:-1:0
    j = 2^k;
    for i = 1:j
      @inbounds a[i] = a[i] + a[i+j]
    end
  end
end

a = [1, 2, 3, 4, 5, 6, 7, 8];
@btime reduction_threads!(a);
println(a);