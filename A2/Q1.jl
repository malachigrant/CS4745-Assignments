using BenchmarkTools
using Base.Threads

function reduction_threads!(a)
  for k = Int(log(2, length(a)))-1:-1:0
    j = 2^k;
    @threads for i = 1:j
      @inbounds a[i] = a[i] + a[i+j]
    end
  end
end

a = rand(Float64, 2^25);
@btime reduction_threads!(a);

# @btime sum(a);