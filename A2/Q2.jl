using BenchmarkTools

function reduction_threads_spawn(a, n=length(a), lo=1, hi=length(a), ntasks=16)
  if hi - lo > n/ntasks
      mid = (lo+hi)>>>1
      finish = Threads.@spawn reduction_threads_spawn(a, n, lo, mid, ntasks)
      sum1 = reduction_threads_spawn(a, n, mid+1, hi, ntasks)
      sum2 = fetch(finish)
      return sum1 + sum2
  end
  sum = 0
  for j in lo:hi
      @inbounds sum += a[j]
  end
  return sum
end

a = rand(Float64, 2^25)
@btime reduction_threads_spawn(a)

# @btime sum(a)